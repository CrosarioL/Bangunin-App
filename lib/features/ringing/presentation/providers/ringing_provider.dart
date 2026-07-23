import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../missions/domain/mission_type.dart';
import '../../../stats/domain/entities/wake_record.dart';

/// Watches the clock while the app is foregrounded and reports alarms that
/// just became due, so ringing takes over even without a notification tap.
final dueAlarmWatcherProvider = Provider<DueAlarmWatcher>((ref) {
  return DueAlarmWatcher(ref);
});

class DueAlarmWatcher {
  DueAlarmWatcher(this._ref);

  final Ref _ref;
  Timer? _timer;
  DateTime _lastCheck = DateTime.now();

  void Function(String alarmId)? onDue;

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) => _check());
  }

  Future<void> _check() async {
    final now = DateTime.now();
    final from = _lastCheck;
    _lastCheck = now;
    final alarms = await _ref.read(alarmRepositoryProvider).getAll();
    for (final alarm in alarms.where((a) => a.enabled)) {
      final next = alarm.nextTrigger(from);
      if (!next.isAfter(now)) {
        onDue?.call(alarm.id);
        return;
      }
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

/// State of the current ringing session (one alarm at a time).
class RingingSession {
  const RingingSession({
    required this.alarm,
    required this.startedAt,
    this.snoozeCount = 0,
    this.missionAttempts = 0,
  });

  final Alarm alarm;
  final DateTime startedAt;
  final int snoozeCount;
  final int missionAttempts;

  bool get canSnooze => alarm.snoozeEnabled && snoozeCount < alarm.maxSnoozes;

  RingingSession copyWith({int? snoozeCount, int? missionAttempts}) =>
      RingingSession(
        alarm: alarm,
        startedAt: startedAt,
        snoozeCount: snoozeCount ?? this.snoozeCount,
        missionAttempts: missionAttempts ?? this.missionAttempts,
      );
}

final ringingSessionProvider =
    NotifierProvider<RingingSessionNotifier, RingingSession?>(
      RingingSessionNotifier.new,
    );

class RingingSessionNotifier extends Notifier<RingingSession?> {
  static const _uuid = Uuid();

  /// Snoozes consumed per alarm occurrence. Survives the session being
  /// cleared while a snooze waits, so [Alarm.maxSnoozes] is enforced across
  /// snooze round-trips. Reset when the wake completes.
  final _snoozeCounts = <String, int>{};

  @override
  RingingSession? build() => null;

  /// Starts (or resumes) ringing for [alarmId]. Safe to call twice.
  Future<Alarm?> begin(String alarmId) async {
    final existing = state;
    if (existing != null && existing.alarm.id == alarmId) {
      return existing.alarm;
    }
    final alarm = await ref.read(alarmRepositoryProvider).getById(alarmId);
    if (alarm == null) return null;

    state = RingingSession(
      alarm: alarm,
      startedAt: DateTime.now(),
      snoozeCount: _snoozeCounts[alarmId] ?? 0,
    );
    await ref.read(alarmAudioServiceProvider).startRinging(alarm);
    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.alarmRinging, {
        'mission': alarm.missionType.name,
      }),
    );
    return alarm;
  }

  /// Lowers, but never silences, the alarm while a mission is attempted.
  /// The session stays active so abandoning the mission restores full volume.
  Future<void> pauseForMission() async {
    final session = state;
    if (session == null) return;
    await ref.read(alarmAudioServiceProvider).enterMissionMode(session.alarm);
    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.missionStarted, {
        'mission': state?.alarm.missionType.name,
      }),
    );
  }

  Future<void> resumeRinging() async {
    final session = state;
    if (session == null) return;
    await ref.read(alarmAudioServiceProvider).exitMissionMode(session.alarm);
  }

  /// Records each submitted photo attempt. Movement missions are recorded as
  /// one verified attempt on completion because their frames are continuous.
  Future<void> recordMissionAttempt() async {
    final session = state;
    if (session == null) return;
    state = session.copyWith(missionAttempts: session.missionAttempts + 1);
  }

  Future<bool> snooze() async {
    final session = state;
    if (session == null || !session.canSnooze) return false;
    await ref.read(alarmAudioServiceProvider).stopRinging();
    await ref
        .read(alarmSchedulerProvider)
        .scheduleSnooze(session.alarm, session.alarm.snoozeMinutes);
    _snoozeCounts[session.alarm.id] = session.snoozeCount + 1;
    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.alarmSnoozed, {
        'count': session.snoozeCount + 1,
      }),
    );
    // Snoozing hands control back to the OS notification.
    state = null;
    return true;
  }

  /// Mission passed (or no mission): stop audio, record the wake, clear the
  /// session, resync future occurrences.
  Future<void> complete({
    int verifiedReps = 0,
    String? verificationMethod,
  }) async {
    final session = state;
    if (session == null) return;
    await ref.read(alarmAudioServiceProvider).stopRinging();

    final alarm = session.alarm;
    _snoozeCounts.remove(alarm.id);
    final dismissedAt = DateTime.now();
    final hasMission = alarm.missionType != MissionType.none;
    await ref
        .read(wakeStatsRepositoryProvider)
        .add(
          WakeRecord(
            id: _uuid.v4(),
            alarmId: alarm.id,
            scheduledAt: _scheduledOccurrence(alarm, session.startedAt),
            dismissedAt: dismissedAt,
            missionType: alarm.missionType,
            snoozeCount: session.snoozeCount,
            ringingStartedAt: session.startedAt,
            missionDurationSeconds: dismissedAt
                .difference(session.startedAt)
                .inSeconds,
            missionAttempts: hasMission
                ? (session.missionAttempts == 0 ? 1 : session.missionAttempts)
                : 0,
            verifiedReps: verifiedReps,
            verificationMethod:
                verificationMethod ?? (hasMission ? 'mission' : 'tap'),
          ),
        );

    // One-off alarms disable themselves after firing.
    if (!alarm.repeats) {
      await ref
          .read(alarmRepositoryProvider)
          .upsert(alarm.copyWith(enabled: false));
    }
    final alarms = await ref.read(alarmRepositoryProvider).getAll();
    await ref.read(alarmSchedulerProvider).reschedule(alarms);

    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.missionCompleted, {
        'mission': alarm.missionType.name,
      }),
    );
    state = null;
  }

  DateTime _scheduledOccurrence(Alarm alarm, DateTime startedAt) {
    var scheduled = DateTime(
      startedAt.year,
      startedAt.month,
      startedAt.day,
      alarm.hour,
      alarm.minute,
    );
    // If a delayed notification is opened shortly after midnight, its clock
    // time belongs to the previous day rather than tomorrow.
    if (scheduled.isAfter(startedAt.add(const Duration(minutes: 2)))) {
      scheduled = scheduled.subtract(const Duration(days: 1));
    }
    return scheduled;
  }
}
