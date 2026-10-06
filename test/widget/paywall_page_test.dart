import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/subscriptions/subscription_service.dart';
import 'package:wakio/features/paywall/presentation/pages/paywall_page.dart';

import '../helpers/test_app.dart';

class _EmptyPlansSubscriptionService extends FakeSubscriptionService {
  _EmptyPlansSubscriptionService(super.prefs);

  @override
  Future<List<PremiumPlan>> loadPlans() async => const [];
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

  testWidgets('plans, CTA and the renewal terms fit on the first screen', (
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
    final cta = find.text('Unlock Bangunin Premium');
    expect(cta, findsOneWidget);
    expect(tester.getRect(cta).bottom, lessThan(visibleBottom));
    // Apple 3.1.2: price, period and auto-renewal stated by the button.
    final terms = find.textContaining('Renews automatically');
    expect(terms, findsOneWidget);
    expect(tester.getRect(terms).bottom, lessThan(visibleBottom));
  });

  testWidgets('paywall lists yearly and monthly plans, no free trial', (
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
      find.text('Unlock Bangunin Premium'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Unlock Bangunin Premium'), findsOneWidget);
    // No trial anywhere: no badge, no toggle, no "free" wording.
    expect(
      find.textContaining(RegExp('free|trial', caseSensitive: false)),
      findsNothing,
    );
    expect(find.byType(Switch), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Restore purchases'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('purchasing via the CTA grants premium', (tester) async {
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

    final ctaFinder = find.text('Unlock Bangunin Premium');
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

  testWidgets('the terms follow the selected plan', (tester) async {
    await useRealisticPhoneSurface(tester);
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
    final scrollable = find.byType(Scrollable);

    expect(find.textContaining(r'$29.99 per year. Renews'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Monthly'),
      100,
      scrollable: scrollable,
    );
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining(r'$4.99 per month. Renews'),
      100,
      scrollable: scrollable,
    );
    expect(find.textContaining(r'$4.99 per month. Renews'), findsOneWidget);
  });

  testWidgets('when plans cannot load, only a retry is offered', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      testApp(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subscriptionServiceProvider.overrideWithValue(
            _EmptyPlansSubscriptionService(prefs),
          ),
        ],
        child: const PaywallPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    // Premium is unlocked only through the store (App Store 3.1.1).
    expect(find.textContaining('access code'), findsNothing);
  });

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
