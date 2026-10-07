import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../missions/domain/mission_type.dart';
import 'providers/ringing_provider.dart';
import 'widgets/emergency_escape_sheet.dart';

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

/// Snooze the ringing alarm (while snoozes remain) and go home. Offered on
/// the ringing screen and on every mission screen.
Future<void> runSnooze(BuildContext context, WidgetRef ref) async {
  final snoozed = await ref.read(ringingSessionProvider.notifier).snooze();
  if (snoozed && context.mounted) context.go(Routes.home);
}

/// The emergency exit: pledge sheet, then the alarm stops and the morning is
/// recorded as missed. Offered on the ringing screen and every mission.
Future<void> runEmergencyEscape(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(ringingSessionProvider.notifier);
  final escaped = await showEmergencyEscapeSheet(
    context,
    usedThisMonth: notifier.emergencyEscapesThisMonth(),
  );
  if (!escaped || !context.mounted) return;
  await notifier.escape();
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.emergencyDone)));
  context.go(Routes.home);
}

/// Snooze and the emergency exit, under every mission. Opening an alarm from
/// the lock screen now lands directly in the mission, so these must be here
/// and not only on the ringing screen.
class MissionExitBar extends ConsumerWidget {
  const MissionExitBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(ringingSessionProvider);
    if (session == null) return const SizedBox.shrink();
    final alarm = session.alarm;
    final muted = Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: Colors.white60);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            if (session.canSnooze)
              Expanded(
                child: TextButton(
                  onPressed: () => runSnooze(context, ref),
                  child: Text(
                    l10n.snoozeWithRemaining(
                      alarm.snoozeMinutes,
                      alarm.maxSnoozes - session.snoozeCount,
                    ),
                    textAlign: TextAlign.center,
                    style: muted,
                  ),
                ),
              ),
            Expanded(
              child: TextButton(
                onPressed: () => runEmergencyEscape(context, ref),
                child: Text(
                  l10n.emergencyLink,
                  textAlign: TextAlign.center,
                  style: muted.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white60,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
