import 'package:flutter/widgets.dart';

import '../../../core/services/notifications/notification_service.dart';
import '../../../core/utils/current_locale.dart';
import '../../missions/domain/mission_type.dart';
import '../domain/entities/alarm.dart';

/// Maps alarms to scheduled OS notifications. Each alarm reserves a block of
/// notification ids so repeating alarms can pre-schedule the next several
/// occurrences (iOS has no true repeating exact alarms).
class AlarmScheduler {
  AlarmScheduler(this._notifications, {this.localeOverride});

  final NotificationService _notifications;
  final Locale? localeOverride;

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
    await _notifications.cancelAll();
    for (final alarm in alarms.where((a) => a.enabled)) {
      await _scheduleAlarm(alarm);
    }
    await _restorePendingSnooze();
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
        title: alarm.label.isEmpty ? l10n.notificationDefaultTitle : alarm.label,
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
