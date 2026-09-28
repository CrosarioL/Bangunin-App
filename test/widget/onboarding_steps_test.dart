import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/audio/alarm_audio_service.dart';
import 'package:wakio/features/alarms/domain/alarm_clip.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';
import 'package:wakio/features/onboarding/presentation/pages/onboarding_steps.dart';
import 'package:wakio/features/onboarding/presentation/providers/onboarding_provider.dart';

import '../helpers/test_app.dart';

/// Starts from fixed answers instead of the defaults.
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('sound step starts new users on the first meme', (tester) async {
    final container = ProviderContainer(
      overrides: [alarmAudioServiceProvider.overrideWithValue(_SilentAudio())],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testApp(child: SoundStep(onNext: () {})),
      ),
    );
    await tester.pump();
    expect(
      container.read(onboardingAnswersProvider).clipId,
      AlarmClips.onboarding.first.id,
    );
  });

  testWidgets('welcome step shows the hook and CTA advances', (tester) async {
    var advanced = false;
    await tester.pumpWidget(
      testApp(child: WelcomeStep(onNext: () => advanced = true)),
    );

    expect(
      find.text('Normal alarms are easy to turn off in your sleep.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Get started'));
    expect(advanced, isTrue);
  });

  testWidgets('mission step starts on Random Hunt; swiping changes the pick', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testApp(child: MissionStep(onNext: () {})),
      ),
    );

    expect(find.text('Most fun'), findsOneWidget);
    expect(
      container.read(onboardingAnswersProvider).mission,
      MissionType.randomHunt,
    );

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(container.read(onboardingAnswersProvider).mission, MissionType.math);
  });

  Future<void> pumpReady(
    WidgetTester tester,
    OnboardingAnswers answers,
    DateTime now,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingAnswersProvider.overrideWith(() => _Seeded(answers)),
        ],
        child: testApp(
          child: ReadyStep(onNext: () {}, now: now),
        ),
      ),
    );
  }

  testWidgets('ready step says "Tomorrow" on a weeknight', (tester) async {
    // Wednesday evening → Thursday morning.
    await pumpReady(
      tester,
      const OnboardingAnswers(wakeGoalHour: 6, wakeGoalMinute: 30),
      DateTime(2026, 9, 30, 21),
    );
    expect(find.textContaining('Tomorrow at'), findsOneWidget);
    expect(find.textContaining('find a random object'), findsOneWidget);
  });

  testWidgets('ready step names Monday when set on a Friday night', (
    tester,
  ) async {
    await pumpReady(
      tester,
      const OnboardingAnswers(mission: MissionType.none),
      DateTime(2026, 10, 2, 22),
    );
    expect(find.textContaining('Monday at'), findsOneWidget);
    expect(find.textContaining('One tap turns it off'), findsOneWidget);
  });
}
