import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../missions/domain/mission_type.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../domain/entities/alarm.dart';

/// Live alarm list.
final alarmsProvider = StreamProvider<List<Alarm>>(
  (ref) => ref.watch(alarmRepositoryProvider).watchAll(),
);

/// The next alarm that will fire, used by the home header countdown.
final nextAlarmProvider = Provider<({Alarm alarm, DateTime at})?>((ref) {
  final alarms = ref.watch(alarmsProvider).value ?? const [];
  final now = DateTime.now();
  ({Alarm alarm, DateTime at})? next;
  for (final alarm in alarms.where((a) => a.enabled)) {
    final at = alarm.nextTrigger(now);
    if (next == null || at.isBefore(next.at)) {
      next = (alarm: alarm, at: at);
    }
  }
  return next;
});

/// Write-side operations. Every mutation persists, re-syncs the OS
/// notification schedule, and logs an analytics event.
final alarmActionsProvider = Provider<AlarmActions>(AlarmActions.new);

class AlarmActions {
  AlarmActions(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  Alarm draft({int? hour, int? minute}) {
    final now = DateTime.now();
    return Alarm(
      id: _uuid.v4(),
      hour: hour ?? 7,
      minute: minute ?? 0,
      createdAt: now,
    );
  }

  Future<void> save(Alarm alarm, {required bool isNew}) async {
    // A reference photo or custom sound that gets replaced is never
    // referenced again — without this, every re-recorded sound and every
    // re-registered Object Hunt photo leaves its predecessor on disk
    // forever.
    if (!isNew) {
      final previous = await _ref.read(alarmRepositoryProvider).getById(alarm.id);
      if (previous != null) {
        await _deleteIfReplaced(previous.objectReferencePath, alarm.objectReferencePath);
        await _deleteIfReplaced(previous.customSoundPath, alarm.customSoundPath);
      }
    }

    await _ref.read(alarmRepositoryProvider).upsert(alarm);
    await _resync();
    if (isNew) {
      unawaited(
        _ref.read(analyticsProvider).logEvent(
          AnalyticsEvents.alarmCreated,
          {'mission': alarm.missionType.name, 'repeats': alarm.repeats},
        ),
      );
    }
  }

  Future<void> toggle(Alarm alarm, {required bool enabled}) async {
    await _ref
        .read(alarmRepositoryProvider)
        .upsert(alarm.copyWith(enabled: enabled));
    await _resync();
  }

  Future<void> delete(String id) async {
    final alarm = await _ref.read(alarmRepositoryProvider).getById(id);
    await _ref.read(alarmRepositoryProvider).delete(id);
    await _resync();
    if (alarm != null) {
      await _deleteQuietly(alarm.objectReferencePath);
      await _deleteQuietly(alarm.customSoundPath);
    }
    unawaited(
      _ref.read(analyticsProvider).logEvent(AnalyticsEvents.alarmDeleted),
    );
  }

  Future<void> _deleteIfReplaced(String? oldPath, String? newPath) {
    if (oldPath == null || oldPath == newPath) return Future.value();
    return _deleteQuietly(oldPath);
  }

  Future<void> _deleteQuietly(String? path) async {
    if (path == null) return;
    try {
      await File(path).delete();
    } on FileSystemException {
      // Best-effort cleanup; a stray file is not worth surfacing to the user.
    }
  }

  Future<void> _resync() async {
    final alarms = await _ref.read(alarmRepositoryProvider).getAll();
    await _ref.read(alarmSchedulerProvider).reschedule(alarms);
  }

  /// Creates the user's first alarm from their onboarding answers — the
  /// wake-goal time they picked, repeating on weekdays, with a mission
  /// chosen from the struggle(s) they flagged. Does nothing if an alarm
  /// already exists (e.g. onboarding was re-entered after a data reset).
  Future<void> createFromOnboarding(OnboardingAnswers answers) async {
    final existing = await _ref.read(alarmRepositoryProvider).getAll();
    if (existing.isNotEmpty) return;

    final mission = _missionForStruggles(answers.struggles);
    final alarm = draft(
      hour: answers.wakeGoalHour,
      minute: answers.wakeGoalMinute,
    ).copyWith(
      repeatDays: const {
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
      },
      missionType: mission,
      missionReps: mission.isMovement ? mission.defaultReps : 0,
    );
    await save(alarm, isNew: true);
  }

  /// "I stay in bed" / "I fall back asleep" → a movement mission forces
  /// them physically up. "I dismiss it half asleep" → a photo mission
  /// (further from the bed) requires enough alertness to compose a shot.
  /// No clear signal → no mission, so the very first alarm isn't a wall.
  MissionType _missionForStruggles(Set<String> struggles) {
    if (struggles.contains('stay_in_bed') ||
        struggles.contains('phone_in_bed')) {
      return MissionType.squats;
    }
    if (struggles.contains('dismiss_half_asleep')) {
      return MissionType.skyPhoto;
    }
    return MissionType.none;
  }
}
