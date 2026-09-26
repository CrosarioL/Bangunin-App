import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/pressable_scale.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/mission_type.dart';
import 'mission_experience.dart';

/// Reusable camera viewfinder with a capture button. Handles permission
/// denial and camera init errors with inline retry states.
class MissionCamera extends StatefulWidget {
  const MissionCamera({
    super.key,
    required this.onCaptured,
    this.mission = MissionType.objectHunt,
  });

  final ValueChanged<String> onCaptured;
  final MissionType mission;

  @override
  State<MissionCamera> createState() => _MissionCameraState();
}

enum _CameraState { initializing, ready, denied, error }

class _MissionCameraState extends State<MissionCamera>
    with WidgetsBindingObserver {
  CameraController? _controller;
  _CameraState _state = _CameraState.initializing;
  bool _capturing = false;
  bool _initializing = false;
  bool _cameraAllowed = true;
  bool _resumeRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_init());
  }

  Future<void> _init() async {
    if (_initializing || !mounted) return;
    _initializing = true;
    setState(() => _state = _CameraState.initializing);
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        if (mounted) setState(() => _state = _CameraState.denied);
        return;
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('none', 'No cameras');
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted || !_cameraAllowed) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      _resumeRequested = false;
      setState(() => _state = _CameraState.ready);
    } on Exception {
      if (mounted) setState(() => _state = _CameraState.error);
    } finally {
      _initializing = false;
      if (_resumeRequested &&
          mounted &&
          _controller == null &&
          _state != _CameraState.denied) {
        _resumeRequested = false;
        unawaited(_init());
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _cameraAllowed = false;
      _resumeRequested = false;
      if (controller != null) unawaited(controller.dispose());
      _controller = null;
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _cameraAllowed = true;
      if (_initializing) {
        _resumeRequested = true;
      } else {
        unawaited(_init());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    super.dispose();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      Haptics.commit();
      final file = await controller.takePicture();
      widget.onCaptured(file.path);
    } on CameraException {
      if (mounted) setState(() => _state = _CameraState.error);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (_state) {
      _CameraState.initializing => const Center(
        child: CircularProgressIndicator(),
      ),
      _CameraState.denied => _Message(
        icon: Icons.no_photography_rounded,
        text: l10n.cameraPermissionNeeded,
        buttonLabel: l10n.openSettings,
        onPressed: openAppSettings,
      ),
      _CameraState.error => _Message(
        icon: Icons.error_outline_rounded,
        text: l10n.cameraError,
        buttonLabel: l10n.retry,
        onPressed: _init,
      ),
      _CameraState.ready => ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CoverCameraPreview(controller: _controller!),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x6606152D),
                    Colors.transparent,
                    Color(0xCC06152D),
                  ],
                  stops: [0, .54, 1],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: 78,
              bottom: 176,
              child: MissionGuideFrame(mission: widget.mission),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Center(
                child: PressableScale(
                  // Disabled while capture is in flight so a second tap
                  // cannot fire another takePicture() call.
                  onPressed: _capturing ? null : _capture,
                  semanticLabel: l10n.takePhoto,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.nightTop.withValues(alpha: .72),
                      border: Border.all(
                        color: widget.mission.experienceColor,
                        width: 6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.mission.experienceColor.withValues(
                            alpha: .32,
                          ),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _capturing
                            ? AppColors.textTertiary
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    };
  }
}

class _CoverCameraPreview extends StatelessWidget {
  const _CoverCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final preview = controller.value.previewSize;
    if (preview == null) return CameraPreview(controller);
    return LayoutBuilder(
      builder: (context, _) => FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: preview.height,
          height: preview.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final String buttonLabel;
  final Future<dynamic> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.lg),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            TextButton(onPressed: () => onPressed(), child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
