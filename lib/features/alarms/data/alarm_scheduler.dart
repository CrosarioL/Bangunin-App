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

  Future<void> reschedule(List<Alarm> alarms) async {
    await _notifications.cancelAll();
    for (final alarm in alarms.where((a) => a.enabled)) {
      await _scheduleAlarm(alarm);
    }
  }

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

  /// Schedules a single snooze firing [minutes] from now.
  Future<void> scheduleSnooze(Alarm alarm, int minutes) async {
    final l10n = currentLocalizations(override: localeOverride);
    await _notifications.schedule(
      id: notificationBaseId(alarm.id) + occurrencesPerAlarm,
      title: alarm.label.isEmpty ? l10n.notificationDefaultTitle : alarm.label,
      body: l10n.notificationBodySnoozeOver,
      at: DateTime.now().add(Duration(minutes: minutes)),
      payload: alarm.id,
    );
  }

  /// Stable notification id block derived from the alarm's uuid.
  static int notificationBaseId(String alarmId) =>
      (alarmId.hashCode & 0x7fffffff) % 1000000 * (occurrencesPerAlarm + 1);
}
