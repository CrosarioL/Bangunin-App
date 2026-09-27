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
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/alarm_clip.dart';
import '../../domain/entities/alarm.dart';
import 'alarm_sound_l10n.dart';

/// Result of the sound picker: a video alarm, the chosen bundled sound, or a
/// custom file (imported audio/video or a fresh mic recording).
class SoundSelection {
  const SoundSelection(this.sound, {this.customPath, this.clipId});

  /// With [clipId] set this is only the fallback, played if the clip ever
  /// leaves the catalog.
  final AlarmSound sound;
  final String? customPath;
  final String? clipId;
}

Future<SoundSelection?> showSoundPickerSheet(
  BuildContext context, {
  required AlarmSound current,
  String? currentCustomPath,
  String? currentClipId,
}) {
  return showModalBottomSheet<SoundSelection>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _SoundPickerSheet(
      current: current,
      currentCustomPath: currentCustomPath,
      currentClipId: currentClipId,
    ),
  );
}

class _SoundPickerSheet extends ConsumerStatefulWidget {
  const _SoundPickerSheet({
    required this.current,
    this.currentCustomPath,
    this.currentClipId,
  });

  final AlarmSound current;
  final String? currentCustomPath;
  final String? currentClipId;

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
      child: SingleChildScrollView(
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
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.sunsetCoral.withValues(alpha: .14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.sunsetCoral,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.soundSection,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  const BanguninMascot(pose: MascotPose.crowing, size: 64),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (AlarmClips.all.isNotEmpty) ...[
                Text(
                  l10n.videoAlarmsSection,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 176,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AlarmClips.all.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final clip = AlarmClips.all[index];
                      return ClipTile(
                        clip: clip,
                        selected: widget.currentClipId == clip.id,
                        onTap: () async {
                          Haptics.selection();
                          await ref
                              .read(alarmAudioServiceProvider)
                              .previewClip(clip);
                          if (context.mounted) {
                            Navigator.of(context).pop(
                              SoundSelection(
                                widget.current,
                                customPath: widget.currentCustomPath,
                                clipId: clip.id,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.soundsSection, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
              ],
              for (final sound in const [
                AlarmSound.classic,
                AlarmSound.sunrise,
                AlarmSound.pulse,
              ])
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.nightTop.withValues(alpha: .22),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusControl,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .1),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    leading: const Icon(
                      Icons.music_note_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(sound.localizedName(l10n)),
                    trailing:
                        widget.current == sound &&
                            widget.currentCustomPath == null &&
                            widget.currentClipId == null
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
                ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: .2),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.library_music_rounded,
                        color: AppColors.cyan,
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
                    Divider(color: Colors.white.withValues(alpha: .1)),
                    ListTile(
                      leading: Icon(
                        _recording
                            ? Icons.stop_circle_rounded
                            : Icons.mic_rounded,
                        color: _recording
                            ? AppColors.danger
                            : AppColors.sunsetCoral,
                      ),
                      title: Text(
                        _recording ? l10n.stopRecording : l10n.recordSound,
                      ),
                      onTap: _toggleRecording,
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

/// A video alarm's thumbnail card. Public so onboarding can offer the same
/// tiles as the editor.
class ClipTile extends StatelessWidget {
  const ClipTile({
    super.key,
    required this.clip,
    required this.selected,
    required this.onTap,
  });

  final AlarmClip clip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    return Semantics(
      button: true,
      selected: selected,
      label: clip.title(language),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 108,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 136,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: .12),
                    width: selected ? 3 : 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      clip.thumbnailAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: AppColors.nightTop),
                    ),
                    Center(
                      child: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.play_circle_fill_rounded,
                        color: Colors.white.withValues(alpha: .9),
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                clip.title(language),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
