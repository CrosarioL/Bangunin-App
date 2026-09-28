import 'package:shared_preferences/shared_preferences.dart';

/// A Wake Up Check waiting to happen: at [checkAt] the user is asked whether
/// they're still up, and unless they confirm, the alarm rings again at
/// [ringAt].
class PendingWakeCheck {
  const PendingWakeCheck({
    required this.alarmId,
    required this.checkAt,
    required this.ringAt,
  });

  final String alarmId;
  final DateTime checkAt;
  final DateTime ringAt;

  /// How long the user has to answer the check before the alarm returns.
  static const answerWindow = Duration(seconds: 60);
}

/// Persists the one pending Wake Up Check.
///
/// Persisted, unlike the in-memory pending snooze, because the likeliest
/// time for it to matter is exactly when the app isn't running: the user
/// dismissed the alarm, the OS reclaimed the app, and a reschedule on the
/// next launch must not quietly cancel the check.
class WakeCheckStore {
  WakeCheckStore(this._prefs);

  final SharedPreferences _prefs;

  static const _alarmKey = 'wake_check_alarm';
  static const _checkAtKey = 'wake_check_at';
  static const _ringAtKey = 'wake_check_ring_at';

  PendingWakeCheck? read() {
    final alarmId = _prefs.getString(_alarmKey);
    final checkAt = _prefs.getInt(_checkAtKey);
    final ringAt = _prefs.getInt(_ringAtKey);
    if (alarmId == null || checkAt == null || ringAt == null) return null;
    return PendingWakeCheck(
      alarmId: alarmId,
      checkAt: DateTime.fromMillisecondsSinceEpoch(checkAt),
      ringAt: DateTime.fromMillisecondsSinceEpoch(ringAt),
    );
  }

  Future<void> write(PendingWakeCheck check) async {
    await _prefs.setString(_alarmKey, check.alarmId);
    await _prefs.setInt(_checkAtKey, check.checkAt.millisecondsSinceEpoch);
    await _prefs.setInt(_ringAtKey, check.ringAt.millisecondsSinceEpoch);
  }

  Future<void> clear() async {
    await _prefs.remove(_alarmKey);
    await _prefs.remove(_checkAtKey);
    await _prefs.remove(_ringAtKey);
  }
}
