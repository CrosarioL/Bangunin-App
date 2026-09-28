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
import '../../../../app/widgets/primary_button.dart';
import '../../../../app/widgets/swipe_carousel.dart';
import '../../../../core/services/audio/alarm_audio_service.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/alarm_clip.dart';
import '../../domain/entities/alarm.dart';
import 'alarm_sound_l10n.dart';
import 'clip_art.dart';

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

/// One card in a sound carousel: a meme clip, a bundled sound, or the user's
/// own imported/recorded file. Shared by the sound picker and onboarding.
class SoundOption {
  const SoundOption.clip(AlarmClip this.clip) : sound = null, custom = false;
  const SoundOption.sound(AlarmSound this.sound) : clip = null, custom = false;
  const SoundOption.custom() : clip = null, sound = null, custom = true;

  final AlarmClip? clip;
  final AlarmSound? sound;
  final bool custom;

  static const bundled = [
    SoundOption.sound(AlarmSound.classic),
    SoundOption.sound(AlarmSound.sunrise),
    SoundOption.sound(AlarmSound.pulse),
  ];

  String name(BuildContext context) {
    final l10n = context.l10n;
    if (clip != null) {
      return clip!.title(Localizations.localeOf(context).languageCode);
    }
    if (custom) return l10n.soundCustom;
    return sound!.localizedName(l10n);
  }

  /// Bundled and custom sounds reuse the clip art card, so every card in a
  /// carousel looks like it belongs to the same set.
  AlarmClip art(BuildContext context) {
    if (clip != null) return clip!;
    final (category, emoji) = custom
        ? (ClipCategory.motivation, '🎤')
        : switch (sound!) {
            AlarmSound.classic => (ClipCategory.motivation, '⏰'),
            AlarmSound.sunrise => (ClipCategory.calm, '🌅'),
            AlarmSound.pulse => (ClipCategory.loud, '📳'),
            AlarmSound.custom => (ClipCategory.motivation, '🎤'),
          };
    final title = name(context);
    return AlarmClip(
      id: 'bundled',
      titleEn: title,
      titleId: title,
      category: category,
      emoji: emoji,
    );
  }

  Future<void> preview(AlarmAudioService audio, {String? customPath}) {
    if (clip != null) return audio.previewClip(clip!);
    if (custom) return audio.preview(AlarmSound.custom, customPath: customPath);
    return audio.preview(sound!);
  }
}

class _SoundPickerSheetState extends ConsumerState<_SoundPickerSheet> {
  final _recorder = AudioRecorder();
  bool _recording = false;
  bool _importing = false;
  Timer? _previewDebounce;

  // Read in initState, not lazily: a lazy read first touched in dispose()
  // (picker closed without playing anything) uses `ref` after unmount.
  late final AlarmAudioService _audio;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(alarmAudioServiceProvider);
  }

  /// Memes first (they're the point), then the plain sounds, then the
  /// user's own file if the alarm already has one.
  late final List<SoundOption> _items = [
    for (final clip in AlarmClips.all) SoundOption.clip(clip),
    ...SoundOption.bundled,
    if (widget.currentCustomPath != null) const SoundOption.custom(),
  ];

  late int _page = () {
    final index = _items.indexWhere(_isCurrent);
    return index < 0 ? 0 : index;
  }();

  bool _isCurrent(SoundOption item) {
    if (item.clip != null) return item.clip!.id == widget.currentClipId;
    if (widget.currentClipId != null) return false;
    if (item.custom) return widget.currentCustomPath != null;
    return item.sound == widget.current && widget.currentCustomPath == null;
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    unawaited(_audio.stopPreview());
    unawaited(_recorder.dispose());
    super.dispose();
  }

  /// Plays whatever card is in front. Debounced, so flicking through ten
  /// sounds plays the one you stop on rather than ten half-second bursts.
  void _schedulePreview() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_play(_items[_page])),
    );
  }

  Future<void> _play(SoundOption item) =>
      item.preview(_audio, customPath: widget.currentCustomPath);

  void _choose(SoundOption item) {
    Haptics.selection();
    final clip = item.clip;
    Navigator.of(context).pop(
      clip != null
          ? SoundSelection(
              widget.current,
              customPath: widget.currentCustomPath,
              clipId: clip.id,
            )
          : item.custom
          ? SoundSelection(
              AlarmSound.custom,
              customPath: widget.currentCustomPath,
            )
          : SoundSelection(item.sound!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final item = _items[_page];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.soundSection,
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          l10n.soundSwipeHint,
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const BanguninMascot(pose: MascotPose.crowing, size: 56),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwipeCarousel(
              itemCount: _items.length,
              initialPage: _page,
              height: 340,
              onPageChanged: (page) {
                setState(() => _page = page);
                _schedulePreview();
              },
              onTapFocused: (index) {
                Haptics.tap();
                unawaited(_play(_items[index]));
              },
              itemBuilder: (context, index, focused) {
                final entry = _items[index];
                return SoundCard(
                  option: entry,
                  focused: focused,
                  badge: _isCurrent(entry) ? l10n.missionCurrent : null,
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  PrimaryButton(
                    label: l10n.chooseSound,
                    onPressed: () => _choose(item),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _importing ? null : _importFile,
                          icon: _importing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.library_music_rounded),
                          label: Text(l10n.importSoundShort),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _toggleRecording,
                          icon: Icon(
                            _recording
                                ? Icons.stop_circle_rounded
                                : Icons.mic_rounded,
                            color: _recording ? AppColors.danger : null,
                          ),
                          label: Text(
                            _recording ? l10n.stopRecording : l10n.recordSound,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

/// A sound as a carousel card: its art, a speaker hint, and an optional
/// corner [badge]. Shared with onboarding.
class SoundCard extends StatelessWidget {
  const SoundCard({
    super.key,
    required this.option,
    required this.focused,
    this.badge,
  });

  final SoundOption option;
  final bool focused;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final art = option.art(context);
    final accent = art.category.gradient.first;
    return Semantics(
      button: true,
      label: option.name(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: focused ? Colors.white : Colors.white.withValues(alpha: .12),
            width: focused ? 3 : 1.5,
          ),
          boxShadow: [
            if (focused)
              BoxShadow(color: accent.withValues(alpha: .35), blurRadius: 28),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipArt(clip: art, large: true),
            if (badge != null)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: CarouselBadge(text: badge!, color: Colors.white),
              ),
            Positioned(
              left: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Icon(
                Icons.volume_up_rounded,
                color: Colors.white.withValues(alpha: .85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
