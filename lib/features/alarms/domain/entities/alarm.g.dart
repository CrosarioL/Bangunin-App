// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Alarm _$AlarmFromJson(Map<String, dynamic> json) => _Alarm(
  id: json['id'] as String,
  hour: (json['hour'] as num).toInt(),
  minute: (json['minute'] as num).toInt(),
  label: json['label'] as String? ?? '',
  repeatDays:
      (json['repeatDays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toSet() ??
      const <int>{},
  enabled: json['enabled'] as bool? ?? true,
  missionType:
      $enumDecodeNullable(_$MissionTypeEnumMap, json['missionType']) ??
      MissionType.none,
  missionReps: (json['missionReps'] as num?)?.toInt() ?? 0,
  sound:
      $enumDecodeNullable(_$AlarmSoundEnumMap, json['sound']) ??
      AlarmSound.classic,
  customSoundPath: json['customSoundPath'] as String?,
  objectReferencePath: json['objectReferencePath'] as String?,
  volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
  vibrate: json['vibrate'] as bool? ?? true,
  snoozeEnabled: json['snoozeEnabled'] as bool? ?? true,
  snoozeMinutes: (json['snoozeMinutes'] as num?)?.toInt() ?? 5,
  maxSnoozes: (json['maxSnoozes'] as num?)?.toInt() ?? 3,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AlarmToJson(_Alarm instance) => <String, dynamic>{
  'id': instance.id,
  'hour': instance.hour,
  'minute': instance.minute,
  'label': instance.label,
  'repeatDays': instance.repeatDays.toList(),
  'enabled': instance.enabled,
  'missionType': _$MissionTypeEnumMap[instance.missionType]!,
  'missionReps': instance.missionReps,
  'sound': _$AlarmSoundEnumMap[instance.sound]!,
  'customSoundPath': instance.customSoundPath,
  'objectReferencePath': instance.objectReferencePath,
  'volume': instance.volume,
  'vibrate': instance.vibrate,
  'snoozeEnabled': instance.snoozeEnabled,
  'snoozeMinutes': instance.snoozeMinutes,
  'maxSnoozes': instance.maxSnoozes,
  'createdAt': instance.createdAt.toIso8601String(),
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

const _$AlarmSoundEnumMap = {
  AlarmSound.classic: 'classic',
  AlarmSound.sunrise: 'sunrise',
  AlarmSound.pulse: 'pulse',
  AlarmSound.custom: 'custom',
};
