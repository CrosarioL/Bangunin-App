import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../alarms/presentation/widgets/alarm_card.dart';
import '../../../ringing/presentation/mission_flow.dart';
import '../../../ringing/presentation/providers/ringing_provider.dart';
import '../../data/pose_rep_counter.dart';
import '../../domain/mission_type.dart';
import '../widgets/mission_experience.dart';

/// Camera pose mission. The phone stays placed where the full body is visible;
/// pose landmarks are processed on-device and no frames are saved.
class MovementMissionPage extends ConsumerStatefulWidget {
  const MovementMissionPage({super.key, this.alarmId, this.previewMission})
    : assert(alarmId != null || previewMission != null);

  final String? alarmId;
  final MissionType? previewMission;

  bool get isPreview => previewMission != null;

  @override
  ConsumerState<MovementMissionPage> createState() =>
      _MovementMissionPageState();
}

class _MovementMissionPageState extends ConsumerState<MovementMissionPage>
    with WidgetsBindingObserver {
  Alarm? _alarm;
  CameraController? _camera;
  PoseDetector? _detector;
  PoseRepCounter? _counter;
  int _reps = 0;
  bool _processing = false;
  bool _completing = false;
  bool _cameraStarting = false;
  bool _cameraAllowed = true;
  bool _resumeRequested = false;
  Future<void>? _cameraStopping;
  String? _error;

  /// Live coaching state, so the user is told why nothing is counting.
  PoseGuidance _guidance = PoseGuidance.getIntoStartPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    final alarm = widget.isPreview
        ? Alarm(
            id: 'mission-preview',
            hour: 0,
            minute: 0,
            missionType: widget.previewMission!,
            missionReps: widget.previewMission!.defaultReps,
            createdAt: DateTime.now(),
          )
        : (await ref.read(alarmRepositoryProvider).getById(widget.alarmId!))
              ?.forStep(currentMissionStep(ref));
    if (!mounted || alarm == null) return;
    final target = alarm.missionReps > 0
        ? alarm.missionReps
        : alarm.missionType.defaultReps;
    final counter = PoseRepCounter(
      mission: alarm.missionType,
      targetReps: target,
    );
    setState(() {
      _alarm = alarm;
      _counter = counter;
      _error = null;
    });
    await _startCamera(counter);
  }

  Future<void> _startCamera(PoseRepCounter counter) async {
    if (_cameraStarting || _camera != null || !_cameraAllowed || !mounted) {
      return;
    }
    _cameraStarting = true;
    CameraController? camera;
    PoseDetector? detector;
    try {
      await _cameraStopping;
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        if (mounted) setState(() => _error = 'camera');
        return;
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('none', 'No cameras');
      final description = cameras.firstWhere(
        (candidate) => candidate.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      camera = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      detector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );
      await camera.initialize();
      if (!mounted || !_cameraAllowed) return;
      await camera.startImageStream(
        (image) => _processFrame(image, description, detector!, counter),
      );
      if (!mounted || !_cameraAllowed) return;
      setState(() {
        _camera = camera;
        _detector = detector;
        _error = null;
      });
      camera = null;
      detector = null;
    } on Exception {
      if (mounted && _cameraAllowed) setState(() => _error = 'unavailable');
    } finally {
      if (camera != null) {
        if (camera.value.isStreamingImages) {
          try {
            await camera.stopImageStream();
          } on CameraException {
            // Already stopped by the platform lifecycle.
          }
        }
        await camera.dispose();
      }
      await detector?.close();
      _cameraStarting = false;
      if (_camera != null) _resumeRequested = false;
      final resumeCounter = _counter;
      if (_resumeRequested &&
          mounted &&
          _cameraAllowed &&
          _camera == null &&
          _error != 'camera' &&
          resumeCounter != null) {
        _resumeRequested = false;
        unawaited(_startCamera(resumeCounter));
      }
    }
  }

  Future<void> _processFrame(
    CameraImage image,
    CameraDescription description,
    PoseDetector detector,
    PoseRepCounter counter,
  ) async {
    if (_processing || !mounted) return;
    final input = _inputImage(image, description);
    if (input == null) return;
    _processing = true;
    try {
      final poses = await detector.processImage(input);
      // An empty result is itself information — tell the user we can't see
      // them rather than leaving the screen silent while they rep away.
      final update = poses.isEmpty
          ? const PoseRepUpdate(
              reps: 0,
              guidance: PoseGuidance.noPersonDetected,
            )
          : counter.addPose(poses.first);

      if (update.repCounted) Haptics.tap();
      if (mounted && (update.repCounted || update.guidance != _guidance)) {
        setState(() {
          _reps = counter.reps;
          _guidance = update.guidance;
        });
      }
      if (counter.isComplete) unawaited(_complete());
    } on Exception {
      // A frame can finish after either platform pauses and closes the
      // detector. The next resumed stream starts cleanly.
    } finally {
      _processing = false;
    }
  }

  InputImage? _inputImage(CameraImage image, CameraDescription description) {
    final rotation = InputImageRotationValue.fromRawValue(
      description.sensorOrientation,
    );
    final format = InputImageFormatValue.fromRawValue(image.format.raw as int);
    if (rotation == null || format == null || image.planes.length != 1) {
      return null;
    }
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> _complete() async {
    if (_completing) return;
    _completing = true;
    Haptics.success();
    if (mounted) setState(() => _guidance = PoseGuidance.complete);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    if (widget.isPreview) {
      Navigator.of(context).pop(true);
      return;
    }
    await finishMissionStep(context, ref, widget.alarmId!);
  }

  Future<void> _abandon() async {
    if (widget.isPreview) {
      if (mounted) Navigator.of(context).pop(false);
      return;
    }
    await ref.read(ringingSessionProvider.notifier).resumeRinging();
    if (mounted) context.go(Routes.ringing(widget.alarmId!));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _cameraAllowed = false;
      _resumeRequested = false;
      unawaited(_stopCamera());
    } else if (state == AppLifecycleState.resumed) {
      _cameraAllowed = true;
      final counter = _counter;
      if (counter != null && !_completing) {
        if (_cameraStarting) {
          _resumeRequested = true;
        } else {
          unawaited(_startCamera(counter));
        }
      }
    }
  }

  Future<void> _stopCamera() async {
    final camera = _camera;
    final detector = _detector;
    _camera = null;
    _detector = null;
    final stopping = () async {
      if (camera != null) {
        if (camera.value.isStreamingImages) {
          try {
            await camera.stopImageStream();
          } on CameraException {
            // The operating system may already have stopped the stream.
          }
        }
        await camera.dispose();
      }
      await detector?.close();
    }();
    _cameraStopping = stopping;
    await stopping;
    if (identical(_cameraStopping, stopping)) _cameraStopping = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraAllowed = false;
    unawaited(_stopCamera());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final alarm = _alarm;
    final target = _counter?.targetReps ?? 0;

    return PopScope(
      canPop: widget.isPreview,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_abandon());
      },
      child: Scaffold(
        backgroundColor: AppColors.nightTop,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: widget.isPreview ? l10n.close : l10n.abandonMission,
            onPressed: _abandon,
          ),
          title: Text(
            alarm?.missionType.localizedName(l10n) ?? '',
            style: theme.textTheme.titleMedium!.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          actions: [AlarmActivePill(active: !widget.isPreview)],
        ),
        bottomNavigationBar: widget.isPreview ? null : const MissionExitBar(),
        body: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.no_photography_rounded, size: 52),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _error == 'camera'
                            ? l10n.cameraPermissionNeeded
                            : l10n.cameraError,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: openAppSettings,
                        child: Text(l10n.openSettings),
                      ),
                    ],
                  ),
                ),
              )
            : alarm == null || _camera == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                top: false,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _MovementCameraBackground(controller: _camera!),
                    Positioned(
                      left: AppSpacing.xl,
                      right: AppSpacing.xl,
                      top: 120,
                      bottom: 286,
                      child: MissionGuideFrame(mission: alarm.missionType),
                    ),
                    Positioned(
                      right: -8,
                      bottom: 270,
                      child: MissionMascotCoach(mission: alarm.missionType),
                    ),
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.glass,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .12),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 28,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _GuidanceBanner(guidance: _guidance),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    l10n.missionSafetyNote,
                                    style: theme.textTheme.bodySmall!.copyWith(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _RepProgress(
                              reps: _reps,
                              target: target,
                              color: alarm.missionType.experienceColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MovementCameraBackground extends StatelessWidget {
  const _MovementCameraBackground({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final preview = controller.value.previewSize;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (preview == null)
          CameraPreview(controller)
        else
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: preview.height,
              height: preview.width,
              child: CameraPreview(controller),
            ),
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x7706152D),
                Colors.transparent,
                Color(0xE606152D),
              ],
              stops: [0, .5, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _RepProgress extends StatelessWidget {
  const _RepProgress({
    required this.reps,
    required this.target,
    required this.color,
  });

  final int reps;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: target == 0 ? 0 : reps / target),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: Colors.white12,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    '$reps',
                    key: ValueKey(reps),
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                      height: .9,
                    ),
                  ),
                ),
                Text(
                  l10n.repsOf(target),
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Live coaching line under the camera.
///
/// Tracking problems are the common case and the one users can act on, so
/// they get a warning tint and an icon; ordinary rep prompts stay quiet. The
/// text is announced politely to VoiceOver rather than interrupting.
class _GuidanceBanner extends StatelessWidget {
  const _GuidanceBanner({required this.guidance});

  final PoseGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final (text, isProblem) = switch (guidance) {
      PoseGuidance.noPersonDetected => (l10n.poseGuidanceNoPerson, true),
      PoseGuidance.keyJointsNotVisible => (l10n.poseGuidanceJointsHidden, true),
      PoseGuidance.getIntoStartPosition => (l10n.poseGuidanceGetReady, false),
      PoseGuidance.ready => (l10n.poseGuidanceGoDown, false),
      PoseGuidance.lowered => (l10n.poseGuidanceComeUp, false),
      PoseGuidance.complete => (l10n.poseGuidanceComplete, false),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Row(
        key: ValueKey(guidance),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isProblem) ...[
            const Icon(
              Icons.visibility_off_rounded,
              size: 20,
              color: AppColors.danger,
              semanticLabel: '',
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall!.copyWith(
                color: isProblem ? AppColors.danger : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
