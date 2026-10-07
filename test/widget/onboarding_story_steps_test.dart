import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/app/theme/app_theme.dart';
import 'package:wakio/app/widgets/app_card.dart';
import 'package:wakio/app/widgets/bangunin_mascot.dart';
import 'package:wakio/app/widgets/primary_button.dart';
import 'package:wakio/core/services/audio/alarm_audio_service.dart';
import 'package:wakio/features/onboarding/presentation/pages/onboarding_steps.dart';
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

class _SilentAudio implements AlarmAudioService {
  @override
  Future<void> stopPreview() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
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
    expect(find.text('Take a photo of the sky'), findsOneWidget);
    // Shutter, then the on-device check passes.
    await tester.pump(const Duration(milliseconds: 2600));
    expect(find.text('Verified'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
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

  for (final (name, size, top, bottom) in [
    ('iPhone SE', const Size(375, 667), 20.0, 0.0),
    ('iPhone 14', const Size(390, 844), 47.0, 34.0),
  ]) {
    testWidgets('the whole demo fits above the button on $name', (
      tester,
    ) async {
      for (final (family, path) in [
        ('Baloo2', 'assets/fonts/Baloo2.ttf'),
        ('Nunito', 'assets/fonts/Nunito.ttf'),
      ]) {
        final bytes = File(path).readAsBytesSync();
        await (FontLoader(
          family,
        )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      }
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = FakeViewPadding(top: top, bottom: bottom);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        testApp(
          child: Scaffold(
            body: SafeArea(child: DemoStep(onNext: () {})),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      final demo = tester.getRect(find.byType(ProductDemo));
      final button = tester.getRect(find.text('Continue'));
      // Test motion is off, so the demo holds its mid-mission frame.
      final caption = tester.getRect(
        find.text('Finish the mission to stop it'),
      );
      expect(demo.top, greaterThanOrEqualTo(0));
      expect(caption.bottom, lessThan(button.top));
      expect(demo.bottom, lessThanOrEqualTo(size.height - bottom));
    });
  }

  group('every story screen fits above its button', () {
    final screens = <String, Widget Function()>{
      'hook': () => WelcomeStep(onNext: () {}),
      'problem': () => StoryStep(
        pose: MascotPose.sleeping,
        title: 'You turn your alarm off in your sleep.',
        body:
            "Snooze, snooze, and you're late again. It isn't laziness: a "
            'half-asleep thumb always wins.',
        onNext: () {},
      ),
      'name': () => NameStep(onNext: () {}),
      'snooze': () => SnoozeStep(onNext: () {}),
      'cost': () => CostStep(onNext: () {}),
      'lose': () => LoseStep(onNext: () {}),
      'goal': () => GoalStep(onNext: () {}),
      'heard from': () => HeardFromStep(onNext: () {}),
      'proof': () => ProofStep(onNext: () {}),
      'plan': () => PlanStep(onNext: () {}),
      'wake time': () => WakeGoalStep(onNext: () {}),
      'sound': () => SoundStep(onNext: () {}),
      'mission': () => MissionStep(onNext: () {}),
      'permissions': () => NotificationStep(onNext: () {}),
      'ready': () => ReadyStep(onNext: () {}, now: DateTime(2026, 10, 6, 21)),
    };
    for (final (device, size, top, bottom) in [
      ('iPhone SE', const Size(375, 667), 20.0, 0.0),
      ('iPhone 14', const Size(390, 844), 47.0, 34.0),
    ]) {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} on $device', (tester) async {
          for (final (family, path) in [
            ('Baloo2', 'assets/fonts/Baloo2.ttf'),
            ('Nunito', 'assets/fonts/Nunito.ttf'),
          ]) {
            final bytes = File(path).readAsBytesSync();
            await (FontLoader(
              family,
            )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
          }
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.view.padding = FakeViewPadding(top: top, bottom: bottom);
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                alarmAudioServiceProvider.overrideWithValue(_SilentAudio()),
                onboardingAnswersProvider.overrideWith(
                  () => _Seeded(
                    const OnboardingAnswers(
                      name: 'Rina',
                      snooze: SnoozeHabit.some,
                      reason: WakeReason.work,
                    ),
                  ),
                ),
              ],
              child: testApp(
                child: Scaffold(body: SafeArea(child: entry.value())),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 2));

          expect(tester.takeException(), isNull, reason: 'no overflow');
          final button = tester.getRect(find.byType(PrimaryButton));
          expect(button.bottom, lessThanOrEqualTo(size.height - bottom));
          // Whatever is shown above the button ends before it starts (or
          // scrolls, but never sits underneath it).
          final scroll = find.byType(SingleChildScrollView);
          if (scroll.evaluate().isNotEmpty) {
            expect(
              tester.getRect(scroll.first).bottom,
              lessThanOrEqualTo(button.top),
            );
          }
          // Cards hug their content instead of filling the screen.
          final cards = find.byType(AppCard);
          if (const {
                'problem',
                'snooze',
                'cost',
                'lose',
                'goal',
                'heard from',
                'proof',
                'plan',
              }.contains(entry.key) &&
              cards.evaluate().isNotEmpty) {
            final card = tester.getSize(cards.first).height;
            final column = tester
                .getSize(
                  find
                      .descendant(
                        of: cards.first,
                        matching: find.byType(Column),
                      )
                      .first,
                )
                .height;
            expect(
              card,
              lessThan(column + 60),
              reason: 'card height follows its content',
            );
          }
          // Everything fits on screen without scrolling.
          for (final state in tester.stateList<ScrollableState>(
            find.byType(Scrollable),
          )) {
            if (state.position.axis != Axis.vertical) continue;
            expect(
              state.position.maxScrollExtent,
              lessThan(1),
              reason: '${entry.key} must fit on $device without scrolling',
            );
          }
          if (entry.key == 'name') {
            expect(
              tester.getSize(find.byType(AppCard)).height,
              lessThan(120),
              reason: 'the name box is a field, not the whole screen',
            );
          }
        });
      }
    }
  });
}
