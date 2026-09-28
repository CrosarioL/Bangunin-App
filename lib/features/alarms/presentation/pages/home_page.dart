import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/mascot_bubble.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../app/widgets/pressable_scale.dart';
import '../../../../app/widgets/stat_pill.dart';
import '../../../../app/widgets/sunset_page_header.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../shell/presentation/app_shell.dart';
import '../../../stats/presentation/providers/stats_provider.dart';
import '../providers/alarms_provider.dart';
import '../widgets/alarm_capability_banner.dart';
import '../widgets/alarm_card.dart';
import '../widgets/battery_advice_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final alarmsAsync = ref.watch(alarmsProvider);
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
                sliver: SliverToBoxAdapter(child: _Header(streak: streak)),
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
                          168,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 84.0),
        child: PressableScale(
          onPressed: () => context.push(Routes.alarmNew),
          semanticLabel: l10n.newAlarm,
          child: Container(
            key: fabKey,
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.horizon],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .7)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .36),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_alarm_rounded,
              size: 32,
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

class _Header extends StatelessWidget {
  const _Header({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SunsetPageHeader(
          title: l10n.homeTitle,
          icon: Icons.alarm_rounded,
          trailing: Align(
            alignment: Alignment.centerLeft,
            child: StatPill(
              icon: Icons.local_fire_department_rounded,
              value: '$streak',
              color: AppColors.primaryDeep,
            ),
          ),
        ),
        // Whether this iPhone can actually ring through Silent Mode and
        // Focus, stated plainly. The user should never have to guess.
        const AlarmCapabilityBanner(),
        // Android vendor battery managers kill alarms regardless of
        // permissions. Renders nothing on iOS.
        const BatteryAdviceCard(),
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
