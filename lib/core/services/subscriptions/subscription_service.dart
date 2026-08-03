import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
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

  /// Grants a temporary, device-local promotional entitlement when [code]
  /// matches one of the early-review access codes.
  ///
  /// This is intentionally not a secure or globally single-use mechanism.
  Future<bool> redeemAccessCode(String code);

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
    final plans = <PremiumPlan>[];
    for (final details in response.productDetails) {
      if (details is GooglePlayProductDetails) {
        final offerIndex = details.subscriptionIndex;
        final offers = details.productDetails.subscriptionOfferDetails;
        if (offerIndex != null &&
            offers != null &&
            offerIndex < offers.length) {
          final phases = offers[offerIndex].pricingPhases;
          final recurring = phases.where(
            (phase) =>
                phase.recurrenceMode.name == 'infiniteRecurring' &&
                phase.priceAmountMicros > 0,
          );
          if (recurring.isEmpty) continue;
          final renewal = recurring.last;
          final freeTrial = phases.any(
            (phase) =>
                phase.priceAmountMicros == 0 && phase.billingPeriod == 'P3D',
          );
          plans.add(
            PremiumPlan(
              productId: details.id,
              price: renewal.formattedPrice,
              period: details.id == AppConfig.monthlyProductId
                  ? 'month'
                  : 'year',
              trialDays: freeTrial ? AppConfig.trialDays : 0,
              productDetails: details,
            ),
          );
          continue;
        }
      }
      final appleTrialDays = _appleFreeTrialDays(details);
      plans.add(
        PremiumPlan(
          productId: details.id,
          price: details.price,
          period: details.id == AppConfig.monthlyProductId ? 'month' : 'year',
          trialDays: appleTrialDays,
          productDetails: details,
        ),
      );
    }
    // Play can return multiple offers for one product. Prefer the configured
    // three-day-trial offer, then keep one purchasable plan per product.
    plans.sort((a, b) => b.trialDays.compareTo(a.trialDays));
    final byProduct = <String, PremiumPlan>{};
    for (final plan in plans) {
      byProduct.putIfAbsent(plan.productId, () => plan);
    }
    return byProduct.values.toList();
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

  @override
  Future<bool> redeemAccessCode(String code) async {
    if (!_isValidEarlyAccessCode(code)) return false;
    await _grantPremium();
    return true;
  }

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
  Future<bool> redeemAccessCode(String code) async {
    if (!_isValidEarlyAccessCode(code)) return false;
    _premium.value = true;
    await _prefs.setBool(_key, true);
    return true;
  }

  @override
  Future<void> dispose() async => _premium.dispose();
}

int _appleFreeTrialDays(ProductDetails details) {
  if (details is AppStoreProductDetails) {
    final offer = details.skProduct.introductoryPrice;
    if (offer == null ||
        offer.paymentMode != SKProductDiscountPaymentMode.freeTrail ||
        offer.price != '0') {
      return 0;
    }
    return _trialDays(
      units: offer.subscriptionPeriod.numberOfUnits * offer.numberOfPeriods,
      unit: offer.subscriptionPeriod.unit.name,
    );
  }
  if (details is AppStoreProduct2Details) {
    final offers =
        details.sk2Product.subscription?.promotionalOffers ?? const [];
    for (final offer in offers) {
      if (offer.type == SK2SubscriptionOfferType.introductory &&
          offer.paymentMode == SK2SubscriptionOfferPaymentMode.freeTrial &&
          offer.price == 0) {
        return _trialDays(
          units: offer.period.value * offer.periodCount,
          unit: offer.period.unit.name,
        );
      }
    }
  }
  return 0;
}

int _trialDays({required int units, required String unit}) {
  return switch (unit) {
    'day' => units,
    'week' => units * 7,
    _ => 0,
  };
}

// Hashes keep the plain codes out of casual string extraction. This does not
// make local redemption secure: a determined user can still patch or replay
// the client, and the codes remain reusable across installations.
const _earlyAccessCodeHashes = <String>{
  'ea29427d61091dc2ca6670eb95131088ce78aec45789f2261478e190ef74cb2e',
  '66cc37e1af68311d01921a6e824cabfaf4b661de50104491487fceffed18845e',
  '59b5e9469ccf7f2577a7843dec938d5d3709b15b7696b46ea2d7e22ca67c8a92',
  '917efd2833a835bb0965345a0273e574e7b65b5481c7f2f6c82fa6cd006b42a1',
  '380a23256dd81e913a6435f832fc0dbd9dd6ec81700758c03735e5243ed1db5e',
};

bool _isValidEarlyAccessCode(String code) {
  final normalized = code.trim().toLowerCase();
  final digest = sha256.convert(utf8.encode(normalized)).toString();
  return _earlyAccessCodeHashes.contains(digest);
}
