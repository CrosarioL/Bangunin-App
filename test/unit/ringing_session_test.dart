import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/alarms/alarm_kit_service.dart';
import 'package:wakio/core/services/audio/alarm_audio_service.dart';
import 'package:wakio/core/storage/local_store.dart';
import 'package:wakio/features/alarms/data/alarm_repository_impl.dart';
import 'package:wakio/features/alarms/data/alarm_scheduler.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/alarms/domain/repositories/alarm_repository.dart';
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
}

void main() {
  late Directory tempDir;
  late ProviderContainer container;
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

    container = ProviderContainer(
      overrides: [
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
}
