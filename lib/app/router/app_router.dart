import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alarms/presentation/pages/alarm_editor_page.dart';
import '../../features/alarms/presentation/pages/home_page.dart';
import '../../features/missions/presentation/pages/movement_mission_page.dart';
import '../../features/missions/presentation/pages/object_registration_page.dart';
import '../../features/missions/presentation/pages/photo_mission_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_flow_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/paywall/presentation/pages/paywall_page.dart';
import '../../features/paywall/presentation/providers/premium_provider.dart';
import '../../features/ringing/presentation/pages/ringing_page.dart';
import '../../features/ringing/presentation/pages/wake_success_page.dart';
import '../../features/ringing/presentation/providers/ringing_provider.dart';
import '../../features/settings/presentation/pages/founder_story_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../di/providers.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ValueNotifier<bool>(
    ref.read(onboardingCompletedProvider),
  );
  final premium = ValueNotifier<bool>(ref.read(isPremiumProvider));
  ref
    ..listen(
      onboardingCompletedProvider,
      (_, next) => onboardingDone.value = next,
    )
    ..listen(isPremiumProvider, (_, next) => premium.value = next)
    ..onDispose(onboardingDone.dispose)
    ..onDispose(premium.dispose);

  final refresh = Listenable.merge([onboardingDone, premium]);

  final launchAlarmId = ref.read(notificationServiceProvider).launchPayload;

  final router = GoRouter(
    initialLocation:
        launchAlarmId != null ? Routes.ringing(launchAlarmId) : Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.uri.path;
      final inRingingFlow = path.startsWith('/ringing') ||
          path.startsWith('/mission') ||
          path == Routes.wakeSuccess;
      // Never gate an actively ringing alarm behind onboarding/paywall.
      if (inRingingFlow) return null;

      if (!onboardingDone.value) {
        return path == Routes.onboarding ? null : Routes.onboarding;
      }
      // Hard paywall: everything requires the subscription.
      if (!premium.value) {
        return path == Routes.paywall ? null : Routes.paywall;
      }
      if (path == Routes.onboarding || path == Routes.paywall) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingFlowPage(),
      ),
      GoRoute(
        path: Routes.paywall,
        builder: (context, state) => const PaywallPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.stats,
                builder: (context, state) => const StatsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.alarmNew,
        pageBuilder: (context, state) => const MaterialPage<void>(
          fullscreenDialog: true,
          child: AlarmEditorPage(alarmId: null),
        ),
      ),
      GoRoute(
        path: Routes.alarmEditPattern,
        pageBuilder: (context, state) => MaterialPage<void>(
          fullscreenDialog: true,
          child: AlarmEditorPage(alarmId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: Routes.ringingPattern,
        builder: (context, state) =>
            RingingPage(alarmId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.photoMissionPattern,
        builder: (context, state) =>
            PhotoMissionPage(alarmId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.movementMissionPattern,
        builder: (context, state) =>
            MovementMissionPage(alarmId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.objectRegistration,
        builder: (context, state) => const ObjectRegistrationPage(),
      ),
      GoRoute(
        path: Routes.wakeSuccess,
        builder: (context, state) => const WakeSuccessPage(),
      ),
      GoRoute(
        path: Routes.ourStory,
        builder: (context, state) => const FounderStoryPage(),
      ),
    ],
  );

  // A tapped alarm notification always takes over the screen.
  final sub = ref
      .read(notificationServiceProvider)
      .selectedPayloads
      .listen((alarmId) => router.go(Routes.ringing(alarmId)));
  // Foreground watcher: when an alarm becomes due while the app is open,
  // notifications may not fire a tap event, so we navigate ourselves.
  final ticker = ref.read(dueAlarmWatcherProvider)
    ..onDue = (alarmId) {
      final current =
          router.routerDelegate.currentConfiguration.uri.path;
      if (!current.startsWith('/ringing')) {
        router.go(Routes.ringing(alarmId));
      }
    }
    ..start();

  ref
    ..onDispose(() => unawaited(sub.cancel()))
    ..onDispose(ticker.stop)
    ..onDispose(router.dispose);

  return router;
});
