import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/router/routes.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';
import 'package:wakio/features/ringing/presentation/mission_flow.dart';
import 'package:wakio/features/ringing/presentation/providers/ringing_provider.dart';

import '../helpers/test_app.dart';

class _Ringing extends RingingSessionNotifier {
  _Ringing(this._session);

  final RingingSession? _session;

  @override
  RingingSession? build() => _session;
}

RingingSession _session({int snoozes = 0}) => RingingSession(
  alarm: Alarm(
    id: 'a1',
    hour: 6,
    minute: 30,
    missionType: MissionType.math,
    createdAt: DateTime(2026),
  ),
  startedAt: DateTime(2026),
  snoozeCount: snoozes,
);

Future<void> _pump(WidgetTester tester, RingingSession? session) =>
    tester.pumpWidget(
      testApp(
        overrides: [
          ringingSessionProvider.overrideWith(() => _Ringing(session)),
        ],
        child: const Scaffold(bottomNavigationBar: MissionExitBar()),
      ),
    );

void main() {
  testWidgets('every mission offers snooze and the emergency exit', (
    tester,
  ) async {
    await _pump(tester, _session());
    expect(find.textContaining('Snooze'), findsOneWidget);
    expect(find.text("Emergency? Can't do the mission"), findsOneWidget);
  });

  testWidgets('snooze disappears once the snoozes are used up', (tester) async {
    final session = _session();
    await _pump(tester, _session(snoozes: session.alarm.maxSnoozes));
    expect(find.textContaining('Snooze'), findsNothing);
    expect(find.text("Emergency? Can't do the mission"), findsOneWidget);
  });

  testWidgets('nothing shows without a ringing alarm (mission preview)', (
    tester,
  ) async {
    await _pump(tester, null);
    expect(find.byType(TextButton), findsNothing);
  });

  test('the lock-screen button opens the mission directly', () {
    expect(Routes.ringing('a1'), '/ringing/a1');
    expect(Routes.ringing('a1', startMission: true), '/ringing/a1?mission=1');
  });
}
