import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../missions/domain/hunt_target.dart';
import '../../../missions/domain/mission_type.dart';
import '../../../stats/domain/entities/wake_record.dart';
import '../../domain/emergency_escape.dart';

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

  /// A Wake Up Check's prompt time has come while the app is open, where
  /// the OS notification may never be tapped.
  void Function(String alarmId)? onWakeCheckDue;
  DateTime? _promptedCheckAt;

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) => _check());
  }

  Future<void> _check() async {
    final now = DateTime.now();
    final from = _lastCheck;
    _lastCheck = now;

    final wakeCheck = _ref.read(alarmSchedulerProvider).pendingWakeCheck;
    if (wakeCheck != null) {
      if (!now.isBefore(wakeCheck.ringAt)) {
        onDue?.call(wakeCheck.alarmId);
        return;
      }
      if (!now.isBefore(wakeCheck.checkAt) &&
          _promptedCheckAt != wakeCheck.checkAt) {
        _promptedCheckAt = wakeCheck.checkAt;
        onWakeCheckDue?.call(wakeCheck.alarmId);
      }
    }

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
    this.missionStep = 0,
  });

  final Alarm alarm;
  final DateTime startedAt;
  final int snoozeCount;

  /// Index into [Alarm.missionChain] of the mission still to be passed.
  /// Survives backing out of a mission, so a passed step stays passed.
  final int missionStep;

  bool get canSnooze => alarm.snoozeEnabled && snoozeCount < alarm.maxSnoozes;

  /// The mission to do now, or none once the chain is done.
  MissionType get currentMission {
    final chain = alarm.missionChain;
    return missionStep < chain.length ? chain[missionStep] : MissionType.none;
  }

  RingingSession copyWith({int? snoozeCount, int? missionStep}) =>
      RingingSession(
        alarm: alarm,
        startedAt: startedAt,
        snoozeCount: snoozeCount ?? this.snoozeCount,
        missionStep: missionStep ?? this.missionStep,
      );
}

/// The object a Random Hunt ring is asking for.
class HuntAssignment {
  const HuntAssignment({
    required this.alarmId,
    required this.target,
    required this.rerollsLeft,
  });

  final String alarmId;
  final HuntTarget target;
  final int rerollsLeft;
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

  /// Random Hunt target for the ringing alarm. Held here rather than in the
  /// mission page so backing out and re-entering the mission doesn't roll a
  /// fresh object for free — only [rerollHunt] does, and it is capped.
  HuntAssignment? _hunt;

  final _random = math.Random();

  @override
  RingingSession? build() => null;

  /// The object this ring asks for, assigned on first request.
  HuntAssignment huntAssignment(String alarmId) {
    final existing = _hunt;
    if (existing != null && existing.alarmId == alarmId) return existing;
    final assignment = HuntAssignment(
      alarmId: alarmId,
      target: HuntTargets.pick(_random),
      rerollsLeft: HuntTargets.maxRerolls,
    );
    _hunt = assignment;
    _logHunt(AnalyticsEvents.huntTargetAssigned, assignment);
    return assignment;
  }

  /// Swaps in a different object, or returns null once rerolls run out.
  HuntAssignment? rerollHunt(String alarmId) {
    final current = huntAssignment(alarmId);
    if (current.rerollsLeft <= 0) return null;
    final next = HuntAssignment(
      alarmId: alarmId,
      target: HuntTargets.pick(_random, exclude: {current.target.id}),
      rerollsLeft: current.rerollsLeft - 1,
    );
    _hunt = next;
    _logHunt(AnalyticsEvents.huntRerolled, next, from: current.target.id);
    return next;
  }

  void _logHunt(String event, HuntAssignment assignment, {String? from}) {
    unawaited(
      ref.read(analyticsProvider).logEvent(event, {
        'target': assignment.target.id,
        'from': ?from,
        'rerolls_left': assignment.rerollsLeft,
      }),
    );
  }

  /// Starts (or resumes) ringing for [alarmId]. Safe to call twice.
  Future<Alarm?> begin(String alarmId) async {
    final existing = state;
    if (existing != null && existing.alarm.id == alarmId) {
      return existing.alarm;
    }
    final alarm = await ref.read(alarmRepositoryProvider).getById(alarmId);
    if (alarm == null) return null;

    // Ringing again makes any pending Wake Up Check for this alarm moot: it
    // either lapsed (this is its re-ring) or the next occurrence beat it.
    final scheduler = ref.read(alarmSchedulerProvider);
    final check = scheduler.pendingWakeCheck;
    if (check != null && check.alarmId == alarmId) {
      await scheduler.cancelWakeCheck();
      unawaited(
        ref.read(analyticsProvider).logEvent(AnalyticsEvents.wakeCheckMissed),
      );
    }

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

  /// Lowers the alarm while a mission is attempted. The session stays active;
  /// abandoning the mission restores full volume.
  Future<void> pauseForMission() async {
    await ref.read(alarmAudioServiceProvider).duckForMission();
    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.missionStarted, {
        'mission': state?.alarm.missionType.name,
      }),
    );
  }

  Future<void> resumeRinging() async {
    final session = state;
    if (session == null) return;
    final audio = ref.read(alarmAudioServiceProvider);
    if (audio.isPlaying) {
      await audio.restoreRingingVolume();
    } else {
      await audio.startRinging(session.alarm);
    }
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

  /// The current mission in the chain was passed. Returns the next one to
  /// do, or null when the chain is finished and [complete] should follow.
  MissionType? advanceMission() {
    final session = state;
    if (session == null) return null;
    final next = session.copyWith(missionStep: session.missionStep + 1);
    state = next;
    final mission = next.currentMission;
    return mission == MissionType.none ? null : mission;
  }

  /// Mission passed (or no mission): stop audio, record the wake, clear the
  /// session, resync future occurrences, and arm the Wake Up Check if the
  /// alarm has one.
  Future<void> complete() => _finish(success: true);

  /// Emergency exit: the alarm stops like [complete], but the morning is
  /// recorded as a failure so it never feeds a streak, and it counts against
  /// this month's escapes (which lengthens the next pledge).
  Future<void> escape() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final used = emergencyEscapesThisMonth();
    await prefs.setString(
      _escapeMonthKey,
      EmergencyEscape.monthKey(DateTime.now()),
    );
    await prefs.setInt(_escapeCountKey, used + 1);
    unawaited(
      ref.read(analyticsProvider).logEvent(AnalyticsEvents.emergencyEscape, {
        'mission': state?.alarm.missionType.name,
        'used_this_month': used + 1,
      }),
    );
    await _finish(success: false);
  }

  static const _escapeMonthKey = 'emergency_escape_month';
  static const _escapeCountKey = 'emergency_escape_count';

  /// Escapes already used in the current calendar month.
  int emergencyEscapesThisMonth() {
    final prefs = ref.read(sharedPreferencesProvider);
    final month = prefs.getString(_escapeMonthKey);
    if (month != EmergencyEscape.monthKey(DateTime.now())) return 0;
    return prefs.getInt(_escapeCountKey) ?? 0;
  }

  Future<void> _finish({required bool success}) async {
    final session = state;
    if (session == null) return;
    await ref.read(alarmAudioServiceProvider).stopRinging();

    final alarm = session.alarm;
    _snoozeCounts.remove(alarm.id);
    _hunt = null;
    // The wake is done, so any snooze the scheduler is holding for re-arming
    // is stale — drop it before the resync below calls reschedule().
    ref.read(alarmSchedulerProvider).clearPendingSnooze();
    await ref
        .read(wakeStatsRepositoryProvider)
        .add(
          WakeRecord(
            id: _uuid.v4(),
            alarmId: alarm.id,
            scheduledAt: session.startedAt,
            dismissedAt: DateTime.now(),
            missionType: alarm.missionType,
            snoozeCount: session.snoozeCount,
            success: success,
          ),
        );

    // One-off alarms disable themselves after firing.
    if (!alarm.repeats) {
      await ref
          .read(alarmRepositoryProvider)
          .upsert(alarm.copyWith(enabled: false));
    }
    final alarms = await ref.read(alarmRepositoryProvider).getAll();
    final scheduler = ref.read(alarmSchedulerProvider);
    await scheduler.reschedule(alarms);

    // After the reschedule, which would otherwise cancel it straight away.
    // Never after an emergency escape: that is an admission of not doing
    // the mission, and checking on it would only punish honesty.
    if (success && alarm.wakeCheckMinutes > 0) {
      await scheduler.scheduleWakeCheck(alarm);
      unawaited(
        ref.read(analyticsProvider).logEvent(
          AnalyticsEvents.wakeCheckScheduled,
          {'minutes': alarm.wakeCheckMinutes},
        ),
      );
    }

    if (success) {
      unawaited(
        ref.read(analyticsProvider).logEvent(AnalyticsEvents.missionCompleted, {
          'mission': alarm.missionType.name,
        }),
      );
    }
    state = null;
  }
}
