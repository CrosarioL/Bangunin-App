import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/subscriptions/subscription_service.dart';
import 'package:wakio/features/paywall/presentation/providers/premium_provider.dart';

/// Fails (or comes back empty) for the first [failures] calls, then serves
/// a plan — a store connection that is slow to wake up.
class _FlakyService implements SubscriptionService {
  _FlakyService({required this.failures, this.throws = false});

  final int failures;
  final bool throws;
  int calls = 0;

  @override
  Future<List<PremiumPlan>> loadPlans() async {
    calls++;
    if (calls <= failures) {
      if (throws) throw Exception('offline');
      return const [];
    }
    return const [
      PremiumPlan(productId: 'yearly', price: 'Rp 199.000', period: 'year'),
    ];
  }

  @override
  ValueListenable<bool> get isPremium => ValueNotifier(false);
  @override
  Future<bool> purchase(PremiumPlan plan) async => false;
  @override
  Future<void> restore() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  Future<List<PremiumPlan>> load(SubscriptionService service) {
    final container = ProviderContainer(
      overrides: [subscriptionServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    return container.read(premiumPlansProvider.future);
  }

  test('an empty first answer is retried before giving up', () async {
    final service = _FlakyService(failures: 1);
    final plans = await load(service);
    expect(plans, hasLength(1));
    expect(service.calls, 2);
  });

  test('a failed first fetch is retried too', () async {
    final service = _FlakyService(failures: 1, throws: true);
    final plans = await load(service);
    expect(plans, hasLength(1));
  });

  test('a working store is asked once', () async {
    final service = _FlakyService(failures: 0);
    await load(service);
    expect(service.calls, 1);
  });
}
