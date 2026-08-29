import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_card.dart';
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
import '../widgets/trial_timeline.dart';

/// Hard paywall shown right after onboarding (and on any locked entry
/// point). Yearly is pre-selected as the anchor and carries the free trial;
/// monthly sits below it. There is no close button — the product gates
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
                onAccessCode: _showAccessCodeDialog,
              ),
              data: (plans) {
                if (plans.isEmpty) {
                  return _ErrorState(
                    onRetry: () => ref.invalidate(premiumPlansProvider),
                    onAccessCode: _showAccessCodeDialog,
                  );
                }
                final selected = plans.firstWhere(
                  (p) => p.productId == _selectedProductId,
                  orElse: () => plans.first,
                );
                final trialPlans = plans.where((p) => p.hasTrial);
                final noTrialPlans = plans.where((p) => !p.hasTrial);
                final trialPlan = trialPlans.isEmpty ? null : trialPlans.first;
                final noTrialPlan = noTrialPlans.isEmpty
                    ? null
                    : noTrialPlans.first;
                return ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      userName.isNotEmpty
                          ? l10n.paywallTitleNamed(userName)
                          : l10n.paywallTitle,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.paywallGoalLine(
                        TimeFormat.clock(
                          context,
                          answers.wakeGoalHour,
                          answers.wakeGoalMinute,
                        ),
                      ),
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.paywallSubtitle,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Feature(text: l10n.paywallFeatureMissions),
                    _Feature(text: l10n.paywallFeatureSounds),
                    _Feature(text: l10n.paywallFeatureStreaks),
                    _Feature(text: l10n.paywallFeatureNoLimit),
                    const SizedBox(height: AppSpacing.xl),
                    for (final plan in plans) ...[
                      _PlanCard(
                        plan: plan,
                        selected: plan.productId == selected.productId,
                        onTap: () {
                          Haptics.selection();
                          setState(() => _selectedProductId = plan.productId);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    // The toggle only makes sense when there's an actual
                    // trial vs. no-trial choice between plans; now that
                    // every plan carries a trial, noTrialPlan is always
                    // null and this simply never renders.
                    if (trialPlan != null && noTrialPlan != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.freeTrialToggle,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            Switch(
                              value: selected.hasTrial,
                              onChanged: (enabled) {
                                Haptics.selection();
                                setState(() {
                                  _selectedProductId =
                                      (enabled ? trialPlan : noTrialPlan)
                                          .productId;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ] else
                      const SizedBox(height: AppSpacing.sm),
                    // The timeline reflects whichever plan is selected,
                    // independent of whether a toggle is even shown above —
                    // every plan can carry a trial.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: selected.hasTrial
                            ? TrialTimeline(
                                key: const ValueKey('trial-timeline'),
                                trialDays: selected.trialDays,
                              )
                            : const SizedBox(
                                key: ValueKey('no-trial-timeline'),
                                width: double.infinity,
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: selected.hasTrial
                          ? l10n.paywallCtaTrial(selected.trialDays)
                          : l10n.paywallCtaNoTrial,
                      loading: purchasing,
                      onPressed: () => _purchase(selected),
                    ),
                    if (selected.hasTrial) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        Localizations.localeOf(context).languageCode == 'id'
                            ? 'Setelah uji coba ${selected.trialDays} hari, '
                                  '${selected.price} per ${selected.period == 'month' ? 'bulan' : 'tahun'}. '
                                  'Langganan diperpanjang otomatis sampai dibatalkan di ${_storeName()}.'
                            : 'After the ${selected.trialDays}-day trial, '
                                  '${selected.price} per ${selected.period}. '
                                  'Auto-renews until cancelled in ${_storeName()}.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (selected.hasTrial) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.noPaymentNow,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
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
                      child: TextButton(
                        onPressed: purchasing ? null : _showAccessCodeDialog,
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'id'
                              ? 'Punya kode akses?'
                              : 'Have an access code?',
                        ),
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

  Future<void> _showAccessCodeDialog() async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.accessCodeTitle),
        content: TextField(
          controller: controller,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(hintText: l10n.accessCodeHint),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.accessCodeRedeem),
          ),
        ],
      ),
    );
    // Wait for the dialog's reverse transition before releasing the
    // controller; the TextField remains mounted during that animation.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (code == null || !mounted) return;

    final accepted = await ref
        .read(subscriptionServiceProvider)
        .redeemAccessCode(code);
    if (!accepted && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accessCodeInvalid)));
    }
  }

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
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
    required this.selected,
    required this.onTap,
  });

  final PremiumPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isYearly = plan.period == 'year';
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
            color: selected
                ? AppColors.primary.withValues(alpha: 0.16)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            border: Border.all(
              color: selected ? AppColors.primary : theme.colorScheme.outline,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: selected ? AppColors.primaryEdge : AppColors.surfaceEdge,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isYearly ? l10n.planYearly : l10n.planMonthly,
                          style: theme.textTheme.titleSmall,
                        ),
                        if (isYearly) ...[
                          const SizedBox(width: AppSpacing.sm),
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
                              l10n.saveBadge,
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
                    Text(
                      isYearly
                          ? l10n.pricePerYear(plan.price)
                          : l10n.pricePerMonth(plan.price),
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
  const _ErrorState({required this.onRetry, required this.onAccessCode});

  final VoidCallback onRetry;
  final VoidCallback onAccessCode;

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
          TextButton(
            onPressed: onAccessCode,
            child: Text(
              Localizations.localeOf(context).languageCode == 'id'
                  ? 'Punya kode akses?'
                  : 'Have an access code?',
            ),
          ),
        ],
      ),
    );
  }
}
