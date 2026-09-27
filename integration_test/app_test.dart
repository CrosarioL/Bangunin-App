import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wakio/app/app.dart';
import 'package:wakio/bootstrap.dart';

/// End-to-end smoke test on a real device/emulator:
/// boots the app and walks the 6-step onboarding flow to the paywall.
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

    // Step 1 — Welcome hook.
    expect(
      find.text('Normal alarms are easy to turn off in your sleep.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Step 2 — Wake time (Cupertino picker, default value is fine).
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 3 — Sound; tapping one previews it.
    await tester.tap(find.text('Pulse'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 4 — Mission; Random Hunt is pre-selected and badged.
    expect(find.text('Most fun'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 5 — Notification prime (system dialog handled by the OS harness).
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Step 6 — Ready: when it rings and what stops it.
    expect(find.textContaining('find a random object'), findsOneWidget);
    await tester.tap(find.text("I'm ready"));
    await tester.pumpAndSettle();

    // Redirected to the paywall. Onboarding no longer asks for a name, so
    // the headline is the generic one.
    expect(find.text('Never oversleep again'), findsOneWidget);
  });
}
