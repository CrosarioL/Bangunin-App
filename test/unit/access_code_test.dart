import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/core/services/subscriptions/subscription_service.dart';

void main() {
  test('all five early access codes grant local premium', () async {
    for (var number = 1; number <= 5; number++) {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = FakeSubscriptionService(prefs);

      expect(await service.redeemAccessCode('iamtheownerfree$number'), isTrue);
      expect(service.isPremium.value, isTrue);
      await service.dispose();
    }
  });

  test(
    'access codes are case-insensitive and trim surrounding spaces',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = FakeSubscriptionService(prefs);

      expect(await service.redeemAccessCode(' IAMTHEOWNERFREE1 '), isTrue);
      await service.dispose();
    },
  );

  test('an unknown access code is rejected', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = FakeSubscriptionService(prefs);

    expect(await service.redeemAccessCode('not-a-real-code'), isFalse);
    expect(service.isPremium.value, isFalse);
    await service.dispose();
  });
}
