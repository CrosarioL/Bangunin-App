import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';

void main() {
  Alarm alarm({
    required int hour,
    required int minute,
    Set<int> repeatDays = const {},
  }) {
    return Alarm(
      id: 'a1',
      hour: hour,
      minute: minute,
      repeatDays: repeatDays,
      createdAt: DateTime(2026),
    );
  }

  group('Alarm.nextTrigger', () {
    test('one-off alarm later today fires today', () {
      // Wednesday 06:00.
      final from = DateTime(2026, 7, 8, 6);
      final next = alarm(hour: 7, minute: 30).nextTrigger(from);
      expect(next, DateTime(2026, 7, 8, 7, 30));
    });

    test('one-off alarm earlier today fires tomorrow', () {
      final from = DateTime(2026, 7, 8, 8);
      final next = alarm(hour: 7, minute: 30).nextTrigger(from);
      expect(next, DateTime(2026, 7, 9, 7, 30));
    });

    test('exact same minute rolls to the next day', () {
      final from = DateTime(2026, 7, 8, 7, 30);
      final next = alarm(hour: 7, minute: 30).nextTrigger(from);
      expect(next, DateTime(2026, 7, 9, 7, 30));
    });

    test('repeat alarm skips to next matching weekday', () {
      // From Wednesday evening, alarm repeats Mon+Fri.
      final from = DateTime(2026, 7, 8, 22);
      final next = alarm(
        hour: 7,
        minute: 0,
        repeatDays: {DateTime.monday, DateTime.friday},
      ).nextTrigger(from);
      expect(next.weekday, DateTime.friday);
      expect(next, DateTime(2026, 7, 10, 7));
    });

    test('repeat alarm today-before-time fires today when day matches', () {
      // Wednesday early morning, repeats Wednesday.
      final from = DateTime(2026, 7, 8, 5);
      final next = alarm(
        hour: 7,
        minute: 0,
        repeatDays: {DateTime.wednesday},
      ).nextTrigger(from);
      expect(next, DateTime(2026, 7, 8, 7));
    });

    test('weekly repeat wraps a full week', () {
      // Wednesday after alarm time, repeats Wednesday only.
      final from = DateTime(2026, 7, 8, 9);
      final next = alarm(
        hour: 7,
        minute: 0,
        repeatDays: {DateTime.wednesday},
      ).nextTrigger(from);
      expect(next, DateTime(2026, 7, 15, 7));
    });
  });

  group('Alarm json round-trip', () {
    test('preserves all fields', () {
      final original = Alarm(
        id: 'x',
        hour: 6,
        minute: 45,
        label: 'Gym',
        repeatDays: const {1, 3, 5},
        sound: AlarmSound.pulse,
        snoozeMinutes: 9,
        createdAt: DateTime(2026, 5),
      );
      final restored = Alarm.fromJson(original.toJson());
      expect(restored, original);
    });
  });
}
