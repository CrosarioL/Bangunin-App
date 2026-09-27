import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/time_format.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../alarms/presentation/widgets/alarm_card.dart';
import '../../../alarms/presentation/widgets/alarm_sound_l10n.dart';
import '../../../missions/domain/mission_type.dart';
import '../../../missions/presentation/widgets/mission_experience.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_flow_page.dart';

/// Step 1 — the hook: ordinary alarms lose to a half-asleep thumb.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingStepScaffold(
      title: l10n.onboardingWelcomeTitle,
      subtitle: l10n.onboardingWelcomeSubtitle,
      ctaLabel: l10n.getStarted,
      onNext: onNext,
      child: const Center(child: BanguninMascot(size: 210, flap: true)),
    );
  }
}

/// Step 2 — the first alarm's time. Seconds into the app, the user is
/// already setting tomorrow morning rather than answering a survey.
class WakeGoalStep extends ConsumerWidget {
  const WakeGoalStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final answers = ref.watch(onboardingAnswersProvider);

    return OnboardingStepScaffold(
      title: l10n.wakeGoalQuestion,
      subtitle: l10n.wakeGoalSubtitle,
      ctaLabel: l10n.continueLabel,
      onNext: onNext,
      child: Center(
        child: SizedBox(
          height: 200,
          child: CupertinoTheme(
            data: CupertinoThemeData(brightness: Theme.of(context).brightness),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime(
                2000,
                1,
                1,
                answers.wakeGoalHour,
                answers.wakeGoalMinute,
              ),
              use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
              onDateTimeChanged: (value) {
                Haptics.selection();
                ref
                    .read(onboardingAnswersProvider.notifier)
                    .setWakeGoal(value.hour, value.minute);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Step 3 — the alarm sound. Tapping a sound plays it, so the choice is made
/// by ear, and the pick is logged at completion as a selection-rate signal.
class SoundStep extends ConsumerStatefulWidget {
  const SoundStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<SoundStep> createState() => _SoundStepState();
}

class _SoundStepState extends ConsumerState<SoundStep> {
  /// Custom sounds need an import or recording; that stays in the editor.
  static final _sounds = AlarmSound.values
      .where((s) => s != AlarmSound.custom)
      .toList();

  // Read eagerly: `ref` is unusable by the time dispose() runs.
  late final _audio = ref.read(alarmAudioServiceProvider);

  @override
  void dispose() {
    unawaited(_audio.stopPreview());
    super.dispose();
  }

  void _select(AlarmSound sound) {
    ref.read(onboardingAnswersProvider.notifier).setSound(sound);
    unawaited(_audio.preview(sound));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = ref.watch(onboardingAnswersProvider).sound;

    return OnboardingStepScaffold(
      title: l10n.onboardingSoundTitle,
      subtitle: l10n.onboardingSoundSubtitle,
      ctaLabel: l10n.continueLabel,
      onNext: () {
        unawaited(_audio.stopPreview());
        widget.onNext();
      },
      child: Column(
        children: [
          for (final sound in _sounds) ...[
            SurveyOption(
              label: sound.localizedName(l10n),
              icon: selected == sound
                  ? Icons.volume_up_rounded
                  : Icons.music_note_rounded,
              selected: selected == sound,
              onTap: () => _select(sound),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Step 4 — the mission, the product's whole difference. Random Hunt is
/// pre-selected and badged: it needs no setup and it's the one people film.
class MissionStep extends ConsumerWidget {
  const MissionStep({super.key, required this.onNext});

  final VoidCallback onNext;

  /// Missions that work with zero setup. Object Hunt needs a reference photo
  /// registered first, and pushups need the phone propped on the floor, so
  /// both are left for the editor.
  static const missions = [
    MissionType.randomHunt,
    MissionType.squats,
    MissionType.skyPhoto,
    MissionType.makeBed,
    MissionType.none,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(onboardingAnswersProvider).mission;

    return OnboardingStepScaffold(
      title: l10n.onboardingMissionTitle,
      subtitle: l10n.onboardingMissionSubtitle,
      ctaLabel: l10n.continueLabel,
      onNext: onNext,
      child: Column(
        children: [
          for (final mission in missions) ...[
            SurveyOption(
              label: mission.localizedName(l10n),
              description: mission.localizedDescription(l10n),
              icon: mission.icon,
              accent: mission == MissionType.none
                  ? null
                  : mission.experienceColor,
              badge: mission == MissionType.randomHunt
                  ? l10n.onboardingMissionBadge
                  : null,
              selected: selected == mission,
              onTap: () => ref
                  .read(onboardingAnswersProvider.notifier)
                  .setMission(mission),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Step 5 — notification permission, asked only now that there is an alarm
/// it is obviously for.
class NotificationStep extends ConsumerStatefulWidget {
  const NotificationStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<NotificationStep> createState() => _NotificationStepState();
}

class _NotificationStepState extends ConsumerState<NotificationStep> {
  bool _requesting = false;

  Future<void> _request() async {
    setState(() => _requesting = true);
    await ref.read(notificationServiceProvider).requestPermission();
    if (mounted) {
      setState(() => _requesting = false);
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingStepScaffold(
      title: l10n.notificationsTitle,
      subtitle: l10n.notificationsSubtitle,
      ctaLabel: _requesting ? '…' : l10n.allowNotifications,
      ctaEnabled: !_requesting,
      onNext: _request,
      child: Center(
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_active_rounded,
            size: 64,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Step 6 — "Besok jam 06:30." The alarm exists; say exactly when it rings
/// and what it will take to stop it, then hand off to the paywall.
class ReadyStep extends ConsumerWidget {
  const ReadyStep({super.key, required this.onNext, this.now});

  final VoidCallback onNext;

  /// Injectable clock for tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final answers = ref.watch(onboardingAnswersProvider);
    final from = now ?? DateTime.now();
    final firstRing = answers
        .toAlarm(Alarm(id: '', hour: 0, minute: 0, createdAt: from))
        .nextTrigger(from);

    final time = TimeFormat.clock(
      context,
      answers.wakeGoalHour,
      answers.wakeGoalMinute,
    );
    final when = _dayLabel(context, from, firstRing);
    final mission = answers.mission;
    final missionLine = switch (mission) {
      MissionType.none => l10n.onboardingReadyNoMission,
      MissionType.randomHunt => l10n.onboardingReadyHunt,
      _ => l10n.onboardingReadyMission(mission.localizedName(l10n)),
    };

    return OnboardingStepScaffold(
      title: l10n.onboardingReadyTitle(when, time),
      subtitle: missionLine,
      ctaLabel: l10n.onboardingReadyCta,
      onNext: () {
        Haptics.success();
        onNext();
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BanguninMascot(pose: MascotPose.crowing, size: 180),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.onboardingReadyFootnote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(BuildContext context, DateTime from, DateTime ring) {
    final l10n = context.l10n;
    final today = DateTime(from.year, from.month, from.day);
    final days = DateTime(
      ring.year,
      ring.month,
      ring.day,
    ).difference(today).inDays;
    if (days == 0) return l10n.onboardingReadyToday;
    if (days == 1) return l10n.onboardingReadyTomorrow;
    return DateFormat.EEEE(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(ring);
  }
}

/// A selectable row shared by the choice steps.
class SurveyOption extends StatelessWidget {
  const SurveyOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.description,
    this.icon,
    this.accent,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? description;
  final IconData? icon;

  /// Tint for the icon; the selection colour stays the brand primary.
  final Color? accent;

  /// Short pill beside the label, e.g. "Most fun".
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = accent ?? AppColors.primary;
    return GestureDetector(
      onTap: () {
        Haptics.selection();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        // Chunky tappable tile: thick border + a hard solid lip, tinted to
        // the accent when picked so selection feels physical.
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          border: Border.all(
            color: selected ? AppColors.primary : theme.colorScheme.outline,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? AppColors.primaryEdge : AppColors.surfaceEdge,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: selected
                                ? AppColors.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _Badge(text: badge!),
                      ],
                    ],
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCapsule),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: AppColors.nightTop,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
