import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/subscriptions/subscription_service.dart';
import 'package:wakio/features/paywall/presentation/pages/paywall_page.dart';
import 'package:wakio/features/paywall/presentation/widgets/trial_timeline.dart';

import '../helpers/test_app.dart';

class _EmptyPlansSubscriptionService extends FakeSubscriptionService {
  _EmptyPlansSubscriptionService(super.prefs);

  @override
  Future<List<PremiumPlan>> loadPlans() async => const [];
}

class _NoTrialSubscriptionService extends FakeSubscriptionService {
  _NoTrialSubscriptionService(super.prefs);

  @override
  Future<List<PremiumPlan>> loadPlans() async => const [
    PremiumPlan(
      productId: 'bangunin.premium.yearly',
      price: r'$29.99',
      rawPrice: 29.99,
      period: 'year',
      monthlyEquivalentPrice: r'$2.49',
    ),
    PremiumPlan(
      productId: 'bangunin.premium.monthly',
      price: r'$4.99',
      rawPrice: 4.99,
      period: 'month',
    ),
  ];
}

void main() {
  // The paywall is a long scrollable page; flutter_test's default 800x600
  // surface is far shorter than any real phone (e.g. iPhone 13: 390x844),
  // which under-builds the tail of the list (SliverList only builds within
  // the viewport + cache extent). A phone-realistic surface avoids testing
  // against a viewport shape that doesn't exist on a real device.
  Future<void> useRealisticPhoneSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('plans, trial timeline and CTA fit on the first screen', (
    tester,
  ) async {
    // Real fonts: the default test font draws every glyph as a wide block,
    // which wraps text far more than on a phone and skews the measurement.
    for (final (family, path) in [
      ('Baloo2', 'assets/fonts/Baloo2.ttf'),
      ('Nunito', 'assets/fonts/Nunito.ttf'),
    ]) {
      final bytes = File(path).readAsBytesSync();
      await (FontLoader(
        family,
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    // iPhone 14 in points, with its notch and home-indicator insets.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      testApp(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subscriptionServiceProvider.overrideWithValue(
            FakeSubscriptionService(prefs),
          ),
        ],
        child: const PaywallPage(),
      ),
    );
    await tester.pumpAndSettle();

    const visibleBottom = 844.0 - 34;
    final cta = find.text('Start my 3-day free trial');
    expect(cta, findsOneWidget);
    expect(find.byType(TrialTimeline), findsOneWidget);
    expect(tester.getRect(cta).bottom, lessThan(visibleBottom));
    expect(
      tester.getRect(find.byType(TrialTimeline)).top,
      lessThan(tester.getRect(cta).top),
    );
  });

  testWidgets('paywall lists yearly and monthly plans with a trial', (
    tester,
  ) async {
    await useRealisticPhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = FakeSubscriptionService(prefs);

    await tester.pumpWidget(
      testApp(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subscriptionServiceProvider.overrideWithValue(service),
        ],
        child: const PaywallPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Never oversleep again'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('SAVE 49%'), findsOneWidget);
    expect(find.text('≈ \$2.49/month'), findsOneWidget);

    // The taller branded header pushes the second plan outside ListView's
    // initial build extent on a phone-sized viewport.
    await tester.scrollUntilVisible(
      find.text('Monthly'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Monthly'), findsOneWidget);

    // Everything from here down (CTA and restore) sits
    // below the fold even on a realistic phone surface — the page grew a
    // lot of content above it. SliverList only builds elements within the
    // viewport + cache extent, so scrollUntilVisible (which scrolls in
    // small steps and re-checks after each one) is required; a plain
    // find.text/ensureVisible on an unbuilt element throws "Bad state: No
    // element" instead of finding it.
    await tester.scrollUntilVisible(
      find.text('Start my 3-day free trial'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Start my 3-day free trial'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(TrialTimeline),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.byType(TrialTimeline), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Restore purchases'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('purchasing via trial CTA grants premium', (tester) async {
    await useRealisticPhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = FakeSubscriptionService(prefs);

    await tester.pumpWidget(
      testApp(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subscriptionServiceProvider.overrideWithValue(service),
        ],
        child: const PaywallPage(),
      ),
    );
    await tester.pumpAndSettle();

    final ctaFinder = find.text('Start my 3-day free trial');
    await tester.scrollUntilVisible(
      ctaFinder,
      100,
      scrollable: find.byType(Scrollable),
    );
    await tester.ensureVisible(ctaFinder);
    await tester.pumpAndSettle();
    await tester.tap(ctaFinder);
    await tester.pumpAndSettle();

    expect(service.isPremium.value, isTrue);
  });

  testWidgets('early access code grants a local premium entitlement', (
    tester,
  ) async {
    await useRealisticPhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = FakeSubscriptionService(prefs);

    await tester.pumpWidget(
      testApp(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subscriptionServiceProvider.overrideWithValue(service),
        ],
        child: const PaywallPage(),
      ),
    );
    await tester.pumpAndSettle();

    final accessCodeButton = find.text('Have an access code?');
    await tester.scrollUntilVisible(
      accessCodeButton,
      100,
      scrollable: find.byType(Scrollable),
    );
    await tester.drag(find.byType(Scrollable), const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(accessCodeButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'IAMTHEOWNERFREE1');
    await tester.tap(find.text('Redeem'));
    await tester.pumpAndSettle();

    expect(service.isPremium.value, isTrue);
  });

  testWidgets('access code remains available when store plans cannot load', (
    tester,
  ) async {
    await useRealisticPhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = _EmptyPlansSubscriptionService(prefs);

    await tester.pumpWidget(
      testApp(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subscriptionServiceProvider.overrideWithValue(service),
        ],
        child: const PaywallPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Have an access code?'), findsOneWidget);
    await tester.tap(find.text('Have an access code?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'iamtheownerfree2');
    await tester.tap(find.text('Redeem'));
    await tester.pumpAndSettle();

    expect(service.isPremium.value, isTrue);
  });

  testWidgets(
    'plans have no trial toggle or timeline when no store offer exists',
    (tester) async {
      await useRealisticPhoneSurface(tester);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = _NoTrialSubscriptionService(prefs);

      await tester.pumpWidget(
        testApp(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            subscriptionServiceProvider.overrideWithValue(service),
          ],
          child: const PaywallPage(),
        ),
      );
      await tester.pumpAndSettle();

      final scrollableFinder = find.byType(Scrollable);

      await tester.scrollUntilVisible(
        find.text('Continue'),
        100,
        scrollable: scrollableFinder,
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(TrialTimeline), findsNothing);
      expect(find.byType(Switch), findsNothing);

      // Switching to Monthly keeps the standard purchase CTA.
      await tester.scrollUntilVisible(
        find.text('Monthly'),
        -100,
        scrollable: scrollableFinder,
      );
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Continue'),
        100,
        scrollable: scrollableFinder,
      );
      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(TrialTimeline), findsNothing);
    },
  );

  testWidgets('personalized headline shows the saved first name', (
    tester,
  ) async {
    await useRealisticPhoneSurface(tester);
    SharedPreferences.setMockInitialValues({'user_first_name': 'Alex'});
    final prefs = await SharedPreferences.getInstance();
    final service = FakeSubscriptionService(prefs);

    await tester.pumpWidget(
      testApp(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subscriptionServiceProvider.overrideWithValue(service),
        ],
        child: const PaywallPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alex, never oversleep again'), findsOneWidget);
    expect(find.text('Never oversleep again'), findsNothing);
  });

  testWidgets('generic headline shown when no first name is saved', (
    tester,
  ) async {
    await useRealisticPhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = FakeSubscriptionService(prefs);

    await tester.pumpWidget(
      testApp(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subscriptionServiceProvider.overrideWithValue(service),
        ],
        child: const PaywallPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Never oversleep again'), findsOneWidget);
  });
}
