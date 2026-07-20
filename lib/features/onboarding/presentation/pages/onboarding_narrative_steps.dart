import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_card.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/time_format.dart';
import '../../domain/snooze_math.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/plan_chart.dart';
import 'onboarding_flow_page.dart';
import 'onboarding_steps.dart';

/// Step — collects the user's first name so later copy can address them
/// directly (personalizing title, plan reveal, paywall).
class NameStep extends ConsumerStatefulWidget {
  const NameStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<NameStep> createState() => _NameStepState();
}

class _NameStepState extends ConsumerState<NameStep> {
  late final _controller = TextEditingController(
    text: ref.read(onboardingAnswersProvider).name,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final answers = ref.watch(onboardingAnswersProvider);

    return OnboardingStepScaffold(
      title: l10n.nameQuestion,
      ctaLabel: l10n.continueLabel,
      ctaEnabled: answers.name.trim().isNotEmpty,
      onNext: widget.onNext,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: l10n.nameHint,
              counterText: '',
            ),
            onChanged: (value) =>
                ref.read(onboardingAnswersProvider.notifier).setName(value),
          ),
        ],
      ),
    );
  }
}

/// Step — age range, used to tune the plan's tone and sleep-need baseline.
class AgeStep extends ConsumerWidget {
  const AgeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final answers = ref.watch(onboardingAnswersProvider);
    final options = [
      l10n.ageUnder18,
      l10n.age18to24,
      l10n.age25to34,
      l10n.age35to54,
      l10n.age55plus,
    ];

    return OnboardingStepScaffold(
      title: l10n.ageQuestion,
      subtitle: l10n.ageSubtitle,
      ctaLabel: l10n.continueLabel,
      ctaEnabled: answers.ageRange != null,
      onNext: onNext,
      child: Column(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            SurveyOption(
              label: options[i],
              selected: answers.ageRange == i,
              onTap: () =>
                  ref.read(onboardingAnswersProvider.notifier).setAgeRange(i),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Step — bedtime picker, paired with the wake goal to compute the sleep
/// window shown on the pain-stat step.
class BedtimeStep extends ConsumerWidget {
  const BedtimeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final answers = ref.watch(onboardingAnswersProvider);

    return OnboardingStepScaffold(
      title: l10n.bedtimeQuestion,
      subtitle: l10n.bedtimeSubtitle,
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
                answers.bedHour,
                answers.bedMinute,
              ),
              use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
              onDateTimeChanged: (value) {
                Haptics.selection();
                ref
                    .read(onboardingAnswersProvider.notifier)
                    .setBedtime(value.hour, value.minute);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Step — the emotional "pain stat": an animated count-up of hours lost to
/// snoozing per year, followed by the planned sleep window.
class PainStatStep extends ConsumerWidget {
  const PainStatStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final answers = ref.watch(onboardingAnswersProvider);
    final hours = SnoozeMath.hoursLostPerYear(answers.snoozeHabit ?? 1);
    final sleepMinutes = SnoozeMath.sleepMinutes(
      bedHour: answers.bedHour,
      bedMinute: answers.bedMinute,
      wakeHour: answers.wakeGoalHour,
      wakeMinute: answers.wakeGoalMinute,
    );
    final sleepDuration = TimeFormat.countdown(Duration(minutes: sleepMinutes));

    return OnboardingStepScaffold(
      title: '',
      subtitle: null,
      ctaLabel: l10n.continueLabel,
      onNext: onNext,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.painStatPrefix,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: hours),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                l10n.painStatHours(value),
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge!.copyWith(
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.painStatSuffix,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.painStatFootnote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Text(
                l10n.sleepWindowNote(sleepDuration),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step — multi-select of the mornings the user is working towards.
class MotivationsStep extends ConsumerWidget {
  const MotivationsStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final answers = ref.watch(onboardingAnswersProvider);
    final motivations = {
      'exercise': l10n.motivationExercise,
      'breakfast': l10n.motivationBreakfast,
      'deep_work': l10n.motivationDeepWork,
      'quiet_time': l10n.motivationQuietTime,
      'family': l10n.motivationFamily,
    };

    return OnboardingStepScaffold(
      title: l10n.motivationsQuestion,
      subtitle: l10n.motivationsSubtitle,
      ctaLabel: l10n.continueLabel,
      ctaEnabled: answers.motivations.isNotEmpty,
      onNext: onNext,
      child: Column(
        children: [
          for (final entry in motivations.entries) ...[
            SurveyOption(
              label: entry.value,
              selected: answers.motivations.contains(entry.key),
              onTap: () => ref
                  .read(onboardingAnswersProvider.notifier)
                  .toggleMotivation(entry.key),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Step — a micro-commitment moment before the permission ask: a single
/// deliberate tap that primes follow-through (foot-in-the-door effect).
class CommitmentStep extends StatelessWidget {
  const CommitmentStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingStepScaffold(
      title: l10n.commitmentTitle,
      subtitle: l10n.commitmentBody,
      ctaLabel: l10n.commitmentCta,
      onNext: () {
        Haptics.success();
        onNext();
      },
      child: Center(
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.handshake_rounded,
            size: 64,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Step — social proof (star rating + testimonials) that also opportunistically
/// prompts the platform's native App Store / Play Store review dialog.
class SocialProofStep extends ConsumerStatefulWidget {
  const SocialProofStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<SocialProofStep> createState() => _SocialProofStepState();
}

class _SocialProofStepState extends ConsumerState<SocialProofStep> {
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    if (!_requested) {
      _requested = true;
      unawaited(_maybeRequestReview());
    }
  }

  Future<void> _maybeRequestReview() async {
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      }
    } catch (_) {
      // Platform channel may be unavailable (e.g. in tests) — never throw.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final testimonials = [
      (quote: l10n.socialProofQuote1, author: l10n.socialProofAuthor1),
      (quote: l10n.socialProofQuote2, author: l10n.socialProofAuthor2),
      (quote: l10n.socialProofQuote3, author: l10n.socialProofAuthor3),
    ];

    return OnboardingStepScaffold(
      title: l10n.socialProofTitle,
      subtitle: l10n.socialProofSubtitle,
      ctaLabel: l10n.continueLabel,
      onNext: widget.onNext,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final t in testimonials) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.quote,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(t.author, style: theme.textTheme.labelLarge),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Final step — reveals the personalized 30-day plan and its projected
/// improvement curve.
class PlanRevealStep extends ConsumerWidget {
  const PlanRevealStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final answers = ref.watch(onboardingAnswersProvider);

    final goalTime = TimeFormat.clock(
      context,
      answers.wakeGoalHour,
      answers.wakeGoalMinute,
    );

    final driftMinutes = 30 + 30 * (answers.snoozeHabit ?? 1);
    final goalMinutesOfDay = answers.wakeGoalHour * 60 + answers.wakeGoalMinute;
    final nowMinutesOfDay = (goalMinutesOfDay + driftMinutes) % (24 * 60);
    final nowTime = TimeFormat.clock(
      context,
      nowMinutesOfDay ~/ 60,
      nowMinutesOfDay % 60,
    );

    final title = answers.name.trim().isNotEmpty
        ? l10n.planRevealTitleNamed(answers.name.trim())
        : l10n.planRevealTitle;

    return OnboardingStepScaffold(
      title: title,
      subtitle: l10n.planRevealSubtitle(goalTime),
      ctaLabel: l10n.planRevealCta,
      onNext: onNext,
      child: Center(
        child: AppCard(
          child: PlanChart(nowLabel: nowTime, goalLabel: goalTime),
        ),
      ),
    );
  }
}
