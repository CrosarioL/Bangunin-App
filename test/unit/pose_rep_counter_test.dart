import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:wakio/features/missions/data/pose_rep_counter.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

typedef _Point = ({double x, double y});

/// Places a third point so that the angle at [vertex] between [reference] and
/// the result is exactly [degrees]. `_jointAngle` folds angles to <= 180, so
/// the direction of rotation does not matter.
_Point _atAngle(_Point vertex, _Point reference, double degrees) {
  final base = math.atan2(reference.y - vertex.y, reference.x - vertex.x);
  final target = base + degrees * math.pi / 180;
  return (
    x: vertex.x + 100 * math.cos(target),
    y: vertex.y + 100 * math.sin(target),
  );
}

/// Builds a pose from explicit landmark positions.
///
/// Deliberately not built from independent joint "triples": shoulders and
/// ankles each participate in two of the angles the counter reads, so laying
/// them out separately would overwrite one angle with another and the fixture
/// would silently describe a body that cannot exist.
Pose _poseFrom(
  Map<PoseLandmarkType, _Point> points, {
  double likelihood = 0.9,
  Set<PoseLandmarkType> omit = const {},
}) => Pose(
  landmarks: {
    for (final entry in points.entries)
      if (!omit.contains(entry.key))
        entry.key: PoseLandmark(
          type: entry.key,
          x: entry.value.x,
          y: entry.value.y,
          z: 0,
          likelihood: likelihood,
        ),
  },
);

/// Side-on pushup skeleton: one shoulder/elbow/wrist chain plus a
/// shoulder/hip/ankle body line, mirrored to the other side.
Pose pushupPose({
  required double elbowDegrees,
  double bodyDegrees = 170,
  double likelihood = 0.9,
  Set<PoseLandmarkType> omit = const {},
}) {
  final points = <PoseLandmarkType, _Point>{};

  for (final (side, offset) in [(false, 0.0), (true, 500.0)]) {
    final shoulder = (x: offset, y: 0.0);
    final elbow = (x: offset + 100, y: 0.0);
    final hip = (x: offset + 200, y: 0.0);
    points[side
            ? PoseLandmarkType.rightShoulder
            : PoseLandmarkType.leftShoulder] =
        shoulder;
    points[side ? PoseLandmarkType.rightElbow : PoseLandmarkType.leftElbow] =
        elbow;
    points[side ? PoseLandmarkType.rightWrist : PoseLandmarkType.leftWrist] =
        _atAngle(elbow, shoulder, elbowDegrees);
    points[side ? PoseLandmarkType.rightHip : PoseLandmarkType.leftHip] = hip;
    points[side ? PoseLandmarkType.rightAnkle : PoseLandmarkType.leftAnkle] =
        _atAngle(hip, shoulder, bodyDegrees);
  }

  return _poseFrom(points, likelihood: likelihood, omit: omit);
}

/// Squat skeleton: only the hip/knee/ankle chain matters.
Pose squatPose({required double kneeDegrees, double likelihood = 0.9}) {
  final points = <PoseLandmarkType, _Point>{};

  for (final (side, offset) in [(false, 0.0), (true, 500.0)]) {
    final hip = (x: offset, y: 0.0);
    final knee = (x: offset, y: 100.0);
    points[side ? PoseLandmarkType.rightHip : PoseLandmarkType.leftHip] = hip;
    points[side ? PoseLandmarkType.rightKnee : PoseLandmarkType.leftKnee] =
        knee;
    points[side ? PoseLandmarkType.rightAnkle : PoseLandmarkType.leftAnkle] =
        _atAngle(knee, hip, kneeDegrees);
  }

  return _poseFrom(points, likelihood: likelihood);
}

Pose pushupExtended({double likelihood = 0.9}) =>
    pushupPose(elbowDegrees: 170, likelihood: likelihood);

Pose pushupLowered({double likelihood = 0.9}) =>
    pushupPose(elbowDegrees: 80, likelihood: likelihood);

/// Halfway down — inside the hysteresis band, so neither state.
Pose pushupPartial() => pushupPose(elbowDegrees: 130);

Pose squatStanding() => squatPose(kneeDegrees: 170);

Pose squatLowered() => squatPose(kneeDegrees: 90);

void main() {
  const frames = 3; // matches PoseRepCounter._requiredFrames

  PoseRepCounter counter({
    MissionType mission = MissionType.pushups,
    int target = 5,
  }) => PoseRepCounter(mission: mission, targetReps: target);

  /// Feeds the same pose [count] times and returns the final update.
  PoseRepUpdate feed(
    PoseRepCounter c,
    Pose pose, {
    int count = frames,
    DateTime? now,
  }) {
    late PoseRepUpdate update;
    for (var i = 0; i < count; i++) {
      update = c.addPose(pose, now: now);
    }
    return update;
  }

  group('extended start state is required', () {
    test('no rep is credited for lowered -> extended alone', () {
      final c = counter();

      // Someone already lying on the floor who just pushes up. Before the
      // fix this scored a rep despite never completing a cycle.
      feed(c, pushupLowered());
      feed(c, pushupExtended());

      expect(c.reps, 0);
    });

    test('counting only begins after the start position is held', () {
      final c = counter();

      expect(c.hasStarted, isFalse);
      final update = feed(c, pushupExtended());

      expect(c.hasStarted, isTrue);
      expect(update.guidance, PoseGuidance.ready);
    });

    test('a partial hold does not establish the start', () {
      final c = counter();

      final update = feed(c, pushupExtended(), count: frames - 1);

      expect(c.hasStarted, isFalse);
      expect(update.guidance, PoseGuidance.getIntoStartPosition);
    });
  });

  group('full cycles count', () {
    test('extended -> lowered -> extended is one rep', () {
      final c = counter();
      final start = DateTime(2026);

      feed(c, pushupExtended(), now: start);
      feed(c, pushupLowered(), now: start);
      final update = feed(
        c,
        pushupExtended(),
        now: start.add(const Duration(seconds: 2)),
      );

      expect(c.reps, 1);
      expect(update.repCounted, isTrue);
    });

    test('repCounted fires on exactly one frame', () {
      final c = counter();
      final start = DateTime(2026);
      var countedFrames = 0;

      feed(c, pushupExtended(), now: start);
      feed(c, pushupLowered(), now: start);
      for (var i = 0; i < 6; i++) {
        final at = start.add(Duration(seconds: 2 + i));
        if (c.addPose(pushupExtended(), now: at).repCounted) countedFrames++;
      }

      expect(c.reps, 1);
      expect(countedFrames, 1, reason: 'holding extended must not re-credit');
    });

    test('squats count off knee angle', () {
      final c = counter(mission: MissionType.squats);
      final start = DateTime(2026);

      feed(c, squatStanding(), now: start);
      feed(c, squatLowered(), now: start);
      feed(c, squatStanding(), now: start.add(const Duration(seconds: 2)));

      expect(c.reps, 1);
    });

    test('reaching the target reports complete', () {
      final c = counter(target: 2);
      var at = DateTime(2026);

      feed(c, pushupExtended(), now: at);
      for (var rep = 0; rep < 2; rep++) {
        at = at.add(const Duration(seconds: 2));
        feed(c, pushupLowered(), now: at);
        at = at.add(const Duration(seconds: 2));
        feed(c, pushupExtended(), now: at);
      }

      expect(c.reps, 2);
      expect(c.isComplete, isTrue);
      expect(
        c.addPose(pushupExtended(), now: at).guidance,
        PoseGuidance.complete,
      );
    });
  });

  group('incomplete repetitions are rejected', () {
    test('a partial descent never reaches the lowered state', () {
      final c = counter();
      final start = DateTime(2026);

      feed(c, pushupExtended(), now: start);
      final update = feed(c, pushupPartial(), count: 10, now: start);
      feed(c, pushupExtended(), now: start.add(const Duration(seconds: 2)));

      expect(c.reps, 0);
      expect(
        update.guidance,
        PoseGuidance.ready,
        reason: 'the hysteresis band is neither lowered nor a new rep',
      );
    });

    test('bobbing inside the hysteresis band counts nothing', () {
      final c = counter();
      final start = DateTime(2026);
      feed(c, pushupExtended(), now: start);

      for (var i = 0; i < 20; i++) {
        c.addPose(pushupPartial(), now: start);
        c.addPose(pushupExtended(), now: start);
      }

      expect(c.reps, 0);
    });

    test('a single lowered frame is not a confirmed descent', () {
      final c = counter();
      final start = DateTime(2026);

      feed(c, pushupExtended(), now: start);
      c.addPose(pushupLowered(), now: start);
      feed(c, pushupExtended(), now: start.add(const Duration(seconds: 2)));

      expect(c.reps, 0);
    });
  });

  group('debounce', () {
    // Debounce is measured between consecutive reps. The first rep has no
    // predecessor to be "too fast" after, and the six frames of confirmation
    // it already needs are the guard there.

    test('a second rep too soon after the first is not credited', () {
      final c = counter();
      final at = DateTime(2026);

      feed(c, pushupExtended(), now: at);
      feed(c, pushupLowered(), now: at);
      feed(c, pushupExtended(), now: at);
      expect(c.reps, 1, reason: 'first rep stands');

      // A second full cycle at the same instant: inside the 650ms floor.
      feed(c, pushupLowered(), now: at);
      feed(c, pushupExtended(), now: at);

      expect(c.reps, 1, reason: 'the implausibly fast second rep is rejected');
    });

    test('a rejected rep still returns to extended so the next one counts', () {
      final c = counter();
      final at = DateTime(2026);

      feed(c, pushupExtended(), now: at);
      feed(c, pushupLowered(), now: at);
      feed(c, pushupExtended(), now: at);
      feed(c, pushupLowered(), now: at);
      feed(c, pushupExtended(), now: at); // rejected: too fast
      expect(c.reps, 1);

      final later = at.add(const Duration(seconds: 3));
      feed(c, pushupLowered(), now: later);
      feed(c, pushupExtended(), now: later);

      expect(c.reps, 2, reason: 'a genuine later rep must still be credited');
    });
  });

  group('landmark confidence and visibility', () {
    test('low-confidence landmarks report joints not visible', () {
      final c = counter();

      final update = feed(c, pushupExtended(likelihood: 0.2));

      expect(update.guidance, PoseGuidance.keyJointsNotVisible);
      expect(update.isTracking, isFalse);
      expect(c.reps, 0);
    });

    test('an empty pose reports no person detected', () {
      final c = counter();

      final update = c.addPose(Pose(landmarks: {}));

      expect(update.guidance, PoseGuidance.noPersonDetected);
      expect(update.isTracking, isFalse);
    });

    test('missing joints report joints not visible, not no-person', () {
      final c = counter();

      final update = c.addPose(
        pushupPose(
          elbowDegrees: 170,
          omit: {PoseLandmarkType.leftWrist, PoseLandmarkType.rightWrist},
        ),
      );

      expect(update.guidance, PoseGuidance.keyJointsNotVisible);
    });

    test('joints vanishing mid-rep prevents that rep completing', () {
      final c = counter();
      final start = DateTime(2026);

      feed(c, pushupExtended(), now: start);
      feed(c, pushupLowered(), now: start);
      // Occluded on the way up.
      feed(c, pushupExtended(likelihood: 0.2), now: start);
      // Only two clean frames follow — one short of confirmation.
      final at = start.add(const Duration(seconds: 2));
      c.addPose(pushupExtended(), now: at);
      c.addPose(pushupExtended(), now: at);

      expect(c.reps, 0);
    });

    test('tracking recovers once the joints come back', () {
      final c = counter();
      final start = DateTime(2026);

      feed(c, pushupExtended(), now: start);
      feed(c, pushupLowered(), now: start);
      feed(c, pushupExtended(likelihood: 0.2), now: start);

      final at = start.add(const Duration(seconds: 2));
      final update = feed(c, pushupExtended(), now: at);

      expect(
        c.reps,
        1,
        reason: 'a clean confirmation should still complete it',
      );
      expect(update.isTracking, isTrue);
    });
  });

  group('bad body line', () {
    test('pushups with a collapsed body line do not count', () {
      final c = counter();
      final start = DateTime(2026);

      // Elbows move correctly but the hips are folded — kneeling/bobbing.
      final extended = pushupPose(elbowDegrees: 170, bodyDegrees: 100);
      final lowered = pushupPose(elbowDegrees: 80, bodyDegrees: 100);

      feed(c, extended, now: start);
      feed(c, lowered, now: start);
      feed(c, extended, now: start.add(const Duration(seconds: 2)));

      expect(c.reps, 0);
      expect(c.hasStarted, isFalse, reason: 'never a valid start position');
    });
  });
}
