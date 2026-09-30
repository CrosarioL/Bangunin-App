import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../features/alarms/domain/alarm_clip.dart';
import '../../../features/alarms/domain/entities/alarm.dart';

/// Gets an alarm's chosen sound to where iOS can ring it
/// (`ios/Runner/AlarmSoundBridge.swift`).
///
/// AlarmKit and local notifications only play sounds they can find by file
/// name, in a PCM format, up to 30 seconds. Without this every iOS alarm rang
/// the default system tone instead of the sound the user picked.
///
/// Mirrors the source order of `AlarmAudioService.startRinging`: clip, then
/// custom file, then the bundled sound. Returns null on Android, or when the
/// sound cannot be prepared, in which case the system default plays.
class AlarmSoundInstaller {
  AlarmSoundInstaller({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('app.bangunin/alarmsound');

  final MethodChannel _channel;

  Future<String?> soundNameFor(Alarm alarm) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;

    final clip = AlarmClips.byId(alarm.clipId);
    final customPath = alarm.customSoundPath;
    final Map<String, String> args;
    if (clip != null) {
      args = {'key': 'bgn_clip_${clip.id}', 'asset': clip.audioAsset};
    } else if (alarm.sound == AlarmSound.custom && customPath != null) {
      final hash = sha1.convert(utf8.encode(customPath)).toString();
      args = {'key': 'bgn_custom_${hash.substring(0, 12)}', 'path': customPath};
    } else {
      final sound = alarm.sound == AlarmSound.custom
          ? AlarmSound.classic
          : alarm.sound;
      args = {'key': 'bgn_${sound.name}', 'asset': sound.assetPath};
    }

    try {
      return await _channel.invokeMethod<String>('install', args);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
