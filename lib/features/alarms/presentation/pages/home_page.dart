import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_card.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/mascot_bubble.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../app/widgets/pressable_scale.dart';
import '../../../../app/widgets/stat_pill.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/time_format.dart';
import '../../../stats/presentation/providers/stats_provider.dart';
import '../providers/alarms_provider.dart';
import '../widgets/alarm_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final alarmsAsync = ref.watch(alarmsProvider);
    final nextAt = ref.watch(nextAlarmProvider)?.at;
    final streak = ref.watch(currentStreakProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: MaxWidthBox(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: _Header(nextAt: nextAt, streak: streak),
                ),
              ),
              alarmsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: Center(
                    child: Text(l10n.genericError, textAlign: TextAlign.center),
                  ),
                ),
                data: (alarms) => alarms.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          120,
                        ),
                        sliver: SliverList.separated(
                          itemCount: alarms.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final alarm = alarms[index];
                            return Dismissible(
                              key: ValueKey(alarm.id),
                              direction: DismissDirection.endToStart,
                              background: _DeleteBackground(),
                              confirmDismiss: (_) => _confirmDelete(context),
                              onDismissed: (_) {
                                Haptics.warning();
                                ref.read(alarmActionsProvider).delete(alarm.id);
                              },
                              child: AlarmCard(
                                alarm: alarm,
                                onTap: () =>
                                    context.push(Routes.alarmEdit(alarm.id)),
                                onToggle: (enabled) {
                                  Haptics.selection();
                                  ref
                                      .read(alarmActionsProvider)
                                      .toggle(alarm, enabled: enabled);
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: PressableScale(
        onPressed: () => context.push(Routes.alarmNew),
        semanticLabel: l10n.newAlarm,
        // Chunky 3D circle: flat yellow face on a solid darker lip.
        child: Container(
          width: 66,
          height: 66,
          decoration: const BoxDecoration(
            color: AppColors.primaryEdge,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.only(bottom: 4),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 34,
              color: AppColors.onPrimary,
              semanticLabel: '',
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
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
    return confirmed ?? false;
  }
}

/// Owns its own 30s ticker so the "rings in Xh Ym" countdown stays fresh
/// without rebuilding the rest of the alarm list above it.
class _Header extends StatefulWidget {
  const _Header({required this.nextAt, required this.streak});

  final DateTime? nextAt;
  final int streak;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  Timer? _minuteTicker;

  @override
  void initState() {
    super.initState();
    _minuteTicker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final nextAt = widget.nextAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.homeTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            // Gamified streak chip, always visible — the number to protect.
            StatPill(
              icon: Icons.local_fire_department_rounded,
              value: '${widget.streak}',
              color: AppColors.primaryDeep,
            ),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: nextAt == null
              ? Padding(
                  key: const ValueKey('none'),
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    l10n.noUpcomingAlarm,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              // Hero card: the countdown is the one number that matters on
              // this screen, so it gets card treatment with the mascot
              // keeping watch beside it.
              : Padding(
                  key: const ValueKey('next'),
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.nextAlarmIn.toUpperCase(),
                                style: theme.textTheme.labelSmall!.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                TimeFormat.countdown(
                                  nextAt.difference(DateTime.now()),
                                ),
                                style: theme.textTheme.headlineMedium!
                                    .copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const BanguninMascot(size: 76, flap: true),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The chick talks to you, Duo-style, then dozes below its bubble.
          MascotBubble(text: l10n.emptyAlarmsTitle),
          const SizedBox(height: AppSpacing.md),
          // The sleeping chick: tap it and it wakes up crowing — a tiny
          // easter egg that also demos the brand promise.
          const BanguninMascot(pose: MascotPose.sleeping, size: 150),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.emptyAlarmsSubtitle,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: const Icon(Icons.delete_rounded, color: Colors.white),
    );
  }
}
