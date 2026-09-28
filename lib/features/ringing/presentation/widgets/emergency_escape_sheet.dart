import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/emergency_escape.dart';

/// Walks the user through the emergency exit. Resolves true only once both
/// the taps and the typed pledge are done; any other way out keeps ringing.
Future<bool> showEmergencyEscapeSheet(
  BuildContext context, {
  required int usedThisMonth,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => EmergencyEscapeSheet(usedThisMonth: usedThisMonth),
  );
  return result ?? false;
}

class EmergencyEscapeSheet extends StatefulWidget {
  const EmergencyEscapeSheet({super.key, required this.usedThisMonth});

  final int usedThisMonth;

  @override
  State<EmergencyEscapeSheet> createState() => _EmergencyEscapeSheetState();
}

class _EmergencyEscapeSheetState extends State<EmergencyEscapeSheet> {
  final _controller = TextEditingController();
  int _taps = 0;

  bool get _tapsDone => _taps >= EmergencyEscape.requiredTaps;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pledge = EmergencyEscape.pledge(
      Localizations.localeOf(context).languageCode,
      usedThisMonth: widget.usedThisMonth,
    );
    final left = EmergencyEscape.requiredTaps - _taps;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: AppColors.danger),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.emergencyTitle,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (!_tapsDone) ...[
                Text(l10n.emergencyTapBody(left)),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 72,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger, width: 2),
                    ),
                    onPressed: () {
                      Haptics.tap();
                      setState(() => _taps++);
                    },
                    child: Text(
                      '${l10n.emergencyTapButton} ($left)',
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Text(l10n.emergencyPledgeBody),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(pledge, style: theme.textTheme.bodyLarge),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: 2,
                  maxLines: 5,
                  // Typing it out is the friction; paste would remove it.
                  enableInteractiveSelection: false,
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: l10n.emergencyConfirm,
                  onPressed: EmergencyEscape.matches(_controller.text, pledge)
                      ? () => Navigator.of(context).pop(true)
                      : null,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.emergencyCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
