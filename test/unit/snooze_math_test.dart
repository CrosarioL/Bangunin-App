import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/features/onboarding/domain/snooze_math.dart';

void main() {
  group('SnoozeMath.hoursLostPerYear', () {
    test('habit 0 (almost never: 0.2 snoozes/day)', () {
      // 0.2 * 9 * 365 = 657 minutes/year -> 10.95h -> rounds to 11
      expect(SnoozeMath.hoursLostPerYear(0), 11);
    });

    test('habit 1 (a few times a week: 1.5 snoozes/day)', () {
      // 1.5 * 9 * 365 = 4927.5 minutes/year -> 82.125h -> rounds to 82
      expect(SnoozeMath.hoursLostPerYear(1), 82);
    });

    test('habit 2 (every morning: 3.0 snoozes/day)', () {
      // 3.0 * 9 * 365 = 9855 minutes/year -> 164.25h -> rounds to 164
      expect(SnoozeMath.hoursLostPerYear(2), 164);
    });

    test('clamps out-of-range habit values to the valid range', () {
      expect(SnoozeMath.hoursLostPerYear(-1), SnoozeMath.hoursLostPerYear(0));
      expect(SnoozeMath.hoursLostPerYear(5), SnoozeMath.hoursLostPerYear(2));
    });
  });

  group('SnoozeMath.sleepMinutes', () {
    test('same-day bedtime/wake window', () {
      final minutes = SnoozeMath.sleepMinutes(
        bedHour: 1,
        bedMinute: 0,
        wakeHour: 9,
        wakeMinute: 0,
      );
      expect(minutes, 480);
    });

    test('over-midnight wrap: 23:00 -> 06:30 = 7h30m', () {
      final minutes = SnoozeMath.sleepMinutes(
        bedHour: 23,
        bedMinute: 0,
        wakeHour: 6,
        wakeMinute: 30,
      );
      expect(minutes, 450);
    });
  });
}
