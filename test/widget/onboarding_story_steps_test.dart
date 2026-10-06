import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/theme/app_theme.dart';
import 'package:wakio/features/onboarding/presentation/pages/onboarding_story_steps.dart';
import 'package:wakio/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:wakio/l10n/gen/app_localizations.dart';

import '../helpers/test_app.dart';

class _Seeded extends OnboardingAnswersNotifier {
  _Seeded(this._initial);

  final OnboardingAnswers _initial;

  @override
  OnboardingAnswers build() => _initial;
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget child, {
  OnboardingAnswers answers = const OnboardingAnswers(),
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [onboardingAnswersProvider.overrideWith(() => _Seeded(answers))],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: testApp(child: child),
    ),
  );
  await tester.pump(const Duration(seconds: 2));
  return container;
}

void main() {
  testWidgets('the product demo plays a whole morning, then loops', (
    tester,
  ) async {
    // Motion on (testApp turns it off): the demo is the animation.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Center(child: ProductDemo())),
      ),
    );
    expect(find.text('The alarm rings'), findsOneWidget);
    expect(find.text('Start mission'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Finish the mission to stop it'), findsOneWidget);
    expect(find.textContaining('= ?'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("You're up. Alarm off."), findsOneWidget);
    expect(find.text('Good morning!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('The alarm rings'), findsOneWidget, reason: 'it loops');
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping an answer saves it and moves on by itself', (
    tester,
  ) async {
    var advanced = 0;
    final container = await _pump(tester, SnoozeStep(onNext: () => advanced++));

    await tester.tap(find.text('3–5 times'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(onboardingAnswersProvider).snooze, SnoozeHabit.some);
    expect(advanced, 1);
  });

  testWidgets('the cost is worked out from the snooze answer, with the name', (
    tester,
  ) async {
    await _pump(
      tester,
      CostStep(onNext: () {}),
      answers: const OnboardingAnswers(name: 'Rina', snooze: SnoozeHabit.some),
    );
    // 4 snoozes × 9 min × 365 days = 219 hours ≈ 9 days.
    expect(SnoozeHabit.some.hoursPerYear, 219);
    expect(
      find.text('Rina, snoozing costs you 219 hours a year.'),
      findsOneWidget,
    );
    expect(find.textContaining('9 whole days'), findsOneWidget);
  });

  testWidgets('the name is trimmed and saved', (tester) async {
    var advanced = false;
    final container = await _pump(
      tester,
      NameStep(onNext: () => advanced = true),
    );
    await tester.enterText(find.byType(TextField), '  Budi ');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(container.read(onboardingAnswersProvider).name, 'Budi');
    expect(advanced, isTrue);
  });

  testWidgets('the plan is personalised with name, goal and wake time', (
    tester,
  ) async {
    await _pump(
      tester,
      PlanStep(onNext: () {}),
      answers: const OnboardingAnswers(
        name: 'Rina',
        reason: WakeReason.sahur,
        wakeGoalHour: 4,
        wakeGoalMinute: 15,
      ),
    );
    expect(find.text("Rina's 7-day wake-up plan"), findsOneWidget);
    expect(find.text('For: Sahur and Subuh'), findsOneWidget);
    expect(find.textContaining('4:15'), findsOneWidget);
  });

  testWidgets('social proof states facts, not testimonials or a trial', (
    tester,
  ) async {
    await _pump(tester, ProofStep(onNext: () {}));
    expect(find.textContaining('alarm sounds'), findsOneWidget);
    expect(find.textContaining('★'), findsNothing);
    expect(
      find.textContaining(RegExp('free|trial', caseSensitive: false)),
      findsNothing,
    );
  });
}
