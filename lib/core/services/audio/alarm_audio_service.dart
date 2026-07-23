import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

import '../../../features/alarms/domain/entities/alarm.dart';

/// Plays the looping alarm sound (bundled asset or the user's custom file)
/// and drives the vibration pattern while an alarm is ringing.
class AlarmAudioService {
  AlarmAudioService([AudioPlayer? player]) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  Timer? _vibrationTimer;
  bool _playing = false;

  bool get isPlaying => _playing;

  /// Keeps the alarm audible while the user completes a mission, but at a
  /// level that does not drown out camera positioning and form guidance.
  Future<void> enterMissionMode(Alarm alarm) async {
    if (!_playing) {
      await startRinging(alarm);
    }
    final missionVolume = (alarm.volume * 0.28).clamp(0.08, 0.30).toDouble();
    await _player.setVolume(missionVolume);
  }

  /// Restores the alarm's configured volume when the mission is abandoned.
  Future<void> exitMissionMode(Alarm alarm) async {
    if (!_playing) {
      await startRinging(alarm);
      return;
    }
    await _player.setVolume(alarm.volume);
  }

  /// iOS: `.playback` category so the alarm ignores the silent switch and
  /// keeps playing when the app is backgrounded (paired with the `audio`
  /// UIBackgroundMode). Android: `alarm` usage + exclusive audio focus so
  /// the system treats this like a real alarm, not background music.
  static final _alarmAudioContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {},
    ),
    android: const AudioContextAndroid(
      stayAwake: true,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.alarm,
      audioFocus: AndroidAudioFocus.gain,
    ),
  );

  Future<void> startRinging(Alarm alarm) async {
    if (_playing) return;
    _playing = true;

    await _player.setAudioContext(_alarmAudioContext);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(alarm.volume);

    final customPath = alarm.customSoundPath;
    if (alarm.sound == AlarmSound.custom && customPath != null) {
      await _player.play(DeviceFileSource(customPath));
    } else {
      final sound = alarm.sound == AlarmSound.custom
          ? AlarmSound.classic
          : alarm.sound;
      // AssetSource paths are relative to the assets/ folder.
      await _player.play(
        AssetSource(sound.assetPath.replaceFirst('assets/', '')),
      );
    }

    if (alarm.vibrate) {
      _vibrationTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
        if (await Vibration.hasVibrator()) {
          await Vibration.vibrate(duration: 800);
        }
      });
    }
  }

  Future<void> stopRinging() async {
    if (!_playing) return;
    _playing = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    await _player.stop();
    await Vibration.cancel();
  }

  /// Plays a short, non-looping preview of a sound in the editor. Uses
  /// regular media playback (not the alarm audio context) so it behaves
  /// like any other in-app sound and respects the silent switch.
  Future<void> preview(AlarmSound sound, {String? customPath}) async {
    await _player.setAudioContext(AudioContextConfig().build());
    await _player.setReleaseMode(ReleaseMode.release);
    await _player.setVolume(1);
    if (sound == AlarmSound.custom && customPath != null) {
      await _player.play(DeviceFileSource(customPath));
    } else if (sound != AlarmSound.custom) {
      await _player.play(
        AssetSource(sound.assetPath.replaceFirst('assets/', '')),
      );
    }
  }

  Future<void> stopPreview() => _player.stop();

  Future<void> dispose() async {
    _vibrationTimer?.cancel();
    await _player.dispose();
  }
}
