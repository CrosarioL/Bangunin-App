import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_card.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../app/widgets/swipe_carousel.dart';
import '../../../../core/services/audio/alarm_audio_service.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/time_format.dart';
import '../../../alarms/domain/alarm_clip.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../alarms/presentation/providers/alarm_capability_provider.dart';
import '../../../alarms/presentation/widgets/alarm_card.dart';
import '../../../alarms/presentation/widgets/mission_picker_sheet.dart';
import '../../../alarms/presentation/widgets/sound_picker_sheet.dart';
import '../../../missions/domain/mission_type.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_flow_page.dart';

/// Step 1 — the hook: ordinary alarms lose to a half-asleep thumb.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    // The hook gets the whole slide: one chick and the line, straight on the
    // sky. No header card (that would put a second chick on screen) — the
    // later steps keep theirs because they frame a control underneath.
    return MaxWidthBox(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            // Staged entrance: chick, then the problem, then — on its own
            // beat — the promise lands with a small punch.
            const _Reveal(
              start: 0,
              end: 0.35,
              child: Center(child: BanguninMascot(size: 230, flap: true)),
            ),
            const SizedBox(height: AppSpacing.xl),
            _Reveal(
              start: 0.2,
              end: 0.55,
              child: Text(
                l10n.onboardingWelcomeTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Reveal(
              start: 0.65,
              end: 1,
              punch: true,
              child: Text(
                l10n.onboardingWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(label: l10n.getStarted, onPressed: onNext),
          ],
        ),
      ),
    );
  }
}

/// Fades and slides [child] up during the [start]–[end] slice of the welcome
/// entrance. With [punch] it overshoots slightly and settles, so the line
/// lands rather than just appears.
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.start,
    required this.end,
    required this.child,
    this.punch = false,
  });

  static const _total = Duration(milliseconds: 1800);

  final double start;
  final double end;
  final bool punch;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _total,
      builder: (context, t, child) {
        final local = Interval(start, end).transform(t);
        final eased = Curves.easeOutCubic.transform(local);
        final scale = punch
            ? 0.85 + 0.15 * Curves.easeOutBack.transform(local)
            : 1.0;
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - eased)),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: child,
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
        child: AppCard(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 210,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Theme.of(context).brightness,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: Theme.of(
                    context,
                  ).textTheme.headlineMedium,
                ),
              ),
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
      ),
    );
  }
}

/// Step 3 — the alarm sound, in the same swipe carousel as the editor's
/// sound picker. The card in front is the choice; landing on one plays it.
/// Onboarding memes lead, then the plain sounds. The pick is logged at
/// completion as a selection-rate signal.
class SoundStep extends ConsumerStatefulWidget {
  const SoundStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<SoundStep> createState() => _SoundStepState();
}

class _SoundStepState extends ConsumerState<SoundStep> {
  static final _options = [
    // Every sound, same order as the editor: new users should see the
    // whole catalog, not a shortlist.
    for (final clip in AlarmClips.all) SoundOption.clip(clip),
    ...SoundOption.bundled,
  ];

  // Read in initState, not lazily: a lazy read first touched in dispose()
  // (step left without playing anything) uses `ref` after unmount.
  late final AlarmAudioService _audio;
  late final int _initialPage;
  Timer? _previewDebounce;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(alarmAudioServiceProvider);
    // Untouched answers still say Classic; start new users on the first
    // meme instead, since that is the card they see first. Deferred: the
    // provider can't change while this widget is building.
    final answers = ref.read(onboardingAnswersProvider);
    final first = _options.first.clip;
    final untouched =
        first != null &&
        answers.clipId == null &&
        answers.sound == AlarmSound.classic;
    _initialPage = untouched ? 0 : _indexOf(answers);
    if (untouched) {
      Future.microtask(
        () => ref.read(onboardingAnswersProvider.notifier).setClip(first.id),
      );
    }
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    unawaited(_audio.stopPreview());
    super.dispose();
  }

  int _indexOf(OnboardingAnswers answers) {
    final index = _options.indexWhere(
      (o) => answers.clipId != null
          ? o.clip?.id == answers.clipId
          : o.sound == answers.sound,
    );
    return index < 0 ? 0 : index;
  }

  void _select(SoundOption option) {
    final notifier = ref.read(onboardingAnswersProvider.notifier);
    final clip = option.clip;
    if (clip != null) {
      notifier.setClip(clip.id);
    } else {
      notifier.setSound(option.sound!);
    }
    // Debounced so a fast flick plays only the card you stop on.
    _previewDebounce?.cancel();
    _previewDebounce = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(option.preview(_audio)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return OnboardingStepScaffold(
      title: l10n.onboardingSoundTitle,
      subtitle: l10n.onboardingSoundSubtitle,
      ctaLabel: l10n.continueLabel,
      fullBleedChild: true,
      onNext: () {
        unawaited(_audio.stopPreview());
        widget.onNext();
      },
      child: Center(
        child: SwipeCarousel(
          itemCount: _options.length,
          initialPage: _initialPage,
          height: 340,
          onPageChanged: (page) => _select(_options[page]),
          onTapFocused: (index) {
            Haptics.tap();
            unawaited(_options[index].preview(_audio));
          },
          itemBuilder: (context, index, focused) =>
              SoundCard(option: _options[index], focused: focused),
        ),
      ),
    );
  }
}

/// Step 4 — the mission, the product's whole difference, in the same swipe
/// carousel as the editor's mission picker. The card in front is the choice.
/// Random Hunt comes first and is badged: it needs no setup and it's the
/// one people film.
class MissionStep extends ConsumerWidget {
  const MissionStep({super.key, required this.onNext});

  final VoidCallback onNext;

  /// Missions that work with zero setup. Object Hunt needs a reference photo
  /// registered first, and pushups need the phone propped on the floor, so
  /// both are left for the editor.
  static const missions = [
    MissionType.randomHunt,
    MissionType.math,
    MissionType.shake,
    MissionType.squats,
    MissionType.skyPhoto,
    MissionType.makeBed,
    MissionType.none,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final initial = missions.indexOf(
      ref.read(onboardingAnswersProvider).mission,
    );

    return OnboardingStepScaffold(
      title: l10n.onboardingMissionTitle,
      subtitle: l10n.onboardingMissionSubtitle,
      ctaLabel: l10n.continueLabel,
      fullBleedChild: true,
      onNext: onNext,
      child: Center(
        child: SwipeCarousel(
          itemCount: missions.length,
          initialPage: initial < 0 ? 0 : initial,
          onPageChanged: (page) => ref
              .read(onboardingAnswersProvider.notifier)
              .setMission(missions[page]),
          itemBuilder: (context, index, focused) {
            final mission = missions[index];
            return MissionCard(
              mission: mission,
              name: mission.localizedName(l10n),
              description: mission.localizedDescription(l10n),
              focused: focused,
              badge: mission == MissionType.randomHunt
                  ? l10n.onboardingMissionBadge
                  : null,
            );
          },
        ),
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
    // On iOS 26+ this is what makes the alarm a real alarm (full screen,
    // through Silent Mode and Focus) instead of a notification. It must be
    // asked here, on the screen that explains why: the first alarm is
    // scheduled right after onboarding and uses whichever engine is
    // authorized by then. A no-op answer ("unsupported") elsewhere.
    await ref.read(requestAlarmAuthorizationProvider)();
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
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final point in [
                l10n.notifyPointOnTime,
                l10n.notifyPointLockScreen,
                l10n.notifyPointNoSpam,
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          point,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
            const BanguninMascot(pose: MascotPose.crowing, size: 130),
            const SizedBox(height: AppSpacing.lg),
            // Exactly what the home screen will show, so the first thing
            // after the paywall is already familiar.
            IgnorePointer(
              child: AlarmCard(
                alarm: answers.toAlarm(
                  Alarm(id: 'preview', hour: 0, minute: 0, createdAt: from),
                ),
                onTap: () {},
                onToggle: (_) {},
              ),
            ),
            const SizedBox(height: AppSpacing.md),
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
