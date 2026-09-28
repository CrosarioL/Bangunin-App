import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/app/theme/app_theme.dart';
import 'package:wakio/core/services/analytics/analytics_service.dart';
import 'package:wakio/features/alarms/data/alarm_scheduler.dart';
import 'package:wakio/features/alarms/data/wake_check_store.dart';
import 'package:wakio/features/ringing/presentation/pages/wake_check_page.dart';
import 'package:wakio/l10n/gen/app_localizations.dart';

class _FakeScheduler implements AlarmScheduler {
  _FakeScheduler(this.pendingWakeCheck);

  @override
  PendingWakeCheck? pendingWakeCheck;
  int cancels = 0;

  @override
  Future<void> cancelWakeCheck() async {
    cancels++;
    pendingWakeCheck = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SilentAnalytics implements AnalyticsService {
  @override
  Future<void> logEvent(
    String name, [
    Map<String, Object?> params = const {},
  ]) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final checkAt = DateTime(2026, 9, 29, 6, 35);
  final check = PendingWakeCheck(
    alarmId: 'a',
    checkAt: checkAt,
    ringAt: checkAt.add(PendingWakeCheck.answerWindow),
  );

  Future<_FakeScheduler> pump(
    WidgetTester tester, {
    required DateTime Function() now,
    PendingWakeCheck? pending,
  }) async {
    final scheduler = _FakeScheduler(pending);
    final router = GoRouter(
      initialLocation: '/wake-check/a',
      routes: [
        GoRoute(
          path: '/wake-check/:id',
          builder: (_, state) =>
              WakeCheckPage(alarmId: state.pathParameters['id']!, now: now),
        ),
        GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
        GoRoute(path: '/ringing/:id', builder: (_, _) => const Text('RINGING')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alarmSchedulerProvider.overrideWithValue(scheduler),
          analyticsProvider.overrideWithValue(_SilentAnalytics()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pump();
    return scheduler;
  }

  testWidgets('confirming cancels the re-ring and goes home', (tester) async {
    final scheduler = await pump(
      tester,
      now: () => checkAt.add(const Duration(seconds: 10)),
      pending: check,
    );
    expect(find.text('Still awake?'), findsOneWidget);
    expect(find.text('50s'), findsOneWidget);

    await tester.tap(find.text("I'm awake"));
    await tester.pumpAndSettle();
    expect(scheduler.cancels, 1);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('running out of time hands over to the ringing screen', (
    tester,
  ) async {
    var now = checkAt.add(const Duration(seconds: 58));
    final scheduler = await pump(tester, now: () => now, pending: check);
    expect(find.text('RINGING'), findsNothing);

    now = check.ringAt;
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('RINGING'), findsOneWidget);
    expect(scheduler.cancels, 0, reason: 'the re-ring must still happen');
  });

  testWidgets('an already-answered check just goes home', (tester) async {
    await pump(tester, now: () => checkAt);
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
