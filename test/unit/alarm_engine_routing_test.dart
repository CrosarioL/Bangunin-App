import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/core/services/alarms/alarm_kit_service.dart';
import 'package:wakio/core/services/notifications/notification_service.dart';
import 'package:wakio/features/alarms/data/alarm_scheduler.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';

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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app.bangunin/alarmkit');
  late _RecordingNotificationService notifications;

  /// Stands in for the native side. [supported] and [authorization] decide
  /// which engine the scheduler should pick.
  List<MethodCall> installNativeStub({
    required bool supported,
    required String authorization,
  }) {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'isSupported' => supported,
            'authorizationState' => authorization,
            'requestAuthorization' => authorization,
            'scheduledIds' => <String>[],
            _ => true,
          };
        });
    return calls;
  }

  Alarm alarmAt({
    required String id,
    required int hour,
    Set<int> repeatDays = const <int>{},
  }) => Alarm(
    id: id,
    hour: hour,
    minute: 30,
    repeatDays: repeatDays,
    createdAt: DateTime(2026),
  );

  setUp(() => notifications = _RecordingNotificationService());

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  AlarmScheduler schedulerUsing(AlarmKitService alarmKit) =>
      AlarmScheduler(notifications, alarmKit: alarmKit);

  group('engine selection', () {
    test('AlarmKit is used when supported and authorized', () async {
      installNativeStub(supported: true, authorization: 'authorized');
      final scheduler = schedulerUsing(AlarmKitService(channel: channel));

      expect(await scheduler.activeEngine(), AlarmEngine.alarmKit);
    });

    test('falls back to notifications when authorization is denied', () async {
      installNativeStub(supported: true, authorization: 'denied');
      final scheduler = schedulerUsing(AlarmKitService(channel: channel));

      expect(await scheduler.activeEngine(), AlarmEngine.notifications);
    });

    test('falls back when the user has not been asked yet', () async {
      installNativeStub(supported: true, authorization: 'notDetermined');
      final scheduler = schedulerUsing(AlarmKitService(channel: channel));

      expect(await scheduler.activeEngine(), AlarmEngine.notifications);
    });

    test('falls back on a device without AlarmKit', () async {
      installNativeStub(supported: false, authorization: 'unsupported');
      final scheduler = schedulerUsing(AlarmKitService(channel: channel));

      expect(await scheduler.activeEngine(), AlarmEngine.notifications);
    });

    test('falls back when no native handler exists at all (Android)', () async {
      // No mock installed: the channel throws MissingPluginException.
      final scheduler = schedulerUsing(AlarmKitService(channel: channel));

      expect(await scheduler.activeEngine(), AlarmEngine.notifications);
    });
  });

  group('reschedule routes to exactly one engine', () {
    test(
      'AlarmKit path schedules natively and arms no notifications',
      () async {
        final calls = installNativeStub(
          supported: true,
          authorization: 'authorized',
        );
        final scheduler = schedulerUsing(AlarmKitService(channel: channel));

        await scheduler.reschedule([
          alarmAt(id: 'weekday-alarm', hour: 5, repeatDays: {1, 2, 3, 4, 5}),
        ]);

        final scheduleCalls = calls.where((c) => c.method == 'schedule');
        expect(scheduleCalls, hasLength(1));
        expect(
          notifications.scheduled,
          isEmpty,
          reason: 'a notification alongside a real alarm would ring twice',
        );

        final args = scheduleCalls.first.arguments as Map;
        expect(args['id'], 'weekday-alarm');
        expect(args['hour'], 5);
        expect(args['minute'], 30);
        expect(
          args['weekdays'],
          [1, 2, 3, 4, 5],
          reason: 'ISO weekdays, sorted, straight from repeatDays',
        );
      },
    );

    test('notification path schedules no native alarms', () async {
      final calls = installNativeStub(
        supported: false,
        authorization: 'unsupported',
      );
      final scheduler = schedulerUsing(AlarmKitService(channel: channel));

      await scheduler.reschedule([alarmAt(id: 'fallback-alarm', hour: 6)]);

      expect(calls.where((c) => c.method == 'schedule'), isEmpty);
      expect(
        notifications.scheduled,
        isNotEmpty,
        reason: 'the fallback must still arm real notifications',
      );
    });

    test('both engines are cleared before either is armed', () async {
      final calls = installNativeStub(
        supported: true,
        authorization: 'authorized',
      );
      final scheduler = schedulerUsing(AlarmKitService(channel: channel));

      await scheduler.reschedule([alarmAt(id: 'clear-test', hour: 7)]);

      expect(notifications.cancelAllCount, 1);
      expect(calls.where((c) => c.method == 'cancelAll'), hasLength(1));
    });

    test('a one-off alarm sends an empty weekday list', () async {
      final calls = installNativeStub(
        supported: true,
        authorization: 'authorized',
      );
      final scheduler = schedulerUsing(AlarmKitService(channel: channel));

      await scheduler.reschedule([alarmAt(id: 'one-off', hour: 8)]);

      final args =
          calls.firstWhere((c) => c.method == 'schedule').arguments as Map;
      expect(args['weekdays'], isEmpty);
    });
  });

  group('authorization parsing', () {
    test('maps every native string onto the right state', () {
      expect(
        AlarmKitAuthorization.parse('authorized'),
        AlarmKitAuthorization.authorized,
      );
      expect(
        AlarmKitAuthorization.parse('denied'),
        AlarmKitAuthorization.denied,
      );
      expect(
        AlarmKitAuthorization.parse('notDetermined'),
        AlarmKitAuthorization.notDetermined,
      );
      expect(
        AlarmKitAuthorization.parse('unsupported'),
        AlarmKitAuthorization.unsupported,
      );
    });

    test('an unknown or null value is treated as unsupported', () {
      expect(
        AlarmKitAuthorization.parse(null),
        AlarmKitAuthorization.unsupported,
      );
      expect(
        AlarmKitAuthorization.parse('something-new'),
        AlarmKitAuthorization.unsupported,
      );
    });

    test('only authorized permits real alarms', () {
      expect(AlarmKitAuthorization.authorized.canScheduleRealAlarms, isTrue);
      expect(AlarmKitAuthorization.denied.canScheduleRealAlarms, isFalse);
      expect(
        AlarmKitAuthorization.notDetermined.canScheduleRealAlarms,
        isFalse,
      );
      expect(AlarmKitAuthorization.unsupported.canScheduleRealAlarms, isFalse);
    });
  });

  group('limit handling', () {
    test('a rejected alarm surfaces instead of being swallowed', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'schedule') {
              throw PlatformException(
                code: 'limit_reached',
                message: 'too many alarms',
              );
            }
            return call.method == 'isSupported' ? true : 'authorized';
          });

      expect(
        () => AlarmKitService(channel: channel).schedule(
          id: 'over-limit',
          hour: 5,
          minute: 0,
          weekdays: const [],
          label: 'Bangun',
          missionType: 'none',
          secondaryButtonTitle: 'Stop',
          stopButtonTitle: 'Stop',
        ),
        throwsA(isA<AlarmLimitReachedException>()),
      );
    });
  });
}
