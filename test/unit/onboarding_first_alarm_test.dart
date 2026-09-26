import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/notifications/notification_service.dart';
import 'package:wakio/core/storage/local_store.dart';
import 'package:wakio/features/alarms/data/alarm_repository_impl.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/alarms/domain/repositories/alarm_repository.dart';
import 'package:wakio/features/alarms/presentation/providers/alarms_provider.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';
import 'package:wakio/features/onboarding/presentation/providers/onboarding_provider.dart';

/// Records schedule() calls instead of touching the real
/// flutter_local_notifications platform channel.
class _FakeNotificationService implements NotificationService {
  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  String? launchPayload;

  @override
  Stream<String> get selectedPayloads => const Stream.empty();
}

void main() {
  // AlarmScheduler localizes notification copy via WidgetsBinding.instance
  // (see core/utils/current_locale.dart); in the real app this is always
  // safe because bootstrap() calls ensureInitialized() before anything else
  // runs, but a plain `test()` needs it set up explicitly.
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ProviderContainer container;
  late AlarmRepository alarmRepository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wakio_onboarding_test');
    Hive.init(tempDir.path);
    final store = await LocalStore.open();
    alarmRepository = HiveAlarmRepository(store);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        alarmRepositoryProvider.overrideWithValue(alarmRepository),
        notificationServiceProvider.overrideWithValue(
          _FakeNotificationService(),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('creates a weekday alarm at the chosen wake-goal time', () async {
    const answers = OnboardingAnswers(wakeGoalHour: 6, wakeGoalMinute: 45);
    await container.read(alarmActionsProvider).createFromOnboarding(answers);

    final alarms = await alarmRepository.getAll();
    expect(alarms, hasLength(1));
    expect(alarms.single.hour, 6);
    expect(alarms.single.minute, 45);
    expect(alarms.single.repeatDays, {
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    });
  });

  test('"stay in bed" struggle suggests a movement mission', () async {
    const answers = OnboardingAnswers(struggles: {'stay_in_bed'});
    await container.read(alarmActionsProvider).createFromOnboarding(answers);

    final alarms = await alarmRepository.getAll();
    expect(alarms.single.missionType, MissionType.squats);
    expect(alarms.single.missionReps, greaterThan(0));
  });

  test('"dismiss half asleep" struggle suggests a photo mission', () async {
    const answers = OnboardingAnswers(struggles: {'dismiss_half_asleep'});
    await container.read(alarmActionsProvider).createFromOnboarding(answers);

    final alarms = await alarmRepository.getAll();
    expect(alarms.single.missionType, MissionType.skyPhoto);
  });

  test(
    'no clear struggle signal leaves the first alarm mission-free',
    () async {
      const answers = OnboardingAnswers();
      await container.read(alarmActionsProvider).createFromOnboarding(answers);

      final alarms = await alarmRepository.getAll();
      expect(alarms.single.missionType, MissionType.none);
    },
  );

  test('does not create a second alarm if one already exists', () async {
    await alarmRepository.upsert(
      Alarm(id: 'existing', hour: 9, minute: 0, createdAt: DateTime(2026)),
    );

    await container
        .read(alarmActionsProvider)
        .createFromOnboarding(const OnboardingAnswers());

    final alarms = await alarmRepository.getAll();
    expect(alarms, hasLength(1));
    expect(alarms.single.id, 'existing');
  });
}
