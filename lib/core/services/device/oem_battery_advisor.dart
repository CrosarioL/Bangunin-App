import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Which vendor's background-killing behaviour we are up against.
///
/// This is the single biggest cause of "my alarm didn't go off" on Android,
/// and it is not something correct code can fix: several manufacturers ship
/// battery managers that kill scheduled work regardless of the permissions an
/// app holds. It matters disproportionately in Indonesia, where these brands
/// dominate the market.
enum OemFamily {
  /// Xiaomi, Redmi, POCO — MIUI / HyperOS. Autostart is off by default.
  xiaomi,

  /// OPPO (ColorOS) and realme (realme UI, ColorOS-derived).
  oppo,

  /// vivo / iQOO — Funtouch OS, OriginOS.
  vivo,

  /// OnePlus — OxygenOS.
  oneplus,

  /// Huawei / Honor — EMUI, MagicOS. "Manage manually" per app.
  huawei,

  /// Samsung — One UI. Puts unused apps to sleep by default.
  samsung,

  /// Transsion brands (Infinix, TECNO, itel) — HiOS / XOS. Significant share
  /// in Indonesia and aggressive by default.
  transsion,

  /// Stock-ish Android, or a vendor we have no specific advice for. The
  /// standard battery-optimisation exemption still applies.
  other,
}

/// What we should tell this user, if anything.
class OemBatteryAdvice {
  const OemBatteryAdvice({
    required this.family,
    required this.isExempt,
    required this.applies,
  });

  const OemBatteryAdvice.notApplicable()
    : family = OemFamily.other,
      isExempt = true,
      applies = false;

  final OemFamily family;

  /// Whether the app already holds the battery-optimisation exemption.
  final bool isExempt;

  /// False on iOS, and once the user is exempt on a vendor with no extra
  /// autostart setting to worry about.
  final bool applies;

  /// Vendors that need a second, vendor-specific autostart step beyond the
  /// standard Android exemption — so we keep advising even once exempt.
  bool get needsVendorStep => switch (family) {
    OemFamily.xiaomi ||
    OemFamily.oppo ||
    OemFamily.vivo ||
    OemFamily.huawei ||
    OemFamily.transsion => true,
    OemFamily.oneplus || OemFamily.samsung || OemFamily.other => false,
  };
}

/// Detects the vendor and whether Bangunin is exempt from battery
/// optimisation.
///
/// On the permission itself: `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` is a
/// restricted permission on Google Play, and asking for it without a
/// qualifying use case gets an app rejected. Alarm clocks are one of the use
/// cases Play explicitly permits, which is exactly what Bangunin is — but the
/// declaration in Play Console must say so.
class OemBatteryAdvisor {
  OemBatteryAdvisor({DeviceInfoPlugin? deviceInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  Future<OemBatteryAdvice> advise() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const OemBatteryAdvice.notApplicable();
    }

    final family = await _family();
    final isExempt = await Permission.ignoreBatteryOptimizations.isGranted;

    return OemBatteryAdvice(
      family: family,
      isExempt: isExempt,
      // Keep advising the aggressive vendors even after the exemption is
      // granted: on those, the exemption alone is not enough.
      applies: !isExempt || _vendorNeedsExtraStep(family),
    );
  }

  /// Asks for the standard Android battery-optimisation exemption. Returns
  /// whether it is now granted.
  Future<bool> requestExemption() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    return status.isGranted;
  }

  Future<OemFamily> _family() async {
    try {
      final info = await _deviceInfo.androidInfo;
      return classify(info.manufacturer, info.brand);
    } on Exception {
      return OemFamily.other;
    }
  }

  static bool _vendorNeedsExtraStep(OemFamily family) => const {
    OemFamily.xiaomi,
    OemFamily.oppo,
    OemFamily.vivo,
    OemFamily.huawei,
    OemFamily.transsion,
  }.contains(family);

  /// Maps manufacturer/brand strings onto a family. Exposed for testing —
  /// these strings vary by device and are worth pinning.
  @visibleForTesting
  static OemFamily classify(String manufacturer, String brand) {
    final value = '$manufacturer $brand'.toLowerCase();

    bool has(List<String> needles) => needles.any(value.contains);

    if (has(['xiaomi', 'redmi', 'poco'])) return OemFamily.xiaomi;
    // realme runs ColorOS-derived software, so it gets the same advice.
    if (has(['oppo', 'realme'])) return OemFamily.oppo;
    if (has(['vivo', 'iqoo'])) return OemFamily.vivo;
    if (has(['oneplus'])) return OemFamily.oneplus;
    if (has(['huawei', 'honor'])) return OemFamily.huawei;
    if (has(['samsung'])) return OemFamily.samsung;
    if (has(['infinix', 'tecno', 'itel', 'transsion'])) {
      return OemFamily.transsion;
    }
    return OemFamily.other;
  }
}
