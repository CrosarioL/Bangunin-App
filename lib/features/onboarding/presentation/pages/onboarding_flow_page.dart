import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/utils/haptics.dart';
import '../../../alarms/presentation/providers/alarms_provider.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_narrative_steps.dart';
import 'onboarding_steps.dart';

/// The onboarding container: progress bar + PageView of steps. The flow
/// follows the product's philosophy — first make the pain vivid (snooze
/// habit survey), then promise the outcome, then ask for the permission it
/// needs, then "personalize" and hand off to the paywall.
class OnboardingFlowPage extends ConsumerStatefulWidget {
  const OnboardingFlowPage({super.key});

  @override
  ConsumerState<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends ConsumerState<OnboardingFlowPage> {
  final _pageController = PageController();
  int _step = 0;
  // 13 since the social-proof step was removed: it presented invented
  // testimonials as real user endorsements (Play "Misrepresentation", and
  // deceptive endorsements are separately unlawful in our markets) and fired
  // the store review prompt before the user had used the app at all.
  static const _stepCount = 13;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref.read(analyticsProvider).logEvent(AnalyticsEvents.onboardingStarted),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step >= _stepCount - 1) {
      final answers = ref.read(onboardingAnswersProvider);
      await ref.read(alarmActionsProvider).createFromOnboarding(answers);
      await ref.read(onboardingCompletedProvider.notifier).markCompleted();
      unawaited(
        ref
            .read(analyticsProvider)
            .logEvent(AnalyticsEvents.onboardingCompleted),
      );
      return; // Router redirect takes over (→ paywall).
    }
    Haptics.tap();
    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.onboardingStep, {
        'step': _step + 1,
      }),
    );
    setState(() => _step++);
    await _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (_step + 1) / _stepCount),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    color: AppColors.primary,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WelcomeStep(onNext: _next),
                  NameStep(onNext: _next),
                  AgeStep(onNext: _next),
                  SnoozeHabitStep(onNext: _next),
                  BedtimeStep(onNext: _next),
                  WakeGoalStep(onNext: _next),
                  PainStatStep(onNext: _next),
                  StrugglesStep(onNext: _next),
                  MotivationsStep(onNext: _next),
                  CommitmentStep(onNext: _next),
                  NotificationStep(onNext: _next),
                  PersonalizingStep(onDone: _next),
                  PlanRevealStep(onNext: _next),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared scaffold for a single onboarding step: headline, body content,
/// pinned CTA.
class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    required this.ctaLabel,
    this.ctaEnabled = true,
    required this.onNext,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String ctaLabel;
  final bool ctaEnabled;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      // Steps advance within a single PageView route, not a new route push,
      // so a step with a TextField (e.g. NameStep) otherwise leaves the
      // keyboard up for every step after it. Tapping anywhere outside a
      // field, or advancing, dismisses it.
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: MaxWidthBox(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(title, style: theme.textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
              PrimaryButton(
                label: ctaLabel,
                onPressed: ctaEnabled
                    ? () {
                        FocusScope.of(context).unfocus();
                        onNext();
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
