import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/core/services/alarms/alarm_kit_service.dart';
import 'package:wakio/features/alarms/presentation/providers/alarm_capability_provider.dart';
import 'package:wakio/features/alarms/presentation/widgets/alarms_off_gate.dart';

import '../helpers/test_app.dart';

Widget _gated(AlarmCapability capability) => testApp(
  overrides: [alarmCapabilityProvider.overrideWith((ref) async => capability)],
  child: const AlarmsOffGate(child: Text('home')),
);

void main() {
  testWidgets('blocks the app while Alarms is switched off', (tester) async {
    await tester.pumpWidget(
      _gated(
        const AlarmCapability(
          engine: AlarmEngine.notifications,
          authorization: AlarmKitAuthorization.denied,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsNothing);
    expect(find.text("Bangunin's alarms are switched off"), findsOneWidget);
    // Refused once, so only Settings can turn it on.
    expect(
      find.text('Open Settings → Bangunin → switch on Alarms.'),
      findsOneWidget,
    );
  });

  testWidgets('offers the iOS prompt when never asked', (tester) async {
    await tester.pumpWidget(
      _gated(
        const AlarmCapability(
          engine: AlarmEngine.notifications,
          authorization: AlarmKitAuthorization.notDetermined,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsNothing);
    expect(find.text('Turn on alarms'), findsOneWidget);
  });

  testWidgets('lets the app through once alarms are real', (tester) async {
    await tester.pumpWidget(
      _gated(
        const AlarmCapability(
          engine: AlarmEngine.alarmKit,
          authorization: AlarmKitAuthorization.authorized,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('does not block devices that cannot run AlarmKit', (
    tester,
  ) async {
    await tester.pumpWidget(
      _gated(
        const AlarmCapability(
          engine: AlarmEngine.androidExactAlarm,
          authorization: AlarmKitAuthorization.unsupported,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });
}
