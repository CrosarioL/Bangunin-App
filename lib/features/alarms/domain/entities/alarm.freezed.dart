// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alarm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Alarm {

 String get id; int get hour; int get minute; String get label; Set<int> get repeatDays; bool get enabled; MissionType get missionType; int get missionReps; AlarmSound get sound; String? get customSoundPath; String? get objectReferencePath; double get volume; bool get vibrate; bool get snoozeEnabled; int get snoozeMinutes; int get maxSnoozes; DateTime get createdAt;
/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlarmCopyWith<Alarm> get copyWith => _$AlarmCopyWithImpl<Alarm>(this as Alarm, _$identity);

  /// Serializes this Alarm to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Alarm&&(identical(other.id, id) || other.id == id)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.repeatDays, repeatDays)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.missionType, missionType) || other.missionType == missionType)&&(identical(other.missionReps, missionReps) || other.missionReps == missionReps)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.customSoundPath, customSoundPath) || other.customSoundPath == customSoundPath)&&(identical(other.objectReferencePath, objectReferencePath) || other.objectReferencePath == objectReferencePath)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.vibrate, vibrate) || other.vibrate == vibrate)&&(identical(other.snoozeEnabled, snoozeEnabled) || other.snoozeEnabled == snoozeEnabled)&&(identical(other.snoozeMinutes, snoozeMinutes) || other.snoozeMinutes == snoozeMinutes)&&(identical(other.maxSnoozes, maxSnoozes) || other.maxSnoozes == maxSnoozes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hour,minute,label,const DeepCollectionEquality().hash(repeatDays),enabled,missionType,missionReps,sound,customSoundPath,objectReferencePath,volume,vibrate,snoozeEnabled,snoozeMinutes,maxSnoozes,createdAt);

@override
String toString() {
  return 'Alarm(id: $id, hour: $hour, minute: $minute, label: $label, repeatDays: $repeatDays, enabled: $enabled, missionType: $missionType, missionReps: $missionReps, sound: $sound, customSoundPath: $customSoundPath, objectReferencePath: $objectReferencePath, volume: $volume, vibrate: $vibrate, snoozeEnabled: $snoozeEnabled, snoozeMinutes: $snoozeMinutes, maxSnoozes: $maxSnoozes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AlarmCopyWith<$Res>  {
  factory $AlarmCopyWith(Alarm value, $Res Function(Alarm) _then) = _$AlarmCopyWithImpl;
@useResult
$Res call({
 String id, int hour, int minute, String label, Set<int> repeatDays, bool enabled, MissionType missionType, int missionReps, AlarmSound sound, String? customSoundPath, String? objectReferencePath, double volume, bool vibrate, bool snoozeEnabled, int snoozeMinutes, int maxSnoozes, DateTime createdAt
});




}
/// @nodoc
class _$AlarmCopyWithImpl<$Res>
    implements $AlarmCopyWith<$Res> {
  _$AlarmCopyWithImpl(this._self, this._then);

  final Alarm _self;
  final $Res Function(Alarm) _then;

/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hour = null,Object? minute = null,Object? label = null,Object? repeatDays = null,Object? enabled = null,Object? missionType = null,Object? missionReps = null,Object? sound = null,Object? customSoundPath = freezed,Object? objectReferencePath = freezed,Object? volume = null,Object? vibrate = null,Object? snoozeEnabled = null,Object? snoozeMinutes = null,Object? maxSnoozes = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,repeatDays: null == repeatDays ? _self.repeatDays : repeatDays // ignore: cast_nullable_to_non_nullable
as Set<int>,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,missionType: null == missionType ? _self.missionType : missionType // ignore: cast_nullable_to_non_nullable
as MissionType,missionReps: null == missionReps ? _self.missionReps : missionReps // ignore: cast_nullable_to_non_nullable
as int,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as AlarmSound,customSoundPath: freezed == customSoundPath ? _self.customSoundPath : customSoundPath // ignore: cast_nullable_to_non_nullable
as String?,objectReferencePath: freezed == objectReferencePath ? _self.objectReferencePath : objectReferencePath // ignore: cast_nullable_to_non_nullable
as String?,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,vibrate: null == vibrate ? _self.vibrate : vibrate // ignore: cast_nullable_to_non_nullable
as bool,snoozeEnabled: null == snoozeEnabled ? _self.snoozeEnabled : snoozeEnabled // ignore: cast_nullable_to_non_nullable
as bool,snoozeMinutes: null == snoozeMinutes ? _self.snoozeMinutes : snoozeMinutes // ignore: cast_nullable_to_non_nullable
as int,maxSnoozes: null == maxSnoozes ? _self.maxSnoozes : maxSnoozes // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Alarm].
extension AlarmPatterns on Alarm {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Alarm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Alarm() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Alarm value)  $default,){
final _that = this;
switch (_that) {
case _Alarm():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Alarm value)?  $default,){
final _that = this;
switch (_that) {
case _Alarm() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int hour,  int minute,  String label,  Set<int> repeatDays,  bool enabled,  MissionType missionType,  int missionReps,  AlarmSound sound,  String? customSoundPath,  String? objectReferencePath,  double volume,  bool vibrate,  bool snoozeEnabled,  int snoozeMinutes,  int maxSnoozes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Alarm() when $default != null:
return $default(_that.id,_that.hour,_that.minute,_that.label,_that.repeatDays,_that.enabled,_that.missionType,_that.missionReps,_that.sound,_that.customSoundPath,_that.objectReferencePath,_that.volume,_that.vibrate,_that.snoozeEnabled,_that.snoozeMinutes,_that.maxSnoozes,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int hour,  int minute,  String label,  Set<int> repeatDays,  bool enabled,  MissionType missionType,  int missionReps,  AlarmSound sound,  String? customSoundPath,  String? objectReferencePath,  double volume,  bool vibrate,  bool snoozeEnabled,  int snoozeMinutes,  int maxSnoozes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Alarm():
return $default(_that.id,_that.hour,_that.minute,_that.label,_that.repeatDays,_that.enabled,_that.missionType,_that.missionReps,_that.sound,_that.customSoundPath,_that.objectReferencePath,_that.volume,_that.vibrate,_that.snoozeEnabled,_that.snoozeMinutes,_that.maxSnoozes,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int hour,  int minute,  String label,  Set<int> repeatDays,  bool enabled,  MissionType missionType,  int missionReps,  AlarmSound sound,  String? customSoundPath,  String? objectReferencePath,  double volume,  bool vibrate,  bool snoozeEnabled,  int snoozeMinutes,  int maxSnoozes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Alarm() when $default != null:
return $default(_that.id,_that.hour,_that.minute,_that.label,_that.repeatDays,_that.enabled,_that.missionType,_that.missionReps,_that.sound,_that.customSoundPath,_that.objectReferencePath,_that.volume,_that.vibrate,_that.snoozeEnabled,_that.snoozeMinutes,_that.maxSnoozes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Alarm extends Alarm {
  const _Alarm({required this.id, required this.hour, required this.minute, this.label = '', final  Set<int> repeatDays = const <int>{}, this.enabled = true, this.missionType = MissionType.none, this.missionReps = 0, this.sound = AlarmSound.classic, this.customSoundPath, this.objectReferencePath, this.volume = 1.0, this.vibrate = true, this.snoozeEnabled = true, this.snoozeMinutes = 5, this.maxSnoozes = 3, required this.createdAt}): _repeatDays = repeatDays,super._();
  factory _Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);

@override final  String id;
@override final  int hour;
@override final  int minute;
@override@JsonKey() final  String label;
 final  Set<int> _repeatDays;
@override@JsonKey() Set<int> get repeatDays {
  if (_repeatDays is EqualUnmodifiableSetView) return _repeatDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_repeatDays);
}

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  MissionType missionType;
@override@JsonKey() final  int missionReps;
@override@JsonKey() final  AlarmSound sound;
@override final  String? customSoundPath;
@override final  String? objectReferencePath;
@override@JsonKey() final  double volume;
@override@JsonKey() final  bool vibrate;
@override@JsonKey() final  bool snoozeEnabled;
@override@JsonKey() final  int snoozeMinutes;
@override@JsonKey() final  int maxSnoozes;
@override final  DateTime createdAt;

/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlarmCopyWith<_Alarm> get copyWith => __$AlarmCopyWithImpl<_Alarm>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlarmToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Alarm&&(identical(other.id, id) || other.id == id)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other._repeatDays, _repeatDays)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.missionType, missionType) || other.missionType == missionType)&&(identical(other.missionReps, missionReps) || other.missionReps == missionReps)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.customSoundPath, customSoundPath) || other.customSoundPath == customSoundPath)&&(identical(other.objectReferencePath, objectReferencePath) || other.objectReferencePath == objectReferencePath)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.vibrate, vibrate) || other.vibrate == vibrate)&&(identical(other.snoozeEnabled, snoozeEnabled) || other.snoozeEnabled == snoozeEnabled)&&(identical(other.snoozeMinutes, snoozeMinutes) || other.snoozeMinutes == snoozeMinutes)&&(identical(other.maxSnoozes, maxSnoozes) || other.maxSnoozes == maxSnoozes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hour,minute,label,const DeepCollectionEquality().hash(_repeatDays),enabled,missionType,missionReps,sound,customSoundPath,objectReferencePath,volume,vibrate,snoozeEnabled,snoozeMinutes,maxSnoozes,createdAt);

@override
String toString() {
  return 'Alarm(id: $id, hour: $hour, minute: $minute, label: $label, repeatDays: $repeatDays, enabled: $enabled, missionType: $missionType, missionReps: $missionReps, sound: $sound, customSoundPath: $customSoundPath, objectReferencePath: $objectReferencePath, volume: $volume, vibrate: $vibrate, snoozeEnabled: $snoozeEnabled, snoozeMinutes: $snoozeMinutes, maxSnoozes: $maxSnoozes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AlarmCopyWith<$Res> implements $AlarmCopyWith<$Res> {
  factory _$AlarmCopyWith(_Alarm value, $Res Function(_Alarm) _then) = __$AlarmCopyWithImpl;
@override @useResult
$Res call({
 String id, int hour, int minute, String label, Set<int> repeatDays, bool enabled, MissionType missionType, int missionReps, AlarmSound sound, String? customSoundPath, String? objectReferencePath, double volume, bool vibrate, bool snoozeEnabled, int snoozeMinutes, int maxSnoozes, DateTime createdAt
});




}
/// @nodoc
class __$AlarmCopyWithImpl<$Res>
    implements _$AlarmCopyWith<$Res> {
  __$AlarmCopyWithImpl(this._self, this._then);

  final _Alarm _self;
  final $Res Function(_Alarm) _then;

/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hour = null,Object? minute = null,Object? label = null,Object? repeatDays = null,Object? enabled = null,Object? missionType = null,Object? missionReps = null,Object? sound = null,Object? customSoundPath = freezed,Object? objectReferencePath = freezed,Object? volume = null,Object? vibrate = null,Object? snoozeEnabled = null,Object? snoozeMinutes = null,Object? maxSnoozes = null,Object? createdAt = null,}) {
  return _then(_Alarm(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,repeatDays: null == repeatDays ? _self._repeatDays : repeatDays // ignore: cast_nullable_to_non_nullable
as Set<int>,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,missionType: null == missionType ? _self.missionType : missionType // ignore: cast_nullable_to_non_nullable
as MissionType,missionReps: null == missionReps ? _self.missionReps : missionReps // ignore: cast_nullable_to_non_nullable
as int,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as AlarmSound,customSoundPath: freezed == customSoundPath ? _self.customSoundPath : customSoundPath // ignore: cast_nullable_to_non_nullable
as String?,objectReferencePath: freezed == objectReferencePath ? _self.objectReferencePath : objectReferencePath // ignore: cast_nullable_to_non_nullable
as String?,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,vibrate: null == vibrate ? _self.vibrate : vibrate // ignore: cast_nullable_to_non_nullable
as bool,snoozeEnabled: null == snoozeEnabled ? _self.snoozeEnabled : snoozeEnabled // ignore: cast_nullable_to_non_nullable
as bool,snoozeMinutes: null == snoozeMinutes ? _self.snoozeMinutes : snoozeMinutes // ignore: cast_nullable_to_non_nullable
as int,maxSnoozes: null == maxSnoozes ? _self.maxSnoozes : maxSnoozes // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
