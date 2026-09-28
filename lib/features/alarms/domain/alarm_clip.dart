/// Mood shelves in the video-alarm picker. Named for the *morning*, not the
/// genre: people pick "the one that yells at me", not "comedy".
enum ClipCategory { loud, funny, motivation, calm, seasonal }

/// One meme alarm: its audio is the alarm sound, and the ringing screen
/// shows either a looping muted video ([hasVideo]) or the clip's generated
/// art card (category gradient, [emoji], title), so audio-only memes need
/// no artwork files at all.
///
/// Audio and video ship as separate files on purpose. The video player plays
/// through the media stream, so a phone with media volume at zero would ring
/// silently. The audio goes through AlarmAudioService on the *alarm* stream
/// (ignores the silent switch, takes alarm audio focus), exactly like every
/// other alarm sound, and the video is kept in step with it.
///
/// Files live flat in `assets/clips/`: always `<id>.m4a`, plus `<id>.mp4`
/// and `<id>.jpg` for video clips. `tool/add_alarm_clip.sh` makes them.
class AlarmClip {
  const AlarmClip({
    required this.id,
    required this.titleEn,
    required this.titleId,
    required this.category,
    required this.emoji,
    this.hasVideo = false,
    this.onboarding = false,
  });

  final String id;
  final String titleEn;
  final String titleId;
  final ClipCategory category;

  /// The big symbol on the clip's art card.
  final String emoji;

  /// Ships `<id>.mp4` and `<id>.jpg`. Audio-only clips use the art card.
  final bool hasVideo;

  /// Offered on the onboarding sound step. Keep that shortlist to the few
  /// clips most likely to be picked; the full catalog lives in the editor.
  final bool onboarding;

  String title(String languageCode) => languageCode == 'id' ? titleId : titleEn;

  String get videoAsset => 'assets/clips/$id.mp4';
  String get audioAsset => 'assets/clips/$id.m4a';
  String get thumbnailAsset => 'assets/clips/$id.jpg';
}

abstract final class AlarmClips {
  /// The bundled catalog. Empty until clips are added; every surface that
  /// shows clips hides itself when this is empty.
  ///
  /// When the catalog moves to a server, this becomes the offline fallback:
  /// the next alarm must never depend on the network.
  static const all = <AlarmClip>[];

  static AlarmClip? byId(String? id) {
    if (id == null) return null;
    for (final clip in all) {
      if (clip.id == id) return clip;
    }
    return null;
  }

  static List<AlarmClip> get onboarding =>
      all.where((c) => c.onboarding).toList();
}
