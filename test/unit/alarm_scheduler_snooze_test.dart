import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/core/services/notifications/notification_service.dart';
import 'package:wakio/features/alarms/data/alarm_scheduler.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';

/// Records what the scheduler asks the OS to do, without touching
/// flutter_local_notifications.
class _RecordingNotificationService implements NotificationService {
  final scheduled = <int, DateTime>{};
  int cancelAllCount = 0;

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String payload,
  }) async {
    scheduled[id] = at;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    scheduled.clear();
  }

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);

  // The scheduler only ever calls the three methods above; everything else on
  // NotificationService (init, permission prompts) is irrelevant here.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // The scheduler localizes notification copy, which reads the platform
  // locale off WidgetsBinding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingNotificationService notifications;
  late AlarmScheduler scheduler;

  Alarm alarmAt({required String id, required int hour, bool enabled = true}) =>
      Alarm(
        id: id,
        hour: hour,
        minute: 0,
        enabled: enabled,
        maxSnoozes: 3,
        snoozeMinutes: 5,
        createdAt: DateTime(2026),
      );

  int snoozeIdFor(String alarmId) =>
      AlarmScheduler.notificationBaseId(alarmId) +
      AlarmScheduler.occurrencesPerAlarm;

  setUp(() {
    notifications = _RecordingNotificationService();
    scheduler = AlarmScheduler(notifications);
  });

  group('pending snooze survives a reschedule', () {
    test(
      'a snooze is re-armed after an unrelated alarm change wipes it',
      () async {
        final snoozing = alarmAt(id: 'snoozing-alarm', hour: 5);
        final other = alarmAt(id: 'other-alarm', hour: 9);

        await scheduler.scheduleSnooze(snoozing, 5);
        final snoozeId = snoozeIdFor(snoozing.id);
        expect(
          notifications.scheduled.containsKey(snoozeId),
          isTrue,
          reason: 'snooze should be scheduled immediately',
        );

        // The user toggles an unrelated alarm, which reschedules everything.
        // Before the fix this silently destroyed the pending snooze and the
        // user was never woken.
        await scheduler.reschedule([snoozing, other]);

        expect(notifications.cancelAllCount, 1);
        expect(
          notifications.scheduled.containsKey(snoozeId),
          isTrue,
          reason: 'snooze must be re-armed after reschedule wiped it',
        );
      },
    );

    test('a snooze already in the past is not resurrected', () async {
      final alarm = alarmAt(id: 'past-snooze', hour: 5);

      // Negative minutes puts the fire time behind us straight away.
      await scheduler.scheduleSnooze(alarm, -5);
      await scheduler.reschedule([alarm]);

      expect(
        notifications.scheduled.containsKey(snoozeIdFor(alarm.id)),
        isFalse,
        reason: 'an elapsed snooze must not be re-armed',
      );
    });

    test('clearPendingSnooze stops the snooze being re-armed', () async {
      final alarm = alarmAt(id: 'cleared-snooze', hour: 5);

      await scheduler.scheduleSnooze(alarm, 5);
      scheduler.clearPendingSnooze();
      await scheduler.reschedule([alarm]);

      expect(
        notifications.scheduled.containsKey(snoozeIdFor(alarm.id)),
        isFalse,
        reason: 'a completed wake must not leave a snooze behind',
      );
    });

    test(
      'reschedule with no pending snooze schedules only occurrences',
      () async {
        final alarm = alarmAt(id: 'plain-alarm', hour: 6);

        await scheduler.reschedule([alarm]);

        expect(
          notifications.scheduled.containsKey(snoozeIdFor(alarm.id)),
          isFalse,
        );
        expect(
          notifications.scheduled,
          isNotEmpty,
          reason: 'the alarm occurrences themselves should still be scheduled',
        );
      },
    );

    test('disabled alarms are not scheduled', () async {
      final off = alarmAt(id: 'disabled-alarm', hour: 7, enabled: false);

      await scheduler.reschedule([off]);

      expect(notifications.scheduled, isEmpty);
    });
  });
}
