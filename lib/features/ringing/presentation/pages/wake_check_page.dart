import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../alarms/data/wake_check_store.dart';

/// "Still awake?" A few minutes after a dismissed alarm, the user has
/// [PendingWakeCheck.answerWindow] to say so. If they don't, the alarm's
/// own re-ring (already scheduled with the OS) takes over; this page just
/// counts down to it and hands over to the ringing screen when it lands.
class WakeCheckPage extends ConsumerStatefulWidget {
  const WakeCheckPage({super.key, required this.alarmId, this.now});

  final String alarmId;

  /// Injectable clock for tests.
  final DateTime Function()? now;

  @override
  ConsumerState<WakeCheckPage> createState() => _WakeCheckPageState();
}

class _WakeCheckPageState extends ConsumerState<WakeCheckPage> {
  Timer? _ticker;
  PendingWakeCheck? _check;

  DateTime _now() => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    final check = ref.read(alarmSchedulerProvider).pendingWakeCheck;
    if (check == null || check.alarmId != widget.alarmId) {
      // Already answered, or already lapsed into a re-ring.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.home);
      });
      return;
    }
    _check = check;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    final check = _check;
    if (check == null || !mounted) return;
    if (!_now().isBefore(check.ringAt)) {
      _ticker?.cancel();
      context.go(Routes.ringing(widget.alarmId));
      return;
    }
    setState(() {});
  }

  Future<void> _confirm() async {
    _ticker?.cancel();
    Haptics.success();
    await ref.read(alarmSchedulerProvider).cancelWakeCheck();
    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.wakeCheckPassed),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.wakeCheckPassed)));
    context.go(Routes.home);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final check = _check;
    final left = check == null
        ? 0
        : check.ringAt.difference(_now()).inSeconds.clamp(0, 999);

    return PopScope(
      // Backing out isn't an answer; the re-ring still comes.
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(),
                const BanguninMascot(pose: MascotPose.happy, size: 150),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.wakeCheckTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.wakeCheckBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.wakeCheckCountdown(left),
                    style: theme.textTheme.displaySmall!.copyWith(
                      color: left <= 10 ? AppColors.danger : AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: l10n.wakeCheckConfirm,
                  onPressed: _confirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
