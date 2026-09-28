import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/features/alarms/presentation/widgets/mission_picker_sheet.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

import '../helpers/test_app.dart';

void main() {
  Future<MissionType?> Function() open(
    WidgetTester tester, {
    MissionType current = MissionType.none,
  }) {
    MissionType? picked;
    var done = false;
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    return () async {
      await tester.pumpWidget(
        testApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  picked = await showMissionPickerSheet(
                    context,
                    current: current,
                  );
                  done = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await pumpForAnimations(tester);
      return done ? picked : null;
    };
  }

  testWidgets('opens on the first real mission, with a preview button', (
    tester,
  ) async {
    await open(tester)();
    expect(find.text('Find It'), findsOneWidget);
    expect(find.text('Try mission'), findsOneWidget);
    expect(find.text('Choose this mission'), findsOneWidget);
  });

  testWidgets('swiping moves one mission at a time and choose picks it', (
    tester,
  ) async {
    MissionType? picked;
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        child: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => picked = await showMissionPickerSheet(
                context,
                current: MissionType.none,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await pumpForAnimations(tester);

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await pumpForAnimations(tester);
    await tester.tap(find.text('Choose this mission'));
    await pumpForAnimations(tester);

    expect(picked, MissionType.math, reason: 'second card after Find It');
  });

  testWidgets('opens on the alarm\'s current mission, marked as current', (
    tester,
  ) async {
    await open(tester, current: MissionType.squats)();
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Squats'), findsOneWidget);
  });
}
