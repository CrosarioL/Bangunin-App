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
import '../../../alarms/domain/alarm_clip.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../alarms/presentation/widgets/alarm_card.dart';
import '../../../missions/domain/mission_type.dart';
import '../../../missions/presentation/widgets/mission_experience.dart';
import '../providers/ringing_provider.dart';
import '../widgets/alarm_video_background.dart';
import '../widgets/emergency_escape_sheet.dart';

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
  );

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduce Motion: a repeating full-screen pulse aimed at someone half
    // awake in a dark room is a real vestibular and photosensitivity
    // concern, not a stylistic nicety. Hold the mascot still instead.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 1;
    } else if (!reduceMotion && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
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
    final clip = AlarmClips.byId(alarm?.clipId);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: clip == null ? null : AppColors.nightTop,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (clip != null) AlarmVideoBackground(clip: clip),
            SafeArea(
              // At the largest accessibility text sizes the clock, label, mission
              // name, button and snooze row cannot all fit. Scrolling is the only
              // honest answer — the ringing screen is the worst possible place to
              // silently clip the controls that switch the alarm off.
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerRight,
                              child: AlarmActivePill(active: true),
                            ),
                            const Spacer(),
                            // A video alarm is the show; the mascot would sit on
                            // top of the clip's subject.
                            if (clip == null) ...[
                              FadeTransition(
                                opacity: _pulseOpacity,
                                child: ScaleTransition(
                                  scale: _pulseScale,
                                  child: const BanguninMascot(
                                    pose: MascotPose.crowing,
                                    size: 170,
                                    animateIdle: false,
                                    interactive: false,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.xl,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.glass,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .13),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: .14,
                                    ),
                                    blurRadius: 28,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const _LiveClock(),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    alarm == null
                                        ? ''
                                        : (alarm.label.isEmpty
                                              ? l10n.ringingWakeUp
                                              : alarm.label),
                                    style: theme.textTheme.headlineSmall!
                                        .copyWith(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (alarm != null) ...[
                              if (alarm.missionType != MissionType.none) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: alarm.missionType.experienceColor
                                        .withValues(alpha: .14),
                                    borderRadius: BorderRadius.circular(99),
                                    border: Border.all(
                                      color: alarm.missionType.experienceColor
                                          .withValues(alpha: .34),
                                    ),
                                  ),
                                  child: Text(
                                    alarm.missionType.localizedName(l10n),
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      color: alarm.missionType.experienceColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
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
                                      alarm.maxSnoozes -
                                          (session?.snoozeCount ?? 0),
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 40),
                              // Mission alarms only: without a mission the
                              // dismiss button already is the way out.
                              if (alarm.missionType != MissionType.none)
                                TextButton(
                                  onPressed: _emergencyEscape,
                                  child: Text(
                                    l10n.emergencyLink,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall!.copyWith(
                                      color: AppColors.textTertiary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startMission(Alarm alarm) async {
    await ref.read(ringingSessionProvider.notifier).pauseForMission();
    if (!mounted) return;
    if (alarm.missionType.isPhoto) {
      unawaited(context.push(Routes.photoMission(alarm.id)));
    } else if (alarm.missionType.isPhoneTask) {
      unawaited(context.push(Routes.phoneMission(alarm.id)));
    } else {
      unawaited(context.push(Routes.movementMission(alarm.id)));
    }
  }

  Future<void> _dismissNoMission() async {
    await ref.read(ringingSessionProvider.notifier).complete();
    if (mounted) context.go(Routes.wakeSuccess);
  }

  Future<void> _emergencyEscape() async {
    final notifier = ref.read(ringingSessionProvider.notifier);
    final escaped = await showEmergencyEscapeSheet(
      context,
      usedThisMonth: notifier.emergencyEscapesThisMonth(),
    );
    if (!escaped || !mounted) return;
    await notifier.escape();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.emergencyDone)));
    context.go(Routes.home);
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
    // The clock already starts at 72pt. Scaling it the full accessibility
    // range would push the stop and snooze controls off screen, so it is
    // clamped — generously, and it is the only text in the app that is.
    // Everything around it scales freely.
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1,
      maxScaleFactor: scale.clamp(1.0, 1.3),
      child: Text(
        TimeFormat.clock(context, now.hour, now.minute),
        style: Theme.of(
          context,
        ).textTheme.displayLarge!.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
