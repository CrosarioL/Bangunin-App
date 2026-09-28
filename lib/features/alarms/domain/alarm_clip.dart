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
  ///
  /// Order is picker order. Sources: Myinstants re-uploads of viral memes,
  /// never commercial songs (see tool/add_alarm_clip.sh).
  static const all = <AlarmClip>[
    // Indonesia.
    AlarmClip(
      id: 'tung_sahur',
      titleEn: 'Tung Tung Tung Sahur',
      titleId: 'Tung Tung Tung Sahur',
      category: ClipCategory.seasonal,
      emoji: '🥁',
      onboarding: true,
    ),
    // The yell at the end of @hikaru_0772's "POV: Bapak bangunin sahur",
    // looped with a breath between yells.
    AlarmClip(
      id: 'sahur_bapak',
      titleEn: 'Dad Yelling SAHUR',
      titleId: 'Bapak Bangunin Sahur',
      category: ClipCategory.seasonal,
      emoji: '👨',
      onboarding: true,
    ),
    AlarmClip(
      id: 'om_telolet',
      titleEn: 'Om Telolet Om',
      titleId: 'Om Telolet Om',
      category: ClipCategory.loud,
      emoji: '🚌',
      onboarding: true,
    ),
    AlarmClip(
      id: 'tahu_bulat',
      titleEn: 'Tahu Bulat',
      titleId: 'Tahu Bulat',
      category: ClipCategory.funny,
      emoji: '📣',
      onboarding: true,
    ),
    AlarmClip(
      id: 'bangun_sahur',
      titleEn: 'Bangun Sahur!',
      titleId: 'Bangun Sahur!',
      category: ClipCategory.seasonal,
      emoji: '🌙',
    ),
    AlarmClip(
      id: 'bangunin_subuh',
      titleEn: 'Bangunin Gw Subuh',
      titleId: 'Bangunin Gw Subuh',
      category: ClipCategory.funny,
      emoji: '🌅',
    ),
    AlarmClip(
      id: 'bangun',
      titleEn: 'BANGUN!',
      titleId: 'BANGUN!',
      category: ClipCategory.loud,
      emoji: '📢',
    ),
    AlarmClip(
      id: 'sayur',
      titleEn: 'Sayuuur!',
      titleId: 'Sayuuur!',
      category: ClipCategory.funny,
      emoji: '🥬',
    ),
    AlarmClip(
      id: 'rem_truk',
      titleEn: 'Truck Air Brake',
      titleId: 'Rem Truk',
      category: ClipCategory.loud,
      emoji: '🚛',
    ),
    AlarmClip(
      id: 'waduh',
      titleEn: 'Waduh',
      titleId: 'Waduh',
      category: ClipCategory.funny,
      emoji: '😰',
    ),
    AlarmClip(
      id: 'ngakak',
      titleEn: 'Annoying Laugh',
      titleId: 'Ketawa Ngeselin',
      category: ClipCategory.funny,
      emoji: '🤣',
    ),
    // Global.
    AlarmClip(
      id: 'phone_ringing',
      titleEn: 'Your Phone Ringing',
      titleId: 'Your Phone Ringing',
      category: ClipCategory.funny,
      emoji: '📱',
      onboarding: true,
    ),
    AlarmClip(
      id: 'patapim_alarm',
      titleEn: 'Brr Brr Patapim',
      titleId: 'Brr Brr Patapim',
      category: ClipCategory.funny,
      emoji: '🌳',
      onboarding: true,
    ),
    AlarmClip(
      id: 'danger_alarm',
      titleEn: 'Danger Alarm',
      titleId: 'Alarm Bahaya',
      category: ClipCategory.loud,
      emoji: '🚨',
      onboarding: true,
    ),
    AlarmClip(
      id: 'bombardiro',
      titleEn: 'Bombardiro Crocodilo',
      titleId: 'Bombardiro Crocodilo',
      category: ClipCategory.funny,
      emoji: '🐊',
    ),
    AlarmClip(
      id: 'fahh',
      titleEn: 'FAHHH',
      titleId: 'FAHHH',
      category: ClipCategory.loud,
      emoji: '😫',
    ),
    AlarmClip(
      id: 'vine_boom',
      titleEn: 'Vine Boom',
      titleId: 'Vine Boom',
      category: ClipCategory.loud,
      emoji: '💥',
    ),
    AlarmClip(
      id: 'metal_pipe',
      titleEn: 'Metal Pipe',
      titleId: 'Pipa Besi Jatuh',
      category: ClipCategory.loud,
      emoji: '🔩',
    ),
    AlarmClip(
      id: 'metal_gear',
      titleEn: 'Metal Gear Alert',
      titleId: 'Metal Gear Alert',
      category: ClipCategory.loud,
      emoji: '❗',
    ),
    AlarmClip(
      id: 'nuclear_siren',
      titleEn: 'Nuclear Siren',
      titleId: 'Sirine Nuklir',
      category: ClipCategory.loud,
      emoji: '☢️',
    ),
    AlarmClip(
      id: 'emotional_damage',
      titleEn: 'Emotional Damage',
      titleId: 'Emotional Damage',
      category: ClipCategory.funny,
      emoji: '💔',
    ),
    AlarmClip(
      id: 'wakey_school',
      titleEn: 'Wakey Wakey, School Time',
      titleId: 'Wakey Wakey, Waktunya Sekolah',
      category: ClipCategory.motivation,
      emoji: '🎒',
    ),
  ];

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
