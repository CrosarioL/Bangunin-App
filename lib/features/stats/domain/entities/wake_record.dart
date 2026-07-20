import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../missions/domain/mission_type.dart';

part 'wake_record.freezed.dart';
part 'wake_record.g.dart';

/// One completed (or abandoned) wake-up. Powers streaks and morning stats.
@freezed
abstract class WakeRecord with _$WakeRecord {
  const factory WakeRecord({
    required String id,
    required String alarmId,
    required DateTime scheduledAt,
    required DateTime dismissedAt,
    required MissionType missionType,
    @Default(0) int snoozeCount,
    @Default(true) bool success,
  }) = _WakeRecord;

  factory WakeRecord.fromJson(Map<String, dynamic> json) =>
      _$WakeRecordFromJson(json);
}
