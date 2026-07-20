import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/alarms/presentation/widgets/alarm_card.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

import '../helpers/test_app.dart';

void main() {
  Alarm alarm({
    MissionType mission = MissionType.none,
    Set<int> repeatDays = const {},
    bool enabled = true,
    String label = '',
  }) {
    return Alarm(
      id: 'a1',
      hour: 7,
      minute: 30,
      label: label,
      repeatDays: repeatDays,
      enabled: enabled,
      missionType: mission,
      createdAt: DateTime(2026),
    );
  }

  testWidgets('shows time, repeat summary and mission chip', (tester) async {
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: AlarmCard(
            alarm: alarm(
              mission: MissionType.squats,
              repeatDays: {
                DateTime.monday,
                DateTime.tuesday,
                DateTime.wednesday,
                DateTime.thursday,
                DateTime.friday,
              },
              label: 'Gym',
            ),
            onTap: () {},
            onToggle: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('7:30 AM'), findsOneWidget);
    expect(find.textContaining('Weekdays'), findsOneWidget);
    expect(find.textContaining('Gym'), findsOneWidget);
    expect(find.text('Squats'), findsOneWidget);
  });

  testWidgets('one-off alarm without mission shows Once and no chip',
      (tester) async {
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: AlarmCard(
            alarm: alarm(),
            onTap: () {},
            onToggle: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Once'), findsOneWidget);
    expect(find.byIcon(MissionType.squats.icon), findsNothing);
  });

  testWidgets('switch reports toggle', (tester) async {
    bool? toggled;
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: AlarmCard(
            alarm: alarm(),
            onTap: () {},
            onToggle: (value) => toggled = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    expect(toggled, isFalse);
  });

  testWidgets('tapping the switch does not also open the editor',
      (tester) async {
    // Regression test: the switch and the info column used to share one
    // tappable region (the whole card wrapped in PressableScale), so a tap
    // meant only to flip the switch could race against and also fire onTap.
    var tapCount = 0;
    bool? toggled;
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: AlarmCard(
            alarm: alarm(),
            onTap: () => tapCount++,
            onToggle: (value) => toggled = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    expect(toggled, isFalse);
    expect(tapCount, 0);
  });

  testWidgets('tapping the info column opens the editor without touching the switch',
      (tester) async {
    var tapCount = 0;
    bool toggleCalled = false;
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: AlarmCard(
            alarm: alarm(),
            onTap: () => tapCount++,
            onToggle: (_) => toggleCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('7:30 AM'));
    expect(tapCount, 1);
    expect(toggleCalled, isFalse);
  });
}
