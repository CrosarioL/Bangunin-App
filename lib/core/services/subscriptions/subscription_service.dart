import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

/// A purchasable plan surfaced on the paywall.
class PremiumPlan {
  const PremiumPlan({
    required this.productId,
    required this.price,
    required this.period,
    this.monthlyEquivalentPrice,
    this.trialDays = 0,
    this.productDetails,
  });

  final String productId;

  /// Localized price string, e.g. "$59.99".
  final String price;

  /// "month" or "year" — used by the paywall copy.
  final String period;

  /// For yearly plans: the per-month framing shown under the price
  /// (e.g. "$4.99"). Null for monthly plans.
  final String? monthlyEquivalentPrice;

  /// Days of free trial attached to this plan (0 = none).
  final int trialDays;

  final ProductDetails? productDetails;

  bool get hasTrial => trialDays > 0;
}

/// Entitlement state + purchase flow. Mirrors how the shipped product works:
/// StoreKit/Play Billing purchases, a single "premium" entitlement, no user
/// accounts (the entitlement is cached locally and restorable via the store).
abstract interface class SubscriptionService {
  ValueListenable<bool> get isPremium;

  Future<List<PremiumPlan>> loadPlans();

  /// Returns true when the purchase completed and premium was granted.
  Future<bool> purchase(PremiumPlan plan);

  Future<void> restore();

  Future<void> dispose();
}

class StoreSubscriptionService implements SubscriptionService {
  StoreSubscriptionService(this._prefs) {
    _premium = ValueNotifier<bool>(_prefs.getBool(_premiumKey) ?? false);
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdates,
    );
  }

  static const _premiumKey = 'premium_entitlement';

  final SharedPreferences _prefs;
  late final ValueNotifier<bool> _premium;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSub;
  Completer<bool>? _pendingPurchase;

  @override
  ValueListenable<bool> get isPremium => _premium;

  @override
  Future<List<PremiumPlan>> loadPlans() async {
    if (!await InAppPurchase.instance.isAvailable()) return const [];
    final response = await InAppPurchase.instance.queryProductDetails(
      AppConfig.allProductIds,
    );
    final plans = <String, PremiumPlan>{};
    for (final details in response.productDetails) {
      final plan = _planFromStoreDetails(details);
      final current = plans[details.id];
      // Play may return a base plan and one or more offers. Prefer the offer
      // with a real trial; otherwise keep the first purchasable base plan.
      if (current == null || (!current.hasTrial && plan.hasTrial)) {
        plans[details.id] = plan;
      }
    }
    return plans.values.toList();
  }

  PremiumPlan _planFromStoreDetails(ProductDetails details) {
    var displayPrice = details.price;
    var trialDays = 0;
    if (details is GooglePlayProductDetails &&
        details.subscriptionIndex != null) {
      final index = details.subscriptionIndex!;
      final offers = details.productDetails.subscriptionOfferDetails;
      if (offers != null && index < offers.length) {
        final phases = offers[index].pricingPhases;
        final trial = phases.where((phase) => phase.priceAmountMicros == 0);
        if (trial.isNotEmpty) {
          trialDays = _isoPeriodDays(trial.first.billingPeriod);
        }
        final paid = phases.where((phase) => phase.priceAmountMicros > 0);
        if (paid.isNotEmpty) displayPrice = paid.last.formattedPrice;
      }
    } else {
      // StoreKit free-trial eligibility is finalized by Apple's purchase
      // sheet. The configured offer is mirrored here for the iOS UI.
      trialDays = AppConfig.trialDays;
    }
    return PremiumPlan(
      productId: details.id,
      price: displayPrice,
      period: details.id == AppConfig.monthlyProductId ? 'month' : 'year',
      trialDays: trialDays,
      productDetails: details,
    );
  }

  int _isoPeriodDays(String period) {
    final match = RegExp(r'^P(\d+)D$').firstMatch(period);
    return match == null ? 0 : int.tryParse(match.group(1)!) ?? 0;
  }

  @override
  Future<bool> purchase(PremiumPlan plan) async {
    final details = plan.productDetails;
    if (details == null) return false;
    _pendingPurchase = Completer<bool>();
    final started = await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
    if (!started) {
      _pendingPurchase = null;
      return false;
    }
    return _pendingPurchase!.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => false,
    );
  }

  @override
  Future<void> restore() => InAppPurchase.instance.restorePurchases();

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantPremium();
          _pendingPurchase?.complete(true);
          _pendingPurchase = null;
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          _pendingPurchase?.complete(false);
          _pendingPurchase = null;
        case PurchaseStatus.pending:
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<void> _grantPremium() async {
    _premium.value = true;
    await _prefs.setBool(_premiumKey, true);
  }

  @override
  Future<void> dispose() async {
    await _purchaseSub.cancel();
    _premium.dispose();
  }
}

/// Simulated store (see [AppConfig.fakePaywall]): serves fixed display
/// prices and "completes" any purchase instantly and locally. No store
/// connection, no charge — the paywall UX is fully exercisable before real
/// products exist. Prices are locale-aware the same way the real stores
/// are: Indonesian devices see the IDR price tier, everyone else sees USD.
class FakeSubscriptionService implements SubscriptionService {
  FakeSubscriptionService(this._prefs)
    : _premium = ValueNotifier<bool>(_prefs.getBool(_key) ?? false);

  static const _key = 'fake_premium_entitlement';

  final SharedPreferences _prefs;
  final ValueNotifier<bool> _premium;

  @override
  ValueListenable<bool> get isPremium => _premium;

  @override
  Future<List<PremiumPlan>> loadPlans() async {
    final isIndonesian =
        PlatformDispatcher.instance.locale.languageCode == 'id';
    if (isIndonesian) {
      return const [
        PremiumPlan(
          productId: AppConfig.yearlyProductId,
          price: 'Rp 199.000',
          period: 'year',
          monthlyEquivalentPrice: 'Rp 16.600',
          trialDays: AppConfig.trialDays,
        ),
        PremiumPlan(
          productId: AppConfig.monthlyProductId,
          price: 'Rp 49.000',
          period: 'month',
          trialDays: AppConfig.trialDays,
        ),
      ];
    }
    return const [
      PremiumPlan(
        productId: AppConfig.yearlyProductId,
        price: r'$29.99',
        period: 'year',
        monthlyEquivalentPrice: r'$2.49',
        trialDays: AppConfig.trialDays,
      ),
      PremiumPlan(
        productId: AppConfig.monthlyProductId,
        price: r'$4.99',
        period: 'month',
        trialDays: AppConfig.trialDays,
      ),
    ];
  }

  @override
  Future<bool> purchase(PremiumPlan plan) async {
    // A short beat so the CTA's loading state reads as a real transaction.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _premium.value = true;
    await _prefs.setBool(_key, true);
    return true;
  }

  @override
  Future<void> restore() async {
    _premium.value = true;
    await _prefs.setBool(_key, true);
  }

  @override
  Future<void> dispose() async => _premium.dispose();
}
