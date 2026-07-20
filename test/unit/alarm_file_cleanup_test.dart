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
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory filesDir;
  late ProviderContainer container;
  late AlarmRepository alarmRepository;

  Future<File> makeFile(String name) async {
    final file = File('${filesDir.path}/$name');
    await file.writeAsBytes([1, 2, 3]);
    return file;
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wakio_cleanup_test');
    filesDir = await Directory('${tempDir.path}/files').create();
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

  test('deleting an alarm removes its reference photo and custom sound',
      () async {
    final refPhoto = await makeFile('ref.jpg');
    final customSound = await makeFile('sound.m4a');
    final alarm = Alarm(
      id: 'a1',
      hour: 7,
      minute: 0,
      missionType: MissionType.objectHunt,
      objectReferencePath: refPhoto.path,
      sound: AlarmSound.custom,
      customSoundPath: customSound.path,
      createdAt: DateTime(2026),
    );
    await alarmRepository.upsert(alarm);

    await container.read(alarmActionsProvider).delete('a1');

    expect(await refPhoto.exists(), isFalse);
    expect(await customSound.exists(), isFalse);
  });

  test('replacing a custom sound on save deletes the old file', () async {
    final oldSound = await makeFile('old.m4a');
    final newSound = await makeFile('new.m4a');
    final alarm = Alarm(
      id: 'a2',
      hour: 7,
      minute: 0,
      sound: AlarmSound.custom,
      customSoundPath: oldSound.path,
      createdAt: DateTime(2026),
    );
    await alarmRepository.upsert(alarm);

    await container.read(alarmActionsProvider).save(
          alarm.copyWith(customSoundPath: newSound.path),
          isNew: false,
        );

    expect(await oldSound.exists(), isFalse);
    expect(await newSound.exists(), isTrue);
  });

  test('re-saving with the same file path does not delete it', () async {
    final sound = await makeFile('kept.m4a');
    final alarm = Alarm(
      id: 'a3',
      hour: 7,
      minute: 0,
      sound: AlarmSound.custom,
      customSoundPath: sound.path,
      createdAt: DateTime(2026),
    );
    await alarmRepository.upsert(alarm);

    // Saved again unchanged (e.g. user only flipped the vibrate toggle).
    await container.read(alarmActionsProvider).save(
          alarm.copyWith(vibrate: false),
          isNew: false,
        );

    expect(await sound.exists(), isTrue);
  });

  test('toggling enabled does not touch any files', () async {
    final refPhoto = await makeFile('ref2.jpg');
    final alarm = Alarm(
      id: 'a4',
      hour: 7,
      minute: 0,
      missionType: MissionType.objectHunt,
      objectReferencePath: refPhoto.path,
      createdAt: DateTime(2026),
    );
    await alarmRepository.upsert(alarm);

    await container.read(alarmActionsProvider).toggle(alarm, enabled: false);

    expect(await refPhoto.exists(), isTrue);
  });
}
