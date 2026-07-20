import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/services/subscriptions/subscription_service.dart';

/// Reactive premium entitlement, bridged from the subscription service's
/// ValueListenable so widgets and the router can watch it.
final isPremiumProvider = Provider<bool>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  final listenable = service.isPremium;

  void onChange() => ref.invalidateSelf();
  listenable.addListener(onChange);
  ref.onDispose(() => listenable.removeListener(onChange));

  return listenable.value;
});

/// Plans for the paywall. Order (yearly-anchored vs. weekly-first) is a
/// remote-config lever — see [FeatureFlags.paywallShowsWeeklyFirst] — so it
/// can be A/B tested without a release.
final premiumPlansProvider = FutureProvider<List<PremiumPlan>>((ref) async {
  final plans = await ref.watch(subscriptionServiceProvider).loadPlans();
  final weeklyFirst = ref.watch(featureFlagsProvider).paywallShowsWeeklyFirst;
  final sorted = [...plans]
    ..sort((a, b) {
      if (a.period == b.period) return a.productId.compareTo(b.productId);
      final yearlyFirst = a.period == 'year' ? -1 : 1;
      return weeklyFirst ? -yearlyFirst : yearlyFirst;
    });
  return sorted;
});

/// In-flight purchase state so the paywall can disable buttons and show a
/// spinner on the tapped plan.
final purchaseInProgressProvider =
    NotifierProvider<PurchaseInProgressNotifier, bool>(
      PurchaseInProgressNotifier.new,
    );

class PurchaseInProgressNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<bool> purchase(PremiumPlan plan) async {
    if (state) return false;
    state = true;
    try {
      return await ref.read(subscriptionServiceProvider).purchase(plan);
    } on Exception catch (error, stackTrace) {
      await ref.read(crashReporterProvider).recordError(error, stackTrace);
      return false;
    } finally {
      state = false;
    }
  }

  Future<void> restore() async {
    if (state) return;
    state = true;
    try {
      await ref.read(subscriptionServiceProvider).restore();
    } on Exception catch (error, stackTrace) {
      if (kDebugMode) debugPrint('restore failed: $error');
      await ref.read(crashReporterProvider).recordError(error, stackTrace);
    } finally {
      state = false;
    }
  }
}
