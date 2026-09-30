import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/core/services/notifications/notification_service.dart';
import 'package:wakio/features/alarms/data/alarm_scheduler.dart';
import 'package:wakio/features/alarms/data/wake_check_store.dart';
import 'package:wakio/features/alarms/domain/alarm_payload.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

class _Scheduled {
  _Scheduled(this.at, this.payload, this.urgent);

  final DateTime at;
  final String payload;
  final bool urgent;
}

class _RecordingNotifications implements NotificationService {
  final scheduled = <int, _Scheduled>{};

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String payload,
    bool urgent = true,
    String? sound,
  }) async {
    scheduled[id] = _Scheduled(at, payload, urgent);
  }

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);

  @override
  Future<void> cancelAll() async => scheduled.clear();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Alarm alarm({
    String id = 'a',
    MissionType mission = MissionType.randomHunt,
    List<MissionType> extras = const [],
    int wakeCheckMinutes = 5,
  }) => Alarm(
    id: id,
    hour: 7,
    minute: 0,
    missionType: mission,
    missionReps: mission.defaultReps,
    extraMissions: extras,
    wakeCheckMinutes: wakeCheckMinutes,
    createdAt: DateTime(2026),
  );

  group('mission chain', () {
    test('lists the primary then the extras; empty without a mission', () {
      final chained = alarm(extras: [MissionType.math, MissionType.shake]);
      expect(chained.missionChain, [
        MissionType.randomHunt,
        MissionType.math,
        MissionType.shake,
      ]);
      expect(
        alarm(
          mission: MissionType.none,
          extras: [MissionType.math],
        ).missionChain,
        isEmpty,
      );
    });

    test('forStep swaps in the step mission at its default count', () {
      final chained = alarm(
        mission: MissionType.squats,
        extras: [MissionType.math],
      ).copyWith(missionReps: 25);
      expect(chained.forStep(0).missionReps, 25);
      final step = chained.forStep(1);
      expect(step.missionType, MissionType.math);
      expect(step.missionReps, MissionType.math.defaultReps);
      expect(chained.forStep(9), chained, reason: 'out of range is a no-op');
    });

    test('chain and wake check survive a save/load round trip', () {
      final original = alarm(extras: [MissionType.shake, MissionType.pushups]);
      final loaded = Alarm.fromJson(original.toJson());
      expect(loaded.extraMissions, [MissionType.shake, MissionType.pushups]);
      expect(loaded.wakeCheckMinutes, 5);
    });

    test('old alarms without the new fields still load', () {
      final json = alarm().toJson()
        ..remove('extraMissions')
        ..remove('wakeCheckMinutes');
      final loaded = Alarm.fromJson(json);
      expect(loaded.extraMissions, isEmpty);
      expect(loaded.wakeCheckMinutes, 0);
    });

    test('Object Hunt and none can never be chained', () {
      expect(MissionType.objectHunt.canChain, isFalse);
      expect(MissionType.none.canChain, isFalse);
      expect(MissionType.randomHunt.canChain, isTrue);
    });
  });

  test('payloads: bare ids still ring, prefixed ones ask the check', () {
    expect(AlarmPayload.parse('abc'), isA<RingPayload>());
    final check = AlarmPayload.parse(AlarmPayload.wakeCheck('abc'));
    expect(check, isA<WakeCheckPayload>());
    expect(check.alarmId, 'abc');
  });

  group('AlarmScheduler wake check', () {
    late _RecordingNotifications notifications;
    late AlarmScheduler scheduler;
    late WakeCheckStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = WakeCheckStore(await SharedPreferences.getInstance());
      notifications = _RecordingNotifications();
      scheduler = AlarmScheduler(notifications, wakeChecks: store);
    });

    test('posts a gentle prompt, then a real alarm a minute later', () async {
      final now = DateTime.now();
      final check = await scheduler.scheduleWakeCheck(alarm(), now: now);

      expect(check.checkAt, now.add(const Duration(minutes: 5)));
      expect(check.ringAt, check.checkAt.add(PendingWakeCheck.answerWindow));

      final prompt = notifications.scheduled.values.singleWhere(
        (n) => n.payload == AlarmPayload.wakeCheck('a'),
      );
      expect(prompt.urgent, isFalse);
      expect(prompt.at, check.checkAt);

      final ring = notifications.scheduled.values.singleWhere(
        (n) => n.payload == 'a',
      );
      expect(ring.urgent, isTrue);
      expect(ring.at, check.ringAt);
    });

    test('is persisted, so a fresh scheduler still knows about it', () async {
      await scheduler.scheduleWakeCheck(alarm());
      final restarted = AlarmScheduler(notifications, wakeChecks: store);
      expect(restarted.pendingWakeCheck?.alarmId, 'a');
    });

    test('survives a reschedule, which cancels everything first', () async {
      await scheduler.scheduleWakeCheck(alarm());
      await scheduler.reschedule([alarm()]);
      expect(
        notifications.scheduled.values.map((n) => n.payload),
        contains(AlarmPayload.wakeCheck('a')),
      );
    });

    test('is dropped on reschedule if its alarm was deleted', () async {
      await scheduler.scheduleWakeCheck(alarm());
      await scheduler.reschedule(const []);
      expect(scheduler.pendingWakeCheck, isNull);
      expect(notifications.scheduled, isEmpty);
    });

    test('cancel pulls both notifications and forgets it', () async {
      await scheduler.scheduleWakeCheck(alarm());
      await scheduler.cancelWakeCheck();
      expect(notifications.scheduled, isEmpty);
      expect(scheduler.pendingWakeCheck, isNull);
      expect(store.read(), isNull);
    });

    test("ids stay inside the alarm's own block", () async {
      await scheduler.reschedule([alarm()]);
      await scheduler.scheduleSnooze(alarm(), 5);
      await scheduler.scheduleWakeCheck(alarm());
      final base = AlarmScheduler.notificationBaseId('a');
      final nextBlock = AlarmScheduler.notificationBaseId('a') + 11;
      for (final id in notifications.scheduled.keys) {
        expect(id, inInclusiveRange(base, nextBlock - 1));
      }
      expect(notifications.scheduled.length, 1 + 1 + 2);
    });
  });
}
