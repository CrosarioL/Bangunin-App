import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/features/alarms/presentation/widgets/mission_picker_sheet.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('mission picker offers a real preview before selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        child: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  showMissionPickerSheet(context, current: MissionType.none),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await pumpForAnimations(tester);

    expect(find.text('Try mission'), findsWidgets);
    expect(find.text('Object Hunt'), findsOneWidget);
  });
}
