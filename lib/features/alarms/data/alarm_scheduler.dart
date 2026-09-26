import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/services/alarms/alarm_kit_service.dart';
import '../../../core/services/notifications/notification_service.dart';
import '../../../core/utils/current_locale.dart';
import '../../missions/domain/mission_type.dart';
import '../domain/entities/alarm.dart';

/// Schedules alarms with the strongest mechanism the device allows.
///
/// Three engines, and the difference between them is user-visible:
///
///  * **iOS 26+, authorized → AlarmKit.** Rings through Silent Mode and Focus,
///    presents full screen, reaches the Lock Screen.
///  * **Android → exact alarms.** A different mechanism, comparable outcome:
///    USE_EXACT_ALARM plus USE_FULL_SCREEN_INTENT, notification category
///    `alarm` and AudioAttributesUsage.alarm genuinely do launch full screen
///    and ring through the ringer. Android is **not** the weak path.
///  * **iOS below 26, or AlarmKit denied → notifications.** The only genuinely
///    weak engine: it cannot beat Silent Mode or Focus, cannot launch the app,
///    and stops after ~30s.
///
/// [activeEngine] reports which is in force so the UI can tell the truth
/// rather than implying every device gets the strong behaviour — or, just as
/// badly, telling an Android user their alarms are weak when they are not.
///
/// Exactly one engine is armed at a time; the other is cleared on every
/// reschedule so a user can never be woken twice by the same alarm.
class AlarmScheduler {
  AlarmScheduler(
    this._notifications, {
    AlarmKitService? alarmKit,
    this.localeOverride,
  }) : _alarmKit = alarmKit ?? AlarmKitService();

  final NotificationService _notifications;
  final AlarmKitService _alarmKit;
  final Locale? localeOverride;

  /// Which mechanism will ring the user's alarms right now.
  Future<AlarmEngine> activeEngine() async {
    // Android is not the iOS fallback. Exact alarms plus a full-screen intent
    // and alarm-usage audio genuinely do launch full screen and ring through
    // the ringer, so reporting it as the weak path would be false.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AlarmEngine.androidExactAlarm;
    }
    if (!await _alarmKit.isSupported()) return AlarmEngine.notifications;
    final authorization = await _alarmKit.authorizationState();
    return authorization.canScheduleRealAlarms
        ? AlarmEngine.alarmKit
        : AlarmEngine.notifications;
  }

  /// How many upcoming occurrences to pre-schedule per alarm.
  static const occurrencesPerAlarm = 8;

  /// The snooze currently in flight, if any.
  ///
  /// [reschedule] wipes every pending notification with `cancelAll` (the only
  /// way to clear occurrences belonging to alarms that have since been
  /// deleted), which would otherwise take a live snooze down with it: the
  /// user snoozes at 05:05, toggles an unrelated alarm at 05:06, and is
  /// never woken. Remembering the snooze lets us put it straight back.
  ///
  /// Known gap: this lives in memory, and the provider that owns this
  /// scheduler watches the locale override — so changing the app language
  /// while a snooze is pending rebuilds the scheduler and forgets it. The
  /// already-scheduled OS notification still fires; only the re-arm-after-
  /// reschedule protection is lost, and only in that one window. Phase 3
  /// moves snooze onto AlarmKit, which makes this state redundant.
  ({Alarm alarm, DateTime at})? _pendingSnooze;

  Future<void> reschedule(List<Alarm> alarms) async {
    final engine = await activeEngine();
    final enabled = alarms.where((a) => a.enabled).toList();

    // Clear both engines first. Leaving the other one armed is how you get an
    // alarm that rings twice.
    await _notifications.cancelAll();
    if (await _alarmKit.isSupported()) await _alarmKit.cancelAll();

    if (engine == AlarmEngine.alarmKit) {
      for (final alarm in enabled) {
        await _scheduleWithAlarmKit(alarm);
      }
      // Snooze still rides on notifications until the countdown presentation
      // (and the widget extension it requires) lands.
      await _restorePendingSnooze();
      return;
    }

    for (final alarm in enabled) {
      await _scheduleAlarm(alarm);
    }
    await _restorePendingSnooze();
  }

  /// Hands one alarm to AlarmKit. A rejected alarm is surfaced, not swallowed:
  /// an alarm the system quietly refused is exactly what people write one-star
  /// reviews about.
  Future<void> _scheduleWithAlarmKit(Alarm alarm) async {
    final l10n = currentLocalizations(override: localeOverride);
    await _alarmKit.schedule(
      id: alarm.id,
      hour: alarm.hour,
      minute: alarm.minute,
      // repeatDays already uses DateTime.monday..sunday, which is the ISO
      // numbering the native side maps to Locale.Weekday.
      weekdays: alarm.repeatDays.toList()..sort(),
      label: alarm.label.isEmpty ? l10n.notificationDefaultTitle : alarm.label,
      missionType: alarm.missionType.name,
      secondaryButtonTitle: alarm.missionType == MissionType.none
          ? l10n.dismissAlarm
          : l10n.startMission,
      stopButtonTitle: l10n.dismissAlarm,
    );
  }

  /// Re-arms a snooze that [reschedule] just cancelled. Dropped once it is in
  /// the past, or once its alarm no longer exists.
  Future<void> _restorePendingSnooze() async {
    final snooze = _pendingSnooze;
    if (snooze == null) return;
    final remaining = snooze.at.difference(DateTime.now());
    if (remaining.isNegative) {
      _pendingSnooze = null;
      return;
    }
    await _writeSnooze(snooze.alarm, snooze.at);
  }

  /// Clears the remembered snooze once it has fired or the user dismissed the
  /// alarm, so a later [reschedule] does not resurrect a stale one.
  void clearPendingSnooze() => _pendingSnooze = null;

  Future<void> _scheduleAlarm(Alarm alarm) async {
    final l10n = currentLocalizations(override: localeOverride);
    var from = DateTime.now();
    final baseId = notificationBaseId(alarm.id);
    for (var slot = 0; slot < occurrencesPerAlarm; slot++) {
      final at = alarm.nextTrigger(from);
      await _notifications.schedule(
        id: baseId + slot,
        title: alarm.label.isEmpty
            ? l10n.notificationDefaultTitle
            : alarm.label,
        body: alarm.missionType == MissionType.none
            ? l10n.notificationBodyNoMission
            : l10n.notificationBodyMission,
        at: at,
        payload: alarm.id,
      );
      if (!alarm.repeats) break;
      from = at;
    }
  }

  /// Schedules a single snooze firing [minutes] from now, and remembers it so
  /// a subsequent [reschedule] can re-arm it instead of silently dropping it.
  Future<void> scheduleSnooze(Alarm alarm, int minutes) async {
    final at = DateTime.now().add(Duration(minutes: minutes));
    _pendingSnooze = (alarm: alarm, at: at);
    await _writeSnooze(alarm, at);
  }

  Future<void> _writeSnooze(Alarm alarm, DateTime at) async {
    final l10n = currentLocalizations(override: localeOverride);
    await _notifications.schedule(
      id: notificationBaseId(alarm.id) + occurrencesPerAlarm,
      title: alarm.label.isEmpty ? l10n.notificationDefaultTitle : alarm.label,
      body: l10n.notificationBodySnoozeOver,
      at: at,
      payload: alarm.id,
    );
  }

  /// Stable notification id block derived from the alarm's uuid.
  static int notificationBaseId(String alarmId) =>
      (alarmId.hashCode & 0x7fffffff) % 1000000 * (occurrencesPerAlarm + 1);
}
