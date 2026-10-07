import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_card.dart';
import '../../../../core/utils/l10n_ext.dart';

/// "How your trial works" timeline shown when the selected plan carries a
/// free trial. Three rows connected by a vertical line so the trial reads
/// as a guided sequence rather than a list of disconnected facts.
class TrialTimeline extends StatelessWidget {
  const TrialTimeline({
    super.key,
    required this.trialDays,
    this.compact = false,
  });

  final int trialDays;

  /// Tighter rows, for when the timeline shares the first screen with the
  /// plans and the purchase button.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineRow(
            icon: Icons.lock_open_rounded,
            title: l10n.trialToday,
            body: l10n.trialTodayBody,
            isLast: false,
            compact: compact,
          ),
          _TimelineRow(
            icon: Icons.notifications_active_rounded,
            title: l10n.trialDay2,
            body: l10n.trialDay2Body(
              defaultTargetPlatform == TargetPlatform.iOS
                  ? 'App Store'
                  : 'Google Play',
            ),
            isLast: false,
            compact: compact,
          ),
          _TimelineRow(
            icon: Icons.workspace_premium_rounded,
            title: l10n.trialDayFinal(trialDays),
            body: l10n.trialDayFinalBody,
            isLast: true,
            compact: compact,
            iconColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.isLast,
    this.iconColor = AppColors.primary,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool isLast;
  final Color iconColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circleSize = compact ? 32.0 : 40.0;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: compact ? 17 : 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : (compact ? AppSpacing.sm : AppSpacing.lg),
                top: compact ? 2 : AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
