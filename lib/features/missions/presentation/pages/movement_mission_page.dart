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
import '../../../ringing/presentation/providers/ringing_provider.dart';
import '../../data/pose_rep_counter.dart';

/// Camera pose mission. The phone stays placed where the full body is visible;
/// pose landmarks are processed on-device and no frames are saved.
class MovementMissionPage extends ConsumerStatefulWidget {
  const MovementMissionPage({super.key, required this.alarmId});

  final String alarmId;

  @override
  ConsumerState<MovementMissionPage> createState() =>
      _MovementMissionPageState();
}

class _MovementMissionPageState extends ConsumerState<MovementMissionPage> {
  Alarm? _alarm;
  CameraController? _camera;
  PoseDetector? _detector;
  PoseRepCounter? _counter;
  int _reps = 0;
  bool _processing = false;
  String? _error;

  /// Live coaching state, so the user is told why nothing is counting.
  PoseGuidance _guidance = PoseGuidance.getIntoStartPosition;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final alarm = await ref
        .read(alarmRepositoryProvider)
        .getById(widget.alarmId);
    if (!mounted || alarm == null) return;
    final target = alarm.missionReps > 0
        ? alarm.missionReps
        : alarm.missionType.defaultReps;
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (mounted) setState(() => _error = 'camera');
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) setState(() => _error = 'unavailable');
      return;
    }
    final description = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final camera = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    final detector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );
    await camera.initialize();
    final counter = PoseRepCounter(
      mission: alarm.missionType,
      targetReps: target,
    );
    await camera.startImageStream(
      (image) => _processFrame(image, description, detector, counter),
    );
    if (!mounted) {
      await camera.dispose();
      await detector.close();
      return;
    }
    setState(() {
      _alarm = alarm;
      _counter = counter;
      _camera = camera;
      _detector = detector;
    });
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
    Haptics.success();
    await ref.read(ringingSessionProvider.notifier).complete();
    if (mounted) context.go(Routes.wakeSuccess);
  }

  Future<void> _abandon() async {
    await ref.read(ringingSessionProvider.notifier).resumeRinging();
    if (mounted) context.go(Routes.ringing(widget.alarmId));
  }

  @override
  void dispose() {
    final camera = _camera;
    if (camera != null) {
      unawaited(camera.stopImageStream().then((_) => camera.dispose()));
    }
    unawaited(_detector?.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final alarm = _alarm;
    final target = _counter?.targetReps ?? 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_abandon());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: l10n.abandonMission,
            onPressed: _abandon,
          ),
          title: Text(
            alarm?.missionType.localizedName(l10n) ?? '',
            style: theme.textTheme.titleMedium!.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
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
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Text(
                        l10n.missionSafetyNote,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusCard,
                          ),
                          child: CameraPreview(_camera!),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _GuidanceBanner(guidance: _guidance),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: target == 0 ? 0 : _reps / target,
                              ),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) =>
                                  CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 10,
                                    strokeCap: StrokeCap.round,
                                    color: AppColors.primary,
                                    backgroundColor: AppColors.surfaceRaised,
                                  ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                    child: Text(
                                      '$_reps',
                                      key: ValueKey(_reps),
                                      style: theme.textTheme.displayLarge!
                                          .copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    l10n.repsOf(target),
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        Localizations.localeOf(context).languageCode == 'id'
                            ? 'Hanya gerakan lengkap dengan bentuk tubuh yang terlihat akan dihitung. Jika olahraga tidak aman untuk Anda, kembali dan gunakan misi foto.'
                            : 'Only complete repetitions with visible form count. If exercise is not safe for you, go back and choose a photo mission.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
