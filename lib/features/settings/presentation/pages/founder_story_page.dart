import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../core/utils/l10n_ext.dart';

/// The founder's story — why the app exists. Reachable from Settings and
/// mirrored on the landing page and in marketing. Written as a nameless
/// first-person origin story (see marketing/INDO-LAUNCH.md, "Founder story").
class FounderStoryPage extends StatelessWidget {
  const FounderStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: l10n.back,
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.settingsOurStory),
      ),
      body: SafeArea(
        top: false,
        child: MaxWidthBox(
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
                ),
                child: const Icon(
                  Icons.wb_twilight_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.founderStoryTitle,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.founderStoryBody,
                style: theme.textTheme.bodyLarge!.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.founderStorySignature,
                style: theme.textTheme.titleSmall!.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
