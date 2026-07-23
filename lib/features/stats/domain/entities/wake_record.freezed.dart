// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wake_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WakeRecord {

 String get id; String get alarmId; DateTime get scheduledAt; DateTime get dismissedAt; MissionType get missionType; int get snoozeCount; bool get success; DateTime? get ringingStartedAt; int get missionDurationSeconds; int get missionAttempts; int get verifiedReps; String get verificationMethod;
/// Create a copy of WakeRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WakeRecordCopyWith<WakeRecord> get copyWith => _$WakeRecordCopyWithImpl<WakeRecord>(this as WakeRecord, _$identity);

  /// Serializes this WakeRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WakeRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.alarmId, alarmId) || other.alarmId == alarmId)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.dismissedAt, dismissedAt) || other.dismissedAt == dismissedAt)&&(identical(other.missionType, missionType) || other.missionType == missionType)&&(identical(other.snoozeCount, snoozeCount) || other.snoozeCount == snoozeCount)&&(identical(other.success, success) || other.success == success)&&(identical(other.ringingStartedAt, ringingStartedAt) || other.ringingStartedAt == ringingStartedAt)&&(identical(other.missionDurationSeconds, missionDurationSeconds) || other.missionDurationSeconds == missionDurationSeconds)&&(identical(other.missionAttempts, missionAttempts) || other.missionAttempts == missionAttempts)&&(identical(other.verifiedReps, verifiedReps) || other.verifiedReps == verifiedReps)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,alarmId,scheduledAt,dismissedAt,missionType,snoozeCount,success,ringingStartedAt,missionDurationSeconds,missionAttempts,verifiedReps,verificationMethod);

@override
String toString() {
  return 'WakeRecord(id: $id, alarmId: $alarmId, scheduledAt: $scheduledAt, dismissedAt: $dismissedAt, missionType: $missionType, snoozeCount: $snoozeCount, success: $success, ringingStartedAt: $ringingStartedAt, missionDurationSeconds: $missionDurationSeconds, missionAttempts: $missionAttempts, verifiedReps: $verifiedReps, verificationMethod: $verificationMethod)';
}


}

/// @nodoc
abstract mixin class $WakeRecordCopyWith<$Res>  {
  factory $WakeRecordCopyWith(WakeRecord value, $Res Function(WakeRecord) _then) = _$WakeRecordCopyWithImpl;
@useResult
$Res call({
 String id, String alarmId, DateTime scheduledAt, DateTime dismissedAt, MissionType missionType, int snoozeCount, bool success, DateTime? ringingStartedAt, int missionDurationSeconds, int missionAttempts, int verifiedReps, String verificationMethod
});




}
/// @nodoc
class _$WakeRecordCopyWithImpl<$Res>
    implements $WakeRecordCopyWith<$Res> {
  _$WakeRecordCopyWithImpl(this._self, this._then);

  final WakeRecord _self;
  final $Res Function(WakeRecord) _then;

/// Create a copy of WakeRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? alarmId = null,Object? scheduledAt = null,Object? dismissedAt = null,Object? missionType = null,Object? snoozeCount = null,Object? success = null,Object? ringingStartedAt = freezed,Object? missionDurationSeconds = null,Object? missionAttempts = null,Object? verifiedReps = null,Object? verificationMethod = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,alarmId: null == alarmId ? _self.alarmId : alarmId // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,dismissedAt: null == dismissedAt ? _self.dismissedAt : dismissedAt // ignore: cast_nullable_to_non_nullable
as DateTime,missionType: null == missionType ? _self.missionType : missionType // ignore: cast_nullable_to_non_nullable
as MissionType,snoozeCount: null == snoozeCount ? _self.snoozeCount : snoozeCount // ignore: cast_nullable_to_non_nullable
as int,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,ringingStartedAt: freezed == ringingStartedAt ? _self.ringingStartedAt : ringingStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,missionDurationSeconds: null == missionDurationSeconds ? _self.missionDurationSeconds : missionDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,missionAttempts: null == missionAttempts ? _self.missionAttempts : missionAttempts // ignore: cast_nullable_to_non_nullable
as int,verifiedReps: null == verifiedReps ? _self.verifiedReps : verifiedReps // ignore: cast_nullable_to_non_nullable
as int,verificationMethod: null == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WakeRecord].
extension WakeRecordPatterns on WakeRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WakeRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WakeRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WakeRecord value)  $default,){
final _that = this;
switch (_that) {
case _WakeRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WakeRecord value)?  $default,){
final _that = this;
switch (_that) {
case _WakeRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String alarmId,  DateTime scheduledAt,  DateTime dismissedAt,  MissionType missionType,  int snoozeCount,  bool success,  DateTime? ringingStartedAt,  int missionDurationSeconds,  int missionAttempts,  int verifiedReps,  String verificationMethod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WakeRecord() when $default != null:
return $default(_that.id,_that.alarmId,_that.scheduledAt,_that.dismissedAt,_that.missionType,_that.snoozeCount,_that.success,_that.ringingStartedAt,_that.missionDurationSeconds,_that.missionAttempts,_that.verifiedReps,_that.verificationMethod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String alarmId,  DateTime scheduledAt,  DateTime dismissedAt,  MissionType missionType,  int snoozeCount,  bool success,  DateTime? ringingStartedAt,  int missionDurationSeconds,  int missionAttempts,  int verifiedReps,  String verificationMethod)  $default,) {final _that = this;
switch (_that) {
case _WakeRecord():
return $default(_that.id,_that.alarmId,_that.scheduledAt,_that.dismissedAt,_that.missionType,_that.snoozeCount,_that.success,_that.ringingStartedAt,_that.missionDurationSeconds,_that.missionAttempts,_that.verifiedReps,_that.verificationMethod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String alarmId,  DateTime scheduledAt,  DateTime dismissedAt,  MissionType missionType,  int snoozeCount,  bool success,  DateTime? ringingStartedAt,  int missionDurationSeconds,  int missionAttempts,  int verifiedReps,  String verificationMethod)?  $default,) {final _that = this;
switch (_that) {
case _WakeRecord() when $default != null:
return $default(_that.id,_that.alarmId,_that.scheduledAt,_that.dismissedAt,_that.missionType,_that.snoozeCount,_that.success,_that.ringingStartedAt,_that.missionDurationSeconds,_that.missionAttempts,_that.verifiedReps,_that.verificationMethod);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WakeRecord implements WakeRecord {
  const _WakeRecord({required this.id, required this.alarmId, required this.scheduledAt, required this.dismissedAt, required this.missionType, this.snoozeCount = 0, this.success = true, this.ringingStartedAt, this.missionDurationSeconds = 0, this.missionAttempts = 0, this.verifiedReps = 0, this.verificationMethod = 'legacy'});
  factory _WakeRecord.fromJson(Map<String, dynamic> json) => _$WakeRecordFromJson(json);

@override final  String id;
@override final  String alarmId;
@override final  DateTime scheduledAt;
@override final  DateTime dismissedAt;
@override final  MissionType missionType;
@override@JsonKey() final  int snoozeCount;
@override@JsonKey() final  bool success;
@override final  DateTime? ringingStartedAt;
@override@JsonKey() final  int missionDurationSeconds;
@override@JsonKey() final  int missionAttempts;
@override@JsonKey() final  int verifiedReps;
@override@JsonKey() final  String verificationMethod;

/// Create a copy of WakeRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WakeRecordCopyWith<_WakeRecord> get copyWith => __$WakeRecordCopyWithImpl<_WakeRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WakeRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WakeRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.alarmId, alarmId) || other.alarmId == alarmId)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.dismissedAt, dismissedAt) || other.dismissedAt == dismissedAt)&&(identical(other.missionType, missionType) || other.missionType == missionType)&&(identical(other.snoozeCount, snoozeCount) || other.snoozeCount == snoozeCount)&&(identical(other.success, success) || other.success == success)&&(identical(other.ringingStartedAt, ringingStartedAt) || other.ringingStartedAt == ringingStartedAt)&&(identical(other.missionDurationSeconds, missionDurationSeconds) || other.missionDurationSeconds == missionDurationSeconds)&&(identical(other.missionAttempts, missionAttempts) || other.missionAttempts == missionAttempts)&&(identical(other.verifiedReps, verifiedReps) || other.verifiedReps == verifiedReps)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,alarmId,scheduledAt,dismissedAt,missionType,snoozeCount,success,ringingStartedAt,missionDurationSeconds,missionAttempts,verifiedReps,verificationMethod);

@override
String toString() {
  return 'WakeRecord(id: $id, alarmId: $alarmId, scheduledAt: $scheduledAt, dismissedAt: $dismissedAt, missionType: $missionType, snoozeCount: $snoozeCount, success: $success, ringingStartedAt: $ringingStartedAt, missionDurationSeconds: $missionDurationSeconds, missionAttempts: $missionAttempts, verifiedReps: $verifiedReps, verificationMethod: $verificationMethod)';
}


}

/// @nodoc
abstract mixin class _$WakeRecordCopyWith<$Res> implements $WakeRecordCopyWith<$Res> {
  factory _$WakeRecordCopyWith(_WakeRecord value, $Res Function(_WakeRecord) _then) = __$WakeRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String alarmId, DateTime scheduledAt, DateTime dismissedAt, MissionType missionType, int snoozeCount, bool success, DateTime? ringingStartedAt, int missionDurationSeconds, int missionAttempts, int verifiedReps, String verificationMethod
});




}
/// @nodoc
class __$WakeRecordCopyWithImpl<$Res>
    implements _$WakeRecordCopyWith<$Res> {
  __$WakeRecordCopyWithImpl(this._self, this._then);

  final _WakeRecord _self;
  final $Res Function(_WakeRecord) _then;

/// Create a copy of WakeRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? alarmId = null,Object? scheduledAt = null,Object? dismissedAt = null,Object? missionType = null,Object? snoozeCount = null,Object? success = null,Object? ringingStartedAt = freezed,Object? missionDurationSeconds = null,Object? missionAttempts = null,Object? verifiedReps = null,Object? verificationMethod = null,}) {
  return _then(_WakeRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,alarmId: null == alarmId ? _self.alarmId : alarmId // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,dismissedAt: null == dismissedAt ? _self.dismissedAt : dismissedAt // ignore: cast_nullable_to_non_nullable
as DateTime,missionType: null == missionType ? _self.missionType : missionType // ignore: cast_nullable_to_non_nullable
as MissionType,snoozeCount: null == snoozeCount ? _self.snoozeCount : snoozeCount // ignore: cast_nullable_to_non_nullable
as int,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,ringingStartedAt: freezed == ringingStartedAt ? _self.ringingStartedAt : ringingStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,missionDurationSeconds: null == missionDurationSeconds ? _self.missionDurationSeconds : missionDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,missionAttempts: null == missionAttempts ? _self.missionAttempts : missionAttempts // ignore: cast_nullable_to_non_nullable
as int,verifiedReps: null == verifiedReps ? _self.verifiedReps : verifiedReps // ignore: cast_nullable_to_non_nullable
as int,verificationMethod: null == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
