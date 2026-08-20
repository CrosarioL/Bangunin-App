import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/core/services/device/oem_battery_advisor.dart';

void main() {
  group('vendor classification', () {
    // Manufacturer and brand strings vary by device and casing, so these are
    // worth pinning: a miss here means an Indonesian user on a Redmi gets
    // generic advice and keeps missing alarms.
    const cases = <(String manufacturer, String brand, OemFamily expected)>[
      ('Xiaomi', 'Redmi', OemFamily.xiaomi),
      ('Xiaomi', 'POCO', OemFamily.xiaomi),
      ('xiaomi', 'xiaomi', OemFamily.xiaomi),
      ('OPPO', 'OPPO', OemFamily.oppo),
      // realme runs ColorOS-derived software, so it takes OPPO's advice.
      ('realme', 'realme', OemFamily.oppo),
      ('vivo', 'vivo', OemFamily.vivo),
      ('vivo', 'iQOO', OemFamily.vivo),
      ('OnePlus', 'OnePlus', OemFamily.oneplus),
      ('HUAWEI', 'HUAWEI', OemFamily.huawei),
      ('HONOR', 'HONOR', OemFamily.huawei),
      ('samsung', 'samsung', OemFamily.samsung),
      ('INFINIX', 'Infinix', OemFamily.transsion),
      ('TECNO', 'TECNO', OemFamily.transsion),
      ('itel', 'itel', OemFamily.transsion),
      ('Google', 'google', OemFamily.other),
      ('Nothing', 'Nothing', OemFamily.other),
      ('', '', OemFamily.other),
    ];

    for (final (manufacturer, brand, expected) in cases) {
      test('$manufacturer / $brand -> ${expected.name}', () {
        expect(OemBatteryAdvisor.classify(manufacturer, brand), expected);
      });
    }
  });

  group('which vendors need the extra autostart step', () {
    const needsExtra = [
      OemFamily.xiaomi,
      OemFamily.oppo,
      OemFamily.vivo,
      OemFamily.huawei,
      OemFamily.transsion,
    ];

    for (final family in OemFamily.values) {
      test(family.name, () {
        final advice = OemBatteryAdvice(
          family: family,
          isExempt: true,
          applies: true,
        );
        expect(advice.needsVendorStep, needsExtra.contains(family));
      });
    }
  });

  group('when the advice is shown at all', () {
    test('an aggressive vendor keeps advising even once exempt', () {
      // The standard exemption is not sufficient on these, so going quiet
      // after it is granted would leave the user still missing alarms.
      const advice = OemBatteryAdvice(
        family: OemFamily.xiaomi,
        isExempt: true,
        applies: true,
      );

      expect(advice.needsVendorStep, isTrue);
    });

    test('iOS is never applicable', () {
      const advice = OemBatteryAdvice.notApplicable();

      expect(advice.applies, isFalse);
      expect(advice.isExempt, isTrue);
      expect(advice.needsVendorStep, isFalse);
    });
  });
}
