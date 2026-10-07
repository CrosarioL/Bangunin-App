import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/notifications/notification_service.dart';
import 'package:wakio/core/services/subscriptions/subscription_service.dart';
import 'package:wakio/features/paywall/presentation/providers/premium_provider.dart';

class _Recording implements NotificationService {
  final scheduled = <({int id, String title, DateTime at, bool urgent})>[];

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String payload,
    bool urgent = true,
    String? sound,
  }) async => scheduled.add((id: id, title: title, at: at, urgent: urgent));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Store implements SubscriptionService {
  @override
  Future<bool> purchase(PremiumPlan plan) async => true;

  @override
  ValueListenable<bool> get isPremium => ValueNotifier(false);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, _Recording)> setUpContainer() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final notifications = _Recording();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        subscriptionServiceProvider.overrideWithValue(_Store()),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
    addTearDown(container.dispose);
    return (container, notifications);
  }

  test('starting a 3-day trial schedules the reminder for day 2', () async {
    final (container, notifications) = await setUpContainer();
    final before = DateTime.now();

    final bought = await container
        .read(purchaseInProgressProvider.notifier)
        .purchase(
          const PremiumPlan(
            productId: 'y',
            price: 'Rp 199.000',
            period: 'year',
            trialDays: 3,
          ),
        );

    expect(bought, isTrue);
    expect(notifications.scheduled, hasLength(1));
    final reminder = notifications.scheduled.single;
    expect(reminder.id, trialReminderNotificationId);
    expect(reminder.urgent, isFalse, reason: 'a reminder, not an alarm');
    // One day before the third day ends the trial.
    expect(reminder.at.difference(before).inHours, inInclusiveRange(47, 48));
    expect(reminder.title, 'Uji coba gratismu berakhir besok');
  });

  test('a purchase without a trial schedules nothing', () async {
    final (container, notifications) = await setUpContainer();
    await container
        .read(purchaseInProgressProvider.notifier)
        .purchase(
          const PremiumPlan(
            productId: 'm',
            price: 'Rp 49.000',
            period: 'month',
          ),
        );
    expect(notifications.scheduled, isEmpty);
  });

  test('alarm resyncs leave the trial reminder alone', () {
    expect(
      NotificationService.preservedIds,
      contains(trialReminderNotificationId),
    );
  });
}
