import 'dart:math' as math;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../domain/mission_type.dart';

/// What the user needs to hear right now, derived from the same frame that
/// drives counting.
///
/// Without this the UI cannot distinguish "I can't see your elbows" from
/// "keep going" — which is the single most common way camera rep counters
/// fail people in the real world. They stand there repping while nothing
/// increments and the app says nothing.
enum PoseGuidance {
  /// No pose at all: nobody in frame, or too dark.
  noPersonDetected,

  /// A person is there, but the joints this exercise depends on are missing
  /// or below the confidence floor. Usually means "move back" or "turn side-on".
  keyJointsNotVisible,

  /// Landmarks are good, but the user has not yet held the extended starting
  /// position, so counting has not begun.
  getIntoStartPosition,

  /// Extended and counting. The resting state between reps.
  ready,

  /// Currently in the lowered position.
  lowered,

  /// Target reached.
  complete,
}

/// One frame's worth of result.
class PoseRepUpdate {
  const PoseRepUpdate({
    required this.reps,
    required this.guidance,
    this.repCounted = false,
  });

  final int reps;
  final PoseGuidance guidance;

  /// True only on the frame that completed a repetition — drive haptics and
  /// sound off this, not off [reps] changing.
  final bool repCounted;

  /// Whether the counter can currently see enough to do its job.
  bool get isTracking =>
      guidance != PoseGuidance.noPersonDetected &&
      guidance != PoseGuidance.keyJointsNotVisible;
}

/// Counts only complete, deliberate repetitions from on-device pose
/// landmarks. Nothing leaves the device.
///
/// The state machine is deliberately strict, in this order:
///
///  1. **Extended start required.** Counting does not begin until the user
///     holds the extended position (arms straight / standing) for
///     [_requiredFrames]. Without this, someone already lying on the floor
///     scores a rep by pushing up once, having never completed a cycle.
///  2. **Extended → lowered → extended** is one rep. A partial descent that
///     never reaches the lowered threshold counts for nothing.
///  3. **Hysteresis.** The lowered and extended thresholds do not touch, so
///     jitter around a single angle cannot oscillate the state.
///  4. **Frame confirmation.** Each state change needs [_requiredFrames]
///     consecutive agreeing frames, which rejects detector noise.
///  5. **Debounce.** Reps closer together than [_minimumRepInterval] are
///     rejected as physically implausible.
///  6. **Confidence floor.** Any landmark below [_minimumLikelihood]
///     invalidates the frame and reports [PoseGuidance.keyJointsNotVisible]
///     rather than silently doing nothing.
///
/// Holding one pose cannot accumulate reps: a rep requires a fresh descent,
/// because completing one returns the machine to the extended state.
class PoseRepCounter {
  PoseRepCounter({required this.mission, required this.targetReps});

  final MissionType mission;
  final int targetReps;

  int reps = 0;

  _Phase _phase = _Phase.awaitingStart;
  int _extendedFrames = 0;
  int _loweredFrames = 0;
  DateTime _lastRepAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const _requiredFrames = 3;
  // Ankles near the bottom edge of the frame often come back around 0.6.
  static const _minimumLikelihood = 0.5;
  static const _minimumRepInterval = Duration(milliseconds: 650);

  bool get isComplete => reps >= targetReps;

  /// True once the user has established the starting position.
  bool get hasStarted => _phase != _Phase.awaitingStart;

  /// Feeds one detected pose. [now] is injectable so debounce is testable.
  PoseRepUpdate addPose(Pose pose, {DateTime? now}) {
    if (isComplete) {
      return PoseRepUpdate(reps: reps, guidance: PoseGuidance.complete);
    }

    final angles = mission == MissionType.squats
        ? _squatAngles(pose)
        : _pushupAngles(pose);

    // Landmarks we need are missing or low-confidence. Reset the frame
    // counters so a partially-observed rep cannot complete, but keep the
    // phase — the user has not necessarily abandoned the exercise.
    if (angles == null) {
      _extendedFrames = 0;
      _loweredFrames = 0;
      return PoseRepUpdate(
        reps: reps,
        guidance: pose.landmarks.isEmpty
            ? PoseGuidance.noPersonDetected
            : PoseGuidance.keyJointsNotVisible,
      );
    }

    final (isLowered, isExtended) = angles;

    switch (_phase) {
      // Require the extended position before anything counts.
      case _Phase.awaitingStart:
        _extendedFrames = isExtended ? _extendedFrames + 1 : 0;
        if (_extendedFrames >= _requiredFrames) {
          _phase = _Phase.extended;
          _loweredFrames = 0;
          return PoseRepUpdate(reps: reps, guidance: PoseGuidance.ready);
        }
        return PoseRepUpdate(
          reps: reps,
          guidance: PoseGuidance.getIntoStartPosition,
        );

      // Extended: wait for a confirmed descent.
      case _Phase.extended:
        _loweredFrames = isLowered ? _loweredFrames + 1 : 0;
        if (_loweredFrames >= _requiredFrames) {
          _phase = _Phase.lowered;
          _extendedFrames = 0;
          return PoseRepUpdate(reps: reps, guidance: PoseGuidance.lowered);
        }
        return PoseRepUpdate(reps: reps, guidance: PoseGuidance.ready);

      // Lowered: a confirmed return to extended completes the rep.
      case _Phase.lowered:
        _extendedFrames = isExtended ? _extendedFrames + 1 : 0;
        if (_extendedFrames < _requiredFrames) {
          return PoseRepUpdate(reps: reps, guidance: PoseGuidance.lowered);
        }

        final at = now ?? DateTime.now();
        if (at.difference(_lastRepAt) < _minimumRepInterval) {
          // Too fast to be real. Return to extended without crediting it,
          // so the user has to perform a genuine next rep.
          _phase = _Phase.extended;
          _loweredFrames = 0;
          return PoseRepUpdate(reps: reps, guidance: PoseGuidance.ready);
        }

        reps++;
        _lastRepAt = at;
        _phase = _Phase.extended;
        _loweredFrames = 0;
        return PoseRepUpdate(
          reps: reps,
          repCounted: true,
          guidance: isComplete ? PoseGuidance.complete : PoseGuidance.ready,
        );
    }
  }

  /// Returns `(isLowered, isExtended)`, or null when the landmarks needed are
  /// not trustworthy. The gap between the two thresholds is the hysteresis
  /// band: angles inside it are in transit and change nothing.
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
    final depth = _squatDepth(pose);
    if ((left == null || right == null) && depth == null) return null;

    // Two independent readings, so a squat counts whichever way the user
    // faces the phone:
    //  * Knee angle works side-on, but facing the camera the thighs point
    //    at the lens and the flat picture shows almost no bend — the old
    //    angle-only rule never saw a face-on squat at all.
    //  * Depth (hip drop vs shin length) works face-on and side-on.
    final knee = (left != null && right != null) ? (left + right) / 2 : null;
    final lowered =
        (knee != null && knee < 105) || (depth != null && depth < 0.5);
    final extended =
        (knee == null || knee > 158) && (depth == null || depth > 0.75);
    return (lowered && !extended, extended && !lowered);
  }

  /// How far the hips sit above the knees, measured in shin lengths and
  /// averaged over both legs: about 1 standing, near 0 at the bottom of a
  /// squat. Null when no leg is trustworthy.
  double? _squatDepth(Pose pose) {
    final readings = <double>[];
    for (final (hip, knee, ankle) in const [
      (
        PoseLandmarkType.leftHip,
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
      ),
      (
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
      ),
    ]) {
      final h = pose.landmarks[hip];
      final k = pose.landmarks[knee];
      final a = pose.landmarks[ankle];
      if (h == null ||
          k == null ||
          a == null ||
          h.likelihood < _minimumLikelihood ||
          k.likelihood < _minimumLikelihood ||
          a.likelihood < _minimumLikelihood) {
        continue;
      }
      final shin = math.sqrt(math.pow(a.x - k.x, 2) + math.pow(a.y - k.y, 2));
      if (shin < 1) continue;
      readings.add((k.y - h.y) / shin);
    }
    if (readings.isEmpty) return null;
    return readings.reduce((x, y) => x + y) / readings.length;
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
    // A straight-ish body line separates a pushup from kneeling and bobbing.
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

enum _Phase { awaitingStart, extended, lowered }
