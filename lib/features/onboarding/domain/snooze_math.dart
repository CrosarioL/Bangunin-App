/// Pure math behind the personalized "pain stat" screen — kept free of
/// Flutter imports so it is trivially unit-testable.
abstract final class SnoozeMath {
  /// Average snoozes per morning implied by each survey answer
  /// (0 = almost never, 1 = a few times a week, 2 = every morning).
  static const _snoozesPerDay = [0.2, 1.5, 3.0];

  /// The default snooze interval used for the estimate, in minutes.
  static const snoozeMinutes = 9;

  /// Estimated hours per year lost to snoozing for a given survey answer.
  static int hoursLostPerYear(int snoozeHabit) {
    final habit = snoozeHabit.clamp(0, _snoozesPerDay.length - 1);
    final minutesPerYear = _snoozesPerDay[habit] * snoozeMinutes * 365;
    return (minutesPerYear / 60).round();
  }

  /// Estimated sleep duration in minutes given a bedtime and wake goal,
  /// handling the over-midnight wrap (23:00 → 06:30 = 7h30m).
  static int sleepMinutes({
    required int bedHour,
    required int bedMinute,
    required int wakeHour,
    required int wakeMinute,
  }) {
    final bed = bedHour * 60 + bedMinute;
    final wake = wakeHour * 60 + wakeMinute;
    final diff = wake - bed;
    return diff > 0 ? diff : diff + 24 * 60;
  }
}
