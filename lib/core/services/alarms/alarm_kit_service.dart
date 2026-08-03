import 'package:flutter/services.dart';

/// Which mechanism is actually ringing the user's alarms.
///
/// This is a user-facing distinction, not an implementation detail: the two
/// engines have genuinely different capabilities and the UI must say so
/// rather than implying every device gets the strong behaviour.
enum AlarmEngine {
  /// Apple AlarmKit (iOS 26+, authorized). Rings through Silent Mode and
  /// Focus, presents full screen, appears on the Lock Screen.
  alarmKit,

  /// Scheduled local notifications. The honest fallback: it cannot override
  /// Silent Mode or Focus, cannot launch the app, and stops after ~30s.
  notifications,
}

/// Result of asking iOS whether we may schedule real alarms.
enum AlarmKitAuthorization {
  /// Device is below iOS 26, or the framework is unavailable.
  unsupported,

  /// The user has not been asked yet.
  notDetermined,

  /// Real alarms are available.
  authorized,

  /// The user said no. We fall back to notifications and say so.
  denied;

  static AlarmKitAuthorization parse(String? raw) => switch (raw) {
    'authorized' => AlarmKitAuthorization.authorized,
    'denied' => AlarmKitAuthorization.denied,
    'notDetermined' => AlarmKitAuthorization.notDetermined,
    _ => AlarmKitAuthorization.unsupported,
  };

  bool get canScheduleRealAlarms => this == AlarmKitAuthorization.authorized;
}

/// Raised when iOS refuses to accept another alarm.
class AlarmLimitReachedException implements Exception {
  const AlarmLimitReachedException();
  @override
  String toString() => 'AlarmLimitReachedException';
}

/// Dart half of the AlarmKit bridge in `ios/Runner/AlarmKitBridge.swift`.
///
/// Every method degrades safely on platforms without AlarmKit (Android, and
/// iOS below 26): `isSupported` reports false and the caller uses the
/// notification scheduler instead.
class AlarmKitService {
  AlarmKitService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('app.bangunin/alarmkit');

  final MethodChannel _channel;

  bool? _supportedCache;

  /// Whether this device can use AlarmKit at all. Cached — it cannot change
  /// within a single run of the app.
  Future<bool> isSupported() async {
    final cached = _supportedCache;
    if (cached != null) return cached;
    final supported = await _invoke<bool>('isSupported') ?? false;
    _supportedCache = supported;
    return supported;
  }

  Future<AlarmKitAuthorization> authorizationState() async =>
      AlarmKitAuthorization.parse(await _invoke<String>('authorizationState'));

  /// Prompts the user. Only call this from a screen that has already
  /// explained why we are asking.
  Future<AlarmKitAuthorization> requestAuthorization() async =>
      AlarmKitAuthorization.parse(
        await _invoke<String>('requestAuthorization'),
      );

  /// Schedules one alarm.
  ///
  /// [weekdays] uses ISO numbering (1 = Monday … 7 = Sunday). An empty list
  /// schedules a single, non-repeating alarm.
  Future<void> schedule({
    required String id,
    required int hour,
    required int minute,
    required List<int> weekdays,
    required String label,
    required String missionType,
    required String secondaryButtonTitle,
    required String stopButtonTitle,
    String? soundName,
  }) async {
    try {
      await _channel.invokeMethod<bool>('schedule', {
        'id': id,
        'hour': hour,
        'minute': minute,
        'weekdays': weekdays,
        'label': label,
        'missionType': missionType,
        'secondaryButtonTitle': secondaryButtonTitle,
        'stopButtonTitle': stopButtonTitle,
        'soundName': ?soundName,
      });
    } on PlatformException catch (error) {
      if (error.code == 'limit_reached') {
        throw const AlarmLimitReachedException();
      }
      rethrow;
    }
  }

  Future<void> cancel(String id) async => _invoke<bool>('cancel', {'id': id});

  Future<void> cancelAll() async => _invoke<bool>('cancelAll');

  /// Ids AlarmKit currently holds — used to reconcile after an app update or
  /// a reinstall, where our local store and the system can disagree.
  Future<List<String>> scheduledIds() async {
    final ids = await _invoke<List<Object?>>('scheduledIds');
    return ids?.whereType<String>().toList() ?? const [];
  }

  /// The alarm the user opened from an alert's mission button, if any.
  /// Consuming it clears it, so a mission is routed to exactly once.
  Future<String?> consumePendingMissionAlarmId() async =>
      _invoke<String>('consumePendingMissionAlarmId');

  /// Swallows MissingPluginException so the same code path works on Android
  /// and in tests, where the channel simply is not there.
  Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    }
  }
}
