import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../stats/presentation/providers/stats_provider.dart';

/// Celebration after completing the wake-up: streak flame counts up with a
/// spring pop, then offers the way back home.
class WakeSuccessPage extends ConsumerStatefulWidget {
  const WakeSuccessPage({super.key});

  @override
  ConsumerState<WakeSuccessPage> createState() => _WakeSuccessPageState();
}

class _WakeSuccessPageState extends ConsumerState<WakeSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _pop = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  @override
  void initState() {
    super.initState();
    Haptics.success();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final streak = ref.watch(currentStreakProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _pop,
                child: const BanguninMascot(
                  pose: MascotPose.celebrating,
                  tapPose: MascotPose.crowing,
                  size: 190,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.wakeSuccessTitle,
                style: theme.textTheme.headlineMedium!.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.streakCount(streak),
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: l10n.startMyDay,
                onPressed: () => context.go(Routes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
