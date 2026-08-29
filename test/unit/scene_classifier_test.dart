import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wakio/features/missions/data/photo_mission_verifier.dart';
import 'package:wakio/features/missions/data/scene_classifier.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app.bangunin/vision');
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wakio_vision');
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await tempDir.delete(recursive: true);
  });

  /// Stands in for VisionBridge.swift.
  void installVision({
    Map<String, double>? labels,
    double hand = 0,
    bool available = true,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (!available) {
            throw PlatformException(code: 'unavailable');
          }
          return switch (call.method) {
            'classify' => labels,
            'detectHand' => hand,
            _ => null,
          };
        });
  }

  /// A flat green frame: the "green shirt / rug" case the texture heuristic
  /// on its own rejects.
  Future<String> flatGreen(String name) async {
    final image = img.Image(width: 120, height: 120);
    img.fill(image, color: img.ColorRgb8(60, 150, 55));
    final path = '${tempDir.path}/$name.png';
    await File(path).writeAsBytes(img.encodePng(image));
    return path;
  }

  /// A busy green frame: passes the texture heuristic.
  Future<String> texturedGreen(String name) async {
    final image = img.Image(width: 120, height: 120);
    for (var y = 0; y < 120; y++) {
      for (var x = 0; x < 120; x++) {
        final hash = ((x ~/ 3) * 73856093) ^ ((y ~/ 3) * 19349663);
        final shade = (hash.abs() % 70) - 35;
        image.setPixelRgb(
          x,
          y,
          (60 + shade).clamp(0, 255),
          (150 + shade).clamp(0, 255),
          (55 + shade).clamp(0, 255),
        );
      }
    }
    final path = '${tempDir.path}/$name.png';
    await File(path).writeAsBytes(img.encodePng(image));
    return path;
  }

  PhotoMissionVerifier verifierWithVision() =>
      PhotoMissionVerifier(sceneClassifier: SceneClassifier(channel: channel));

  group('Vision overrules the heuristic in both directions', () {
    test('recognised grass passes even where texture was marginal', () async {
      // Flat green fails the texture check on its own — but if Apple's
      // classifier says grass, that is better evidence than a texture number,
      // and rejecting someone standing on real grass is the worst outcome.
      installVision(labels: {'grass': 0.82}, hand: 0.9);
      final path = await flatGreen('marginal_grass');

      final result = await verifierWithVision().verify(
        MissionType.grassPhoto,
        path,
      );

      expect(result.passed, isTrue);
    });

    test('a busy green rug is rejected despite passing texture', () async {
      // Textured green passes the heuristic; Vision sees no grass.
      installVision(labels: {'carpet': 0.77, 'rug': 0.6}, hand: 0.9);
      final path = await texturedGreen('green_rug');

      final result = await verifierWithVision().verify(
        MissionType.grassPhoto,
        path,
      );

      expect(result.passed, isFalse);
      expect(result.failure, PhotoFailure.surfaceDoesNotLookRight);
    });

    test('grass with no hand in frame asks for the hand', () async {
      // Recognising a lawn through a window is not touching it.
      installVision(labels: {'grass': 0.9}, hand: 0.1);
      final path = await texturedGreen('no_hand');

      final result = await verifierWithVision().verify(
        MissionType.grassPhoto,
        path,
      );

      expect(result.passed, isFalse);
      expect(result.failure, PhotoFailure.noHandVisible);
    });

    test('low-confidence labels are not treated as evidence', () async {
      installVision(labels: {'grass': 0.05}, hand: 0.9);
      final path = await texturedGreen('unsure');

      final result = await verifierWithVision().verify(
        MissionType.grassPhoto,
        path,
      );

      expect(result.passed, isFalse);
    });
  });

  group('Vision silence is not a rejection', () {
    test('an empty label set defers to the heuristic', () async {
      installVision(labels: {}, hand: 0.9);
      final path = await texturedGreen('inconclusive');

      final result = await verifierWithVision().verify(
        MissionType.grassPhoto,
        path,
      );

      expect(
        result.passed,
        isTrue,
        reason: 'no opinion must not become a "no"',
      );
    });

    test('an unavailable bridge defers to the heuristic', () async {
      installVision(available: false);
      final path = await texturedGreen('android');

      final result = await verifierWithVision().verify(
        MissionType.grassPhoto,
        path,
      );

      expect(result.passed, isTrue);
    });

    test('no bridge at all (Android) defers to the heuristic', () async {
      final path = await texturedGreen('no_plugin');

      final result = await verifierWithVision().verify(
        MissionType.grassPhoto,
        path,
      );

      expect(result.passed, isTrue);
    });
  });

  group('exposure is reported before the scene check runs', () {
    test('a dark frame reports darkness, not a missing hand', () async {
      installVision(labels: {'grass': 0.9}, hand: 0.0);
      final image = img.Image(width: 120, height: 120);
      img.fill(image, color: img.ColorRgb8(4, 9, 4));
      final path = '${tempDir.path}/dark.png';
      await File(path).writeAsBytes(img.encodePng(image));

      final result = await verifierWithVision().verify(
        MissionType.grassPhoto,
        path,
      );

      expect(result.failure, PhotoFailure.tooDark);
    });
  });

  group('other missions', () {
    test('sky accepts any of the sky labels', () async {
      installVision(labels: {'blue_sky': 0.71});
      final image = img.Image(width: 120, height: 120);
      img.fill(image, color: img.ColorRgb8(110, 160, 235));
      final path = '${tempDir.path}/sky.png';
      await File(path).writeAsBytes(img.encodePng(image));

      final result = await verifierWithVision().verify(
        MissionType.skyPhoto,
        path,
      );

      expect(result.passed, isTrue);
    });

    test('a ceiling labelled as a room is rejected for sky', () async {
      installVision(labels: {'ceiling': 0.8, 'room': 0.6});
      final image = img.Image(width: 120, height: 120);
      img.fill(image, color: img.ColorRgb8(225, 226, 228));
      final path = '${tempDir.path}/ceiling.png';
      await File(path).writeAsBytes(img.encodePng(image));

      final result = await verifierWithVision().verify(
        MissionType.skyPhoto,
        path,
      );

      expect(result.passed, isFalse);
    });

    test('bed does not require a hand', () async {
      installVision(labels: {'bed': 0.66}, hand: 0);
      final path = await texturedGreen('bed_scene');

      final result = await verifierWithVision().verify(
        MissionType.makeBed,
        path,
      );

      expect(result.passed, isTrue);
    });
  });

  group('SceneEvidence', () {
    test('confidenceFor takes the best matching label', () {
      const evidence = SceneEvidence(
        supported: true,
        labels: {'foliage': 0.4, 'grass': 0.9},
      );

      expect(evidence.confidenceFor(['grass', 'foliage']), 0.9);
      expect(evidence.confidenceFor(['nothing']), 0);
    });

    test('sawHand needs real confidence', () {
      expect(
        const SceneEvidence(supported: true, handConfidence: 0.9).sawHand,
        isTrue,
      );
      expect(
        const SceneEvidence(supported: true, handConfidence: 0.2).sawHand,
        isFalse,
      );
    });
  });
}
