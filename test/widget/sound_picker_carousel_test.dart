import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/audio/alarm_audio_service.dart';
import 'package:wakio/features/alarms/domain/alarm_clip.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/alarms/presentation/widgets/sound_picker_sheet.dart';

import '../helpers/test_app.dart';

class _RecordingAudio implements AlarmAudioService {
  final played = <String>[];

  @override
  Future<void> preview(AlarmSound sound, {String? customPath}) async =>
      played.add(sound.name);

  @override
  Future<void> previewClip(AlarmClip clip) async => played.add(clip.id);

  @override
  Future<void> stopPreview() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _RecordingAudio audio;
  SoundSelection? picked;

  Future<void> open(WidgetTester tester, {String? clipId}) async {
    audio = _RecordingAudio();
    picked = null;
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        overrides: [alarmAudioServiceProvider.overrideWithValue(audio)],
        child: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => picked = await showSoundPickerSheet(
                context,
                current: AlarmSound.classic,
                currentClipId: clipId,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await pumpForAnimations(tester);
  }

  testWidgets('opens on the current clip without playing anything', (
    tester,
  ) async {
    await open(tester, clipId: AlarmClips.all[2].id);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('3 / ${AlarmClips.all.length + 3}'), findsOneWidget);
    expect(audio.played, isEmpty, reason: 'opening must not blast a sound');
  });

  testWidgets('swiping previews the card that lands, choose picks it', (
    tester,
  ) async {
    await open(tester, clipId: AlarmClips.all.first.id);
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await pumpForAnimations(tester);

    final next = AlarmClips.all[1].id;
    expect(audio.played, [next]);

    await tester.tap(find.text('Choose this sound'));
    await pumpForAnimations(tester);
    expect(picked?.clipId, next);
  });

  testWidgets('plain sounds come after the memes and clear the clip', (
    tester,
  ) async {
    await open(tester);
    // A plain alarm opens on its own sound: Classic, right after the memes.
    expect(
      find.text('${AlarmClips.all.length + 1} / ${AlarmClips.all.length + 3}'),
      findsOneWidget,
    );
    await tester.tap(find.text('Choose this sound'));
    await pumpForAnimations(tester);
    expect(picked?.sound, AlarmSound.classic);
    expect(picked?.clipId, isNull);
  });
}
