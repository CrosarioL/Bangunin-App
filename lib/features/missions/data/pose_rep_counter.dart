import 'dart:math' as math;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../domain/mission_type.dart';

/// Counts only full down→up exercise cycles from on-device pose landmarks.
/// Three consecutive frames must confirm each position and repetitions are
/// debounced, which limits counts from brief detector noise.
class PoseRepCounter {
  PoseRepCounter({required this.mission, required this.targetReps});

  final MissionType mission;
  final int targetReps;

  int reps = 0;
  bool _downConfirmed = false;
  int _downFrames = 0;
  int _upFrames = 0;
  DateTime _lastRepAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const _requiredFrames = 3;
  static const _minimumLikelihood = 0.65;
  static const _minimumRepInterval = Duration(milliseconds: 650);

  bool get isComplete => reps >= targetReps;

  bool addPose(Pose pose, {DateTime? now}) {
    if (isComplete) return false;
    final angles = mission == MissionType.squats
        ? _squatAngles(pose)
        : _pushupAngles(pose);
    if (angles == null) {
      _downFrames = 0;
      _upFrames = 0;
      return false;
    }

    final (isDown, isUp) = angles;
    if (!_downConfirmed) {
      _downFrames = isDown ? _downFrames + 1 : 0;
      if (_downFrames >= _requiredFrames) {
        _downConfirmed = true;
        _upFrames = 0;
      }
      return false;
    }

    _upFrames = isUp ? _upFrames + 1 : 0;
    final at = now ?? DateTime.now();
    if (_upFrames < _requiredFrames ||
        at.difference(_lastRepAt) < _minimumRepInterval) {
      return false;
    }
    reps++;
    _lastRepAt = at;
    _downConfirmed = false;
    _downFrames = 0;
    _upFrames = 0;
    return true;
  }

  (bool, bool)? _squatAngles(Pose pose) {
    final left = _jointAngle(
      pose,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
    );
    final right = _jointAngle(
      pose,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
    );
    if (left == null || right == null) return null;
    final knee = (left + right) / 2;
    return (knee < 105, knee > 158);
  }

  (bool, bool)? _pushupAngles(Pose pose) {
    final leftElbow = _jointAngle(
      pose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
    );
    final rightElbow = _jointAngle(
      pose,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
    );
    final leftBody = _jointAngle(
      pose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftAnkle,
    );
    final rightBody = _jointAngle(
      pose,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightAnkle,
    );
    if (leftElbow == null ||
        rightElbow == null ||
        leftBody == null ||
        rightBody == null) {
      return null;
    }
    final elbow = (leftElbow + rightElbow) / 2;
    final body = (leftBody + rightBody) / 2;
    final validBodyLine = body > 145;
    return (validBodyLine && elbow < 100, validBodyLine && elbow > 155);
  }

  double? _jointAngle(
    Pose pose,
    PoseLandmarkType first,
    PoseLandmarkType vertex,
    PoseLandmarkType third,
  ) {
    final a = pose.landmarks[first];
    final b = pose.landmarks[vertex];
    final c = pose.landmarks[third];
    if (a == null ||
        b == null ||
        c == null ||
        a.likelihood < _minimumLikelihood ||
        b.likelihood < _minimumLikelihood ||
        c.likelihood < _minimumLikelihood) {
      return null;
    }
    final radians =
        (math.atan2(c.y - b.y, c.x - b.x) - math.atan2(a.y - b.y, a.x - b.x))
            .abs();
    final degrees = radians * 180 / math.pi;
    return degrees > 180 ? 360 - degrees : degrees;
  }
}
