import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/services/locale/locale_override_provider.dart';
import '../../../../core/services/notifications/notification_service.dart';
import '../../../../core/services/subscriptions/subscription_service.dart';
import '../../../../core/utils/current_locale.dart';

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
  final service = ref.watch(subscriptionServiceProvider);
  // One quiet retry before showing an error: a slow first connection is
  // common, and an error screen is where a converting user gives up.
  List<PremiumPlan> plans;
  try {
    plans = await service.loadPlans();
  } on Object {
    plans = const [];
  }
  if (plans.isEmpty) {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    plans = await service.loadPlans();
  }
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
/// The single "your free trial ends tomorrow" notification. Listed in
/// [NotificationService.preservedIds] so alarm resyncs don't wipe it.
const trialReminderNotificationId = 2000000001;

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
      final bought = await ref.read(subscriptionServiceProvider).purchase(plan);
      if (bought && plan.hasTrial) await _scheduleTrialReminder(plan);
      return bought;
    } on Exception catch (error, stackTrace) {
      await ref.read(crashReporterProvider).recordError(error, stackTrace);
      return false;
    } finally {
      state = false;
    }
  }

  /// Keeps onboarding's promise: a reminder one day before the trial turns
  /// into a paid subscription. Best effort; a failure never blocks the
  /// purchase that just succeeded.
  Future<void> _scheduleTrialReminder(PremiumPlan plan, {DateTime? now}) async {
    try {
      final l10n = currentLocalizations(
        override: ref.read(localeOverrideProvider),
      );
      final store = defaultTargetPlatform == TargetPlatform.iOS
          ? 'App Store'
          : 'Google Play';
      await ref
          .read(notificationServiceProvider)
          .schedule(
            id: trialReminderNotificationId,
            title: l10n.trialReminderTitle,
            body: l10n.trialReminderBody(store),
            at: (now ?? DateTime.now()).add(Duration(days: plan.trialDays - 1)),
            payload: 'trial_reminder',
            urgent: false,
          );
    } on Exception catch (error, stackTrace) {
      await ref.read(crashReporterProvider).recordError(error, stackTrace);
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
