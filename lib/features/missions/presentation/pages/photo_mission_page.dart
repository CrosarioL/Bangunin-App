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

    final verdict = await ref
        .read(photoMissionVerifierProvider)
        .verify(
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

    if (verdict == PhotoVerdict.pass) {
      await ref.read(ringingSessionProvider.notifier).complete();
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_abandon());
      },
      child: Scaffold(
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
                            style: const TextStyle(color: AppColors.primary),
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
                      Expanded(child: MissionCamera(onCaptured: _onCaptured)),
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
}
