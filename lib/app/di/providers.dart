import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../core/services/alarms/alarm_kit_service.dart';
import '../../core/services/analytics/analytics_service.dart';
import '../../core/services/audio/alarm_audio_service.dart';
import '../../core/services/crash/crash_reporter.dart';
import '../../core/services/device/oem_battery_advisor.dart';
import '../../core/services/locale/locale_override_provider.dart';
import '../../core/services/notifications/notification_service.dart';
import '../../core/services/remote_config/feature_flags.dart';
import '../../core/services/subscriptions/subscription_service.dart';
import '../../core/storage/local_store.dart';
import '../../features/alarms/data/alarm_repository_impl.dart';
import '../../features/alarms/data/alarm_scheduler.dart';
import '../../features/alarms/domain/repositories/alarm_repository.dart';
import '../../features/missions/data/photo_mission_verifier.dart';
import '../../features/missions/data/scene_classifier.dart';
import '../../features/stats/data/wake_stats_repository_impl.dart';
import '../../features/stats/domain/repositories/wake_stats_repository.dart';

/// Composition root. Async singletons ([LocalStore], [SharedPreferences],
/// [NotificationService]) are created in bootstrap() and injected via
/// overrides; everything else is wired here.

final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('Overridden in bootstrap'),
);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in bootstrap'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('Overridden in bootstrap'),
);

final analyticsProvider = Provider<AnalyticsService>(
  (ref) => const DebugAnalyticsService(),
);

final crashReporterProvider = Provider<CrashReporter>(
  (ref) => const DebugCrashReporter(),
);

final featureFlagsProvider = Provider<FeatureFlags>(
  (ref) => const LocalFeatureFlags(),
);

final alarmAudioServiceProvider = Provider<AlarmAudioService>((ref) {
  final service = AlarmAudioService();
  ref.onDispose(service.dispose);
  return service;
});

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final service = AppConfig.fakePaywall
      ? FakeSubscriptionService(prefs) as SubscriptionService
      : StoreSubscriptionService(prefs);
  ref.onDispose(service.dispose);
  return service;
});

final alarmRepositoryProvider = Provider<AlarmRepository>(
  (ref) => HiveAlarmRepository(ref.watch(localStoreProvider)),
);

final wakeStatsRepositoryProvider = Provider<WakeStatsRepository>(
  (ref) => HiveWakeStatsRepository(ref.watch(localStoreProvider)),
);

/// Detects vendor battery managers that kill alarms (Android only).
final oemBatteryAdvisorProvider = Provider<OemBatteryAdvisor>(
  (ref) => OemBatteryAdvisor(),
);

/// Bridge to Apple AlarmKit. Reports unsupported below iOS 26 and on Android,
/// where the scheduler falls back to notifications.
final alarmKitServiceProvider = Provider<AlarmKitService>(
  (ref) => AlarmKitService(),
);

final alarmSchedulerProvider = Provider<AlarmScheduler>(
  (ref) => AlarmScheduler(
    ref.watch(notificationServiceProvider),
    alarmKit: ref.watch(alarmKitServiceProvider),
    localeOverride: ref.watch(localeOverrideProvider),
  ),
);

/// Apple Vision scene understanding. Reports unsupported on Android and in
/// tests, where the verifier falls back to pixel heuristics alone.
final sceneClassifierProvider = Provider<SceneClassifier>(
  (ref) => SceneClassifier(),
);

final photoMissionVerifierProvider = Provider<PhotoMissionVerifier>(
  (ref) =>
      PhotoMissionVerifier(sceneClassifier: ref.watch(sceneClassifierProvider)),
);
