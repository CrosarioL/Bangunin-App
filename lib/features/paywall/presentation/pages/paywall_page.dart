import 'dart:async';

import 'package:flutter/foundation.dart';
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
import '../../../../core/utils/time_format.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/premium_provider.dart';

/// Hard paywall shown right after onboarding (and on any locked entry
/// point). Yearly is pre-selected as the anchor; monthly sits below it.
/// No free trial: the price is paid from day one. There is no close button —
/// the product gates everything on premium.
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final plansAsync = ref.watch(premiumPlansProvider);
    final purchasing = ref.watch(purchaseInProgressProvider);
    final userName = ref.watch(userNameProvider);
    final answers = ref.watch(onboardingAnswersProvider);

    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
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
                return ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    // Compact header: the plans and the button must fit on
                    // the first screen.
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName.isNotEmpty
                                    ? l10n.paywallTitleNamed(userName)
                                    : l10n.paywallTitle,
                                style: theme.textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.paywallGoalLine(
                                  TimeFormat.clock(
                                    context,
                                    answers.wakeGoalHour,
                                    answers.wakeGoalMinute,
                                  ),
                                ),
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const BanguninMascot(
                          size: 72,
                          pose: MascotPose.crowing,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final plan in plans) ...[
                      _PlanCard(
                        plan: plan,
                        savePercent: _yearlySavingPercent(plans),
                        selected: plan.productId == selected.productId,
                        onTap: () {
                          Haptics.selection();
                          setState(() => _selectedProductId = plan.productId);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    PrimaryButton(
                      label: l10n.paywallCta,
                      loading: purchasing,
                      onPressed: () => _purchase(selected),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Apple 3.1.2 / Play: what is charged, how often, and
                    // that it renews, right under the button.
                    Text(
                      selected.period == 'year'
                          ? l10n.paywallRenewsYearly(
                              selected.price,
                              _storeName(),
                            )
                          : l10n.paywallRenewsMonthly(
                              selected.price,
                              _storeName(),
                            ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.paywallSubtitle,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Feature(text: l10n.paywallFeatureMissions),
                    _Feature(text: l10n.paywallFeatureSounds),
                    _Feature(text: l10n.paywallFeatureStreaks),
                    _Feature(text: l10n.paywallFeatureNoLimit),
                    const SizedBox(height: AppSpacing.md),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: TextButton(
                        onPressed: purchasing
                            ? null
                            : () => ref
                                  .read(purchaseInProgressProvider.notifier)
                                  .restore(),
                        child: Text(l10n.restorePurchases),
                      ),
                    ),
                    Center(
                      child: Text(
                        l10n.paywallLegal,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    // Required on the purchase screen itself (Apple 3.1.2 /
                    // Play subscription policy): functional links to the
                    // privacy policy and terms, not just buried in Settings.
                    const SizedBox(height: AppSpacing.xs),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () =>
                                unawaited(_launch(AppConfig.privacyPolicyUrl)),
                            child: Text(l10n.privacyPolicy),
                          ),
                          TextButton(
                            onPressed: () =>
                                unawaited(_launch(AppConfig.termsUrl)),
                            child: Text(l10n.termsOfUse),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
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

String _storeName() =>
    defaultTargetPlatform == TargetPlatform.iOS ? 'App Store' : 'Google Play';

class _Feature extends StatelessWidget {
  const _Feature({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 22,
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.savePercent,
    required this.selected,
    required this.onTap,
  });

  final PremiumPlan plan;

  /// Yearly vs. twelve months of monthly, or null when it can't be computed.
  final int? savePercent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isYearly = plan.period == 'year';
    // Unselected cards sit on dark glass; theme text is dark, so it would
    // disappear (and the price must stay readable, Apple 3.1.2).
    final textColor = selected ? null : Colors.white;
    // A merged Semantics node (not an overriding label) so "selected" is
    // announced alongside the plan's own text instead of replacing it.
    return Semantics(
      button: true,
      selected: selected,
      child: PressableScale(
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? null : AppColors.glass,
            gradient: selected
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: .24),
                      AppColors.sunsetCoral.withValues(alpha: .2),
                      AppColors.glass,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: .1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppColors.primary.withValues(alpha: .2)
                    : AppColors.nightTop.withValues(alpha: .22),
                offset: const Offset(0, 8),
                blurRadius: 22,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          isYearly ? l10n.planYearly : l10n.planMonthly,
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: textColor,
                          ),
                        ),
                        if (isYearly && savePercent != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
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
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Apple 3.1.2: the amount billed stays the clearest price
                    // on the card, so it is not shrunk next to the badge.
                    Text(
                      isYearly
                          ? l10n.pricePerYear(plan.price)
                          : l10n.pricePerMonth(plan.price),
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: textColor,
                      ),
                    ),
                    if (plan.monthlyEquivalentPrice != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.monthlyEquivalent(plan.monthlyEquivalentPrice!),
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant,
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
