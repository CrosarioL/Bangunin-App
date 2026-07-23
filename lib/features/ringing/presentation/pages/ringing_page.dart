import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/time_format.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../alarms/presentation/widgets/alarm_card.dart';
import '../../../missions/domain/mission_type.dart';
import '../providers/ringing_provider.dart';

/// Full-screen takeover while an alarm rings. The only exits are the
/// mission (or dismiss, for mission-less alarms) and snooze while snoozes
/// remain. Back gestures are blocked.
class RingingPage extends ConsumerStatefulWidget {
  const RingingPage({super.key, required this.alarmId});

  final String alarmId;

  @override
  ConsumerState<RingingPage> createState() => _RingingPageState();
}

class _RingingPageState extends ConsumerState<RingingPage>
    with SingleTickerProviderStateMixin {
  Alarm? _alarm;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _pulseOpacity = Tween<double>(
    begin: 0.55,
    end: 1,
  ).animate(_pulse);
  late final Animation<double> _pulseScale = Tween<double>(
    begin: 0.97,
    end: 1.03,
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    unawaited(WakelockPlus.enable());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final alarm = await ref
          .read(ringingSessionProvider.notifier)
          .begin(widget.alarmId);
      if (!mounted) return;
      if (alarm == null) {
        // Alarm was deleted after the notification fired.
        context.go(Routes.home);
        return;
      }
      setState(() => _alarm = alarm);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final session = ref.watch(ringingSessionProvider);
    final alarm = _alarm;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(),
                FadeTransition(
                  opacity: _pulseOpacity,
                  child: ScaleTransition(
                    scale: _pulseScale,
                    child: const BanguninMascot(
                      pose: MascotPose.crowing,
                      size: 170,
                      interactive: false,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const _LiveClock(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  alarm == null
                      ? ''
                      : (alarm.label.isEmpty
                            ? l10n.ringingWakeUp
                            : alarm.label),
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                if (alarm != null) ...[
                  if (alarm.missionType != MissionType.none) ...[
                    Text(
                      alarm.missionType.localizedName(l10n),
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: l10n.startMission,
                      onPressed: () => _startMission(alarm),
                    ),
                  ] else
                    PrimaryButton(
                      label: l10n.dismissAlarm,
                      onPressed: _dismissNoMission,
                    ),
                  const SizedBox(height: AppSpacing.md),
                  if (session?.canSnooze ?? false)
                    TextButton(
                      onPressed: _snooze,
                      child: Text(
                        l10n.snoozeWithRemaining(
                          alarm.snoozeMinutes,
                          alarm.maxSnoozes - (session?.snoozeCount ?? 0),
                        ),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startMission(Alarm alarm) async {
    await ref.read(ringingSessionProvider.notifier).pauseForMission();
    if (!mounted) return;
    if (alarm.missionType.isPhoto) {
      unawaited(context.push(Routes.photoMission(alarm.id)));
    } else {
      unawaited(context.push(Routes.movementMission(alarm.id)));
    }
  }

  Future<void> _dismissNoMission() async {
    await ref.read(ringingSessionProvider.notifier).complete();
    if (mounted) context.go(Routes.wakeSuccess);
  }

  Future<void> _snooze() async {
    final snoozed = await ref.read(ringingSessionProvider.notifier).snooze();
    if (snoozed && mounted) context.go(Routes.home);
  }
}

/// Ticks its own text once a second in isolation, so the rest of the
/// ringing screen (buttons, mission copy) doesn't rebuild every tick.
class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    return Text(
      TimeFormat.clock(context, now.hour, now.minute),
      style: Theme.of(
        context,
      ).textTheme.displayLarge!.copyWith(color: AppColors.textPrimary),
    );
  }
}
