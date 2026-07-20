import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/features/onboarding/presentation/pages/onboarding_steps.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('welcome step shows value prop and CTA advances',
      (tester) async {
    var advanced = false;
    await tester.pumpWidget(
      testApp(child: WelcomeStep(onNext: () => advanced = true)),
    );

    expect(find.text('Wake up. For real this time.'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    expect(advanced, isTrue);
  });

  testWidgets('snooze habit step requires an answer before continuing',
      (tester) async {
    var advanced = false;
    await tester.pumpWidget(
      testApp(child: SnoozeHabitStep(onNext: () => advanced = true)),
    );

    // CTA disabled with no selection.
    await tester.tap(find.text('Continue'));
    expect(advanced, isFalse);

    await tester.tap(find.text('Every single morning'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    expect(advanced, isTrue);
  });

  testWidgets('struggles step supports multi-select', (tester) async {
    var advanced = false;
    await tester.pumpWidget(
      testApp(child: StrugglesStep(onNext: () => advanced = true)),
    );

    await tester.tap(find.text('I stay in bed scrolling'));
    await tester.pump();
    await tester.tap(find.text('I fall back asleep'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    expect(advanced, isTrue);
  });
}
