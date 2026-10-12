/// The way out of a mission you genuinely can't do: you're away from home,
/// the object isn't there, you're injured.
///
/// It has to exist, or a hard mission traps people and they uninstall. It
/// also has to be *more* annoying than just doing the mission, or it becomes
/// the snooze button. So it takes [requiredTaps] taps and then typing one
/// short sentence by hand.
abstract final class EmergencyEscape {
  static const requiredTaps = 10;

  /// The sentence to type. One line: long enough to break autopilot, short
  /// enough for a real emergency.
  static String pledge(String languageCode) => languageCode == 'id'
      ? 'Aku nggak bisa misi sekarang.'
      : "I can't do my mission now.";

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
