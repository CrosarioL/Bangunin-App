import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../data/pose_rep_analyzer.dart';
import '../../domain/mission_type.dart';

/// Hands-free movement mission. The phone is propped up and ML Kit checks a
/// complete body-joint movement locally on the device; camera frames are
/// never saved or uploaded.
class MovementMissionPage extends ConsumerStatefulWidget {
  const MovementMissionPage({super.key, required this.alarmId});

  final String alarmId;

  @override
  ConsumerState<MovementMissionPage> createState() =>
      _MovementMissionPageState();
}

enum _CameraState { initializing, ready, denied, error }

class _MovementMissionPageState extends ConsumerState<MovementMissionPage>
    with WidgetsBindingObserver {
  static const _orientations = <DeviceOrientation, int>{
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Alarm? _alarm;
  CameraController? _controller;
  CameraDescription? _camera;
  PoseDetector? _detector;
  PoseRepAnalyzer? _analyzer;
  _CameraState _cameraState = _CameraState.initializing;
  PoseStage _stage = PoseStage.findingBody;
  int _reps = 0;
  bool _processing = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    final alarm = await ref
        .read(alarmRepositoryProvider)
        .getById(widget.alarmId);
    if (!mounted || alarm == null) return;
    _alarm = alarm;
    _analyzer = PoseRepAnalyzer(alarm.missionType);
    setState(() {});
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (mounted) setState(() => _cameraState = _CameraState.initializing);
    if (!await Permission.camera.request().isGranted) {
      if (mounted) setState(() => _cameraState = _CameraState.denied);
      return;
    }
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      _detector ??= PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );
      _camera = camera;
      _controller = controller;
      await controller.startImageStream(_processFrame);
      if (mounted) setState(() => _cameraState = _CameraState.ready);
    } on Exception {
      if (mounted) setState(() => _cameraState = _CameraState.error);
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_processing || _completing) return;
    final input = _toInputImage(image);
    final detector = _detector;
    final analyzer = _analyzer;
    if (input == null || detector == null || analyzer == null) return;
    _processing = true;
    try {
      final poses = await detector.processImage(input);
      final result = poses.isEmpty
          ? PoseRepResult(reps: analyzer.reps, stage: PoseStage.findingBody)
          : analyzer.analyze(poses.first);
      if (!mounted) return;
      final counted = result.reps > _reps;
      setState(() {
        _reps = result.reps;
        _stage = result.stage;
      });
      if (counted) Haptics.tap();
      final target = _target;
      if (target > 0 && result.reps >= target) await _complete();
    } on Exception {
      // A malformed camera frame is skipped; the next frame usually succeeds.
    } finally {
      _processing = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final controller = _controller;
    final camera = _camera;
    if (controller == null || camera == null || image.planes.length != 1) {
      return null;
    }
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    } else {
      var compensation = _orientations[controller.value.deviceOrientation];
      if (compensation == null) return null;
      compensation = camera.lensDirection == CameraLensDirection.front
          ? (camera.sensorOrientation + compensation) % 360
          : (camera.sensorOrientation - compensation + 360) % 360;
      rotation = InputImageRotationValue.fromRawValue(compensation);
    }
    final rawFormat = image.format.raw;
    if (rawFormat is! int) return null;
    final format = InputImageFormatValue.fromRawValue(rawFormat);
    if (rotation == null ||
        format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
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

  int get _target {
    final alarm = _alarm;
    if (alarm == null) return 0;
    return alarm.missionReps > 0
        ? alarm.missionReps
        : alarm.missionType.defaultReps;
  }

  Future<void> _complete() async {
    if (_completing) return;
    _completing = true;
    Haptics.success();
    await ref
        .read(ringingSessionProvider.notifier)
        .complete(verifiedReps: _reps, verificationMethod: 'on_device_pose');
    if (mounted) context.go(Routes.wakeSuccess);
  }

  Future<void> _abandon() async {
    await ref.read(ringingSessionProvider.notifier).resumeRinging();
    if (mounted) context.go(Routes.ringing(widget.alarmId));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      unawaited(_disposeCamera());
    } else if (state == AppLifecycleState.resumed &&
        _cameraState == _CameraState.ready) {
      unawaited(_initializeCamera());
    }
  }

  Future<void> _disposeCamera() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    if (controller.value.isStreamingImages) await controller.stopImageStream();
    await controller.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeCamera());
    unawaited(_detector?.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alarm = _alarm;
    final isSquat = alarm?.missionType == MissionType.squats;
    final accent = isSquat ? const Color(0xFF38D9C5) : const Color(0xFFFF8A5B);
    final instruction = isSquat
        ? context.l10n.movementInstructionSquats
        : context.l10n.movementInstructionPushups;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_abandon());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF071018),
        body: SafeArea(
          child: alarm == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 18, 10),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _abandon,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          Icon(alarm.missionType.icon, color: accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              alarm.missionType.localizedName(context.l10n),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(
                            '$_reps/$_target',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        instruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _cameraBody(isSquat, accent)),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: _StatusPill(
                        stage: _stage,
                        isSquat: isSquat,
                        accent: accent,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _cameraBody(bool isSquat, Color accent) {
    return switch (_cameraState) {
      _CameraState.initializing => const Center(
        child: CircularProgressIndicator(),
      ),
      _CameraState.denied => _CameraMessage(
        icon: Icons.no_photography_rounded,
        text: context.l10n.cameraPermissionNeeded,
        onPressed: openAppSettings,
      ),
      _CameraState.error => _CameraMessage(
        icon: Icons.error_outline_rounded,
        text: context.l10n.cameraError,
        onPressed: _initializeCamera,
      ),
      _CameraState.ready => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: accent.withValues(alpha: .65),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              Center(
                child: Container(
                  width: isSquat ? 180 : 310,
                  height: isSquat ? 430 : 190,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: accent.withValues(alpha: .75),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(isSquat ? 90 : 48),
                  ),
                  child: Icon(
                    isSquat
                        ? Icons.accessibility_new_rounded
                        : Icons.fitness_center_rounded,
                    size: 54,
                    color: accent.withValues(alpha: .85),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  context.l10n.movementHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    };
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.stage,
    required this.isSquat,
    required this.accent,
  });

  final PoseStage stage;
  final bool isSquat;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final text = switch (stage) {
      PoseStage.findingBody => 'Step back until your full body is in the guide',
      PoseStage.ready =>
        isSquat ? 'Stand tall to begin' : 'Keep your body straight',
      PoseStage.lowering =>
        isSquat ? 'Lower into a full squat' : 'Lower your chest',
      PoseStage.returnToStart =>
        isSquat ? 'Stand all the way up' : 'Push all the way up',
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .14),
        border: Border.all(color: accent.withValues(alpha: .55)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: accent, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final Future<dynamic> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => onPressed(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
