import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../app/widgets/pressable_scale.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/services/subscriptions/subscription_service.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/premium_provider.dart';

/// Hard paywall shown right after onboarding (and on any locked entry
/// point). Deliberately plain: a headline, three benefits, two plans and one
/// button, with the terms in a single line under it. Yearly is pre-selected
/// and carries the free trial. There is no close button; the product gates
/// everything on premium.
class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref.read(analyticsProvider).logEvent(AnalyticsEvents.paywallShown),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(premiumPlansProvider);
    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          child: plansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _ErrorState(
              onRetry: () => ref.invalidate(premiumPlansProvider),
            ),
            data: (plans) {
              if (plans.isEmpty) {
                return _ErrorState(
                  onRetry: () => ref.invalidate(premiumPlansProvider),
                );
              }
              final selected = plans.firstWhere(
                (p) => p.productId == _selectedProductId,
                orElse: () => plans.first,
              );
              return _buildPlans(context, plans, selected);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlans(
    BuildContext context,
    List<PremiumPlan> plans,
    PremiumPlan selected,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final purchasing = ref.watch(purchaseInProgressProvider);
    final userName = ref.watch(userNameProvider);
    final savePercent = _yearlySavingPercent(plans);
    final muted = theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            children: [
              const Center(
                child: BanguninMascot(size: 96, pose: MascotPose.crowing),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                userName.isNotEmpty
                    ? l10n.paywallTitleNamed(userName)
                    : l10n.paywallTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Feature(text: l10n.paywallFeatureMissions),
              _Feature(text: l10n.paywallFeatureNoLimit),
              _Feature(text: l10n.paywallFeatureSounds),
              const SizedBox(height: AppSpacing.md),
              for (final plan in plans) ...[
                _PlanCard(
                  plan: plan,
                  savePercent: plan.period == 'year' ? savePercent : null,
                  selected: plan.productId == selected.productId,
                  onTap: () {
                    Haptics.selection();
                    setState(() => _selectedProductId = plan.productId);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
        // Pinned, so the button and its terms are always on screen.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: selected.hasTrial
                    ? l10n.paywallCtaTrial(selected.trialDays)
                    : l10n.paywallCtaNoTrial,
                loading: purchasing,
                onPressed: () => _purchase(selected),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Apple 3.1.2: trial length, the price after it and that it
              // renews, right under the button.
              Text(
                _termsLine(context, selected),
                textAlign: TextAlign.center,
                style: muted,
              ),
              // One line on every phone: scale down rather than wrap.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FooterLink(
                      text: l10n.restorePurchases,
                      onPressed: purchasing
                          ? null
                          : () => ref
                                .read(purchaseInProgressProvider.notifier)
                                .restore(),
                    ),
                    // Required on the purchase screen itself (Apple 3.1.2 /
                    // Play subscription policy).
                    _FooterLink(
                      text: l10n.privacyPolicy,
                      onPressed: () =>
                          unawaited(_launch(AppConfig.privacyPolicyUrl)),
                    ),
                    _FooterLink(
                      text: l10n.termsOfUse,
                      onPressed: () => unawaited(_launch(AppConfig.termsUrl)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _termsLine(BuildContext context, PremiumPlan plan) {
    final id = Localizations.localeOf(context).languageCode == 'id';
    final yearly = plan.period == 'year';
    final per = id
        ? '${plan.price}/${yearly ? 'tahun' : 'bulan'}'
        : '${plan.price}/${yearly ? 'year' : 'month'}';
    if (id) {
      return plan.hasTrial
          ? 'Gratis ${plan.trialDays} hari, lalu $per. '
                'Diperpanjang otomatis, batalkan kapan saja.'
          : '$per. Diperpanjang otomatis, batalkan kapan saja.';
    }
    return plan.hasTrial
        ? '${plan.trialDays} days free, then $per. '
              'Renews automatically, cancel anytime.'
        : '$per. Renews automatically, cancel anytime.';
  }

  Future<void> _purchase(PremiumPlan plan) async {
    final l10n = context.l10n;
    final succeeded = await ref
        .read(purchaseInProgressProvider.notifier)
        .purchase(plan);
    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.paywallPurchase, {
        'product': plan.productId,
        'success': succeeded,
      }),
    );
    if (!succeeded && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.purchaseFailed)));
    }
    // On success the premium provider flips and the router redirects home.
  }

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// How much the yearly plan saves over paying monthly for a year, from the
/// store's own prices so it is right in every currency.
int? _yearlySavingPercent(List<PremiumPlan> plans) {
  double? priceFor(String period) {
    for (final plan in plans) {
      if (plan.period == period) return plan.rawPrice;
    }
    return null;
  }

  final yearly = priceFor('year');
  final monthly = priceFor('month');
  if (yearly == null || monthly == null || monthly <= 0) return null;
  final percent = ((1 - yearly / (monthly * 12)) * 100).floor();
  return percent > 0 ? percent : null;
}

class _Feature extends StatelessWidget {
  const _Feature({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.text, required this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        minimumSize: const Size(0, 36),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// One plan as a single row: radio, name, price. The yearly row also
/// carries the saving.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.savePercent,
    required this.selected,
    required this.onTap,
  });

  final PremiumPlan plan;

  /// Yearly vs. twelve months of monthly; null hides the badge.
  final int? savePercent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isYearly = plan.period == 'year';
    return Semantics(
      button: true,
      selected: selected,
      child: PressableScale(
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            // Always dark glass, so the white text reads in light mode too.
            color: selected
                ? Color.alphaBlend(
                    AppColors.primary.withValues(alpha: .18),
                    AppColors.glass,
                  )
                : AppColors.glass,
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: .1),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? AppColors.primary : Colors.white54,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isYearly ? l10n.planYearly : l10n.planMonthly,
                      style: theme.textTheme.titleSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    // Apple 3.1.2: the amount billed is the clearest price.
                    Text(
                      isYearly
                          ? l10n.pricePerYear(plan.price)
                          : l10n.pricePerMonth(plan.price),
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (savePercent != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusCapsule,
                    ),
                  ),
                  child: Text(
                    l10n.saveBadge(savePercent!),
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.paywallLoadError, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
