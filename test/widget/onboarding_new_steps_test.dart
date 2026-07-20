import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/features/onboarding/presentation/pages/onboarding_narrative_steps.dart';
import 'package:wakio/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:wakio/features/onboarding/presentation/widgets/plan_chart.dart';

import '../helpers/test_app.dart';

/// A notifier that starts from a fixed [OnboardingAnswers] instead of the
/// default empty state, so steps that read pre-existing answers (like
/// PlanRevealStep reading the saved name) can be exercised in isolation.
class _SeededOnboardingAnswersNotifier extends OnboardingAnswersNotifier {
  _SeededOnboardingAnswersNotifier(this._initial);

  final OnboardingAnswers _initial;

  @override
  OnboardingAnswers build() => _initial;
}

void main() {
  Future<SharedPreferences> mockPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  // Steps assume a Material ancestor (they're normally hosted inside
  // OnboardingFlowPage's Scaffold), so wrap them the same way here.
  Widget inScaffold(Widget child) => Scaffold(body: child);

  group('NameStep', () {
    testWidgets('CTA is disabled until text is entered, then advances',
        (tester) async {
      final prefs = await mockPrefs();
      var nextCalled = false;

      await tester.pumpWidget(
        testApp(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: inScaffold(NameStep(onNext: () => nextCalled = true)),
        ),
      );
      await tester.pumpAndSettle();

      final continueButton = find.text('Continue');
      expect(continueButton, findsOneWidget);

      // Disabled: tapping does nothing.
      await tester.tap(continueButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(nextCalled, isFalse);

      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.pumpAndSettle();

      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      expect(nextCalled, isTrue);
    });
  });

  group('MotivationsStep', () {
    testWidgets('CTA is gated until a selection is made; multi-select works',
        (tester) async {
      final prefs = await mockPrefs();
      var nextCalled = false;

      await tester.pumpWidget(
        testApp(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: inScaffold(MotivationsStep(onNext: () => nextCalled = true)),
        ),
      );
      await tester.pumpAndSettle();

      final continueButton = find.text('Continue');
      await tester.tap(continueButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(nextCalled, isFalse);

      // Select two options (multi-select).
      await tester.tap(find.text('Move my body'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eat a real breakfast'));
      await tester.pumpAndSettle();

      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      expect(nextCalled, isTrue);
    });
  });

  group('PainStatStep', () {
    testWidgets('renders and shows the hours text for the default habit',
        (tester) async {
      final prefs = await mockPrefs();

      await tester.pumpWidget(
        testApp(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: inScaffold(PainStatStep(onNext: () {})),
        ),
      );
      // Let the count-up TweenAnimationBuilder finish.
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Default snoozeHabit is null -> step treats it as habit 1 (82 hours).
      expect(find.text('82 hours'), findsOneWidget);
    });
  });

  group('PlanRevealStep', () {
    testWidgets(
        'shows the personalized title and plan chart when a name is set',
        (tester) async {
      final prefs = await mockPrefs();

      await tester.pumpWidget(
        testApp(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            onboardingAnswersProvider.overrideWith(
              () => _SeededOnboardingAnswersNotifier(
                const OnboardingAnswers(name: 'Alex'),
              ),
            ),
          ],
          child: inScaffold(PlanRevealStep(onNext: () {})),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.textContaining('Alex'), findsWidgets);
      expect(find.byType(PlanChart), findsOneWidget);
      expect(find.text('See my plan'), findsOneWidget);
    });
  });
}
