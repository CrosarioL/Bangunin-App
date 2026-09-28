import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/widgets/primary_button.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';
import 'package:wakio/features/missions/presentation/pages/phone_task_mission_page.dart';
import 'package:wakio/features/ringing/domain/emergency_escape.dart';
import 'package:wakio/features/ringing/presentation/widgets/emergency_escape_sheet.dart';

import '../helpers/test_app.dart';

void main() {
  /// Reads the on-screen sum ("7 × 8 + 13 = ?") and returns its answer.
  int currentAnswer(WidgetTester tester) {
    final prompt = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((s) => s.endsWith('= ?'));
    final m = RegExp(r'(\d+) × (\d+) \+ (\d+)').firstMatch(prompt)!;
    return int.parse(m[1]!) * int.parse(m[2]!) + int.parse(m[3]!);
  }

  Future<void> enter(WidgetTester tester, int value) async {
    for (final digit in '$value'.split('')) {
      await tester.tap(find.widgetWithText(FilledButton, digit));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(FilledButton, '✓'));
    await tester.pump();
  }

  testWidgets('math: a wrong answer swaps the sum, right answers finish', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    bool? result;
    await tester.pumpWidget(
      testApp(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const PhoneTaskMissionPage(
                    previewMission: MissionType.math,
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Problem 1 of 3'), findsOneWidget);
    await enter(tester, currentAnswer(tester) + 1);
    expect(find.text('Not quite. Try this one.'), findsOneWidget);
    expect(find.text('Problem 1 of 3'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await enter(tester, currentAnswer(tester));
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(result, isTrue);
  });

  testWidgets('escape: needs every tap and the typed pledge', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    bool? escaped;
    await tester.pumpWidget(
      testApp(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async => escaped = await showEmergencyEscapeSheet(
              context,
              usedThisMonth: 0,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    for (var i = 0; i < EmergencyEscape.requiredTaps; i++) {
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
    }
    expect(find.byType(TextField), findsOneWidget);

    final confirm = find.widgetWithText(PrimaryButton, 'Turn off alarm');
    Future<bool> confirmEnabled() async =>
        tester.widget<PrimaryButton>(confirm).onPressed != null;

    await tester.enterText(find.byType(TextField), 'I am using the exit');
    await tester.pump();
    expect(await confirmEnabled(), isFalse);

    await tester.enterText(
      find.byType(TextField),
      EmergencyEscape.pledge('en', usedThisMonth: 0),
    );
    await tester.pump();
    expect(await confirmEnabled(), isTrue);

    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(escaped, isTrue);
  });
}
