import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../missions/domain/mission_type.dart';
import '../../../missions/presentation/pages/movement_mission_page.dart';
import '../../../missions/presentation/pages/object_registration_page.dart';
import '../../../missions/presentation/pages/phone_task_mission_page.dart';
import '../../../missions/presentation/pages/photo_mission_page.dart';
import '../../../missions/presentation/widgets/mission_experience.dart';
import 'alarm_card.dart';

/// Mission picker: one mission per screen, swiped left and right, with a
/// big icon and a short description, so each mission gets a proper look
/// instead of being one line in a long list.
///
/// [exclude] hides missions that can't be picked here (already in the chain,
/// or Object Hunt in a chained slot). With [removeLabel], the "No mission"
/// card reads as removing the slot instead, for chained missions.
Future<MissionType?> showMissionPickerSheet(
  BuildContext context, {
  required MissionType current,
  Set<MissionType> exclude = const {},
  String? removeLabel,
}) {
  return showModalBottomSheet<MissionType>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _MissionPickerSheet(
      current: current,
      exclude: exclude,
      removeLabel: removeLabel,
    ),
  );
}

class _MissionPickerSheet extends StatefulWidget {
  const _MissionPickerSheet({
    required this.current,
    required this.exclude,
    required this.removeLabel,
  });

  final MissionType current;
  final Set<MissionType> exclude;
  final String? removeLabel;

  @override
  State<_MissionPickerSheet> createState() => _MissionPickerSheetState();
}

class _MissionPickerSheetState extends State<_MissionPickerSheet> {
  /// "No mission" goes last: people opening the picker want a mission, so
  /// the first card should be one.
  late final List<MissionType> _missions = [
    for (final m in MissionType.values)
      if (m != MissionType.none && !widget.exclude.contains(m)) m,
    if (!widget.exclude.contains(MissionType.none)) MissionType.none,
  ];

  late int _page = () {
    final index = _missions.indexOf(widget.current);
    // A plain alarm opens on the first real mission, not on "No mission".
    return index < 0 || widget.current == MissionType.none ? 0 : index;
  }();

  // Neighbouring cards peek in at the edges, which is what tells people
  // they can swipe.
  late final _controller = PageController(
    initialPage: _page,
    viewportFraction: .84,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _removes(MissionType m) =>
      widget.removeLabel != null && m == MissionType.none;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final mission = _missions[_page];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.missionSection,
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          l10n.missionSwipeHint,
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const BanguninMascot(size: 56, flap: true),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 330,
              child: PageView.builder(
                controller: _controller,
                itemCount: _missions.length,
                onPageChanged: (page) {
                  Haptics.selection();
                  setState(() => _page = page);
                },
                itemBuilder: (context, index) {
                  final m = _missions[index];
                  return _MissionCard(
                    mission: m,
                    name: _removes(m)
                        ? widget.removeLabel!
                        : m.localizedName(l10n),
                    description: _removes(m)
                        ? ''
                        : m.localizedDescription(l10n),
                    selected: m == widget.current,
                    focused: index == _page,
                    onTap: () {
                      if (index == _page) {
                        _choose(m);
                      } else {
                        unawaited(
                          _controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Dots(count: _missions.length, active: _page),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _removes(mission)
                        ? widget.removeLabel!
                        : l10n.chooseMission,
                    onPressed: () => _choose(mission),
                  ),
                  SizedBox(
                    height: 48,
                    child: mission == MissionType.none
                        ? null
                        : TextButton.icon(
                            onPressed: () => _preview(context, mission),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(l10n.tryMission),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _choose(MissionType mission) {
    Haptics.selection();
    Navigator.of(context).pop(mission);
  }

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
            : mission.isPhoneTask
            ? PhoneTaskMissionPage(previewMission: mission)
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

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mission,
    required this.name,
    required this.description,
    required this.selected,
    required this.focused,
    required this.onTap,
  });

  final MissionType mission;
  final String name;
  final String description;
  final bool selected;
  final bool focused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final accent = mission.experienceColor;
    return AnimatedScale(
      // The card in focus sits forward; its neighbours step back.
      scale: focused ? 1 : .92,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Semantics(
          button: true,
          selected: selected,
          label: name,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withValues(alpha: .26),
                    AppColors.nightTop.withValues(alpha: .6),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: selected
                      ? accent
                      : Colors.white.withValues(alpha: .12),
                  width: selected ? 3 : 1.5,
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      height: 28,
                      child: selected
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusCapsule,
                                ),
                              ),
                              child: Text(
                                l10n.missionCurrent,
                                style: theme.textTheme.labelMedium!.copyWith(
                                  color: AppColors.nightTop,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .18),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: .3),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Icon(mission.icon, color: accent, size: 56),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: .25),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}
