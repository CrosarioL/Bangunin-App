import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../missions/domain/mission_type.dart';

part 'alarm.freezed.dart';
part 'alarm.g.dart';

/// A single alarm. Times are wall-clock (hour/minute in the device timezone);
/// [repeatDays] uses [DateTime.monday]..[DateTime.sunday]. An empty set means
/// a one-off alarm that fires at the next occurrence of the time.
@freezed
abstract class Alarm with _$Alarm {
  const Alarm._();

  const factory Alarm({
    required String id,
    required int hour,
    required int minute,
    @Default('') String label,
    @Default(<int>{}) Set<int> repeatDays,
    @Default(true) bool enabled,
    @Default(MissionType.none) MissionType missionType,
    @Default(0) int missionReps,
    @Default(AlarmSound.classic) AlarmSound sound,
    String? customSoundPath,
    String? objectReferencePath,
    @Default(1.0) double volume,
    @Default(true) bool vibrate,
    @Default(true) bool snoozeEnabled,
    @Default(5) int snoozeMinutes,
    @Default(3) int maxSnoozes,
    required DateTime createdAt,
  }) = _Alarm;

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);

  bool get repeats => repeatDays.isNotEmpty;

  /// The next moment this alarm should fire, strictly after [from].
  DateTime nextTrigger(DateTime from) {
    var candidate =
        DateTime(from.year, from.month, from.day, hour, minute);
    if (!candidate.isAfter(from)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    if (repeatDays.isEmpty) return candidate;
    while (!repeatDays.contains(candidate.weekday)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}

/// Bundled alarm sounds. [custom] plays the user's imported/recorded file.
enum AlarmSound {
  classic,
  sunrise,
  pulse,
  custom;

  String get assetPath => switch (this) {
        classic => 'assets/sounds/classic.wav',
        sunrise => 'assets/sounds/sunrise.wav',
        pulse => 'assets/sounds/pulse.wav',
        custom => '',
      };
}
