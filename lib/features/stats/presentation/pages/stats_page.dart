import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../app/widgets/sunset_page_header.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/time_format.dart';
import '../providers/stats_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recordsAsync = ref.watch(wakeRecordsProvider);
    final streak = ref.watch(currentStreakProvider);
    final best = ref.watch(bestStreakProvider);
    final avgMinutes = ref.watch(averageWakeMinutesProvider);
    final monthDays = ref.watch(monthSuccessDaysProvider);
    final totalWakes =
        recordsAsync.value?.where((record) => record.success).length ?? 0;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: MaxWidthBox(
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              SunsetPageHeader(
                title: l10n.statsTitle,
                icon: Icons.local_fire_department_rounded,
              ),
              const SizedBox(height: AppSpacing.xl),
              _StreakHero(streak: streak),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.emoji_events_rounded,
                      label: l10n.bestStreak,
                      value: '$best',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.schedule_rounded,
                      label: l10n.avgWakeTime,
                      value: avgMinutes == null
                          ? '—'
                          : TimeFormat.minutesToClock(context, avgMinutes),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.wb_sunny_rounded,
                      label: l10n.totalWakes,
                      value: '$totalWakes',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _WeekCalendar(successDays: monthDays),
              const SizedBox(height: 120), // Clear bottom nav
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AnimatedStreakFlame extends StatefulWidget {
  const _AnimatedStreakFlame();

  @override
  State<_AnimatedStreakFlame> createState() => _AnimatedStreakFlameState();
}

class _AnimatedStreakFlameState extends State<_AnimatedStreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        // Floating translation up and down
        final yOffset = math.sin(_anim.value * math.pi) * -12.0;
        // Breathing pulse
        final scale = 0.95 + (math.sin(_anim.value * math.pi) * 0.05);

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scale,
            // The flame PNG has a real transparent background, and the pulsing
            // glow is a circle behind it: a shadow on the square image box
            // drew a square halo.
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.4 * _anim.value,
                          ),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/mascot/streak_flame.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        const _AnimatedStreakFlame(),
        const SizedBox(height: AppSpacing.lg),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: streak),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutExpo,
          builder: (context, value, _) => Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 72,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
              shadows: [Shadow(color: AppColors.primary, blurRadius: 20)],
            ),
          ),
        ),
        Text(
          l10n.currentStreak.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({required this.successDays});

  final Set<int> successDays;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // 1 = Monday, 7 = Sunday
    final currentWeekday = now.weekday;
    // Start of the week (Monday)
    final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THIS WEEK',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = weekDays[index];
              final isSuccess = successDays.contains(date.day);
              final isToday = date.day == now.day && date.month == now.month;

              return Column(
                children: [
                  Text(
                    dayLabels[index],
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSuccess
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.05),
                      border: isToday
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                      boxShadow: isSuccess
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: isSuccess
                              ? AppColors.onPrimary
                              : Colors.white54,
                          fontWeight: isSuccess
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
