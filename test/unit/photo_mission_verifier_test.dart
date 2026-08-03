import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wakio/features/missions/data/photo_mission_verifier.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  const verifier = PhotoMissionVerifier();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wakio_photos');
  });

  tearDown(() async => tempDir.delete(recursive: true));

  Future<String> write(String name, img.Image image) async {
    final path = '${tempDir.path}/$name.png';
    await File(path).writeAsBytes(img.encodePng(image));
    return path;
  }

  /// A single flat colour — a painted wall, a shirt, a screen showing one tone.
  img.Image flat(int r, int g, int b) {
    final image = img.Image(width: 160, height: 160);
    img.fill(image, color: img.ColorRgb8(r, g, b));
    return image;
  }

  /// A busy surface with structure at a *block* scale rather than per pixel.
  ///
  /// This matters: the verifier downsamples to 128px before measuring
  /// texture, and per-pixel white noise averages away to nothing under that
  /// resize — which is also true of real capture noise. What survives, and
  /// what actually distinguishes grass from a painted wall, is detail at the
  /// scale of blades and clumps. [offset] shifts the whole pattern, standing
  /// in for the hand shake between two frames of a burst.
  img.Image textured(
    int r,
    int g,
    int b, {
    int seed = 7,
    int offset = 0,
    int blockSize = 3,
    int jitter = 70,
    int hueJitter = 40,
  }) {
    final image = img.Image(width: 160, height: 160);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final bx = (x + offset) ~/ blockSize;
        final by = (y + offset) ~/ blockSize;
        // Deterministic per-block hash, so the pattern is stable and only
        // `offset` moves it.
        final hash = (bx * 73856093) ^ (by * 19349663) ^ (seed * 83492791);
        final shade = (hash.abs() % jitter) - jitter ~/ 2;
        final hueShift = ((hash.abs() >> 8) % hueJitter) - hueJitter ~/ 2;
        image.setPixelRgb(
          x,
          y,
          (r + shade).clamp(0, 255),
          (g + shade + hueShift).clamp(0, 255),
          (b + shade).clamp(0, 255),
        );
      }
    }
    return image;
  }

  /// Brighter at the top than the bottom — how an overcast sky actually looks.
  img.Image brighteningUpward(int base) {
    final image = img.Image(width: 160, height: 160);
    for (var y = 0; y < image.height; y++) {
      final falloff = (y / image.height * 90).round();
      final value = (base - falloff).clamp(0, 255);
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgb(x, y, value, value, value);
      }
    }
    return image;
  }

  group('grass — the green-pixel loophole', () {
    test('a real, textured grass frame passes', () async {
      final path = await write('grass', textured(60, 150, 55));
      final result = await verifier.verify(MissionType.grassPhoto, path);
      expect(result.passed, isTrue);
    });

    test('a flat green frame (shirt, wall, screen) is rejected', () async {
      // The old check was `enough green pixels`, which this passes trivially.
      final path = await write('green_wall', flat(60, 150, 55));
      final result = await verifier.verify(MissionType.grassPhoto, path);

      expect(result.passed, isFalse);
      expect(result.failure, PhotoFailure.notEnoughTexture);
    });

    test('a non-green textured frame is rejected on colour', () async {
      final path = await write('blue', textured(60, 80, 200));
      final result = await verifier.verify(MissionType.grassPhoto, path);

      expect(result.passed, isFalse);
      expect(result.failure, PhotoFailure.surfaceDoesNotLookRight);
    });

    test('a dark frame reports darkness, not a wrong surface', () async {
      final path = await write('dark_grass', textured(5, 12, 5, jitter: 6));
      final result = await verifier.verify(MissionType.grassPhoto, path);

      expect(result.failure, PhotoFailure.tooDark);
    });
  });

  group('sky — the white-ceiling loophole', () {
    test('a blue sky passes', () async {
      final path = await write('sky', flat(110, 160, 235));
      expect(
        (await verifier.verify(MissionType.skyPhoto, path)).passed,
        isTrue,
      );
    });

    test('a flat white ceiling is rejected', () async {
      // Bright and desaturated, so the old overcast clause accepted it — you
      // could finish this mission without getting out of bed.
      final path = await write('ceiling', flat(225, 226, 228));
      final result = await verifier.verify(MissionType.skyPhoto, path);

      expect(result.passed, isFalse);
      expect(result.failure, PhotoFailure.surfaceDoesNotLookRight);
    });

    test('an overcast sky brightening upward still passes', () async {
      final path = await write('overcast', brighteningUpward(245));
      expect(
        (await verifier.verify(MissionType.skyPhoto, path)).passed,
        isTrue,
      );
    });

    test('a dark red frame is rejected', () async {
      final path = await write('red', flat(120, 30, 20));
      expect(
        (await verifier.verify(MissionType.skyPhoto, path)).passed,
        isFalse,
      );
    });
  });

  group('bed', () {
    test('a near-black pocket shot reports darkness', () async {
      final path = await write('black', flat(5, 5, 5));
      final result = await verifier.verify(MissionType.makeBed, path);

      expect(result.failure, PhotoFailure.tooDark);
    });

    test('a blank wall has no structure to judge', () async {
      final path = await write('wall', flat(150, 150, 152));
      final result = await verifier.verify(MissionType.makeBed, path);

      expect(result.passed, isFalse);
      expect(result.failure, PhotoFailure.notEnoughTexture);
    });

    test('a plausibly structured frame passes', () async {
      final path = await write('bed', textured(150, 148, 152, jitter: 55));
      expect((await verifier.verify(MissionType.makeBed, path)).passed, isTrue);
    });
  });

  group('object hunt', () {
    test('the same scene matches its reference', () async {
      final reference = await write('ref', textured(200, 120, 40));
      final photo = await write('photo', textured(200, 120, 40));
      final result = await verifier.verify(
        MissionType.objectHunt,
        photo,
        referencePath: reference,
      );

      expect(result.passed, isTrue);
    });

    test('a very different scene does not match', () async {
      final reference = await write('ref2', textured(200, 120, 40));
      final photo = await write('photo2', textured(20, 30, 220));
      final result = await verifier.verify(
        MissionType.objectHunt,
        photo,
        referencePath: reference,
      );

      expect(result.passed, isFalse);
      expect(result.failure, PhotoFailure.doesNotMatchReference);
    });

    test('a missing reference is reported distinctly', () async {
      final photo = await write('photo3', textured(200, 120, 40));
      final result = await verifier.verify(MissionType.objectHunt, photo);

      expect(result.failure, PhotoFailure.missingReference);
    });
  });

  group('liveness across a burst', () {
    test('identical frames read as a photo of a photo', () async {
      final frame = textured(60, 150, 55);
      final paths = [
        await write('live1', frame),
        await write('live2', frame),
        await write('live3', frame),
      ];

      final result = await verifier.verifyLive(MissionType.grassPhoto, paths);

      expect(result.passed, isFalse);
      expect(result.failure, PhotoFailure.sceneNotLive);
    });

    test('slightly differing frames read as a live scene', () async {
      // Same scene, nudged by a pixel or two between frames — hand shake.
      final paths = [
        await write('sway1', textured(60, 150, 55, offset: 0)),
        await write('sway2', textured(60, 150, 55, offset: 2)),
        await write('sway3', textured(60, 150, 55, offset: 4)),
      ];

      final result = await verifier.verifyLive(MissionType.grassPhoto, paths);

      expect(result.passed, isTrue);
    });

    test('wildly different frames are not one continuous scene', () async {
      final paths = [
        await write('jump1', textured(60, 150, 55)),
        await write('jump2', textured(20, 30, 220)),
      ];

      final result = await verifier.verifyLive(MissionType.grassPhoto, paths);

      expect(result.passed, isFalse);
      expect(result.failure, PhotoFailure.sceneNotLive);
    });

    test('every frame must satisfy the mission, not just one', () async {
      final paths = [
        await write('mixed1', textured(60, 150, 55, seed: 1)),
        // A flat green wall slipped into an otherwise live burst.
        await write('mixed2', flat(60, 150, 55)),
      ];

      final result = await verifier.verifyLive(MissionType.grassPhoto, paths);

      expect(result.passed, isFalse);
    });

    test('an empty burst is rejected', () async {
      final result = await verifier.verifyLive(MissionType.grassPhoto, []);
      expect(result.failure, PhotoFailure.invalidImage);
    });
  });

  test('an undecodable file reports invalidImage', () async {
    final path = '${tempDir.path}/not_an_image.png';
    await File(path).writeAsString('garbage');
    final result = await verifier.verify(MissionType.skyPhoto, path);

    expect(result.failure, PhotoFailure.invalidImage);
  });
}
