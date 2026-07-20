import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_flow_page.dart';

/// Step 1 — value proposition.
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
      child: const Center(
        child: BanguninMascot(size: 210, flap: true),
      ),
    );
  }
}

/// Step 2 — snooze-habit survey question.
class SnoozeHabitStep extends ConsumerWidget {
  const SnoozeHabitStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final answers = ref.watch(onboardingAnswersProvider);
    final options = [
      l10n.snoozeHabitNever,
      l10n.snoozeHabitSometimes,
      l10n.snoozeHabitAlways,
    ];

    return OnboardingStepScaffold(
      title: l10n.snoozeHabitQuestion,
      ctaLabel: l10n.continueLabel,
      ctaEnabled: answers.snoozeHabit != null,
      onNext: onNext,
      child: Column(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            SurveyOption(
              label: options[i],
              selected: answers.snoozeHabit == i,
              onTap: () => ref
                  .read(onboardingAnswersProvider.notifier)
                  .setSnoozeHabit(i),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Step 3 — wake goal time picker.
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

/// Step 4 — multi-select of morning struggles.
class StrugglesStep extends ConsumerWidget {
  const StrugglesStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final answers = ref.watch(onboardingAnswersProvider);
    final struggles = {
      'dismiss_half_asleep': l10n.struggleDismissAsleep,
      'stay_in_bed': l10n.struggleStayInBed,
      'phone_in_bed': l10n.strugglePhoneInBed,
      'no_routine': l10n.struggleNoRoutine,
    };

    return OnboardingStepScaffold(
      title: l10n.strugglesQuestion,
      subtitle: l10n.strugglesSubtitle,
      ctaLabel: l10n.continueLabel,
      ctaEnabled: answers.struggles.isNotEmpty,
      onNext: onNext,
      child: Column(
        children: [
          for (final entry in struggles.entries) ...[
            SurveyOption(
              label: entry.value,
              selected: answers.struggles.contains(entry.key),
              onTap: () => ref
                  .read(onboardingAnswersProvider.notifier)
                  .toggleStruggle(entry.key),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Step 5 — notification permission prime + system prompt.
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

/// Step 6 — "building your plan" loader with sequential checkmarks.
class PersonalizingStep extends ConsumerStatefulWidget {
  const PersonalizingStep({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<PersonalizingStep> createState() => _PersonalizingStepState();
}

class _PersonalizingStepState extends ConsumerState<PersonalizingStep> {
  int _completed = 0;
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      setState(() => _completed++);
      Haptics.tap();
      if (_completed >= 3) {
        timer.cancel();
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (mounted) widget.onDone();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name = ref.watch(onboardingAnswersProvider).name.trim();
    final title = name.isNotEmpty
        ? l10n.personalizingTitleNamed(name)
        : l10n.personalizingTitle;
    final items = [
      l10n.personalizingItem1,
      l10n.personalizingItem2,
      l10n.personalizingItem3,
    ];

    return MaxWidthBox(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < items.length; i++) ...[
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: i < _completed
                        ? const Icon(
                            Icons.check_circle_rounded,
                            key: ValueKey('done'),
                            color: AppColors.success,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            key: const ValueKey('pending'),
                            color: theme.colorScheme.outline,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(items[i], style: theme.textTheme.bodyLarge),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}

/// A selectable survey row shared by the question steps.
class SurveyOption extends StatelessWidget {
  const SurveyOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        child: Text(
          label,
          style: theme.textTheme.titleSmall!.copyWith(
            color: selected ? AppColors.primary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
