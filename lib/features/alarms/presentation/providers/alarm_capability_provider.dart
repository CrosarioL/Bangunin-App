import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/services/alarms/alarm_kit_service.dart';

/// What Bangunin can actually promise about ringing on this device.
///
/// This exists so the UI can tell the truth. The two engines have genuinely
/// different capabilities, and the brief is explicit that we must never imply
/// the notification fallback can override Silent Mode or Focus, force-launch
/// the app, or guarantee delivery.
class AlarmCapability {
  const AlarmCapability({required this.engine, required this.authorization});

  final AlarmEngine engine;
  final AlarmKitAuthorization authorization;

  /// Rings properly: full-screen, through the ringer.
  ///
  /// True for AlarmKit *and* for Android exact alarms — different mechanisms,
  /// comparable outcomes. Only the iOS notification fallback is weak.
  bool get isFullStrength =>
      engine == AlarmEngine.alarmKit || engine == AlarmEngine.androidExactAlarm;

  /// This device could do better if the user allowed it — the only state
  /// where showing a call to action is honest rather than nagging.
  bool get canUpgrade => authorization == AlarmKitAuthorization.notDetermined;

  /// The user said no. We explain the consequence once and offer Settings,
  /// but we do not prompt again.
  bool get wasDeclined => authorization == AlarmKitAuthorization.denied;

  /// The device simply cannot do it (below iOS 26, or Android). Nothing the
  /// user can do, so we state it plainly and offer no action.
  bool get isUnsupported => authorization == AlarmKitAuthorization.unsupported;
}

/// Current alarm capability. Invalidate after requesting authorization.
final alarmCapabilityProvider = FutureProvider<AlarmCapability>((ref) async {
  final alarmKit = ref.watch(alarmKitServiceProvider);

  // Android needs no AlarmKit authorization and is already full strength.
  if (defaultTargetPlatform == TargetPlatform.android) {
    return const AlarmCapability(
      engine: AlarmEngine.androidExactAlarm,
      authorization: AlarmKitAuthorization.unsupported,
    );
  }

  if (!await alarmKit.isSupported()) {
    return const AlarmCapability(
      engine: AlarmEngine.notifications,
      authorization: AlarmKitAuthorization.unsupported,
    );
  }

  final authorization = await alarmKit.authorizationState();
  return AlarmCapability(
    engine: authorization.canScheduleRealAlarms
        ? AlarmEngine.alarmKit
        : AlarmEngine.notifications,
    authorization: authorization,
  );
});

/// Requests AlarmKit authorization and refreshes everything that depends on
/// it — including rescheduling, since the engine may have just changed.
///
/// Only call this from a screen that has already explained why we are
/// asking. iOS gives one chance at this prompt; spending it cold is how apps
/// end up permanently on the weaker path.
final requestAlarmAuthorizationProvider =
    Provider<Future<AlarmKitAuthorization> Function()>((ref) {
      return () async {
        final result = await ref
            .read(alarmKitServiceProvider)
            .requestAuthorization();
        ref.invalidate(alarmCapabilityProvider);
        return result;
      };
    });
