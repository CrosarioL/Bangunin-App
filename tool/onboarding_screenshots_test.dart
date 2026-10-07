// Renders each onboarding screen to PNG for review (not part of the suite).
//   flutter test tool/onboarding_screenshots_test.dart --dart-define=OUT=/path
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/app/theme/app_theme.dart';
import 'package:wakio/app/widgets/app_background.dart';
import 'package:wakio/app/widgets/bangunin_mascot.dart';
import 'package:wakio/core/services/audio/alarm_audio_service.dart';
import 'package:wakio/features/onboarding/presentation/pages/onboarding_steps.dart';
import 'package:wakio/features/onboarding/presentation/pages/onboarding_story_steps.dart';
import 'package:wakio/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:wakio/l10n/gen/app_localizations.dart';

const _out = String.fromEnvironment('OUT');

class _Seeded extends OnboardingAnswersNotifier {
  @override
  OnboardingAnswers build() => const OnboardingAnswers(
    name: 'Rina',
    snooze: SnoozeHabit.some,
    reason: WakeReason.work,
    wakeGoalHour: 6,
    wakeGoalMinute: 30,
  );
}

class _SilentAudio implements AlarmAudioService {
  @override
  Future<void> stopPreview() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> _loadFonts() async {
  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ??
      '${Platform.environment['HOME']}/development/flutter';
  for (final (family, path) in [
    ('Baloo2', 'assets/fonts/Baloo2.ttf'),
    ('Nunito', 'assets/fonts/Nunito.ttf'),
    (
      'MaterialIcons',
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ),
    (
      'CupertinoSystemText',
      '$flutterRoot/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
    ),
    (
      'CupertinoSystemDisplay',
      '$flutterRoot/bin/cache/artifacts/material_fonts/Roboto-Medium.ttf',
    ),
  ]) {
    final bytes = File(path).readAsBytesSync();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}

void main() {
  final shots = <(String, Widget Function(), Duration)>[
    ('01_hook', () => WelcomeStep(onNext: () {}), const Duration(seconds: 2)),
    (
      '02_problem',
      () => Builder(
        builder: (c) => StoryStep(
          pose: MascotPose.sleeping,
          title: AppLocalizations.of(c).obProblemTitle,
          body: AppLocalizations.of(c).obProblemBody,
          onNext: () {},
        ),
      ),
      const Duration(seconds: 2),
    ),
    (
      '03_promise',
      () => Builder(
        builder: (c) => StoryStep(
          pose: MascotPose.crowing,
          title: AppLocalizations.of(c).obPromiseTitle,
          body: AppLocalizations.of(c).obPromiseBody,
          onNext: () {},
        ),
      ),
      const Duration(seconds: 2),
    ),
    (
      '04a_demo_ringing',
      () => DemoStep(onNext: () {}),
      const Duration(milliseconds: 1500),
    ),
    (
      '04b_demo_photo_scan',
      () => DemoStep(onNext: () {}),
      const Duration(milliseconds: 4200),
    ),
    (
      '04c_demo_photo_verified',
      () => DemoStep(onNext: () {}),
      const Duration(milliseconds: 6000),
    ),
    (
      '04d_demo_done',
      () => DemoStep(onNext: () {}),
      const Duration(milliseconds: 8000),
    ),
    ('05_name', () => NameStep(onNext: () {}), const Duration(seconds: 1)),
    ('06_age', () => AgeStep(onNext: () {}), const Duration(seconds: 1)),
    ('07_snooze', () => SnoozeStep(onNext: () {}), const Duration(seconds: 1)),
    ('08_cost', () => CostStep(onNext: () {}), const Duration(seconds: 2)),
    ('09_lose', () => LoseStep(onNext: () {}), const Duration(seconds: 2)),
    (
      '10_fix',
      () => Builder(
        builder: (c) => StoryStep(
          pose: MascotPose.happy,
          title: AppLocalizations.of(c).obFixTitle,
          body: AppLocalizations.of(c).obFixBody,
          onNext: () {},
        ),
      ),
      const Duration(seconds: 2),
    ),
    ('11_goal', () => GoalStep(onNext: () {}), const Duration(seconds: 1)),
    (
      '12_wake_time',
      () => WakeGoalStep(onNext: () {}),
      const Duration(seconds: 1),
    ),
    ('13_sound', () => SoundStep(onNext: () {}), const Duration(seconds: 1)),
    (
      '14_mission',
      () => MissionStep(onNext: () {}),
      const Duration(seconds: 1),
    ),
    (
      '15_heard_from',
      () => HeardFromStep(onNext: () {}),
      const Duration(seconds: 1),
    ),
    ('16_proof', () => ProofStep(onNext: () {}), const Duration(seconds: 2)),
    ('17_plan', () => PlanStep(onNext: () {}), const Duration(seconds: 2)),
    (
      '18_permissions',
      () => NotificationStep(onNext: () {}),
      const Duration(seconds: 1),
    ),
    (
      '19_ready',
      () => ReadyStep(onNext: () {}, now: DateTime(2026, 10, 6, 21)),
      const Duration(seconds: 1),
    ),
    (
      '20_trial_reminder',
      () => TrialReminderStep(trialDays: 3, onNext: () {}),
      const Duration(seconds: 2),
    ),
  ];

  for (final (name, build, wait) in shots) {
    testWidgets(name, (tester) async {
      await _loadFonts();
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 141, bottom: 102);
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingAnswersProvider.overrideWith(_Seeded.new),
            alarmAudioServiceProvider.overrideWithValue(_SilentAudio()),
          ],
          child: RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark,
              locale: const Locale('id'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => AppBackground(child: child!),
              home: Scaffold(body: SafeArea(child: build())),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        for (final pose in MascotPose.values) {
          await precacheImage(AssetImage(pose.assetPath), key.currentContext!);
        }
      });
      var elapsed = Duration.zero;
      const step = Duration(milliseconds: 50);
      while (elapsed < wait) {
        await tester.pump(step);
        elapsed += step;
      }
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_out/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
      });
    });
  }
}
