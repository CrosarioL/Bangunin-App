import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/audio/alarm_audio_service.dart';
import 'package:wakio/features/alarms/domain/alarm_clip.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';
import 'package:wakio/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:wakio/features/ringing/presentation/widgets/alarm_video_background.dart';

class _SilentAudio implements AlarmAudioService {
  @override
  Stream<void> get loopRestarts => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const clip = AlarmClip(
    id: 'missing_clip',
    titleEn: 'Phone ringing',
    titleId: 'HP bunyi',
    category: ClipCategory.funny,
  );

  test('clip files follow the flat assets/clips/<id> layout', () {
    expect(clip.videoAsset, 'assets/clips/missing_clip.mp4');
    expect(clip.audioAsset, 'assets/clips/missing_clip.m4a');
    expect(clip.thumbnailAsset, 'assets/clips/missing_clip.jpg');
    expect(clip.title('id'), 'HP bunyi');
  });

  test('catalog ids are unique and lower_snake_case', () {
    final ids = AlarmClips.all.map((c) => c.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final id in ids) {
      expect(RegExp(r'^[a-z0-9_]+$').hasMatch(id), isTrue, reason: id);
    }
  });

  test('an unknown clip id falls back to the plain sound', () {
    expect(AlarmClips.byId('gone'), isNull);
    expect(AlarmClips.byId(null), isNull);
  });

  test('clipId survives a save/load round trip', () {
    final alarm = Alarm(
      id: 'a',
      hour: 6,
      minute: 30,
      clipId: 'phone_ringing',
      createdAt: DateTime(2026),
    );
    expect(Alarm.fromJson(alarm.toJson()).clipId, 'phone_ringing');
  });

  test('onboarding: picking a clip then a sound clears the clip', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(onboardingAnswersProvider.notifier);

    notifier.setClip('phone_ringing');
    final withClip = container.read(onboardingAnswersProvider);
    expect(
      withClip
          .toAlarm(
            Alarm(id: 'x', hour: 0, minute: 0, createdAt: DateTime(2026)),
          )
          .clipId,
      'phone_ringing',
    );

    notifier.setSound(AlarmSound.pulse);
    final answers = container.read(onboardingAnswersProvider);
    expect(answers.clipId, isNull);
    expect(answers.sound, AlarmSound.pulse);
  });

  testWidgets('a clip that cannot load leaves a usable ringing backdrop', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alarmAudioServiceProvider.overrideWithValue(_SilentAudio()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AlarmVideoBackground(clip: clip)),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    // The legibility gradient is always drawn, video or not.
    expect(find.byType(DecoratedBox), findsWidgets);
  });
}
