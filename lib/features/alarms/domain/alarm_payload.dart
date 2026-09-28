/// What a tapped notification is asking for.
///
/// Alarm notifications carry the bare alarm id, as they always have, so
/// notifications scheduled by older builds still route correctly. Anything
/// else is `<kind>:<alarmId>`.
sealed class AlarmPayload {
  const AlarmPayload(this.alarmId);

  final String alarmId;

  static const _wakeCheckPrefix = 'wakecheck:';

  static AlarmPayload parse(String payload) =>
      payload.startsWith(_wakeCheckPrefix)
      ? WakeCheckPayload(payload.substring(_wakeCheckPrefix.length))
      : RingPayload(payload);

  static String wakeCheck(String alarmId) => '$_wakeCheckPrefix$alarmId';
}

/// Ring this alarm.
final class RingPayload extends AlarmPayload {
  const RingPayload(super.alarmId);
}

/// Ask whether the user is still awake after this alarm.
final class WakeCheckPayload extends AlarmPayload {
  const WakeCheckPayload(super.alarmId);
}
