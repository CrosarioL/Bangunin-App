import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../providers/alarm_capability_provider.dart';
import '../providers/alarms_provider.dart';

/// Tells the user, calmly, which alarm engine is running.
///
/// Deliberate choices here:
///
///  * The fallback is **`info`-tinted, never `danger`.** It is a limitation of
///    the device, not an error the user made, and frightening someone about
///    their alarm is worse than the limitation itself.
///  * The full-strength state is stated **once, quietly** — it is reassurance,
///    not a badge to celebrate.
///  * We prompt for authorization **only** when it has never been asked. A
///    declined user gets an explanation and a route to Settings, never a
///    repeated prompt.
///  * No wording here may imply the fallback can beat Silent Mode or Focus.
class AlarmCapabilityBanner extends ConsumerWidget {
  const AlarmCapabilityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capability = ref.watch(alarmCapabilityProvider);

    return capability.maybeWhen(
      data: (data) => _Banner(capability: data),
      // Never flash a scary fallback message while we're still checking.
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Banner extends ConsumerWidget {
  const _Banner({required this.capability});

  final AlarmCapability capability;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (capability.isFullStrength) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Row(
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              size: 16,
              color: AppColors.success,
              semanticLabel: '',
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                l10n.alarmEngineFullTitle,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.info,
                  semanticLabel: '',
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.alarmEngineFallbackBody,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (capability.canUpgrade) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => unawaited(_educateThenRequest(context, ref)),
                child: Text(l10n.alarmEngineEnable),
              ),
            ] else if (capability.wasDeclined) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => unawaited(openAppSettings()),
                child: Text(l10n.openSettings),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Explains before prompting.
  ///
  /// iOS gives exactly one chance at the system prompt. Spending it cold is
  /// how apps end up permanently stuck on the weaker path, so the user sees
  /// what we're asking for and why, and can decline *our* dialog harmlessly.
  Future<void> _educateThenRequest(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.alarmEngineEducationTitle),
        content: Text(l10n.alarmEngineEducationBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.alarmEngineEnable),
          ),
        ],
      ),
    );
    if (proceed != true) return;

    Haptics.selection();
    final result = await ref.read(requestAlarmAuthorizationProvider)();

    // Granting changes which engine is armed, so everything has to be
    // rescheduled onto AlarmKit — otherwise the user has "real alarms"
    // switched on with nothing actually registered.
    if (result.canScheduleRealAlarms) {
      await ref.read(alarmActionsProvider).resync();
    }
  }
}

/// Kept next to the banner so the copy and the states it describes stay in
/// step; used by settings to show the same information.
String alarmCapabilitySummary(AppLocalizations l10n, AlarmCapability c) =>
    c.isFullStrength ? l10n.alarmEngineFullTitle : l10n.alarmEngineFallbackBody;
