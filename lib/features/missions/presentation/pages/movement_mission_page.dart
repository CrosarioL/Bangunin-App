import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../alarms/presentation/widgets/alarm_card.dart';
import '../../../ringing/presentation/providers/ringing_provider.dart';
import '../../data/motion_rep_counter.dart';
import '../../domain/mission_type.dart';

/// Movement mission: hold the phone and complete the target reps. The rep
/// counter reads the accelerometer; every counted rep ticks the progress
/// ring with a haptic.
class MovementMissionPage extends ConsumerStatefulWidget {
  const MovementMissionPage({super.key, required this.alarmId});

  final String alarmId;

  @override
  ConsumerState<MovementMissionPage> createState() =>
      _MovementMissionPageState();
}

class _MovementMissionPageState extends ConsumerState<MovementMissionPage> {
  Alarm? _alarm;
  MotionRepCounter? _counter;
  StreamSubscription<int>? _repsSub;
  int _reps = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final alarm =
        await ref.read(alarmRepositoryProvider).getById(widget.alarmId);
    if (!mounted || alarm == null) return;
    final target =
        alarm.missionReps > 0 ? alarm.missionReps : alarm.missionType.defaultReps;
    final counter = MotionRepCounter(targetReps: target);
    _repsSub = counter.reps.listen(_onRep);
    counter.start();
    setState(() {
      _alarm = alarm;
      _counter = counter;
    });
  }

  void _onRep(int reps) {
    Haptics.tap();
    setState(() => _reps = reps);
    if (_counter?.isComplete ?? false) {
      unawaited(_complete());
    }
  }

  Future<void> _complete() async {
    Haptics.success();
    await ref.read(ringingSessionProvider.notifier).complete();
    if (mounted) context.go(Routes.wakeSuccess);
  }

  Future<void> _abandon() async {
    await ref.read(ringingSessionProvider.notifier).resumeRinging();
    if (mounted) context.go(Routes.ringing(widget.alarmId));
  }

  @override
  void dispose() {
    unawaited(_repsSub?.cancel());
    unawaited(_counter?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final alarm = _alarm;
    final target = _counter?.targetReps ?? 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_abandon());
      },
      child: Scaffold(

        appBar: AppBar(
  
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: l10n.abandonMission,
            onPressed: _abandon,
          ),
          title: Text(
            alarm?.missionType.localizedName(l10n) ?? '',
            style: theme.textTheme.titleMedium!
                .copyWith(color: AppColors.textPrimary),
          ),
        ),
        body: alarm == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Text(
                        alarm.missionType == MissionType.squats
                            ? l10n.movementInstructionSquats
                            : l10n.movementInstructionPushups,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: target == 0 ? 0 : _reps / target,
                              ),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) =>
                                  CircularProgressIndicator(
                                value: value,
                                strokeWidth: 10,
                                strokeCap: StrokeCap.round,
                                color: AppColors.primary,
                                backgroundColor: AppColors.surfaceRaised,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                    child: Text(
                                      '$_reps',
                                      key: ValueKey(_reps),
                                      style: theme.textTheme.displayLarge!
                                          .copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    l10n.repsOf(target),
                                    style: theme.textTheme.bodyMedium!
                                        .copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.movementHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
