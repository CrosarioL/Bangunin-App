import 'entities/wake_record.dart';

/// Pure streak/stat math over wake records. Kept free of Flutter imports so
/// it is trivially unit-testable.
abstract final class StreakCalculator {
  /// Consecutive calendar days ending today (or yesterday, if today has no
  /// record yet) with at least one successful wake.
  static int currentStreak(List<WakeRecord> records, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    final successDays = records
        .where((r) => r.success)
        .map((r) => _day(r.dismissedAt))
        .toSet();
    if (successDays.isEmpty) return 0;

    var cursor = successDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (successDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int bestStreak(List<WakeRecord> records) {
    final days =
        records
            .where((r) => r.success)
            .map((r) => _day(r.dismissedAt))
            .toSet()
            .toList()
          ..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final day in days) {
      run = (prev != null && day.difference(prev).inDays == 1) ? run + 1 : 1;
      if (run > best) best = run;
      prev = day;
    }
    return best;
  }

  /// Average wake time (minutes after midnight) over successful records.
  static int? averageWakeMinutes(List<WakeRecord> records) {
    final successes = records.where((r) => r.success).toList();
    if (successes.isEmpty) return null;
    final total = successes.fold<int>(
      0,
      (sum, r) => sum + r.dismissedAt.hour * 60 + r.dismissedAt.minute,
    );
    return total ~/ successes.length;
  }

  /// Days of the current month (1-based) with a successful wake.
  static Set<int> successDaysInMonth(List<WakeRecord> records, DateTime month) {
    return records
        .where(
          (r) =>
              r.success &&
              r.dismissedAt.year == month.year &&
              r.dismissedAt.month == month.month,
        )
        .map((r) => r.dismissedAt.day)
        .toSet();
  }

  static DateTime _day(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
