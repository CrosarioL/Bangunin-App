import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../alarms/presentation/widgets/alarm_card.dart';
import '../../../ringing/presentation/mission_flow.dart';
import '../../../ringing/presentation/providers/ringing_provider.dart';
import '../../data/photo_mission_verifier.dart';
import '../../domain/hunt_target.dart';
import '../../domain/mission_type.dart';
import '../widgets/mission_camera.dart';
import '../widgets/mission_experience.dart';

/// Camera mission: capture a photo that satisfies the mission's verifier.
/// Leaving without passing resumes the ringing alarm.
class PhotoMissionPage extends ConsumerStatefulWidget {
  const PhotoMissionPage({
    super.key,
    this.alarmId,
    this.previewMission,
    this.previewReferencePath,
  }) : assert(alarmId != null || previewMission != null);

  final String? alarmId;
  final MissionType? previewMission;
  final String? previewReferencePath;

  bool get isPreview => previewMission != null;

  @override
  ConsumerState<PhotoMissionPage> createState() => _PhotoMissionPageState();
}

enum _VerifyState { idle, verifying, passed, failed }

class _PhotoMissionPageState extends ConsumerState<PhotoMissionPage> {
  Alarm? _alarm;
  _VerifyState _state = _VerifyState.idle;

  /// Why the last attempt failed, so we can say something actionable.
  PhotoFailure? _failure;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  /// Random Hunt only: the object this attempt is looking for.
  HuntAssignment? _hunt;

  Future<void> _load() async {
    final alarm = widget.isPreview
        ? Alarm(
            id: 'mission-preview',
            hour: 0,
            minute: 0,
            missionType: widget.previewMission!,
            objectReferencePath: widget.previewReferencePath,
            createdAt: DateTime.now(),
          )
        : (await ref.read(alarmRepositoryProvider).getById(widget.alarmId!))
              ?.forStep(currentMissionStep(ref));
    HuntAssignment? hunt;
    if (alarm?.missionType == MissionType.randomHunt) {
      // A preview has no ringing session to hold the target, so it rolls its
      // own. A real ring asks the session, so re-entering keeps the object.
      hunt = widget.isPreview
          ? HuntAssignment(
              alarmId: alarm!.id,
              target: HuntTargets.pick(math.Random()),
              rerollsLeft: HuntTargets.maxRerolls,
            )
          : ref.read(ringingSessionProvider.notifier).huntAssignment(alarm!.id);
    }
    if (mounted) {
      setState(() {
        _alarm = alarm;
        _hunt = hunt;
      });
    }
  }

  void _reroll() {
    final current = _hunt;
    if (current == null || current.rerollsLeft <= 0) return;
    Haptics.selection();
    final next = widget.isPreview
        ? HuntAssignment(
            alarmId: current.alarmId,
            target: HuntTargets.pick(
              math.Random(),
              exclude: {current.target.id},
            ),
            rerollsLeft: current.rerollsLeft - 1,
          )
        : ref.read(ringingSessionProvider.notifier).rerollHunt(current.alarmId);
    if (next == null) return;
    setState(() {
      _hunt = next;
      _state = _VerifyState.idle;
      _failure = null;
    });
  }

  Future<void> _onCaptured(String path) async {
    final alarm = _alarm;
    if (alarm == null) return;
    setState(() => _state = _VerifyState.verifying);

    final verifier = ref.read(photoMissionVerifierProvider);
    final hunt = _hunt;
    final verification = hunt != null
        ? await verifier.verifyHunt(hunt.target, path)
        : await verifier.verify(
            alarm.missionType,
            path,
            referencePath: alarm.objectReferencePath,
          );
    // Nothing in the product ever shows this capture again (there's no
    // gallery), and a failed attempt lets the user retake immediately, so
    // the file is disposable the moment verification finishes. Without
    // this, every attempt — pass or fail, every morning — leaves a photo
    // behind indefinitely.
    unawaited(_deleteQuietly(path));
    if (!mounted) return;

    if (verification.passed) {
      setState(() => _state = _VerifyState.passed);
      Haptics.success();
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      if (widget.isPreview) {
        Navigator.of(context).pop(true);
        return;
      }
      await finishMissionStep(context, ref, widget.alarmId!);
    } else {
      Haptics.warning();
      unawaited(
        ref.read(analyticsProvider).logEvent(AnalyticsEvents.missionFailed, {
          'mission': alarm.missionType.name,
          'reason': verification.failure?.name ?? 'unknown',
          'target': ?hunt?.target.id,
        }),
      );
      setState(() {
        _failure = verification.failure;
        _state = _VerifyState.failed;
      });
    }
  }

  /// Deliberately hedged wording. These checks are heuristics, not proof, so
  /// they say "we couldn't verify", never "that is not grass".
  String _failureMessage(BuildContext context, AppLocalizations l10n) =>
      switch (_failure) {
        PhotoFailure.targetNotFound => l10n.photoFailTargetNotFound(
          _huntName(context) ?? '',
        ),
        PhotoFailure.tooDark => l10n.photoFailTooDark,
        PhotoFailure.tooBright => l10n.photoFailTooBright,
        PhotoFailure.notEnoughTexture => l10n.photoFailNotEnoughDetail,
        PhotoFailure.surfaceDoesNotLookRight => l10n.photoFailSurface,
        PhotoFailure.sceneNotLive => l10n.photoFailNotLive,
        PhotoFailure.doesNotMatchReference => l10n.photoFailNoMatch,
        PhotoFailure.noHandVisible => l10n.photoFailNoHand,
        PhotoFailure.missingReference => l10n.photoFailNoReference,
        PhotoFailure.invalidImage || null => l10n.missionPhotoFailed,
      };

  Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Best-effort cleanup; a stray temp file is not worth surfacing.
    }
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
  void dispose() {
    final reference = widget.previewReferencePath;
    if (reference != null) unawaited(_deleteQuietly(reference));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final alarm = _alarm;

    final mission = alarm?.missionType;
    final status = switch (_state) {
      _VerifyState.verifying => l10n.verifyingPhoto,
      _VerifyState.passed => l10n.poseGuidanceComplete,
      _VerifyState.failed => _failureMessage(context, l10n),
      _VerifyState.idle => null,
    };

    return PopScope(
      canPop: widget.isPreview,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_abandon());
      },
      child: Scaffold(
        backgroundColor: AppColors.nightTop,
        extendBodyBehindAppBar: true,
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
                top: false,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MissionCamera(
                      mission: alarm.missionType,
                      onCaptured: _onCaptured,
                    ),
                    Positioned(
                      right: -8,
                      bottom: 250,
                      child: MissionMascotCoach(mission: alarm.missionType),
                    ),
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: 126,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: MissionGlassPanel(
                              key: ValueKey((_state, _hunt?.target.id)),
                              mission: alarm.missionType,
                              icon: _hunt?.target.icon,
                              title: _instruction(alarm.missionType, context),
                              subtitle: _subtitle(alarm.missionType, context),
                              status: status,
                              statusColor: switch (_state) {
                                _VerifyState.failed => AppColors.danger,
                                _VerifyState.passed => AppColors.success,
                                _ => mission?.experienceColor,
                              },
                              statusIcon: switch (_state) {
                                _VerifyState.verifying =>
                                  Icons.hourglass_top_rounded,
                                _VerifyState.failed => Icons.error_rounded,
                                _ => Icons.check_circle_rounded,
                              },
                            ),
                          ),
                          if (_hunt case final hunt?) ...[
                            const SizedBox(height: AppSpacing.sm),
                            _RerollButton(
                              rerollsLeft: hunt.rerollsLeft,
                              onPressed: _state == _VerifyState.verifying
                                  ? null
                                  : _reroll,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String? _huntName(BuildContext context) =>
      _hunt?.target.name(Localizations.localeOf(context).languageCode);

  String _instruction(MissionType mission, BuildContext context) {
    final l10n = context.l10n;
    return switch (mission) {
      MissionType.randomHunt => l10n.huntFind(
        (_huntName(context) ?? '').toUpperCase(),
      ),
      MissionType.objectHunt => l10n.photoInstructionObject,
      MissionType.skyPhoto => l10n.photoInstructionSky,
      MissionType.grassPhoto => l10n.photoInstructionGrass,
      MissionType.makeBed => l10n.photoInstructionBed,
      _ => '',
    };
  }

  String _subtitle(MissionType mission, BuildContext context) {
    final id = Localizations.localeOf(context).languageCode == 'id';
    return switch (mission) {
      MissionType.randomHunt => context.l10n.huntInstruction,
      MissionType.skyPhoto =>
        id
            ? 'Cari langit pagi yang nyata dan terang.'
            : 'Find the real, bright morning sky.',
      MissionType.grassPhoto =>
        id
            ? 'Dekatkan kamera agar tekstur rumput terlihat.'
            : 'Move close enough to show real grass texture.',
      MissionType.makeBed =>
        id
            ? 'Pastikan bantal, seprai, dan area kasur terlihat.'
            : 'Keep the pillows, sheets, and bed area visible.',
      MissionType.objectHunt =>
        id
            ? 'Samakan sudut dan jarak dengan foto referensi.'
            : 'Match the angle and distance of your reference.',
      _ => '',
    };
  }
}

/// "Don't have it? Swap" — the Random Hunt escape hatch for an object the
/// user genuinely doesn't own. Capped, so it can't shop for the easy one.
class _RerollButton extends StatelessWidget {
  const _RerollButton({required this.rerollsLeft, required this.onPressed});

  final int rerollsLeft;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canReroll = rerollsLeft > 0;
    return TextButton.icon(
      onPressed: canReroll ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.nightTop.withValues(alpha: .62),
        disabledForegroundColor: Colors.white60,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      icon: Icon(canReroll ? Icons.shuffle_rounded : Icons.search_rounded),
      label: Text(
        canReroll ? l10n.huntReroll(rerollsLeft) : l10n.huntNoRerolls,
      ),
    );
  }
}
