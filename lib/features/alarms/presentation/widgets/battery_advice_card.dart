import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/services/device/oem_battery_advisor.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/gen/app_localizations.dart';

/// Android battery-manager guidance.
///
/// This is the single biggest cause of "my alarm didn't go off" on Android,
/// and it is not something correct code can fix — several vendors kill
/// scheduled work regardless of the permissions an app holds. It matters
/// disproportionately in Indonesia, where those brands dominate.
///
/// Shown only where it applies: never on iOS, and never once the user is
/// exempt on a vendor with no extra autostart step to worry about.
final batteryAdviceProvider = FutureProvider<OemBatteryAdvice>(
  (ref) => ref.watch(oemBatteryAdvisorProvider).advise(),
);

class BatteryAdviceCard extends ConsumerWidget {
  const BatteryAdviceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advice = ref.watch(batteryAdviceProvider);

    return advice.maybeWhen(
      data: (data) =>
          data.applies ? _Card(advice: data) : const SizedBox.shrink(),
      // Don't flash guidance while we're still checking.
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card({required this.advice});

  final OemBatteryAdvice advice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

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
                  Icons.battery_alert_rounded,
                  size: 18,
                  color: AppColors.info,
                  semanticLabel: '',
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.batteryTitle,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.batteryBody,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // The standard Android exemption. Hidden once granted, because
            // asking again would do nothing.
            if (!advice.isExempt) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () async {
                  Haptics.selection();
                  await ref.read(oemBatteryAdvisorProvider).requestExemption();
                  ref.invalidate(batteryAdviceProvider);
                },
                child: Text(l10n.batteryAllow),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.success,
                    semanticLabel: '',
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.batteryDone,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            // Vendor-specific autostart step. These vendors need a second
            // setting the standard exemption does not cover, so this stays
            // visible even after the exemption is granted.
            if (advice.needsVendorStep) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                vendorSteps(l10n, advice.family),
                style: theme.textTheme.bodySmall!.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Menu paths genuinely differ by device and Android version, so
              // say so rather than sending people hunting for a menu that does
              // not exist on their phone.
              Text(
                l10n.batteryMenusVary,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Vendor-specific wording, kept out of the widget so it can be unit-tested.
@visibleForTesting
String vendorSteps(AppLocalizations l10n, OemFamily family) => switch (family) {
  OemFamily.xiaomi => l10n.batteryStepsXiaomi,
  OemFamily.oppo => l10n.batteryStepsOppo,
  OemFamily.vivo => l10n.batteryStepsVivo,
  OemFamily.huawei => l10n.batteryStepsHuawei,
  OemFamily.transsion => l10n.batteryStepsTranssion,
  OemFamily.oneplus ||
  OemFamily.samsung ||
  OemFamily.other => l10n.batteryStepsGeneric,
};
