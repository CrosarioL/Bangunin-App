import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/services/alarms/alarm_kit_service.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../providers/alarm_capability_provider.dart';
import '../providers/alarms_provider.dart';

/// Blocks the app while iOS has the Alarms permission off.
///
/// Without AlarmKit an alarm is only a notification: no full-screen alert,
/// nothing through Silent Mode, a few seconds of sound. For an alarm clock
/// that is a failure, not a fallback, so the user cannot carry on as if the
/// app works. The gate returns on every launch and every return to the app
/// until the permission is on, then re-arms every alarm on AlarmKit.
///
/// Devices that cannot run AlarmKit at all (below iOS 26) and Android pass
/// straight through: there is nothing the user could switch on.
class AlarmsOffGate extends ConsumerStatefulWidget {
  const AlarmsOffGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AlarmsOffGate> createState() => _AlarmsOffGateState();
}

class _AlarmsOffGateState extends ConsumerState<AlarmsOffGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The usual way back is from Settings, where the switch was flipped.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(alarmCapabilityProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Turning the permission on changes the engine: everything already
    // scheduled as a notification has to move onto AlarmKit.
    ref.listen(alarmCapabilityProvider, (previous, next) {
      final was = previous?.value?.engine;
      final now = next.value?.engine;
      if (was != null &&
          was != AlarmEngine.alarmKit &&
          now == AlarmEngine.alarmKit) {
        unawaited(ref.read(alarmActionsProvider).resync());
      }
    });

    final capability = ref.watch(alarmCapabilityProvider).value;
    final blocked =
        capability != null &&
        !capability.isFullStrength &&
        !capability.isUnsupported;
    if (!blocked) return widget.child;
    return _AlarmsOffPage(canAsk: capability.canUpgrade);
  }
}

class _AlarmsOffPage extends ConsumerWidget {
  const _AlarmsOffPage({required this.canAsk});

  /// Never asked yet: iOS will show its prompt. Otherwise it was refused and
  /// only Settings can change it.
  final bool canAsk;

  Future<void> _turnOn(WidgetRef ref) async {
    Haptics.tap();
    if (canAsk) {
      final result = await ref.read(requestAlarmAuthorizationProvider)();
      if (result.canScheduleRealAlarms) {
        await ref.read(alarmActionsProvider).resync();
      }
    } else {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.alarm_off_rounded,
                      size: 60,
                      color: AppColors.danger,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.alarmsOffTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.alarmsOffBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                if (!canAsk) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.alarmsOffSettingsHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const Spacer(),
                PrimaryButton(
                  label: canAsk ? l10n.alarmsOffEnable : l10n.openSettings,
                  onPressed: () => unawaited(_turnOn(ref)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
