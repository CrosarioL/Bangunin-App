import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_card.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/entities/alarm.dart';
import '../providers/alarms_provider.dart';
import '../widgets/alarm_card.dart';
import '../widgets/alarm_sound_l10n.dart';
import '../widgets/day_selector.dart';
import '../widgets/mission_picker_sheet.dart';
import '../widgets/sound_picker_sheet.dart';

/// Create/edit an alarm. Passing a null [alarmId] creates a new draft.
class AlarmEditorPage extends ConsumerStatefulWidget {
  const AlarmEditorPage({super.key, required this.alarmId});

  final String? alarmId;

  @override
  ConsumerState<AlarmEditorPage> createState() => _AlarmEditorPageState();
}

class _AlarmEditorPageState extends ConsumerState<AlarmEditorPage> {
  Alarm? _alarm;
  bool _isNew = true;
  bool _saving = false;
  late final TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final actions = ref.read(alarmActionsProvider);
    if (widget.alarmId == null) {
      setState(() => _alarm = actions.draft());
      return;
    }
    final existing = await ref
        .read(alarmRepositoryProvider)
        .getById(widget.alarmId!);
    if (!mounted) return;
    setState(() {
      _alarm = existing ?? actions.draft();
      _isNew = existing == null;
      _labelController.text = _alarm!.label;
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _update(Alarm Function(Alarm) transform) {
    final alarm = _alarm;
    if (alarm == null) return;
    setState(() => _alarm = transform(alarm));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final alarm = _alarm;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.newAlarm : l10n.editAlarm),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: l10n.close,
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: l10n.delete,
              onPressed: _delete,
            ),
        ],
      ),
      body: alarm == null
          ? const Center(child: CircularProgressIndicator())
          : MaxWidthBox(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  SizedBox(
                    height: 190,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: theme.brightness,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle:
                              theme.textTheme.headlineMedium,
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime(
                          2000,
                          1,
                          1,
                          alarm.hour,
                          alarm.minute,
                        ),
                        use24hFormat: MediaQuery.of(
                          context,
                        ).alwaysUse24HourFormat,
                        onDateTimeChanged: (value) {
                          Haptics.selection();
                          _update(
                            (a) => a.copyWith(
                              hour: value.hour,
                              minute: value.minute,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.repeatSection,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DaySelector(
                          selected: alarm.repeatDays,
                          onChanged: (days) =>
                              _update((a) => a.copyWith(repeatDays: days)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingRow(
                          icon: alarm.missionType.icon,
                          title: l10n.missionSection,
                          value: alarm.missionType.localizedName(l10n),
                          onTap: _pickMission,
                        ),
                        if (alarm.missionType.isMovement)
                          _SettingRow(
                            icon: Icons.repeat_rounded,
                            title: l10n.repsLabel,
                            value: '${alarm.missionReps}',
                            onTap: _pickReps,
                          ),
                        _SettingRow(
                          icon: Icons.volume_up_rounded,
                          title: l10n.soundSection,
                          value: alarm.sound.localizedName(l10n),
                          onTap: _pickSound,
                        ),
                        _SettingRow(
                          icon: Icons.label_outline_rounded,
                          title: l10n.labelField,
                          value: alarm.label.isEmpty
                              ? l10n.labelNone
                              : alarm.label,
                          onTap: _editLabel,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(l10n.vibrate),
                          value: alarm.vibrate,
                          onChanged: (value) =>
                              _update((a) => a.copyWith(vibrate: value)),
                        ),
                        SwitchListTile(
                          title: Text(l10n.snoozeSection),
                          subtitle: Text(
                            l10n.snoozeSummary(
                              alarm.snoozeMinutes,
                              alarm.maxSnoozes,
                            ),
                          ),
                          value: alarm.snoozeEnabled,
                          onChanged: (value) =>
                              _update((a) => a.copyWith(snoozeEnabled: value)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: l10n.save,
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickMission() async {
    final alarm = _alarm!;
    final mission = await showMissionPickerSheet(
      context,
      current: alarm.missionType,
    );
    if (mission == null || !mounted) return;

    var referencePath = alarm.objectReferencePath;
    if (mission.needsReferencePhoto) {
      referencePath = await context.push<String>(Routes.objectRegistration);
      if (referencePath == null) return; // Registration abandoned.
    }
    _update(
      (a) => a.copyWith(
        missionType: mission,
        missionReps: mission.isMovement
            ? (a.missionReps > 0 ? a.missionReps : mission.defaultReps)
            : 0,
        objectReferencePath: referencePath,
      ),
    );
  }

  Future<void> _pickReps() async {
    final l10n = context.l10n;
    final alarm = _alarm!;
    final options = [5, 10, 15, 20, 30];
    final reps = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.repsLabel,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text('$option'),
                trailing: option == alarm.missionReps
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (reps != null) _update((a) => a.copyWith(missionReps: reps));
  }

  Future<void> _pickSound() async {
    final alarm = _alarm!;
    final selection = await showSoundPickerSheet(
      context,
      current: alarm.sound,
      currentCustomPath: alarm.customSoundPath,
    );
    if (selection == null) return;
    _update(
      (a) => a.copyWith(
        sound: selection.sound,
        customSoundPath: selection.customPath,
      ),
    );
  }

  Future<void> _editLabel() async {
    final l10n = context.l10n;
    _labelController.text = _alarm!.label;
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.labelField),
        content: TextField(
          controller: _labelController,
          autofocus: true,
          maxLength: 30,
          decoration: InputDecoration(hintText: l10n.labelHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_labelController.text.trim()),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
    if (label != null) _update((a) => a.copyWith(label: label));
  }

  Future<void> _save() async {
    final alarm = _alarm!;
    setState(() => _saving = true);
    await ref.read(alarmActionsProvider).save(alarm, isNew: _isNew);
    if (mounted) {
      Haptics.success();
      context.pop();
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAlarmTitle),
        content: Text(l10n.deleteAlarmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(alarmActionsProvider).delete(_alarm!.id);
    if (mounted) context.pop();
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: () {
        Haptics.tap();
        onTap();
      },
    );
  }
}
