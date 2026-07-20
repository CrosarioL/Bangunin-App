import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../missions/domain/mission_type.dart';
import 'alarm_card.dart';

/// Bottom sheet listing every wake-up mission with a one-line description.
Future<MissionType?> showMissionPickerSheet(
  BuildContext context, {
  required MissionType current,
}) {
  return showModalBottomSheet<MissionType>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _MissionPickerSheet(current: current),
  );
}

class _MissionPickerSheet extends StatelessWidget {
  const _MissionPickerSheet({required this.current});

  final MissionType current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.missionSection,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: MissionType.values.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final mission = MissionType.values[index];
                  return _MissionTile(
                    mission: mission,
                    selected: mission == current,
                    description: _description(mission, l10n),
                    onTap: () {
                      Haptics.selection();
                      Navigator.of(context).pop(mission);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _description(MissionType mission, AppLocalizations l10n) =>
      switch (mission) {
        MissionType.none => l10n.missionNoneDescription,
        MissionType.objectHunt => l10n.missionObjectHuntDescription,
        MissionType.skyPhoto => l10n.missionSkyPhotoDescription,
        MissionType.grassPhoto => l10n.missionGrassPhotoDescription,
        MissionType.makeBed => l10n.missionMakeBedDescription,
        MissionType.squats => l10n.missionSquatsDescription,
        MissionType.pushups => l10n.missionPushupsDescription,
      };
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({
    required this.mission,
    required this.selected,
    required this.description,
    required this.onTap,
  });

  final MissionType mission;
  final bool selected;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          border: Border.all(
            color: selected ? AppColors.primary : theme.colorScheme.outline,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(mission.icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.localizedName(l10n),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
