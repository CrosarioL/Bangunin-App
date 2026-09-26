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

  /// Trial length recognized when an active store offer returns a 3-day phase.
  /// The app does not create a trial; Play Console/App Store Connect control
  /// whether one is currently available.
  static const trialDays = 3;

  /// Simulated paywall: the paywall renders and behaves exactly like the
  /// real one (plans and "purchase" flow), but tapping the CTA
  /// grants premium locally without ever contacting StoreKit/Play Billing —
  /// nobody is charged and no store products need to exist. Flip to false
  /// (and create the products in App Store Connect / Play Console) to go
  /// live with real billing.
  static const fakePaywall = bool.fromEnvironment(
    'BANGUNIN_FAKE_PAYWALL',
    defaultValue: kDebugMode,
  );
}
