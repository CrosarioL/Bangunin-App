import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../app/widgets/sunset_page_header.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/services/locale/locale_override_provider.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../alarms/presentation/providers/alarms_provider.dart';
import '../../../paywall/presentation/providers/premium_provider.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_steps.dart';
import 'onboarding_story_steps.dart';

/// The onboarding container: progress bar + PageView of steps.
///
/// Hook → problem → promise → product demo → a short survey (name, age,
/// snoozing) that comes back as the cost of snoozing → what it takes →
/// the fix → why they want to wake up → first-alarm setup (time, sound,
/// mission) → where they heard of us → what the app does → their 7-day
/// plan → permissions → "here's when it rings" → paywall. No free trial.
class OnboardingFlowPage extends ConsumerStatefulWidget {
  const OnboardingFlowPage({super.key});

  @override
  ConsumerState<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends ConsumerState<OnboardingFlowPage> {
  final _pageController = PageController();
  int _step = 0;
  bool _advancing = false;

  List<Widget> get _steps => [
    WelcomeStep(onNext: _next),
    StoryStep(
      pose: MascotPose.sleeping,
      title: context.l10n.obProblemTitle,
      body: context.l10n.obProblemBody,
      onNext: _next,
    ),
    StoryStep(
      pose: MascotPose.crowing,
      title: context.l10n.obPromiseTitle,
      body: context.l10n.obPromiseBody,
      onNext: _next,
    ),
    DemoStep(onNext: _next),
    NameStep(onNext: _next),
    AgeStep(onNext: _next),
    SnoozeStep(onNext: _next),
    CostStep(onNext: _next),
    LoseStep(onNext: _next),
    StoryStep(
      pose: MascotPose.happy,
      title: context.l10n.obFixTitle,
      body: context.l10n.obFixBody,
      onNext: _next,
    ),
    GoalStep(onNext: _next),
    WakeGoalStep(onNext: _next),
    SoundStep(onNext: _next),
    MissionStep(onNext: _next),
    HeardFromStep(onNext: _next),
    ProofStep(onNext: _next),
    PlanStep(onNext: _next),
    NotificationStep(onNext: _next),
    ReadyStep(onNext: _next),
    // Only when this person is actually offered a trial (plans were fetched
    // at the start of onboarding): never promise a reminder for a trial
    // they can't take.
    if (_trialDays case final days?)
      TrialReminderStep(trialDays: days, onNext: _next),
  ];

  int? get _trialDays {
    final plans = ref.watch(premiumPlansProvider).value ?? const [];
    for (final plan in plans) {
      if (plan.hasTrial) return plan.trialDays;
    }
    return null;
  }

  int get _stepCount => _steps.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref.read(analyticsProvider).logEvent(AnalyticsEvents.onboardingStarted),
      );
      // Fetch the paywall's plans now, while onboarding runs, so the paywall
      // opens with prices instead of a spinner. A failure here is fine: the
      // paywall simply fetches again.
      unawaited(
        ref
            .read(subscriptionServiceProvider)
            .loadPlans()
            .then<void>((_) {}, onError: (Object _) {}),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    // A choice auto-advances; a quick second tap (or the button straight
    // after) must not skip the following screen.
    if (_advancing) return;
    if (_step >= _stepCount - 1) {
      _advancing = true;
      final answers = ref.read(onboardingAnswersProvider);
      await saveUserName(ref, answers.name);
      await ref.read(alarmActionsProvider).createFromOnboarding(answers);
      await ref.read(onboardingCompletedProvider.notifier).markCompleted();
      // Which sound and mission new users pick is the selection-rate signal
      // for deciding what to feature and promote; the survey answers say
      // who installs and where they came from. Never the name.
      unawaited(
        ref
            .read(analyticsProvider)
            .logEvent(AnalyticsEvents.onboardingCompleted, {
              'sound': answers.clipId ?? answers.sound.name,
              'mission': answers.mission.name,
              'age': ?answers.age?.name,
              'snooze': ?answers.snooze?.name,
              'reason': ?answers.reason?.name,
              'heard_from': ?answers.heardFrom?.name,
            }),
      );
      return; // Router redirect takes over (→ paywall).
    }
    _advancing = true;
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
    _advancing = false;
  }

  Future<void> _back() async {
    if (_step == 0) return;
    Haptics.tap();
    FocusScope.of(context).unfocus();
    setState(() => _step--);
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
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  // Hidden (not removed) on the first step so the progress
                  // bar keeps the same width throughout.
                  Opacity(
                    opacity: _step == 0 ? 0 : 1,
                    child: IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onPressed: _step == 0 ? null : _back,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),
                  Expanded(child: _progressBar(context)),
                  // Language switch on the first screen only, before any
                  // tutorial text is read. Kept in the layout afterwards so
                  // the progress bar doesn't jump in width.
                  Visibility(
                    visible: _step == 0,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: const Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: _LanguageToggle(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _steps,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: (_step + 1) / _stepCount),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          height: 7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cyan,
                        AppColors.primary,
                        AppColors.horizon,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    this.fullBleedChild = false,
    this.scrollable = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String ctaLabel;
  final bool ctaEnabled;
  final VoidCallback onNext;

  /// Lets the body run edge to edge (carousels peek at the screen edges);
  /// the header and button keep their margins.
  final bool fullBleedChild;

  /// False gives [child] exactly the space between the header and the
  /// button (no scrolling), so it can scale itself to fit: the product
  /// demo must be seen whole, never cut off below the fold.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Steps advance within a single PageView route, not a new route push,
      // so a step with a TextField (e.g. NameStep) otherwise leaves the
      // keyboard up for every step after it. Tapping anywhere outside a
      // field, or advancing, dismisses it.
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: MaxWidthBox(
        child: Padding(
          // Shorter phones (iPhone SE and similar) get tighter margins so
          // every step fits without scrolling.
          padding: EdgeInsets.symmetric(
            vertical: _isShort(context) ? AppSpacing.md : AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: SunsetPageHeader(
                  title: title,
                  subtitle: subtitle,
                  icon: Icons.wb_sunny_rounded,
                ),
              ),
              SizedBox(
                height: _isShort(context) ? AppSpacing.md : AppSpacing.xl,
              ),
              if (!scrollable)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: fullBleedChild ? 0 : AppSpacing.xl,
                    ),
                    child: child,
                  ),
                )
              else
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        // Centred, not stretched: the box is forced to the
                        // full height, and a card placed straight into it
                        // (the name field, the plan) grew to fill it all.
                        child: Center(
                          child: fullBleedChild
                              ? child
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xl,
                                  ),
                                  child: child,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Breathing room so content never runs into the button.
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: PrimaryButton(
                  label: ctaLabel,
                  onPressed: ctaEnabled
                      ? () {
                          FocusScope.of(context).unfocus();
                          onNext();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ID | EN pill. Indonesian is the default; tapping EN switches the whole app
/// (and is remembered, like the Settings choice).
class _LanguageToggle extends ConsumerWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    Widget option(String code, String label) {
      final selected = current == code;
      return Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: selected
              ? null
              : () {
                  Haptics.tap();
                  ref.read(localeOverrideProvider.notifier).set(Locale(code));
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.w800,
                color: selected
                    ? AppColors.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [option('id', 'ID'), option('en', 'EN')],
      ),
    );
  }
}

/// A whole-screen onboarding slide (hook, problem, promise, cost): centred
/// [body], button pinned at the bottom. On a short phone the body scrolls
/// instead of being pushed under the button.
class OnboardingFullSlide extends StatelessWidget {
  const OnboardingFullSlide({
    super.key,
    required this.body,
    required this.button,
  });

  final Widget body;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return MaxWidthBox(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(child: body),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            button,
          ],
        ),
      ),
    );
  }

  /// Mascot size that leaves room for the text on shorter screens.
  static double mascotSize(BuildContext context, double preferred) =>
      (MediaQuery.sizeOf(context).height * 0.24).clamp(110, preferred);
}

/// True on phones around iPhone SE height, where onboarding tightens up.
bool _isShort(BuildContext context) => MediaQuery.sizeOf(context).height < 720;

/// Public alias for steps in other files.
bool onboardingIsShortScreen(BuildContext context) => _isShort(context);
