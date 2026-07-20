import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wakio/app/app.dart';
import 'package:wakio/bootstrap.dart';

/// End-to-end smoke test on a real device/emulator:
/// boots the app and walks the full 14-step onboarding flow to the paywall.
///
/// Run with: `flutter test integration_test/app_test.dart -d <device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boots to onboarding and reaches the paywall', (tester) async {
    final overrides = await bootstrap();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const BanguninApp()),
    );
    // Plain pump, not pumpAndSettle: the welcome screen's mascot idles on a
    // repeating animation that never settles.
    await tester.pump(const Duration(seconds: 2));

    // Step 1 — Welcome.
    expect(find.text('Wake up. For real this time.'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Step 2 — Name (CTA gated on non-empty text).
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 3 — Age (5 options).
    await tester.tap(find.text('25–34'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 4 — Snooze habit survey.
    await tester.tap(find.text('Every single morning'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 5 — Bedtime (Cupertino picker, default value is fine).
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 6 — Wake goal time picker.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 7 — Pain stat (animated count-up, then continue).
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 8 — Struggles multi-select.
    await tester.tap(find.text('I fall back asleep'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 9 — Motivations multi-select (gated).
    await tester.tap(find.text('Move my body'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 10 — Commitment.
    await tester.tap(find.text("I'm ready to wake up better"));
    await tester.pumpAndSettle();

    // Step 11 — Social proof (also fires a guarded in_app_review request).
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 12 — Notification prime (system dialog handled by the OS harness).
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Step 13 — Personalizing loader auto-advances to completion.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 14 — Plan reveal.
    await tester.tap(find.text('See my plan'));
    await tester.pumpAndSettle();

    // Redirected to the paywall — personalized headline uses the entered name.
    expect(find.text('Alex, never oversleep again'), findsOneWidget);
  });
}
