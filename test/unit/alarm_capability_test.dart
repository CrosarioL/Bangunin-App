import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/alarms/alarm_kit_service.dart';
import 'package:wakio/features/alarms/presentation/providers/alarm_capability_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app.bangunin/alarmkit');

  void installNative({required bool supported, required String authorization}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          return switch (call.method) {
            'isSupported' => supported,
            'authorizationState' => authorization,
            'requestAuthorization' => authorization,
            _ => null,
          };
        });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<AlarmCapability> capability() async {
    final container = ProviderContainer(
      overrides: [
        alarmKitServiceProvider.overrideWithValue(
          AlarmKitService(channel: channel),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(alarmCapabilityProvider.future);
  }

  group('capability reflects what the device can really do', () {
    test('authorized reports full strength and offers no action', () async {
      installNative(supported: true, authorization: 'authorized');

      final result = await capability();

      expect(result.isFullStrength, isTrue);
      expect(result.engine, AlarmEngine.alarmKit);
      expect(result.canUpgrade, isFalse);
      expect(result.wasDeclined, isFalse);
    });

    test('not-yet-asked is the only state that invites a prompt', () async {
      installNative(supported: true, authorization: 'notDetermined');

      final result = await capability();

      expect(result.isFullStrength, isFalse);
      expect(
        result.canUpgrade,
        isTrue,
        reason: 'this is the one state where asking is honest',
      );
      expect(result.wasDeclined, isFalse);
    });

    test('declined never invites a repeat prompt', () async {
      installNative(supported: true, authorization: 'denied');

      final result = await capability();

      expect(result.isFullStrength, isFalse);
      expect(
        result.canUpgrade,
        isFalse,
        reason: 're-prompting a user who said no is nagging',
      );
      expect(result.wasDeclined, isTrue);
    });

    test('an unsupported device offers no action at all', () async {
      installNative(supported: false, authorization: 'unsupported');

      final result = await capability();

      expect(result.isUnsupported, isTrue);
      expect(result.engine, AlarmEngine.notifications);
      expect(
        result.canUpgrade,
        isFalse,
        reason: 'nothing the user can do below iOS 26',
      );
      expect(result.wasDeclined, isFalse);
    });

    test('no native bridge at all (Android) is unsupported', () async {
      final result = await capability();

      expect(result.isUnsupported, isTrue);
      expect(result.engine, AlarmEngine.notifications);
    });
  });

  group('exactly one state is full strength', () {
    test('only authorized', () async {
      for (final state in ['notDetermined', 'denied', 'unsupported']) {
        installNative(supported: true, authorization: state);
        final result = await capability();
        expect(
          result.isFullStrength,
          isFalse,
          reason: '$state must not claim real alarms',
        );
      }
    });
  });
}
