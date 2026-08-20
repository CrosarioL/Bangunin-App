import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/pressable_scale.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';

/// Reusable camera viewfinder with a capture button. Handles permission
/// denial and camera init errors with inline retry states.
class MissionCamera extends StatefulWidget {
  const MissionCamera({super.key, required this.onCaptured});

  final ValueChanged<String> onCaptured;

  @override
  State<MissionCamera> createState() => _MissionCameraState();
}

enum _CameraState { initializing, ready, denied, error }

class _MissionCameraState extends State<MissionCamera>
    with WidgetsBindingObserver {
  CameraController? _controller;
  _CameraState _state = _CameraState.initializing;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_init());
  }

  Future<void> _init() async {
    setState(() => _state = _CameraState.initializing);
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (mounted) setState(() => _state = _CameraState.denied);
      return;
    }
    try {
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
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      setState(() => _state = _CameraState.ready);
    } on CameraException {
      if (mounted) setState(() => _state = _CameraState.error);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) return;
    if (state == AppLifecycleState.inactive) {
      unawaited(controller.dispose());
      _controller = null;
    } else if (state == AppLifecycleState.resumed &&
        _state == _CameraState.ready) {
      unawaited(_init());
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
      _CameraState.ready => Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              child: CameraPreview(_controller!),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PressableScale(
            // Disabled (not just ignored) while a capture is in flight so
            // a second tap can't fire a second takePicture() call.
            onPressed: _capturing ? null : _capture,
            semanticLabel: l10n.takePhoto,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              padding: const EdgeInsets.all(5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _capturing ? AppColors.textTertiary : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    };
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
