import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/alarms/alarm_kit_service.dart';
import 'package:wakio/core/services/audio/alarm_audio_service.dart';
import 'package:wakio/core/storage/local_store.dart';
import 'package:wakio/features/alarms/data/alarm_repository_impl.dart';
import 'package:wakio/features/alarms/data/alarm_scheduler.dart';
import 'package:wakio/features/alarms/data/wake_check_store.dart';
import 'package:wakio/features/alarms/domain/alarm_clip.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/alarms/domain/repositories/alarm_repository.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';
import 'package:wakio/features/ringing/presentation/providers/ringing_provider.dart';
import 'package:wakio/features/stats/data/wake_stats_repository_impl.dart';

/// Never touches a real AudioPlayer/platform channel — just records calls.
class _FakeAudioService implements AlarmAudioService {
  bool ringing = false;
  bool ducked = false;
  int startCount = 0;

  @override
  Future<void> startRinging(Alarm alarm) async {
    ringing = true;
    startCount++;
  }

  @override
  Future<void> stopRinging() async => ringing = false;

  @override
  Future<void> duckForMission() async => ducked = true;

  @override
  Future<void> restoreRingingVolume() async => ducked = false;

  @override
  Future<void> preview(AlarmSound sound, {String? customPath}) async {}

  @override
  Future<void> previewClip(AlarmClip clip) async {}

  @override
  Stream<void> get loopRestarts => const Stream.empty();

  @override
  Future<void> stopPreview() async {}

  @override
  Future<void> dispose() async {}

  @override
  bool get isPlaying => ringing;
}

/// Never touches flutter_local_notifications — just records snooze calls.
class _FakeAlarmScheduler implements AlarmScheduler {
  int snoozeCallCount = 0;
  int rescheduleCallCount = 0;
  int clearPendingSnoozeCallCount = 0;

  @override
  Locale? get localeOverride => null;

  @override
  Future<void> reschedule(List<Alarm> alarms) async => rescheduleCallCount++;

  @override
  Future<void> scheduleSnooze(Alarm alarm, int minutes) async =>
      snoozeCallCount++;

  @override
  void clearPendingSnooze() => clearPendingSnoozeCallCount++;

  @override
  Future<AlarmEngine> activeEngine() async => AlarmEngine.notifications;

  @override
  PendingWakeCheck? pendingWakeCheck;

  @override
  Future<PendingWakeCheck> scheduleWakeCheck(
    Alarm alarm, {
    DateTime? now,
  }) async {
    final at = (now ?? DateTime.now()).add(
      Duration(minutes: alarm.wakeCheckMinutes),
    );
    return pendingWakeCheck = PendingWakeCheck(
      alarmId: alarm.id,
      checkAt: at,
      ringAt: at.add(PendingWakeCheck.answerWindow),
    );
  }

  @override
  Future<void> cancelWakeCheck() async => pendingWakeCheck = null;

  final silenced = <String>[];
  final androidDeferred = <String>[];
  final androidCancelled = <String>[];

  @override
  Future<void> silenceFiredNotification(String alarmId) async =>
      silenced.add(alarmId);

  @override
  Future<void> deferAndroidReRing(Alarm alarm, {required int seconds}) async =>
      androidDeferred.add(alarm.id);

  @override
  Future<void> cancelAndroidReRing(String alarmId) async =>
      androidCancelled.add(alarmId);
}

class _FakeAlarmKit extends AlarmKitService {
  final deferred = <String>[];
  final cancelled = <String>[];
  @override
  Future<void> deferReRing(String alarmId, {required int seconds}) async =>
      deferred.add(alarmId);
  @override
  Future<void> cancelReRing(String alarmId) async => cancelled.add(alarmId);
  final backupsCancelled = <String>[];
  @override
  Future<void> cancelBackups(String alarmId) async =>
      backupsCancelled.add(alarmId);
}

void main() {
  // The ringing session watches app lifecycle (lock screen / background).
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late ProviderContainer container;
  late _FakeAlarmKit alarmKit;
  late AlarmRepository alarmRepository;
  late _FakeAudioService audioService;
  late _FakeAlarmScheduler scheduler;

  Alarm testAlarm({int maxSnoozes = 2}) => Alarm(
    id: 'ring-test',
    hour: 7,
    minute: 0,
    maxSnoozes: maxSnoozes,
    snoozeMinutes: 5,
    createdAt: DateTime(2026),
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wakio_ringing_test');
    Hive.init(tempDir.path);
    final store = await LocalStore.open();
    alarmRepository = HiveAlarmRepository(store);
    audioService = _FakeAudioService();
    scheduler = _FakeAlarmScheduler();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    alarmKit = _FakeAlarmKit();
    container = ProviderContainer(
      overrides: [
        alarmKitServiceProvider.overrideWithValue(alarmKit),
        sharedPreferencesProvider.overrideWithValue(prefs),
        alarmRepositoryProvider.overrideWithValue(alarmRepository),
        wakeStatsRepositoryProvider.overrideWithValue(
          HiveWakeStatsRepository(store),
        ),
        alarmAudioServiceProvider.overrideWithValue(audioService),
        alarmSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('snooze count is enforced across snooze round-trips', () async {
    // Regression test: snoozing used to clear RingingSession entirely,
    // which reset snoozeCount to 0 on the next `begin()` and let a user
    // snooze past `maxSnoozes` indefinitely.
    await alarmRepository.upsert(testAlarm(maxSnoozes: 2));
    final notifier = container.read(ringingSessionProvider.notifier);

    await notifier.begin('ring-test');
    expect(container.read(ringingSessionProvider)!.canSnooze, isTrue);
    expect(await notifier.snooze(), isTrue);
    expect(scheduler.snoozeCallCount, 1);

    // Notification "fires again" — begin() is called fresh.
    await notifier.begin('ring-test');
    expect(container.read(ringingSessionProvider)!.snoozeCount, 1);
    expect(await notifier.snooze(), isTrue);
    expect(scheduler.snoozeCallCount, 2);

    // Third occurrence: both snoozes are used up.
    await notifier.begin('ring-test');
    final session = container.read(ringingSessionProvider)!;
    expect(session.snoozeCount, 2);
    expect(session.canSnooze, isFalse);
    expect(await notifier.snooze(), isFalse);
    expect(
      scheduler.snoozeCallCount,
      2,
      reason: 'snooze() must be a no-op past the limit',
    );
  });

  test(
    'completing a wake resets the snooze count for the next occurrence',
    () async {
      await alarmRepository.upsert(
        testAlarm(maxSnoozes: 1).copyWith(repeatDays: {DateTime.monday}),
      );
      final notifier = container.read(ringingSessionProvider.notifier);

      await notifier.begin('ring-test');
      await notifier.snooze();
      await notifier.begin('ring-test');
      expect(container.read(ringingSessionProvider)!.snoozeCount, 1);
      await notifier.complete();

      // Next day's occurrence starts fresh.
      await notifier.begin('ring-test');
      expect(container.read(ringingSessionProvider)!.snoozeCount, 0);
    },
  );

  test(
    'begin() starts audio and complete() records a wake + stops audio',
    () async {
      await alarmRepository.upsert(testAlarm());
      final notifier = container.read(ringingSessionProvider.notifier);

      await notifier.begin('ring-test');
      expect(audioService.ringing, isTrue);

      await notifier.complete();
      expect(audioService.ringing, isFalse);
      expect(container.read(ringingSessionProvider), isNull);

      final records = await container
          .read(wakeStatsRepositoryProvider)
          .getAll();
      expect(records, hasLength(1));
      expect(records.single.alarmId, 'ring-test');
    },
  );

  test(
    'emergency escape stops the alarm but records a failed morning',
    () async {
      await alarmRepository.upsert(testAlarm());
      final notifier = container.read(ringingSessionProvider.notifier);
      expect(notifier.emergencyEscapesThisMonth(), 0);

      await notifier.begin('ring-test');
      await notifier.escape();

      expect(audioService.ringing, isFalse);
      expect(container.read(ringingSessionProvider), isNull);
      final records = await container
          .read(wakeStatsRepositoryProvider)
          .getAll();
      expect(records.single.success, isFalse, reason: 'must not feed a streak');
      expect(notifier.emergencyEscapesThisMonth(), 1);

      await notifier.begin('ring-test');
      await notifier.escape();
      expect(notifier.emergencyEscapesThisMonth(), 2);
    },
  );

  test(
    'a chain walks mission by mission, and backing out keeps progress',
    () async {
      await alarmRepository.upsert(
        testAlarm().copyWith(
          missionType: MissionType.randomHunt,
          extraMissions: [MissionType.math, MissionType.shake],
        ),
      );
      final notifier = container.read(ringingSessionProvider.notifier);
      await notifier.begin('ring-test');
      expect(
        container.read(ringingSessionProvider)!.currentMission,
        MissionType.randomHunt,
      );

      expect(notifier.advanceMission(), MissionType.math);
      // Abandoning a mission resumes ringing; begin() again is a no-op for
      // the same alarm, so the passed step stays passed.
      await notifier.resumeRinging();
      await notifier.begin('ring-test');
      expect(
        container.read(ringingSessionProvider)!.currentMission,
        MissionType.math,
      );

      expect(notifier.advanceMission(), MissionType.shake);
      expect(notifier.advanceMission(), isNull, reason: 'chain finished');
    },
  );

  test('completing arms a Wake Up Check when the alarm has one', () async {
    await alarmRepository.upsert(
      testAlarm().copyWith(missionType: MissionType.math, wakeCheckMinutes: 5),
    );
    final notifier = container.read(ringingSessionProvider.notifier);
    await notifier.begin('ring-test');
    await notifier.complete();

    final check = scheduler.pendingWakeCheck;
    expect(check?.alarmId, 'ring-test');
    expect(
      scheduler.rescheduleCallCount,
      greaterThan(0),
      reason: 'the check is armed after the reschedule that would cancel it',
    );
  });

  test('no Wake Up Check after an emergency escape', () async {
    await alarmRepository.upsert(
      testAlarm().copyWith(missionType: MissionType.math, wakeCheckMinutes: 5),
    );
    final notifier = container.read(ringingSessionProvider.notifier);
    await notifier.begin('ring-test');
    await notifier.escape();
    expect(scheduler.pendingWakeCheck, isNull);
  });

  test('the alarm ringing again clears its pending check', () async {
    await alarmRepository.upsert(
      testAlarm().copyWith(missionType: MissionType.math, wakeCheckMinutes: 5),
    );
    final notifier = container.read(ringingSessionProvider.notifier);
    await notifier.begin('ring-test');
    await notifier.complete();
    expect(scheduler.pendingWakeCheck, isNotNull);

    // The check lapsed: its re-ring fires.
    await notifier.begin('ring-test');
    expect(scheduler.pendingWakeCheck, isNull);
  });

  test(
    'begin() for a deleted alarm returns null without starting audio',
    () async {
      final notifier = container.read(ringingSessionProvider.notifier);
      final result = await notifier.begin('does-not-exist');
      expect(result, isNull);
      expect(audioService.ringing, isFalse);
    },
  );

  test('pauseForMission ducks audio without clearing the session', () async {
    await alarmRepository.upsert(testAlarm());
    final notifier = container.read(ringingSessionProvider.notifier);

    await notifier.begin('ring-test');
    await notifier.pauseForMission();
    expect(audioService.ringing, isTrue);
    expect(audioService.ducked, isTrue);
    expect(container.read(ringingSessionProvider), isNotNull);

    await notifier.resumeRinging();
    expect(audioService.ringing, isTrue);
  });

  test(
    'a mission alarm cannot be outlasted: re-ring held off, then cancelled',
    () async {
      final alarm = Alarm(
        id: 'm1',
        hour: 6,
        minute: 0,
        missionType: MissionType.squats,
        createdAt: DateTime(2026),
      );
      await alarmRepository.upsert(alarm);
      final notifier = container.read(ringingSessionProvider.notifier);

      await notifier.begin('m1');
      expect(alarmKit.deferred, ['m1']);
      expect(scheduler.androidDeferred, ['m1']);

      await notifier.complete();
      expect(alarmKit.cancelled, ['m1']);
      expect(scheduler.androidCancelled, ['m1']);
    },
  );

  test('snoozing replaces the re-ring', () async {
    final alarm = Alarm(
      id: 'm2',
      hour: 6,
      minute: 0,
      missionType: MissionType.squats,
      createdAt: DateTime(2026),
    );
    await alarmRepository.upsert(alarm);
    final notifier = container.read(ringingSessionProvider.notifier);

    await notifier.begin('m2');
    await notifier.snooze();
    expect(alarmKit.cancelled, ['m2']);
    expect(scheduler.androidCancelled, ['m2']);
  });

  test(
    'ringing silences the fired notification so only one sound plays',
    () async {
      final alarm = Alarm(
        id: 's1',
        hour: 6,
        minute: 0,
        createdAt: DateTime(2026),
      );
      await alarmRepository.upsert(alarm);
      await container.read(ringingSessionProvider.notifier).begin('s1');
      expect(scheduler.silenced, ['s1']);
    },
  );

  test('the ringing screen takes over from the advance backups', () async {
    await alarmRepository.upsert(
      Alarm(
        id: 'b1',
        hour: 6,
        minute: 0,
        missionType: MissionType.math,
        createdAt: DateTime(2026),
      ),
    );
    await container.read(ringingSessionProvider.notifier).begin('b1');
    expect(alarmKit.backupsCancelled, ['b1']);
  });

  test(
    'leaving the app lets the re-ring come; returning holds it off again',
    () async {
      await alarmRepository.upsert(
        Alarm(
          id: 'l1',
          hour: 6,
          minute: 0,
          missionType: MissionType.squats,
          createdAt: DateTime(2026),
        ),
      );
      await container.read(ringingSessionProvider.notifier).begin('l1');
      expect(alarmKit.deferred, ['l1']);

      final binding = TestWidgetsFlutterBinding.instance;
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      // Back in the app: the hold is re-armed straight away.
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(alarmKit.deferred, ['l1', 'l1']);
    },
  );
}
