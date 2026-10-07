import 'package:flutter/foundation.dart';

/// Compile-time configuration for the app.
///
/// Brand: **Bangunin** — colloquial Indonesian for "wake (someone) up"
/// ("bangunin aku jam 5!"), with a crowing rooster mascot: in Indonesia the
/// rooster's kukuruyuk IS the sound of morning. Primary market is Indonesia
/// (id locale, IDR pricing); English ships alongside. Run a real trademark
/// search before any store release (see README, "Naming & trademarks").
abstract final class AppConfig {
  static const appName = 'Bangunin';

  static const supportEmail = 'hello@bangunin.app';
  static const privacyPolicyUrl = 'https://bangunin.app/privacy.html';
  static const termsUrl = 'https://bangunin.app/terms.html';
  static const manageGooglePlaySubscriptionUrl =
      'https://play.google.com/store/account/subscriptions'
      '?package=app.bangunin';
  static const manageAppStoreSubscriptionUrl =
      'https://apps.apple.com/account/subscriptions';

  /// Subscription product identifiers. Store-listed IDR (primary market):
  /// Rp 49.000/month and Rp 199.000/year (≈ Rp 16.600/mo, "save 66%").
  /// Rest-of-world USD: $4.99/month and $29.99/year. Set these as Play
  /// Console / App Store Connect price tiers; the fake paywall mirrors them
  /// per-locale.
  static const monthlyProductId = 'bangunin.premium.monthly';
  static const yearlyProductId = 'bangunin.premium.yearly';

  static const allProductIds = {monthlyProductId, yearlyProductId};

  /// RevenueCat entitlement that unlocks premium (RevenueCat > Entitlements).
  static const premiumEntitlementId = 'bangunin_pro';

  /// RevenueCat public SDK keys (Project settings > API keys). Public by
  /// design, so they live in the app. Never put the secret `sk_` key here.
  static const revenueCatAppleKey = 'appl_yvEMLICodGrRKkDTTrycultHjIE';
  static const revenueCatGoogleKey = 'goog_VafVvETvemUYlaGiNVcCEUNciAm';

  /// RevenueCat Test Store: fake purchases, no store products needed. Only
  /// when built with `--dart-define=BANGUNIN_RC_TEST_STORE=true`, and never
  /// in release (RevenueCat rejects it there). Every other build, debug
  /// included, uses the real store keys, so purchases go through Apple's /
  /// Google's sandbox sheet exactly as they will in production.
  static const revenueCatTestStoreKey = 'test_rwsZiRQawjWnzHlMDqQKGyYhUdA';
  static const _useRevenueCatTestStore = bool.fromEnvironment(
    'BANGUNIN_RC_TEST_STORE',
  );

  static String get revenueCatApiKey {
    if (_useRevenueCatTestStore && !kReleaseMode) return revenueCatTestStoreKey;
    return defaultTargetPlatform == TargetPlatform.iOS
        ? revenueCatAppleKey
        : revenueCatGoogleKey;
  }

  /// Trial length recognized when an active store offer returns a 3-day phase.
  /// The app does not create a trial; Play Console/App Store Connect control
  /// whether one is currently available.
  static const trialDays = 3;

  /// Simulated paywall: tapping the CTA grants premium locally without
  /// contacting any store. Off by default in every build now that real
  /// products exist; opt in with `--dart-define=BANGUNIN_FAKE_PAYWALL=true`
  /// (e.g. on a simulator with no sandbox account).
  static const fakePaywall = bool.fromEnvironment('BANGUNIN_FAKE_PAYWALL');
}
