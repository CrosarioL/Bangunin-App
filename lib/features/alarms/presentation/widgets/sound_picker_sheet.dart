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

/// One card in the sound carousel: a meme clip, a bundled sound, or the
/// user's own imported/recorded file.
class _SoundItem {
  const _SoundItem.clip(AlarmClip this.clip) : sound = null, custom = false;
  const _SoundItem.sound(AlarmSound this.sound) : clip = null, custom = false;
  const _SoundItem.custom() : clip = null, sound = null, custom = true;

  final AlarmClip? clip;
  final AlarmSound? sound;
  final bool custom;
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
  late final List<_SoundItem> _items = [
    for (final clip in AlarmClips.all) _SoundItem.clip(clip),
    for (final sound in const [
      AlarmSound.classic,
      AlarmSound.sunrise,
      AlarmSound.pulse,
    ])
      _SoundItem.sound(sound),
    if (widget.currentCustomPath != null) const _SoundItem.custom(),
  ];

  late int _page = () {
    final index = _items.indexWhere(_isCurrent);
    return index < 0 ? 0 : index;
  }();

  late final _controller = PageController(
    initialPage: _page,
    viewportFraction: .84,
  );

  bool _isCurrent(_SoundItem item) {
    if (item.clip != null) return item.clip!.id == widget.currentClipId;
    if (widget.currentClipId != null) return false;
    if (item.custom) return widget.currentCustomPath != null;
    return item.sound == widget.current && widget.currentCustomPath == null;
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _controller.dispose();
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

  Future<void> _play(_SoundItem item) async {
    final clip = item.clip;
    if (clip != null) {
      await _audio.previewClip(clip);
    } else if (item.custom) {
      await _audio.preview(
        AlarmSound.custom,
        customPath: widget.currentCustomPath,
      );
    } else {
      await _audio.preview(item.sound!);
    }
  }

  void _choose(_SoundItem item) {
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

  /// Bundled and custom sounds reuse the clip art card, so every card in
  /// the carousel looks like it belongs to the same set.
  AlarmClip _artFor(_SoundItem item, String name) {
    if (item.clip != null) return item.clip!;
    final (category, emoji) = item.custom
        ? (ClipCategory.motivation, '🎤')
        : switch (item.sound!) {
            AlarmSound.classic => (ClipCategory.motivation, '⏰'),
            AlarmSound.sunrise => (ClipCategory.calm, '🌅'),
            AlarmSound.pulse => (ClipCategory.loud, '📳'),
            AlarmSound.custom => (ClipCategory.motivation, '🎤'),
          };
    return AlarmClip(
      id: 'bundled',
      titleEn: name,
      titleId: name,
      category: category,
      emoji: emoji,
    );
  }

  String _nameFor(_SoundItem item) {
    final l10n = context.l10n;
    if (item.clip != null) {
      return item.clip!.title(Localizations.localeOf(context).languageCode);
    }
    if (item.custom) return l10n.soundCustom;
    return item.sound!.localizedName(l10n);
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
            SizedBox(
              height: 340,
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (page) {
                  Haptics.selection();
                  setState(() => _page = page);
                  _schedulePreview();
                },
                itemBuilder: (context, index) {
                  final entry = _items[index];
                  final name = _nameFor(entry);
                  return _SoundCard(
                    art: _artFor(entry, name),
                    name: name,
                    selected: _isCurrent(entry),
                    focused: index == _page,
                    onTap: () {
                      if (index == _page) {
                        Haptics.tap();
                        unawaited(_play(entry));
                      } else {
                        unawaited(
                          _controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PageDots(count: _items.length, active: _page),
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
                    if (clip.hasVideo)
                      Image.asset(
                        clip.thumbnailAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ClipArt(clip: clip),
                      )
                    else
                      ClipArt(clip: clip),
                    Align(
                      alignment: clip.hasVideo
                          ? Alignment.center
                          : Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.play_circle_fill_rounded,
                          color: Colors.white.withValues(alpha: .9),
                          size: clip.hasVideo ? 34 : 24,
                        ),
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

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.art,
    required this.name,
    required this.selected,
    required this.focused,
    required this.onTap,
  });

  final AlarmClip art;
  final String name;
  final bool selected;
  final bool focused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = art.category.gradient.first;
    return AnimatedScale(
      scale: focused ? 1 : .92,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Semantics(
          button: true,
          selected: selected,
          label: name,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: .12),
                  width: selected ? 3 : 1.5,
                ),
                boxShadow: [
                  if (focused)
                    BoxShadow(
                      color: accent.withValues(alpha: .35),
                      blurRadius: 28,
                    ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipArt(clip: art, large: true),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: selected
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusCapsule,
                              ),
                            ),
                            child: Text(
                              context.l10n.missionCurrent,
                              style: theme.textTheme.labelMedium!.copyWith(
                                color: AppColors.nightTop,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
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
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    // Past a dozen dots they turn into noise; a counter reads better.
    if (count > 12) {
      return Text(
        '${active + 1} / $count',
        style: Theme.of(
          context,
        ).textTheme.labelLarge!.copyWith(color: Colors.white70),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: .25),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}
