import 'package:flutter/foundation.dart';

/// Analytics abstraction. The shipped app is local-first with no user
/// accounts, so events carry no identity — swap in a Firebase/Amplitude
/// implementation by providing another [AnalyticsService] in DI.
abstract interface class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, Object?> params = const {}]);

  Future<void> setProperty(String name, String value);
}

/// Development implementation: prints events in debug, no-ops in release.
class DebugAnalyticsService implements AnalyticsService {
  const DebugAnalyticsService();

  @override
  Future<void> logEvent(
    String name, [
    Map<String, Object?> params = const {},
  ]) async {
    if (kDebugMode) {
      debugPrint('[analytics] $name ${params.isEmpty ? '' : params}');
    }
  }

  @override
  Future<void> setProperty(String name, String value) async {
    if (kDebugMode) {
      debugPrint('[analytics] property $name=$value');
    }
  }
}

/// Event name constants keep call sites typo-safe and greppable.
abstract final class AnalyticsEvents {
  static const onboardingStarted = 'onboarding_started';
  static const onboardingStep = 'onboarding_step';
  static const onboardingCompleted = 'onboarding_completed';
  static const paywallShown = 'paywall_shown';
  static const paywallPurchase = 'paywall_purchase';
  static const paywallDismissed = 'paywall_dismissed';
  static const alarmCreated = 'alarm_created';
  static const alarmDeleted = 'alarm_deleted';
  static const alarmRinging = 'alarm_ringing';
  static const alarmSnoozed = 'alarm_snoozed';
  static const missionStarted = 'mission_started';
  static const missionCompleted = 'mission_completed';
  static const missionFailed = 'mission_failed';
}
