// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wake_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WakeRecord _$WakeRecordFromJson(Map<String, dynamic> json) => _WakeRecord(
  id: json['id'] as String,
  alarmId: json['alarmId'] as String,
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  dismissedAt: DateTime.parse(json['dismissedAt'] as String),
  missionType: $enumDecode(_$MissionTypeEnumMap, json['missionType']),
  snoozeCount: (json['snoozeCount'] as num?)?.toInt() ?? 0,
  success: json['success'] as bool? ?? true,
  ringingStartedAt: json['ringingStartedAt'] == null
      ? null
      : DateTime.parse(json['ringingStartedAt'] as String),
  missionDurationSeconds:
      (json['missionDurationSeconds'] as num?)?.toInt() ?? 0,
  missionAttempts: (json['missionAttempts'] as num?)?.toInt() ?? 0,
  verifiedReps: (json['verifiedReps'] as num?)?.toInt() ?? 0,
  verificationMethod: json['verificationMethod'] as String? ?? 'legacy',
);

Map<String, dynamic> _$WakeRecordToJson(_WakeRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alarmId': instance.alarmId,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'dismissedAt': instance.dismissedAt.toIso8601String(),
      'missionType': _$MissionTypeEnumMap[instance.missionType]!,
      'snoozeCount': instance.snoozeCount,
      'success': instance.success,
      'ringingStartedAt': instance.ringingStartedAt?.toIso8601String(),
      'missionDurationSeconds': instance.missionDurationSeconds,
      'missionAttempts': instance.missionAttempts,
      'verifiedReps': instance.verifiedReps,
      'verificationMethod': instance.verificationMethod,
    };

const _$MissionTypeEnumMap = {
  MissionType.none: 'none',
  MissionType.objectHunt: 'objectHunt',
  MissionType.skyPhoto: 'skyPhoto',
  MissionType.grassPhoto: 'grassPhoto',
  MissionType.makeBed: 'makeBed',
  MissionType.squats: 'squats',
  MissionType.pushups: 'pushups',
};
