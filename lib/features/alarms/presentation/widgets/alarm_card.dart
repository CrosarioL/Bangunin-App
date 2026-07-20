import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_card.dart';
import '../../../../app/widgets/pressable_scale.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../missions/domain/mission_type.dart';
import '../../domain/entities/alarm.dart';

class AlarmCard extends StatelessWidget {
  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onTap,
    required this.onToggle,
  });

  final Alarm alarm;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = !alarm.enabled;

    // The info column and the switch are separate tap targets (each its own
    // Semantics/gesture region) — nesting the Switch inside the card's own
    // tappable area would race the two gesture recognizers against each
    // other, so a tap meant to flip the switch could also open the editor.
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: PressableScale(
              onPressed: onTap,
              semanticLabel: _semanticSummary(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: muted ? 0.4 : 1,
                    child: Text(
                      TimeFormat.clock(context, alarm.hour, alarm.minute),
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _subtitle(context),
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (alarm.missionType != MissionType.none) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _MissionChip(mission: alarm.missionType, muted: muted),
                  ],
                ],
              ),
            ),
          ),
          Switch(
            value: alarm.enabled,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }

  /// One VoiceOver/TalkBack sentence covering everything the visible column
  /// conveys, so the merged reading order isn't "7:30, weekdays, squats"
  /// read as three disconnected fragments.
  String _semanticSummary(BuildContext context) {
    final l10n = context.l10n;
    final time = TimeFormat.clock(context, alarm.hour, alarm.minute);
    final mission = alarm.missionType == MissionType.none
        ? null
        : alarm.missionType.localizedName(l10n);
    final parts = [time, _subtitle(context), ?mission];
    return parts.join(', ');
  }

  String _subtitle(BuildContext context) {
    final l10n = context.l10n;
    final label = alarm.label.isEmpty ? null : alarm.label;
    final repeat = _repeatSummary(l10n);
    return label == null ? repeat : '$label · $repeat';
  }

  String _repeatSummary(AppLocalizations l10n) {
    final days = alarm.repeatDays;
    if (days.isEmpty) return l10n.repeatOnce;
    if (days.length == 7) return l10n.repeatEveryDay;
    const weekdays = {
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    };
    if (days.length == 5 && days.containsAll(weekdays)) {
      return l10n.repeatWeekdays;
    }
    if (days.length == 2 &&
        days.contains(DateTime.saturday) &&
        days.contains(DateTime.sunday)) {
      return l10n.repeatWeekend;
    }
    final names = [
      l10n.dayMonShort,
      l10n.dayTueShort,
      l10n.dayWedShort,
      l10n.dayThuShort,
      l10n.dayFriShort,
      l10n.daySatShort,
      l10n.daySunShort,
    ];
    final sorted = days.toList()..sort();
    return sorted.map((d) => names[d - 1]).join(' ');
  }
}

class _MissionChip extends StatelessWidget {
  const _MissionChip({required this.mission, required this.muted});

  final MissionType mission;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: muted ? 0.4 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppSpacing.radiusCapsule),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(mission.icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              mission.localizedName(l10n),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

extension MissionTypeL10n on MissionType {
  String localizedName(AppLocalizations l10n) => switch (this) {
        MissionType.none => l10n.missionNone,
        MissionType.objectHunt => l10n.missionObjectHunt,
        MissionType.skyPhoto => l10n.missionSkyPhoto,
        MissionType.grassPhoto => l10n.missionGrassPhoto,
        MissionType.makeBed => l10n.missionMakeBed,
        MissionType.squats => l10n.missionSquats,
        MissionType.pushups => l10n.missionPushups,
      };
}
