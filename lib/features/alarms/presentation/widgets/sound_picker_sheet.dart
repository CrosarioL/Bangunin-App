import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/entities/alarm.dart';
import 'alarm_sound_l10n.dart';

/// Result of the sound picker: the chosen bundled sound, or a custom file
/// (imported audio/video or a fresh mic recording).
class SoundSelection {
  const SoundSelection(this.sound, {this.customPath});

  final AlarmSound sound;
  final String? customPath;
}

Future<SoundSelection?> showSoundPickerSheet(
  BuildContext context, {
  required AlarmSound current,
  String? currentCustomPath,
}) {
  return showModalBottomSheet<SoundSelection>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _SoundPickerSheet(
      current: current,
      currentCustomPath: currentCustomPath,
    ),
  );
}

class _SoundPickerSheet extends ConsumerStatefulWidget {
  const _SoundPickerSheet({required this.current, this.currentCustomPath});

  final AlarmSound current;
  final String? currentCustomPath;

  @override
  ConsumerState<_SoundPickerSheet> createState() => _SoundPickerSheetState();
}

class _SoundPickerSheetState extends ConsumerState<_SoundPickerSheet> {
  final _recorder = AudioRecorder();
  bool _recording = false;
  bool _importing = false;

  @override
  void dispose() {
    unawaited(ref.read(alarmAudioServiceProvider).stopPreview());
    unawaited(_recorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.soundSection, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            for (final sound in const [
              AlarmSound.classic,
              AlarmSound.sunrise,
              AlarmSound.pulse,
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.music_note_rounded,
                  color: AppColors.primary,
                ),
                title: Text(sound.localizedName(l10n)),
                trailing:
                    widget.current == sound && widget.currentCustomPath == null
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () async {
                  Haptics.selection();
                  await ref.read(alarmAudioServiceProvider).preview(sound);
                  if (context.mounted) {
                    Navigator.of(context).pop(SoundSelection(sound));
                  }
                },
              ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.library_music_rounded,
                color: AppColors.info,
              ),
              title: Text(l10n.importSound),
              subtitle: Text(
                l10n.importSoundSubtitle,
                style: theme.textTheme.bodySmall,
              ),
              trailing: _importing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _importing ? null : _importFile,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _recording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                color: _recording ? AppColors.danger : AppColors.info,
              ),
              title: Text(_recording ? l10n.stopRecording : l10n.recordSound),
              onTap: _toggleRecording,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFile() async {
    setState(() => _importing = true);
    try {
      final result = await FilePicker.pickFiles(type: FileType.media);
      final path = result?.files.single.path;
      if (path == null) return;
      // Copy into app documents so the sound survives the picker cache.
      final docs = await getApplicationDocumentsDirectory();
      final ext = path.split('.').last;
      final dest =
          '${docs.path}/custom_sound_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(path).copy(dest);
      if (mounted) {
        Navigator.of(
          context,
        ).pop(SoundSelection(AlarmSound.custom, customPath: dest));
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      final path = await _recorder.stop();
      setState(() => _recording = false);
      if (path != null && mounted) {
        Navigator.of(
          context,
        ).pop(SoundSelection(AlarmSound.custom, customPath: path));
      }
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted || !mounted) return;

    final docs = await getApplicationDocumentsDirectory();
    final path =
        '${docs.path}/recorded_sound_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    Haptics.commit();
    setState(() => _recording = true);
  }
}
