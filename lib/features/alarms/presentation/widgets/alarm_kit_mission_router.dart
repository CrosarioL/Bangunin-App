import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/router/routes.dart';

/// Routes into the ringing screen when the user opens Bangunin from a live
/// AlarmKit alert.
///
/// AlarmKit presents its own system alert; tapping our secondary button runs
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  Widget build(BuildContext context) => widget.child;
}
