import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/router/routes.dart';
import '../providers/alarms_provider.dart';

/// Keeps the alarm schedule honest across app lifecycle events.
///
/// Two jobs, both of which only make sense at the app root:
///
///  1. **Mission routing.** Routes into the ringing screen when the user opens
///     Bangunin from a live AlarmKit alert.
///  2. **Timezone rehydration.** Alarms are wall-clock times, so crossing a
///     timezone (Jakarta -> Bali, WIB -> WITA) leaves every scheduled
///     occurrence an hour out until something else happens to reschedule
///     them. Nothing did, before this.
///
/// On mission routing: AlarmKit presents its own system alert; tapping our
/// secondary button runs
/// `StartMissionIntent`, which opens the app and leaves the alarm id behind.
/// This picks it up. Without it the user taps "Start mission" on the lock
/// screen and lands on the home page, with the alarm still ringing and no
/// obvious way to finish.
///
/// Checked on launch *and* on resume, because the app may already have been
/// in memory when the alarm fired.
class AlarmKitMissionRouter extends ConsumerStatefulWidget {
  const AlarmKitMissionRouter({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AlarmKitMissionRouter> createState() =>
      _AlarmKitMissionRouterState();
}

class _AlarmKitMissionRouterState extends ConsumerState<AlarmKitMissionRouter>
    with WidgetsBindingObserver {
  /// Guards against two checks overlapping — the id is consumed on read, but
  /// a second in-flight call could still route twice.
  bool _checking = false;

  /// Offset we last scheduled against, to spot a timezone change on resume.
  Duration? _lastKnownOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastKnownOffset = DateTime.now().timeZoneOffset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_routePendingMission());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_routePendingMission());
      unawaited(_resyncIfTimezoneChanged());
    }
  }

  Future<void> _routePendingMission() async {
    if (_checking) return;
    _checking = true;
    try {
      // Consuming clears it, so a mission is routed to exactly once.
      final alarmId = await ref
          .read(alarmKitServiceProvider)
          .consumePendingMissionAlarmId();
      if (alarmId == null || alarmId.isEmpty || !mounted) return;

      // Only route to an alarm that still exists — it may have been deleted
      // between the alert firing and the app opening.
      final alarm = await ref.read(alarmRepositoryProvider).getById(alarmId);
      if (alarm == null || !mounted) return;

      ref.read(appRouterProvider).go(Routes.ringing(alarmId));
    } finally {
      _checking = false;
    }
  }

  /// Re-arms every alarm when the device's UTC offset has moved.
  ///
  /// Alarms are stored as wall-clock times, so 05:00 must stay 05:00 in
  /// whatever zone the user wakes up in — but the occurrences we handed the
  /// OS were computed in the old zone and would fire at the wrong moment.
  Future<void> _resyncIfTimezoneChanged() async {
    final offset = DateTime.now().timeZoneOffset;
    if (offset == _lastKnownOffset) return;
    _lastKnownOffset = offset;
    if (!mounted) return;
    await ref.read(alarmActionsProvider).resync();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
