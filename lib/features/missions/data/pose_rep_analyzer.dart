import 'dart:math' as math;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../domain/mission_type.dart';

enum PoseStage { findingBody, ready, lowering, returnToStart }

class PoseRepResult {
  const PoseRepResult({required this.reps, required this.stage});

  final int reps;
  final PoseStage stage;
}

/// Converts ML Kit body landmarks into strict, full-range exercise reps.
/// A rep only counts after a visible start -> bottom -> start sequence.
class PoseRepAnalyzer {
  PoseRepAnalyzer(this.mission);

  final MissionType mission;
  int _reps = 0;
  bool _reachedBottom = false;
  DateTime? _lastRepAt;

  int get reps => _reps;

  PoseRepResult analyze(Pose pose) {
    return mission == MissionType.squats
        ? _analyzeSquat(pose)
        : _analyzePushup(pose);
  }

  PoseRepResult _analyzeSquat(Pose pose) {
    final side = _bestSide(pose, const [
      _Joint.shoulder,
      _Joint.hip,
      _Joint.knee,
      _Joint.ankle,
    ]);
    if (side == null) return _result(PoseStage.findingBody);

    final hip = _landmark(pose, side, _Joint.hip)!;
    final knee = _landmark(pose, side, _Joint.knee)!;
    final ankle = _landmark(pose, side, _Joint.ankle)!;
    final kneeAngle = _angle(hip, knee, ankle);

    if (kneeAngle < 105) {
      _reachedBottom = true;
      return _result(PoseStage.returnToStart);
    }
    if (kneeAngle > 155) {
      if (_reachedBottom) _countRep();
      return _result(PoseStage.lowering);
    }
    return _result(
      _reachedBottom ? PoseStage.returnToStart : PoseStage.lowering,
    );
  }

  PoseRepResult _analyzePushup(Pose pose) {
    final side = _bestSide(pose, const [
      _Joint.shoulder,
      _Joint.elbow,
      _Joint.wrist,
      _Joint.hip,
      _Joint.ankle,
    ]);
    if (side == null) return _result(PoseStage.findingBody);

    final shoulder = _landmark(pose, side, _Joint.shoulder)!;
    final elbow = _landmark(pose, side, _Joint.elbow)!;
    final wrist = _landmark(pose, side, _Joint.wrist)!;
    final hip = _landmark(pose, side, _Joint.hip)!;
    final ankle = _landmark(pose, side, _Joint.ankle)!;
    final elbowAngle = _angle(shoulder, elbow, wrist);
    final bodyAngle = _angle(shoulder, hip, ankle);

    // Bent hips do not count as a push-up. The phone is propped side-on, so
    // the user can keep both hands on the floor throughout the mission.
    if (bodyAngle < 145) return _result(PoseStage.ready);
    if (elbowAngle < 100) {
      _reachedBottom = true;
      return _result(PoseStage.returnToStart);
    }
    if (elbowAngle > 155) {
      if (_reachedBottom) _countRep();
      return _result(PoseStage.lowering);
    }
    return _result(
      _reachedBottom ? PoseStage.returnToStart : PoseStage.lowering,
    );
  }

  void _countRep() {
    final now = DateTime.now();
    if (_lastRepAt == null ||
        now.difference(_lastRepAt!) > const Duration(milliseconds: 650)) {
      _reps++;
      _lastRepAt = now;
    }
    _reachedBottom = false;
  }

  PoseRepResult _result(PoseStage stage) =>
      PoseRepResult(reps: _reps, stage: stage);

  _Side? _bestSide(Pose pose, List<_Joint> joints) {
    double score(_Side side) => joints.fold(
      0,
      (sum, joint) => sum + (_landmark(pose, side, joint)?.likelihood ?? 0),
    );

    final leftScore = score(_Side.left);
    final rightScore = score(_Side.right);
    final side = leftScore >= rightScore ? _Side.left : _Side.right;
    final selected = [for (final joint in joints) _landmark(pose, side, joint)];
    if (selected.any((point) => point == null || point.likelihood < 0.45)) {
      return null;
    }
    return side;
  }

  PoseLandmark? _landmark(Pose pose, _Side side, _Joint joint) {
    final type = switch ((side, joint)) {
      (_Side.left, _Joint.shoulder) => PoseLandmarkType.leftShoulder,
      (_Side.right, _Joint.shoulder) => PoseLandmarkType.rightShoulder,
      (_Side.left, _Joint.elbow) => PoseLandmarkType.leftElbow,
      (_Side.right, _Joint.elbow) => PoseLandmarkType.rightElbow,
      (_Side.left, _Joint.wrist) => PoseLandmarkType.leftWrist,
      (_Side.right, _Joint.wrist) => PoseLandmarkType.rightWrist,
      (_Side.left, _Joint.hip) => PoseLandmarkType.leftHip,
      (_Side.right, _Joint.hip) => PoseLandmarkType.rightHip,
      (_Side.left, _Joint.knee) => PoseLandmarkType.leftKnee,
      (_Side.right, _Joint.knee) => PoseLandmarkType.rightKnee,
      (_Side.left, _Joint.ankle) => PoseLandmarkType.leftAnkle,
      (_Side.right, _Joint.ankle) => PoseLandmarkType.rightAnkle,
    };
    return pose.landmarks[type];
  }

  double _angle(PoseLandmark a, PoseLandmark vertex, PoseLandmark c) {
    final radians =
        math.atan2(c.y - vertex.y, c.x - vertex.x) -
        math.atan2(a.y - vertex.y, a.x - vertex.x);
    var degrees = radians.abs() * 180 / math.pi;
    if (degrees > 180) degrees = 360 - degrees;
    return degrees;
  }
}

enum _Side { left, right }

enum _Joint { shoulder, elbow, wrist, hip, knee, ankle }
