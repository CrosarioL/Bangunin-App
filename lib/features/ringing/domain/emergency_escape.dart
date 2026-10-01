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
    'I really cannot do my mission right now.',
    'I know this does not count as waking up.',
    'Tomorrow I will do the mission properly.',
    'I promise I am not just going back to sleep.',
  ];

  static const _sentencesId = [
    'Aku beneran nggak bisa kerjakan misi sekarang.',
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

  /// Case, spacing and punctuation don't matter, and a few slips are
  /// forgiven (about one character in fifteen): typing the whole thing out
  /// is the friction, not spelling it perfectly at 5am on a phone keyboard.
  /// Changing a word ("does count" for "does not count") is still too far.
  static bool matches(String typed, String pledge) {
    final a = _normalise(typed);
    final b = _normalise(pledge);
    if (a.isEmpty) return false;
    final allowed = (b.length / 15).floor().clamp(1, 6);
    return _distance(a, b) <= allowed;
  }

  /// Levenshtein edit distance.
  static int _distance(String a, String b) {
    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0)..[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = [
          previous[j] + 1,
          current[j - 1] + 1,
          previous[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      previous = current;
    }
    return previous[b.length];
  }

  static String _normalise(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim();

  /// `yyyy-MM`, the bucket the monthly count resets on.
  static String monthKey(DateTime now) =>
      '${now.year}-${now.month.toString().padLeft(2, '0')}';
}
