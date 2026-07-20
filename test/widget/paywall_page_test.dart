import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/subscriptions/subscription_service.dart';
import 'package:wakio/features/paywall/presentation/pages/paywall_page.dart';
import 'package:wakio/features/paywall/presentation/widgets/trial_timeline.dart';

import '../helpers/test_app.dart';

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

  testWidgets('paywall lists yearly and monthly plans with trial CTA',
      (tester) async {
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
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('SAVE 50%'), findsOneWidget);
    expect(find.text('≈ \$2.49/month'), findsOneWidget);

    // Everything from here down (toggle, trial timeline, CTA, restore) sits
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
    await tester.tap(ctaFinder);
    await tester.pumpAndSettle();

    expect(service.isPremium.value, isTrue);
  });

  testWidgets(
      'every plan carries a trial: no toggle, and the timeline follows '
      'whichever plan is selected', (tester) async {
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

    final scrollableFinder = find.byType(Scrollable);

    await tester.scrollUntilVisible(
      find.text('Start my 3-day free trial'),
      100,
      scrollable: scrollableFinder,
    );

    // Yearly is pre-selected: trial CTA and timeline both visible. No
    // trial-off toggle exists — every plan carries the trial now.
    expect(find.text('Start my 3-day free trial'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);

    // Switching to Monthly keeps the same trial CTA and timeline, since
    // monthly carries the trial too.
    await tester.scrollUntilVisible(
      find.text('Monthly'),
      -100,
      scrollable: scrollableFinder,
    );
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Start my 3-day free trial'),
      100,
      scrollable: scrollableFinder,
    );
    expect(find.text('Start my 3-day free trial'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('personalized headline shows the saved first name',
      (tester) async {
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

  testWidgets('generic headline shown when no first name is saved',
      (tester) async {
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
