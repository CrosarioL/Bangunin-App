import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../widgets/mission_camera.dart';

/// Registers the reference photo for an Object Hunt alarm. Pops with the
/// stored file path, or null when abandoned.
class ObjectRegistrationPage extends StatefulWidget {
  const ObjectRegistrationPage({super.key});

  @override
  State<ObjectRegistrationPage> createState() => _ObjectRegistrationPageState();
}

class _ObjectRegistrationPageState extends State<ObjectRegistrationPage> {
  String? _capturedPath;

  Future<void> _onCaptured(String rawCapturePath) async {
    // A retake leaves the previous permanent copy orphaned unless it's
    // cleared first — persisted reference photos never get looked at again
    // once replaced. Awaited (not fire-and-forget): this is the
    // deterministic, every-retake leak path, and a local delete is cheap
    // enough that awaiting it costs nothing perceptible.
    final previous = _capturedPath;
    if (previous != null) await _deleteQuietly(previous);

    // Persist outside the camera cache so the reference survives restarts.
    final docs = await getApplicationDocumentsDirectory();
    final dest =
        '${docs.path}/object_ref_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(rawCapturePath).copy(dest);
    await _deleteQuietly(rawCapturePath);
    if (mounted) setState(() => _capturedPath = dest);
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Best-effort cleanup; a stray temp file is not worth surfacing.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final captured = _capturedPath;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerObjectTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: l10n.close,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Text(
                l10n.registerObjectSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: captured == null
                    ? MissionCamera(onCaptured: _onCaptured)
                    : Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusCard,
                              ),
                              child: Image.file(
                                File(captured),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PrimaryButton(
                            label: l10n.usePhoto,
                            onPressed: () => context.pop(captured),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _capturedPath = null),
                            child: Text(l10n.retakePhoto),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
