import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

/// A purchasable plan surfaced on the paywall.
class PremiumPlan {
  const PremiumPlan({
    required this.productId,
    required this.price,
    required this.period,
    this.monthlyEquivalentPrice,
    this.rawPrice,
    this.trialDays = 0,
    this.package,
  });

  final String productId;

  /// Localized price string, e.g. "$59.99".
  final String price;

  /// "month" or "year" — used by the paywall copy.
  final String period;

  /// For yearly plans: the per-month framing shown under the price
  /// (e.g. "$4.99"). Null for monthly plans.
  final String? monthlyEquivalentPrice;

  /// The renewal price as a number, in the store's currency. Used to work out
  /// the yearly saving; null when the store did not report it.
  final double? rawPrice;

  /// Days of free trial attached to this plan (0 = none).
  final int trialDays;

  /// The RevenueCat package to buy. Null for the simulated store.
  final Package? package;

  bool get hasTrial => trialDays > 0;
}

/// Entitlement state + purchase flow. Mirrors how the shipped product works:
/// App Store / Play purchases through RevenueCat, a single "premium"
/// entitlement, no user accounts (RevenueCat's anonymous ID; restorable via
/// the store).
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

/// Real billing through RevenueCat, on both App Store and Google Play.
///
/// Premium follows RevenueCat's `premium` entitlement, re-read on every launch
/// and whenever RevenueCat pushes a change, so a cancelled trial, an expired
/// subscription or a refund takes premium away again. The last known state is
/// cached so the app opens straight into premium while offline.
///
/// Early-access codes are a separate, device-local grant and survive the
/// entitlement lapsing.
class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService(this._prefs) {
    _premium = ValueNotifier<bool>(
      (_prefs.getBool(_entitlementCacheKey) ?? false) ||
          (_prefs.getBool(_accessCodeKey) ?? false),
    );
    _ready = _configure();
  }

  static const _entitlementCacheKey = 'rc_premium_entitlement';
  static const _accessCodeKey = 'access_code_premium';

  final SharedPreferences _prefs;
  late final ValueNotifier<bool> _premium;
  late final Future<bool> _ready;

  @override
  ValueListenable<bool> get isPremium => _premium;

  Future<bool> _configure() async {
    final apiKey = AppConfig.revenueCatApiKey;
    if (apiKey.isEmpty) {
      debugPrint('RevenueCat: no API key for this platform/build.');
      return false;
    }
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      Purchases.addCustomerInfoUpdateListener(_apply);
      _apply(await Purchases.getCustomerInfo());
      return true;
    } on PlatformException catch (error) {
      debugPrint('RevenueCat configure failed: ${error.message}');
      return false;
    }
  }

  void _apply(CustomerInfo info) {
    final active = info.entitlements.active.containsKey(
      AppConfig.premiumEntitlementId,
    );
    unawaited(_prefs.setBool(_entitlementCacheKey, active));
    _premium.value = active || (_prefs.getBool(_accessCodeKey) ?? false);
  }

  @override
  Future<List<PremiumPlan>> loadPlans() async {
    if (!await _ready) return const [];
    final offering = (await Purchases.getOfferings()).current;
    if (offering == null) return const [];

    final packages = [?offering.annual, ?offering.monthly];
    final eligibility = await _introEligibility(packages);

    return [
      for (final package in packages)
        _planFor(
          package,
          eligible: eligibility[package.storeProduct.identifier] ?? true,
        ),
    ];
  }

  PremiumPlan _planFor(Package package, {required bool eligible}) {
    final product = package.storeProduct;
    final isYearly = package.packageType == PackageType.annual;
    return PremiumPlan(
      productId: product.identifier,
      price: product.priceString,
      rawPrice: product.price,
      period: isYearly ? 'year' : 'month',
      monthlyEquivalentPrice: isYearly ? product.pricePerMonthString : null,
      trialDays: eligible ? _freeTrialDays(product.introductoryPrice) : 0,
      package: package,
    );
  }

  /// Apple offers the trial only once per subscription group, so ask before
  /// advertising it. Google already hides offers the user can't take.
  Future<Map<String, bool>> _introEligibility(List<Package> packages) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return const {};
    try {
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility([
        for (final p in packages) p.storeProduct.identifier,
      ]);
      return {
        for (final entry in result.entries)
          entry.key:
              entry.value.status !=
              IntroEligibilityStatus.introEligibilityStatusIneligible,
      };
    } on PlatformException {
      return const {};
    }
  }

  @override
  Future<bool> purchase(PremiumPlan plan) async {
    final package = plan.package;
    if (package == null || !await _ready) return false;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _apply(result.customerInfo);
      return _premium.value;
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) !=
          PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat purchase failed: ${error.message}');
      }
      return false;
    }
  }

  @override
  Future<void> restore() async {
    if (!await _ready) return;
    try {
      _apply(await Purchases.restorePurchases());
    } on PlatformException catch (error) {
      debugPrint('RevenueCat restore failed: ${error.message}');
    }
  }

  @override
  Future<bool> redeemAccessCode(String code) async {
    if (!_isValidEarlyAccessCode(code)) return false;
    await _prefs.setBool(_accessCodeKey, true);
    _premium.value = true;
    return true;
  }

  @override
  Future<void> dispose() async {
    Purchases.removeCustomerInfoUpdateListener(_apply);
    _premium.dispose();
  }
}

/// Length of a free (zero-price) introductory phase, in days; 0 if none.
int _freeTrialDays(IntroductoryPrice? intro) {
  if (intro == null || intro.price != 0) return 0;
  final units = intro.periodNumberOfUnits * intro.cycles;
  return switch (intro.periodUnit) {
    PeriodUnit.day => units,
    PeriodUnit.week => units * 7,
    _ => 0,
  };
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
          rawPrice: 199000,
          period: 'year',
          monthlyEquivalentPrice: 'Rp 16.600',
          trialDays: AppConfig.trialDays,
        ),
        PremiumPlan(
          productId: AppConfig.monthlyProductId,
          price: 'Rp 49.000',
          rawPrice: 49000,
          period: 'month',
          trialDays: AppConfig.trialDays,
        ),
      ];
    }
    return const [
      PremiumPlan(
        productId: AppConfig.yearlyProductId,
        price: r'$29.99',
        rawPrice: 29.99,
        period: 'year',
        monthlyEquivalentPrice: r'$2.49',
        trialDays: AppConfig.trialDays,
      ),
      PremiumPlan(
        productId: AppConfig.monthlyProductId,
        price: r'$4.99',
        rawPrice: 4.99,
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
