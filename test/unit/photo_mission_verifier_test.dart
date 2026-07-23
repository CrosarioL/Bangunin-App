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

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<String> writeImage(String name, img.Color color) async {
    final image = img.Image(width: 64, height: 64);
    img.fill(image, color: color);
    final path = '${tempDir.path}/$name.png';
    await File(path).writeAsBytes(img.encodePng(image));
    return path;
  }

  test('sky mission passes on a bright blue frame', () async {
    final path = await writeImage('sky', img.ColorRgb8(110, 160, 235));
    expect(
      await verifier.verify(MissionType.skyPhoto, path),
      PhotoVerdict.pass,
    );
  });

  test('sky mission fails on a dark red frame', () async {
    final path = await writeImage('red', img.ColorRgb8(120, 30, 20));
    expect(
      await verifier.verify(MissionType.skyPhoto, path),
      PhotoVerdict.fail,
    );
  });

  test('grass mission passes on a green frame', () async {
    final path = await writeImage('grass', img.ColorRgb8(60, 150, 55));
    expect(
      await verifier.verify(MissionType.grassPhoto, path),
      PhotoVerdict.pass,
    );
  });

  test('grass mission fails on a blue frame', () async {
    final path = await writeImage('blue', img.ColorRgb8(60, 80, 200));
    expect(
      await verifier.verify(MissionType.grassPhoto, path),
      PhotoVerdict.fail,
    );
  });

  test('bed mission rejects a near-black (pocket) shot', () async {
    final path = await writeImage('black', img.ColorRgb8(5, 5, 5));
    expect(await verifier.verify(MissionType.makeBed, path), PhotoVerdict.fail);
  });

  test('object hunt passes when photo matches the reference', () async {
    final reference = await writeImage('ref', img.ColorRgb8(200, 120, 40));
    final photo = await writeImage('photo', img.ColorRgb8(200, 120, 40));
    expect(
      await verifier.verify(
        MissionType.objectHunt,
        photo,
        referencePath: reference,
      ),
      PhotoVerdict.pass,
    );
  });

  test('object hunt fails on a very different photo', () async {
    final reference = await writeImage('ref2', img.ColorRgb8(200, 120, 40));
    final photo = await writeImage('photo2', img.ColorRgb8(20, 30, 220));
    expect(
      await verifier.verify(
        MissionType.objectHunt,
        photo,
        referencePath: reference,
      ),
      PhotoVerdict.fail,
    );
  });

  test('invalid file reports invalidImage', () async {
    final path = '${tempDir.path}/not_an_image.png';
    await File(path).writeAsString('garbage');
    expect(
      await verifier.verify(MissionType.skyPhoto, path),
      PhotoVerdict.invalidImage,
    );
  });
}
