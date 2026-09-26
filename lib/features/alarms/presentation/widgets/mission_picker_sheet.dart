import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../missions/domain/mission_type.dart';
import '../../../missions/presentation/pages/movement_mission_page.dart';
import '../../../missions/presentation/pages/object_registration_page.dart';
import '../../../missions/presentation/pages/photo_mission_page.dart';
import '../../../missions/presentation/widgets/mission_experience.dart';
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
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: .14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wb_twilight_rounded,
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.missionSection,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const BanguninMascot(size: 64, flap: true),
              ],
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
                    onPreview: mission == MissionType.none
                        ? null
                        : () => _preview(context, mission),
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

  Future<void> _preview(BuildContext context, MissionType mission) async {
    Haptics.tap();
    String? referencePath;
    if (mission.needsReferencePhoto) {
      referencePath = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const ObjectRegistrationPage(),
        ),
      );
      if (referencePath == null || !context.mounted) return;
    }

    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => mission.isMovement
            ? MovementMissionPage(previewMission: mission)
            : PhotoMissionPage(
                previewMission: mission,
                previewReferencePath: referencePath,
              ),
      ),
    );
    if (completed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.missionPreviewSuccess)),
      );
    }
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({
    required this.mission,
    required this.selected,
    required this.description,
    required this.onTap,
    required this.onPreview,
  });

  final MissionType mission;
  final bool selected;
  final String description;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final accent = mission.experienceColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.18)
              : AppColors.nightTop.withValues(alpha: .22),
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          border: Border.all(
            color: selected ? accent : Colors.white.withValues(alpha: .1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(mission.icon, color: accent),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) Icon(Icons.check_circle_rounded, color: accent),
                if (onPreview != null)
                  TextButton(
                    onPressed: onPreview,
                    child: Text(l10n.tryMission),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
