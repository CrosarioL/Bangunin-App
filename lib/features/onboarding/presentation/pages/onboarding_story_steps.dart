import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_card.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../alarms/domain/alarm_clip.dart';
import '../../../alarms/presentation/widgets/sound_picker_sheet.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_flow_page.dart';

// The story half of onboarding: problem → promise → demo → a short survey
// whose answers come back as the cost of snoozing and a personal plan. No
// free trial is mentioned anywhere; the paywall states the price plainly.

/// A full-slide statement: one chick, a headline and a line under it.
/// Used for the problem, the promise and the fix.
class StoryStep extends StatelessWidget {
  const StoryStep({
    super.key,
    required this.pose,
    required this.title,
    required this.body,
    required this.onNext,
    this.ctaLabel,
  });

  final MascotPose pose;
  final String title;
  final String body;
  final VoidCallback onNext;
  final String? ctaLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingFullSlide(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FadeUp(
            child: Center(
              child: BanguninMascot(
                pose: pose,
                size: OnboardingFullSlide.mascotSize(context, 190),
                flap: pose == MascotPose.happy,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _FadeUp(
            delay: .15,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FadeUp(
            delay: .3,
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: .78),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      button: PrimaryButton(
        label: ctaLabel ?? context.l10n.continueLabel,
        onPressed: onNext,
      ),
    );
  }
}

/// Fades and lifts its child in once, [delay] (0..1) into a short entrance.
class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.child, this.delay = 0});

  final Widget child;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, t, child) {
        final local = Interval(delay, math.min(1, delay + .6)).transform(t);
        final eased = Curves.easeOutCubic.transform(local);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - eased)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// "How it works": a looping, animated phone showing one Bangunin morning —
/// the alarm rings, the mission starts, a photo of the sky is taken and
/// verified on the phone, the alarm goes quiet. Drawn in Flutter, so it follows the app's language and theme
/// and adds nothing to the download.
class DemoStep extends StatelessWidget {
  const DemoStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingStepScaffold(
      title: l10n.obDemoTitle,
      subtitle: l10n.obDemoSubtitle,
      ctaLabel: l10n.continueLabel,
      onNext: onNext,
      scrollable: false,
      // Scales the whole demo down to the space available, so on a small
      // phone it shrinks instead of running off the bottom of the screen.
      child: const Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: ProductDemo()),
      ),
    );
  }
}

/// The animated phone used by [DemoStep]. Public so it can be tested and
/// reused (for example on the website or a store preview).
class ProductDemo extends StatefulWidget {
  const ProductDemo({super.key});

  /// One full morning, then it starts again.
  static const loop = Duration(seconds: 9);

  @override
  State<ProductDemo> createState() => _ProductDemoState();
}

enum _DemoScene { ringing, mission, done }

class _ProductDemoState extends State<ProductDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: ProductDemo.loop,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduce Motion: hold the most telling frame (mid-mission) instead of
    // looping a ringing phone at someone who asked for less movement.
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock
        ..stop()
        ..value = .5;
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  // Timeline (fraction of the loop):
  //  0.00–0.30 ringing, the Start mission button pulses, then is "tapped"
  //  0.30–0.75 photo mission: frame the sky, snap, verified
  //  0.75–1.00 done: alarm off, good morning
  static _DemoScene _sceneAt(double t) => t < .30
      ? _DemoScene.ringing
      : t < .75
      ? _DemoScene.mission
      : _DemoScene.done;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _clock,
      builder: (context, _) {
        final t = _clock.value;
        final scene = _sceneAt(t);
        final caption = switch (scene) {
          _DemoScene.ringing => l10n.obDemoRinging,
          _DemoScene.mission => l10n.obDemoMission,
          _DemoScene.done => l10n.obDemoDone,
        };
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Phone(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: switch (scene) {
                  _DemoScene.ringing => _RingingScreen(
                    key: const ValueKey('ringing'),
                    t: t / .30,
                  ),
                  _DemoScene.mission => _PhotoScreen(
                    key: const ValueKey('mission'),
                    t: (t - .30) / .45,
                  ),
                  _DemoScene.done => const _DoneScreen(key: ValueKey('done')),
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _StepDots(active: scene.index),
            const SizedBox(height: AppSpacing.sm),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                caption,
                key: ValueKey(caption),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Phone extends StatelessWidget {
  const _Phone({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 380,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F1E),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: Colors.white.withValues(alpha: .18),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .18),
            blurRadius: 36,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.nightTop, AppColors.nightMid],
            ),
          ),
          child: SizedBox.expand(child: child),
        ),
      ),
    );
  }
}

class _RingingScreen extends StatelessWidget {
  const _RingingScreen({super.key, required this.t});

  /// Progress through this scene, 0..1.
  final double t;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final shake = math.sin(t * math.pi * 18) * .18 * (t < .8 ? 1 : 0);
    // The button is "tapped" near the end of the scene.
    final pressed = t > .8;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Transform.rotate(
            angle: shake,
            child: const Icon(
              Icons.alarm_rounded,
              size: 58,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '06:30',
            style: theme.textTheme.displaySmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          const BanguninMascot(
            pose: MascotPose.crowing,
            size: 86,
            animateIdle: false,
            interactive: false,
          ),
          const Spacer(),
          AnimatedScale(
            scale: pressed ? .92 : 1 + .04 * math.sin(t * math.pi * 6).abs(),
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.horizon],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                l10n.obDemoStartMission,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge!.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// The photo mission in miniature: the sky in the viewfinder, a scanning
/// frame, the shutter, then the on-device check passing.
class _PhotoScreen extends StatelessWidget {
  const _PhotoScreen({super.key, required this.t});

  /// Progress through this scene, 0..1.
  final double t;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final flash = t > .52 && t < .62 ? 1 - ((t - .52) / .10) : 0.0;
    final verified = t >= .6;
    final scan = (t / .52).clamp(0.0, 1.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        // The viewfinder: a morning sky with drifting clouds.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4FA3F7), Color(0xFFBFE3FF)],
            ),
          ),
        ),
        Positioned(
          top: 70,
          left: 20 + 14 * t,
          child: Icon(
            Icons.cloud_rounded,
            size: 54,
            color: Colors.white.withValues(alpha: .95),
          ),
        ),
        Positioned(
          top: 150,
          right: 18 + 10 * t,
          child: Icon(
            Icons.cloud_rounded,
            size: 40,
            color: Colors.white.withValues(alpha: .85),
          ),
        ),
        // What to photograph.
        Positioned(
          top: 14,
          left: 10,
          right: 10,
          child: _Chip(
            icon: Icons.photo_camera_rounded,
            label: l10n.obDemoPhotoPrompt,
            color: Colors.black.withValues(alpha: .45),
          ),
        ),
        // The scanning frame, then the result.
        Positioned(
          left: 22,
          right: 22,
          top: 52,
          bottom: 92,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: verified ? AppColors.success : Colors.white,
                width: verified ? 4 : 2,
              ),
            ),
            child: verified
                ? null
                : Align(
                    alignment: Alignment(0, -1 + 2 * scan),
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .7),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        if (verified)
          Positioned(
            left: 10,
            right: 10,
            bottom: 104,
            child: _Chip(
              icon: Icons.check_circle_rounded,
              label: l10n.obDemoVerified,
              color: AppColors.success,
            ),
          ),
        // Shutter button.
        Positioned(
          left: 0,
          right: 0,
          bottom: 22,
          child: Center(
            child: AnimatedScale(
              scale: t > .48 && t < .58 ? .85 : 1,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .5),
                    width: 5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Shutter flash.
        if (flash > 0)
          IgnorePointer(
            child: ColoredBox(color: Colors.white.withValues(alpha: flash)),
          ),
      ],
    );
  }
}

/// A small label pill on the demo phone. Shrinks rather than overflowing
/// when the text is long or the user's text size is large.
class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 15),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneScreen extends StatelessWidget {
  const _DoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.nightMid, AppColors.horizon],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BanguninMascot(
            pose: MascotPose.celebrating,
            size: 110,
            animateIdle: false,
            interactive: false,
          ),
          const SizedBox(height: AppSpacing.md),
          const Icon(
            Icons.notifications_off_rounded,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.obDemoGoodMorning,
            style: theme.textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .25),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}

/// "What should we call you?" Optional: the button works with an empty
/// field, and an empty name just means the generic wording later.
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

  void _submit() {
    ref.read(onboardingAnswersProvider.notifier).setName(_controller.text);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingStepScaffold(
      title: l10n.obNameTitle,
      subtitle: l10n.obNameSubtitle,
      ctaLabel: l10n.continueLabel,
      onNext: _submit,
      child: AppCard(
        child: TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 24,
          autofillHints: const [AutofillHints.givenName],
          style: Theme.of(context).textTheme.titleLarge,
          decoration: InputDecoration(
            hintText: l10n.obNameHint,
            border: InputBorder.none,
            counterText: '',
          ),
          onSubmitted: (_) => _submit(),
        ),
      ),
    );
  }
}

/// A single-choice question. Tapping an option selects it and moves on
/// after a short beat, so the survey feels quick; the button is there for
/// anyone who taps it instead.
class ChoiceStep<T> extends StatelessWidget {
  const ChoiceStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    required this.labelOf,
    required this.selected,
    required this.onSelect,
    required this.onNext,
    this.iconOf,
  });

  final String title;
  final String? subtitle;
  final List<T> options;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;
  final T? selected;
  final ValueChanged<T> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return OnboardingStepScaffold(
      title: title,
      subtitle: subtitle,
      ctaLabel: context.l10n.continueLabel,
      ctaEnabled: selected != null,
      onNext: onNext,
      child: Column(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Semantics(
                button: true,
                selected: option == selected,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Haptics.selection();
                    onSelect(option);
                    await Future<void>.delayed(
                      const Duration(milliseconds: 260),
                    );
                    onNext();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: onboardingIsShortScreen(context)
                          ? 10
                          : AppSpacing.md + 2,
                    ),
                    decoration: BoxDecoration(
                      color: option == selected
                          ? AppColors.primary.withValues(alpha: .18)
                          : (isDark ? AppColors.glass : AppColors.glassLight),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusControl,
                      ),
                      border: Border.all(
                        color: option == selected
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: .08),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (iconOf != null) ...[
                          Icon(iconOf!(option), color: AppColors.primary),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Expanded(
                          child: Text(
                            labelOf(option),
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          option == selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: option == selected
                              ? AppColors.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The age question.
class AgeStep extends ConsumerWidget {
  const AgeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ChoiceStep<AgeRange>(
      title: l10n.obAgeTitle,
      options: AgeRange.values,
      selected: ref.watch(onboardingAnswersProvider).age,
      labelOf: (age) => switch (age) {
        AgeRange.under18 => l10n.obAgeUnder18,
        AgeRange.from18to24 => '18–24',
        AgeRange.from25to34 => '25–34',
        AgeRange.from35to44 => '35–44',
        AgeRange.over45 => '45+',
      },
      onSelect: ref.read(onboardingAnswersProvider.notifier).setAge,
      onNext: onNext,
    );
  }
}

/// How often the user snoozes. Feeds [CostStep].
class SnoozeStep extends ConsumerWidget {
  const SnoozeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ChoiceStep<SnoozeHabit>(
      title: l10n.obSnoozeTitle,
      options: SnoozeHabit.values,
      selected: ref.watch(onboardingAnswersProvider).snooze,
      labelOf: (habit) => switch (habit) {
        SnoozeHabit.never => l10n.obSnoozeNever,
        SnoozeHabit.few => l10n.obSnoozeFew,
        SnoozeHabit.some => l10n.obSnoozeSome,
        SnoozeHabit.lots => l10n.obSnoozeLots,
      },
      onSelect: ref.read(onboardingAnswersProvider.notifier).setSnooze,
      onNext: onNext,
    );
  }
}

/// "{Name}, snoozing costs you N hours a year." Worked out from the snooze
/// answer: nine minutes a snooze, every morning, for a year.
class CostStep extends ConsumerWidget {
  const CostStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final answers = ref.watch(onboardingAnswersProvider);
    final hours = (answers.snooze ?? SnoozeHabit.few).hoursPerYear;
    final days = (hours / 24).round();
    final never = answers.snooze == SnoozeHabit.never;

    final title = never
        ? l10n.obProblemTitle
        : answers.name.isNotEmpty
        ? l10n.obCostTitleNamed(answers.name, hours)
        : l10n.obCostTitle(hours);

    return OnboardingFullSlide(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!never)
            _FadeUp(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: hours.toDouble()),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Text(
                  '${value.round()}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.sunsetCoral,
                  ),
                ),
              ),
            )
          else
            _FadeUp(
              child: Center(
                child: BanguninMascot(
                  pose: MascotPose.sleeping,
                  size: OnboardingFullSlide.mascotSize(context, 170),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          _FadeUp(
            delay: .2,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FadeUp(
            delay: .35,
            child: Text(
              never ? l10n.obCostNever : l10n.obCostBody(days),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: .78),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      button: PrimaryButton(label: l10n.continueLabel, onPressed: onNext),
    );
  }
}

/// What oversleeping costs beyond the hours.
class LoseStep extends StatelessWidget {
  const LoseStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingStepScaffold(
      title: l10n.obLoseTitle,
      ctaLabel: l10n.continueLabel,
      onNext: onNext,
      child: _PointList(
        points: [
          (Icons.directions_run_rounded, l10n.obLoseLate),
          (Icons.nightlight_round, l10n.obLoseSahur),
          (Icons.bolt_rounded, l10n.obLoseRush),
          (Icons.heart_broken_rounded, l10n.obLoseTrust),
        ],
        color: AppColors.sunsetCoral,
      ),
    );
  }
}

/// Why they want to get up. Personalises the plan.
class GoalStep extends ConsumerWidget {
  const GoalStep({super.key, required this.onNext});

  final VoidCallback onNext;

  static String labelOf(AppLocalizations l10n, WakeReason reason) =>
      switch (reason) {
        WakeReason.work => l10n.obGoalWork,
        WakeReason.school => l10n.obGoalSchool,
        WakeReason.sahur => l10n.obGoalSahur,
        WakeReason.exercise => l10n.obGoalExercise,
        WakeReason.productive => l10n.obGoalProductive,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ChoiceStep<WakeReason>(
      title: l10n.obGoalTitle,
      options: WakeReason.values,
      selected: ref.watch(onboardingAnswersProvider).reason,
      labelOf: (reason) => labelOf(l10n, reason),
      iconOf: (reason) => switch (reason) {
        WakeReason.work => Icons.work_rounded,
        WakeReason.school => Icons.school_rounded,
        WakeReason.sahur => Icons.mosque_rounded,
        WakeReason.exercise => Icons.fitness_center_rounded,
        WakeReason.productive => Icons.trending_up_rounded,
      },
      onSelect: ref.read(onboardingAnswersProvider.notifier).setReason,
      onNext: onNext,
    );
  }
}

/// "Where did you hear about Bangunin?" Attribution for marketing.
class HeardFromStep extends ConsumerWidget {
  const HeardFromStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ChoiceStep<HeardFrom>(
      title: l10n.obSourceTitle,
      options: HeardFrom.values,
      selected: ref.watch(onboardingAnswersProvider).heardFrom,
      labelOf: (from) => switch (from) {
        HeardFrom.tiktok => 'TikTok',
        HeardFrom.instagram => 'Instagram',
        HeardFrom.youtube => 'YouTube',
        HeardFrom.friend => l10n.obSourceFriend,
        HeardFrom.store => l10n.obSourceStore,
        HeardFrom.other => l10n.obSourceOther,
      },
      onSelect: ref.read(onboardingAnswersProvider.notifier).setHeardFrom,
      onNext: onNext,
    );
  }
}

/// Social proof without testimonials: there are no real reviews to quote
/// yet, and invented ones are fake reviews (App Store 5.6, Play policy).
/// What the app actually does, stated plainly, instead.
class ProofStep extends StatelessWidget {
  const ProofStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final soundCount = AlarmClips.all.length + SoundOption.bundled.length;
    return OnboardingStepScaffold(
      title: l10n.obProofTitle,
      subtitle: l10n.obProofSubtitle,
      ctaLabel: l10n.continueLabel,
      onNext: onNext,
      child: _PointList(
        points: [
          (Icons.flag_rounded, l10n.obProofMissions),
          (Icons.music_note_rounded, l10n.obProofSounds(soundCount)),
          (Icons.volume_up_rounded, l10n.obProofReal),
          (Icons.lock_rounded, l10n.obProofPrivate),
        ],
        color: AppColors.success,
      ),
    );
  }
}

/// "{Name}'s 7-day wake-up plan", built from their answers.
class PlanStep extends ConsumerWidget {
  const PlanStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final answers = ref.watch(onboardingAnswersProvider);
    final time = TimeFormat.clock(
      context,
      answers.wakeGoalHour,
      answers.wakeGoalMinute,
    );
    final reason = answers.reason;
    final days = [
      l10n.obPlanDay1(time),
      l10n.obPlanDay3,
      l10n.obPlanDay5,
      l10n.obPlanDay7,
    ];
    return OnboardingStepScaffold(
      title: answers.name.isNotEmpty
          ? l10n.obPlanTitleNamed(answers.name)
          : l10n.obPlanTitle,
      subtitle: reason == null
          ? null
          : l10n.obPlanGoal(GoalStep.labelOf(l10n, reason)),
      ctaLabel: l10n.continueLabel,
      onNext: onNext,
      child: AppCard(
        child: Column(
          children: [
            for (var i = 0; i < days.length; i++)
              _FadeUp(
                delay: i * .15,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i == days.length - 1
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: .18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          i == days.length - 1
                              ? Icons.emoji_events_rounded
                              : Icons.wb_sunny_rounded,
                          size: 17,
                          color: i == days.length - 1
                              ? AppColors.onPrimary
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          days[i],
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PointList extends StatelessWidget {
  const _PointList({required this.points, required this.color});

  final List<(IconData, String)> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < points.length; i++)
            _FadeUp(
              delay: i * .15,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: onboardingIsShortScreen(context) ? 5 : 10,
                ),
                child: Row(
                  children: [
                    Icon(points[i].$1, color: color, size: 26),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        points[i].$2,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
