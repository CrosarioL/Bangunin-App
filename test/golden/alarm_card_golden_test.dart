import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/alarms/presentation/widgets/alarm_card.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('alarm card golden', (tester) async {
    final alarm = Alarm(
      id: 'golden',
      hour: 6,
      minute: 45,
      label: 'Morning run',
      repeatDays: const {
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
      },
      missionType: MissionType.skyPhoto,
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AlarmCard(
                alarm: alarm,
                onTap: () {},
                onToggle: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(AlarmCard),
      matchesGoldenFile('goldens/alarm_card.png'),
    );
  });

  testWidgets('disabled alarm card golden', (tester) async {
    final alarm = Alarm(
      id: 'golden2',
      hour: 9,
      minute: 0,
      enabled: false,
      missionType: MissionType.squats,
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AlarmCard(
                alarm: alarm,
                onTap: () {},
                onToggle: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    // Let the muted-opacity animation settle before capturing.
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AlarmCard),
      matchesGoldenFile('goldens/alarm_card_disabled.png'),
    );
  });
}
