import 'dart:async';
import 'dart:io';

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
import '../../../ringing/presentation/providers/ringing_provider.dart';
import '../../data/photo_mission_verifier.dart';
import '../../domain/mission_type.dart';
import '../widgets/mission_camera.dart';

/// Camera mission: capture a photo that satisfies the mission's verifier.
/// Leaving without passing resumes the ringing alarm.
class PhotoMissionPage extends ConsumerStatefulWidget {
  const PhotoMissionPage({super.key, required this.alarmId});

  final String alarmId;

  @override
  ConsumerState<PhotoMissionPage> createState() => _PhotoMissionPageState();
}

enum _VerifyState { idle, verifying, failed }

class _PhotoMissionPageState extends ConsumerState<PhotoMissionPage> {
  Alarm? _alarm;
  _VerifyState _state = _VerifyState.idle;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final alarm = await ref
        .read(alarmRepositoryProvider)
        .getById(widget.alarmId);
    if (mounted) setState(() => _alarm = alarm);
  }

  Future<void> _onCaptured(String path) async {
    final alarm = _alarm;
    if (alarm == null) return;
    setState(() => _state = _VerifyState.verifying);

    await ref.read(ringingSessionProvider.notifier).recordMissionAttempt();
    var verdict = await ref
        .read(photoMissionVerifierProvider)
        .verify(
          alarm.missionType,
          path,
          referencePath: alarm.objectReferencePath,
        );
    if (verdict == PhotoVerdict.pass &&
        alarm.missionType == MissionType.makeBed) {
      try {
        final containsBed = await ref
            .read(imageLabelServiceProvider)
            .containsBed(path);
        if (!containsBed) verdict = PhotoVerdict.fail;
      } on Exception {
        verdict = PhotoVerdict.fail;
      }
    }
    // Nothing in the product ever shows this capture again (there's no
    // gallery), and a failed attempt lets the user retake immediately, so
    // the file is disposable the moment verification finishes. Without
    // this, every attempt — pass or fail, every morning — leaves a photo
    // behind indefinitely.
    unawaited(_deleteQuietly(path));
    if (!mounted) return;

    if (verdict == PhotoVerdict.pass) {
      await ref
          .read(ringingSessionProvider.notifier)
          .complete(
            verificationMethod: alarm.missionType == MissionType.makeBed
                ? 'on_device_image_label'
                : 'on_device_photo',
          );
      if (mounted) context.go(Routes.wakeSuccess);
    } else {
      Haptics.warning();
      unawaited(
        ref.read(analyticsProvider).logEvent(AnalyticsEvents.missionFailed, {
          'mission': alarm.missionType.name,
        }),
      );
      setState(() => _state = _VerifyState.failed);
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Best-effort cleanup; a stray temp file is not worth surfacing.
    }
  }

  Future<void> _abandon() async {
    await ref.read(ringingSessionProvider.notifier).resumeRinging();
    if (mounted) context.go(Routes.ringing(widget.alarmId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final alarm = _alarm;
    final visual = alarm == null ? null : _visualFor(alarm.missionType);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_abandon());
      },
      child: Scaffold(
        backgroundColor: visual?.background,

        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: l10n.abandonMission,
            onPressed: _abandon,
          ),
          title: Text(
            alarm?.missionType.localizedName(l10n) ?? '',
            style: theme.textTheme.titleMedium!.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: alarm == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Icon(visual!.icon, color: visual.accent, size: 38),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _instruction(alarm.missionType, l10n),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: switch (_state) {
                          _VerifyState.verifying => Text(
                            l10n.verifyingPhoto,
                            key: const ValueKey('verifying'),
                            style: TextStyle(color: visual.accent),
                          ),
                          _VerifyState.failed => Text(
                            l10n.missionPhotoFailed,
                            key: const ValueKey('failed'),
                            style: const TextStyle(color: AppColors.danger),
                          ),
                          _VerifyState.idle => const SizedBox(height: 20),
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: MissionCamera(
                          onCaptured: _onCaptured,
                          overlay: _MissionOverlay(
                            mission: alarm.missionType,
                            accent: visual.accent,
                          ),
                          accentColor: visual.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String _instruction(MissionType mission, AppLocalizations l10n) =>
      switch (mission) {
        MissionType.objectHunt => l10n.photoInstructionObject,
        MissionType.skyPhoto => l10n.photoInstructionSky,
        MissionType.grassPhoto => l10n.photoInstructionGrass,
        MissionType.makeBed => l10n.photoInstructionBed,
        _ => '',
      };

  _MissionVisual _visualFor(MissionType mission) => switch (mission) {
    MissionType.objectHunt => const _MissionVisual(
      Color(0xFFB792FF),
      Color(0xFF100A1A),
      Icons.center_focus_strong_rounded,
    ),
    MissionType.skyPhoto => const _MissionVisual(
      Color(0xFF55C7FF),
      Color(0xFF071523),
      Icons.wb_twilight_rounded,
    ),
    MissionType.grassPhoto => const _MissionVisual(
      Color(0xFF72DE79),
      Color(0xFF07180C),
      Icons.grass_rounded,
    ),
    MissionType.makeBed => const _MissionVisual(
      Color(0xFFFFB65B),
      Color(0xFF1B1107),
      Icons.bed_rounded,
    ),
    _ => const _MissionVisual(
      AppColors.primary,
      Color(0xFF071018),
      Icons.camera_alt_rounded,
    ),
  };
}

class _MissionVisual {
  const _MissionVisual(this.accent, this.background, this.icon);
  final Color accent;
  final Color background;
  final IconData icon;
}

class _MissionOverlay extends StatelessWidget {
  const _MissionOverlay({required this.mission, required this.accent});

  final MissionType mission;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final guide = switch (mission) {
      MissionType.objectHunt => const Size(190, 190),
      MissionType.skyPhoto => const Size(double.infinity, 170),
      MissionType.grassPhoto => const Size(double.infinity, 210),
      MissionType.makeBed => const Size(300, 180),
      _ => const Size(220, 220),
    };
    final alignment = switch (mission) {
      MissionType.skyPhoto => Alignment.topCenter,
      MissionType.grassPhoto => Alignment.bottomCenter,
      _ => Alignment.center,
    };
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Align(
          alignment: alignment,
          child: Container(
            width: guide.width,
            height: guide.height,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .06),
              border: Border.all(
                color: accent.withValues(alpha: .85),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(
                mission == MissionType.objectHunt ? 999 : 26,
              ),
            ),
            child: Icon(
              mission.icon,
              color: accent.withValues(alpha: .8),
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
