import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';
import 'package:wakio/features/stats/domain/entities/wake_record.dart';
import 'package:wakio/features/stats/domain/streak_calculator.dart';

void main() {
  var counter = 0;
  WakeRecord record(DateTime day, {bool success = true}) {
    return WakeRecord(
      id: 'r${counter++}',
      alarmId: 'a',
      scheduledAt: day,
      dismissedAt: day,
      missionType: MissionType.skyPhoto,
      success: success,
    );
  }

  final now = DateTime(2026, 7, 9, 12);

  group('currentStreak', () {
    test('empty history is zero', () {
      expect(StreakCalculator.currentStreak(const [], now: now), 0);
    });

    test('counts consecutive days ending today', () {
      final records = [
        record(DateTime(2026, 7, 9, 7)),
        record(DateTime(2026, 7, 8, 7)),
        record(DateTime(2026, 7, 7, 7)),
      ];
      expect(StreakCalculator.currentStreak(records, now: now), 3);
    });

    test('yesterday-ending streak still counts (today not woken yet)', () {
      final records = [
        record(DateTime(2026, 7, 8, 7)),
        record(DateTime(2026, 7, 7, 7)),
      ];
      expect(StreakCalculator.currentStreak(records, now: now), 2);
    });

    test('gap breaks the streak', () {
      final records = [
        record(DateTime(2026, 7, 9, 7)),
        record(DateTime(2026, 7, 6, 7)),
      ];
      expect(StreakCalculator.currentStreak(records, now: now), 1);
    });

    test('failed wakes do not extend the streak', () {
      final records = [
        record(DateTime(2026, 7, 9, 7)),
        record(DateTime(2026, 7, 8, 7), success: false),
        record(DateTime(2026, 7, 7, 7)),
      ];
      expect(StreakCalculator.currentStreak(records, now: now), 1);
    });
  });

  group('bestStreak', () {
    test('finds the longest run anywhere in history', () {
      final records = [
        record(DateTime(2026, 6, 1, 7)),
        record(DateTime(2026, 6, 2, 7)),
        record(DateTime(2026, 6, 3, 7)),
        record(DateTime(2026, 6, 10, 7)),
        record(DateTime(2026, 6, 11, 7)),
      ];
      expect(StreakCalculator.bestStreak(records), 3);
    });
  });

  group('averageWakeMinutes', () {
    test('null with no successes', () {
      expect(
        StreakCalculator.averageWakeMinutes([
          record(DateTime(2026, 7, 1, 7), success: false),
        ]),
        isNull,
      );
    });

    test('averages dismissal clock times', () {
      final records = [
        record(DateTime(2026, 7, 1, 7)), // 420
        record(DateTime(2026, 7, 2, 8)), // 480
      ];
      expect(StreakCalculator.averageWakeMinutes(records), 450);
    });
  });

  test('successDaysInMonth filters by month and success', () {
    final records = [
      record(DateTime(2026, 7, 1, 7)),
      record(DateTime(2026, 7, 15, 7)),
      record(DateTime(2026, 7, 20, 7), success: false),
      record(DateTime(2026, 6, 30, 7)),
    ];
    expect(StreakCalculator.successDaysInMonth(records, DateTime(2026, 7)), {
      1,
      15,
    });
  });

  test('plain tap-to-dismiss alarms do not build a mission streak', () {
    final plain = WakeRecord(
      id: 'plain',
      alarmId: 'plain-alarm',
      scheduledAt: now,
      dismissedAt: now,
      missionType: MissionType.none,
    );
    expect(StreakCalculator.currentStreak([plain], now: now), 0);
  });
}
