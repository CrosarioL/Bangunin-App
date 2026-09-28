import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../missions/domain/mission_type.dart';
import 'providers/ringing_provider.dart';

/// The screen that runs [mission] for the ringing alarm [alarmId].
String missionRoute(MissionType mission, String alarmId) {
  if (mission.isPhoto) return Routes.photoMission(alarmId);
  if (mission.isPhoneTask) return Routes.phoneMission(alarmId);
  return Routes.movementMission(alarmId);
}

/// Every mission page calls this when its mission is passed. With more
/// missions chained, it goes straight to the next one (the alarm stays
/// ducked, not silenced); after the last, the wake is complete.
Future<void> finishMissionStep(
  BuildContext context,
  WidgetRef ref,
  String alarmId,
) async {
  final notifier = ref.read(ringingSessionProvider.notifier);
  final next = notifier.advanceMission();
  if (next != null) {
    if (context.mounted) context.go(missionRoute(next, alarmId));
    return;
  }
  await notifier.complete();
  if (context.mounted) context.go(Routes.wakeSuccess);
}

/// The step of the chain a mission page should run, for a live ring.
int currentMissionStep(WidgetRef ref) =>
    ref.read(ringingSessionProvider)?.missionStep ?? 0;
