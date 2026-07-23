import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:wakio/features/missions/data/pose_rep_analyzer.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

void main() {
  PoseLandmark point(PoseLandmarkType type, double x, double y) =>
      PoseLandmark(type: type, x: x, y: y, z: 0, likelihood: 1);

  Pose squat({required bool down}) => Pose(
    landmarks: {
      PoseLandmarkType.leftShoulder: point(
        PoseLandmarkType.leftShoulder,
        0,
        -1,
      ),
      PoseLandmarkType.leftHip: point(
        PoseLandmarkType.leftHip,
        down ? 1 : 0,
        down ? 1 : 0,
      ),
      PoseLandmarkType.leftKnee: point(PoseLandmarkType.leftKnee, 0, 1),
      PoseLandmarkType.leftAnkle: point(PoseLandmarkType.leftAnkle, 0, 2),
    },
  );

  Pose pushup({required bool down, bool bentHips = false}) => Pose(
    landmarks: {
      PoseLandmarkType.leftShoulder: point(PoseLandmarkType.leftShoulder, 0, 0),
          PoseLandmarkType.leftElbow: point(
            PoseLandmarkType.leftElbow,
            1,
            down ? 1 : 0,
      ),
      PoseLandmarkType.leftWrist: point(PoseLandmarkType.leftWrist, 2, 0),
      PoseLandmarkType.leftHip: point(
        PoseLandmarkType.leftHip,
        1,
        bentHips ? 1 : 0,
      ),
      PoseLandmarkType.leftAnkle: point(
        PoseLandmarkType.leftAnkle,
        2,
        bentHips ? 1 : 0,
      ),
    },
  );

  test('squat only counts after standing, full depth, then standing', () {
    final analyzer = PoseRepAnalyzer(MissionType.squats);
    expect(analyzer.analyze(squat(down: false)).reps, 0);
    expect(analyzer.analyze(squat(down: true)).reps, 0);
    expect(analyzer.analyze(squat(down: false)).reps, 1);
  });

  test('push-up counts full elbow depth with a straight body', () {
    final analyzer = PoseRepAnalyzer(MissionType.pushups);
    expect(analyzer.analyze(pushup(down: false)).reps, 0);
    expect(analyzer.analyze(pushup(down: true)).reps, 0);
    expect(analyzer.analyze(pushup(down: false)).reps, 1);
  });

  test('bent-hip push-up does not count', () {
    final analyzer = PoseRepAnalyzer(MissionType.pushups);
    analyzer.analyze(pushup(down: false));
    analyzer.analyze(pushup(down: true, bentHips: true));
    expect(analyzer.analyze(pushup(down: false)).reps, 0);
  });
}
