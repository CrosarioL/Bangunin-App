import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/missions/data/photo_mission_verifier.dart';
import 'package:wakio/features/missions/data/scene_classifier.dart';
import 'package:wakio/features/missions/domain/hunt_target.dart';
import 'package:wakio/features/missions/domain/mission_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app.bangunin/vision');
  late Directory tempDir;
  const verifier = PhotoMissionVerifier(sceneClassifier: null);
  final withVision = PhotoMissionVerifier(sceneClassifier: SceneClassifier());
  final helmet = HuntTargets.byId('helmet')!;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wakio_hunt');
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await tempDir.delete(recursive: true);
  });

  void installVision(Map<String, double> labels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async => call.method == 'classify' ? labels : 0.0,
        );
  }

  Future<String> frame(String name, int value) async {
    final image = img.Image(width: 64, height: 64);
    img.fill(image, color: img.ColorRgb8(value, value, value));
    final path = '${tempDir.path}/$name.png';
    await File(path).writeAsBytes(img.encodePng(image));
    return path;
  }

  group('HuntTargets', () {
    test('ids are unique and every target has labels', () {
      final ids = HuntTargets.all.map((t) => t.id).toSet();
      expect(ids.length, HuntTargets.all.length);
      for (final target in HuntTargets.all) {
        expect(target.labels, isNotEmpty, reason: target.id);
        expect(
          target.labels.every((l) => l == l.toLowerCase()),
          isTrue,
          reason: '${target.id} labels must be lower-case',
        );
      }
    });

    test('pick never returns an excluded target', () {
      final random = math.Random(1);
      for (var i = 0; i < 200; i++) {
        expect(
          HuntTargets.pick(random, exclude: {'helmet'}).id,
          isNot('helmet'),
        );
      }
    });

    test('matches ML Kit capitalised labels too', () {
      expect(helmet.confidenceIn({'Helmet': 0.8}), 0.8);
      expect(helmet.confidenceIn({'Chair': 0.9}), 0);
    });
  });

  test('a Random Hunt alarm survives a save/load round trip', () {
    final alarm = Alarm(
      id: 'a',
      hour: 6,
      minute: 30,
      missionType: MissionType.randomHunt,
      createdAt: DateTime(2026),
    );
    expect(
      Alarm.fromJson(alarm.toJson()).missionType,
      MissionType.randomHunt,
    );
  });

  group('verifyHunt', () {
    test('passes when the classifier sees the target', () async {
      installVision({'helmet': 0.7, 'indoor': 0.9});
      final result = await withVision.verifyHunt(
        helmet,
        await frame('ok', 128),
      );
      expect(result.passed, isTrue);
    });

    test('fails with targetNotFound when it sees something else', () async {
      installVision({'chair': 0.9});
      final result = await withVision.verifyHunt(
        helmet,
        await frame('wrong', 128),
      );
      expect(result.failure, PhotoFailure.targetNotFound);
    });

    test('fails open when no classifier is available', () async {
      final result = await verifier.verifyHunt(helmet, await frame('any', 128));
      expect(result.passed, isTrue);
    });

    test('still rejects a black frame', () async {
      final result = await verifier.verifyHunt(helmet, await frame('dark', 5));
      expect(result.failure, PhotoFailure.tooDark);
    });
  });
}
