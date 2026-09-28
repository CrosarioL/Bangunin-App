/// The way out of a mission you genuinely can't do: you're away from home,
/// the object isn't there, you're injured.
///
/// It has to exist, or a hard mission traps people and they uninstall. It
/// also has to be *more* annoying than just doing the mission, or it becomes
/// the snooze button. So it takes [requiredTaps] taps and then typing a
/// pledge by hand, and the pledge grows by one sentence for every escape
/// already used this calendar month.
abstract final class EmergencyEscape {
  static const requiredTaps = 10;

  /// Sentences in the order they are added. The first is always required.
  static const _sentencesEn = [
    'I am using the emergency exit because I really cannot do my mission.',
    'I know this does not count as waking up.',
    'Tomorrow I will do the mission properly.',
    'I promise I am not just going back to sleep.',
  ];

  static const _sentencesId = [
    'Aku pakai jalan darurat karena beneran nggak bisa selesaikan misi.',
    'Aku tahu ini nggak dihitung sebagai bangun.',
    'Besok aku kerjakan misinya dengan benar.',
    'Aku janji nggak lanjut tidur lagi.',
  ];

  /// The pledge to type, given how many escapes were already used this
  /// month. Caps at every sentence.
  static String pledge(String languageCode, {required int usedThisMonth}) {
    final sentences = languageCode == 'id' ? _sentencesId : _sentencesEn;
    final count = (1 + usedThisMonth).clamp(1, sentences.length);
    return sentences.take(count).join(' ');
  }

  /// Case, spacing and punctuation don't matter; the words do. Typing it is
  /// the friction, not getting a full stop exactly right at 5am.
  static bool matches(String typed, String pledge) =>
      _normalise(typed) == _normalise(pledge);

  static String _normalise(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim();

  /// `yyyy-MM`, the bucket the monthly count resets on.
  static String monthKey(DateTime now) =>
      '${now.year}-${now.month.toString().padLeft(2, '0')}';
}
