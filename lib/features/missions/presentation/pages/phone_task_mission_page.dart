import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/chunky_progress.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../alarms/presentation/widgets/alarm_card.dart';
import '../../../ringing/presentation/providers/ringing_provider.dart';
import '../../data/shake_counter.dart';
import '../../domain/math_problem.dart';
import '../../domain/mission_type.dart';
import '../widgets/mission_experience.dart';

/// Math and Shake: missions done on the phone itself, no camera.
///
/// Leaving without finishing resumes the ringing alarm, the same contract
/// as the photo and movement missions.
class PhoneTaskMissionPage extends ConsumerStatefulWidget {
  const PhoneTaskMissionPage({super.key, this.alarmId, this.previewMission})
    : assert(alarmId != null || previewMission != null);

  final String? alarmId;
  final MissionType? previewMission;

  bool get isPreview => previewMission != null;

  @override
  ConsumerState<PhoneTaskMissionPage> createState() =>
      _PhoneTaskMissionPageState();
}

class _PhoneTaskMissionPageState extends ConsumerState<PhoneTaskMissionPage> {
  Alarm? _alarm;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final alarm = widget.isPreview
        ? Alarm(
            id: 'mission-preview',
            hour: 0,
            minute: 0,
            missionType: widget.previewMission!,
            missionReps: widget.previewMission!.defaultReps,
            createdAt: DateTime.now(),
          )
        : await ref.read(alarmRepositoryProvider).getById(widget.alarmId!);
    if (mounted) setState(() => _alarm = alarm);
  }

  int get _target {
    final alarm = _alarm!;
    return alarm.missionReps > 0
        ? alarm.missionReps
        : alarm.missionType.defaultReps;
  }

  Future<void> _complete() async {
    if (_completing) return;
    _completing = true;
    Haptics.success();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    if (widget.isPreview) {
      Navigator.of(context).pop(true);
      return;
    }
    await ref.read(ringingSessionProvider.notifier).complete();
    if (mounted) context.go(Routes.wakeSuccess);
  }

  Future<void> _abandon() async {
    if (widget.isPreview) {
      if (mounted) Navigator.of(context).pop(false);
      return;
    }
    await ref.read(ringingSessionProvider.notifier).resumeRinging();
    if (mounted) context.go(Routes.ringing(widget.alarmId!));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final alarm = _alarm;

    return PopScope(
      canPop: widget.isPreview,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_abandon());
      },
      child: Scaffold(
        backgroundColor: AppColors.nightTop,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: widget.isPreview ? l10n.close : l10n.abandonMission,
            onPressed: _abandon,
          ),
          title: Text(
            alarm?.missionType.localizedName(l10n) ?? '',
            style: theme.textTheme.titleMedium!.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          actions: [AlarmActivePill(active: !widget.isPreview)],
        ),
        body: alarm == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: alarm.missionType == MissionType.math
                      ? _MathTask(
                          target: _target,
                          onSolvedAll: _complete,
                          onWrong: () => _logWrong(alarm),
                        )
                      : _ShakeTask(target: _target, onDone: _complete),
                ),
              ),
      ),
    );
  }

  void _logWrong(Alarm alarm) {
    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.missionFailed, {
        'mission': alarm.missionType.name,
        'reason': 'wrong_answer',
      }),
    );
  }
}

class _MathTask extends StatefulWidget {
  const _MathTask({
    required this.target,
    required this.onSolvedAll,
    required this.onWrong,
  });

  final int target;
  final VoidCallback onSolvedAll;
  final VoidCallback onWrong;

  @override
  State<_MathTask> createState() => _MathTaskState();
}

class _MathTaskState extends State<_MathTask> {
  final _random = math.Random();
  late MathProblem _problem = MathProblem.random(_random);
  String _entry = '';
  int _solved = 0;
  bool _wasWrong = false;

  void _press(String key) {
    Haptics.tap();
    setState(() {
      _wasWrong = false;
      if (key == '⌫') {
        if (_entry.isNotEmpty) _entry = _entry.substring(0, _entry.length - 1);
      } else if (_entry.length < MathProblem.maxDigits) {
        _entry += key;
      }
    });
  }

  void _submit() {
    if (_entry.isEmpty) return;
    if (int.parse(_entry) == _problem.answer) {
      Haptics.success();
      setState(() {
        _solved++;
        _entry = '';
      });
      if (_solved >= widget.target) {
        widget.onSolvedAll();
      } else {
        setState(() => _problem = MathProblem.random(_random));
      }
    } else {
      // A fresh sum, not another guess at the same one: working it out is
      // the point, so trial and error mustn't be a shortcut.
      Haptics.warning();
      widget.onWrong();
      setState(() {
        _wasWrong = true;
        _entry = '';
        _problem = MathProblem.random(_random);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final accent = MissionType.math.experienceColor;
    return Column(
      children: [
        ChunkyProgress(value: _solved / widget.target, color: accent),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.mathProgress(
            math.min(_solved + 1, widget.target),
            widget.target,
          ),
          style: theme.textTheme.titleSmall!.copyWith(color: Colors.white70),
        ),
        const Spacer(),
        Semantics(
          liveRegion: true,
          child: Text(
            '${_problem.prompt} = ?',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall!.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _wasWrong ? AppColors.danger : accent,
              width: 2,
            ),
          ),
          child: Text(
            _entry.isEmpty ? ' ' : _entry,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall!.copyWith(color: accent),
          ),
        ),
        SizedBox(
          height: 32,
          child: _wasWrong
              ? Center(
                  child: Text(
                    l10n.mathWrong,
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                )
              : null,
        ),
        const Spacer(),
        _Keypad(onKey: _press, onSubmit: _submit, accent: accent),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onKey,
    required this.onSubmit,
    required this.accent,
  });

  final ValueChanged<String> onKey;
  final VoidCallback onSubmit;
  final Color accent;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['⌫', '0', '✓'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final row in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 60,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: key == '✓'
                                ? accent
                                : AppColors.glass,
                            foregroundColor: key == '✓'
                                ? AppColors.nightTop
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => key == '✓' ? onSubmit() : onKey(key),
                          child: Text(key, style: theme.textTheme.titleLarge),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ShakeTask extends StatefulWidget {
  const _ShakeTask({required this.target, required this.onDone});

  final int target;
  final VoidCallback onDone;

  @override
  State<_ShakeTask> createState() => _ShakeTaskState();
}

class _ShakeTaskState extends State<_ShakeTask> {
  late final ShakeCounter _counter = ShakeCounter(target: widget.target);
  StreamSubscription<int>? _sub;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _sub = _counter.shakes.listen((count) {
      Haptics.tap();
      setState(() => _count = count);
      if (_counter.isComplete) widget.onDone();
    });
    _counter.start();
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    unawaited(_counter.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final accent = MissionType.shake.experienceColor;
    final progress = _count / widget.target;
    return Column(
      children: [
        const Spacer(),
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 14,
                color: accent,
                backgroundColor: AppColors.glass,
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Semantics(
                  liveRegion: true,
                  label: '$_count / ${widget.target}',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_count',
                        style: theme.textTheme.displayLarge!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '/ ${widget.target}',
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Icon(MissionType.shake.icon, color: accent, size: 44),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.shakeInstruction,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall!.copyWith(color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.shakeHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white60),
        ),
        const Spacer(),
      ],
    );
  }
}
