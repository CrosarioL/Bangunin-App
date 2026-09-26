import 'package:flutter/services.dart';

import '../domain/mission_type.dart';

/// What on-device scene understanding thinks is in a mission photo.
///
/// [supported] is false wherever Vision is unavailable (Android, or any
/// failure), in which case the caller falls back to pixel heuristics alone
/// and must not treat the absence of a verdict as a rejection.
class SceneEvidence {
  const SceneEvidence({
    required this.supported,
    this.labels = const {},
    this.handConfidence = 0,
  });

  const SceneEvidence.unsupported()
    : supported = false,
      labels = const {},
      handConfidence = 0;

  final bool supported;

  /// `label -> confidence`, from Apple's image classifier.
  final Map<String, double> labels;

  /// Highest confidence that a human hand is visible, 0 if none.
  final double handConfidence;

  double confidenceFor(Iterable<String> candidates) {
    var best = 0.0;
    for (final candidate in candidates) {
      final value = labels[candidate];
      if (value != null && value > best) best = value;
    }
    return best;
  }

  bool get sawHand => handConfidence >= 0.5;
}

/// Bridges to Apple's Vision framework (`ios/Runner/VisionBridge.swift`).
///
/// Chosen over bundling a classifier: 0 MB of binary, no third-party licence,
/// no review impact. A probe of `VNClassifyImageRequest`'s 1,303-label
/// taxonomy confirmed it already carries `grass`, `bed`, `bedding`,
/// `bedroom`, `pillow`, `sky`, `blue_sky`, `night_sky` and `cloudy`.
///
/// Runs entirely on-device. Nothing is uploaded.
class SceneClassifier {
  SceneClassifier({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('app.bangunin/vision');

  final MethodChannel _channel;

  /// Labels that support each mission, most specific first.
  static const missionLabels = <MissionType, List<String>>{
    MissionType.grassPhoto: ['grass', 'foliage', 'garden', 'plant'],
    MissionType.skyPhoto: ['sky', 'blue_sky', 'night_sky', 'cloudy'],
    MissionType.makeBed: ['bed', 'bedding', 'bedroom', 'pillow'],
  };

  /// Confidence at or above which a label is treated as real evidence.
  ///
  /// Deliberately moderate: Vision is used to *confirm* what the heuristics
  /// already suspect, not to overrule a user standing on actual grass in bad
  /// light. Needs calibration against real photos before launch — see
  /// marketing/research/MISSION_MODEL_EVALUATION.md.
  static const supportingConfidence = 0.35;

  Future<SceneEvidence> inspect(String path, {bool wantHand = false}) async {
    try {
      final raw = await _channel.invokeMapMethod<String, double>('classify', {
        'path': path,
      });
      if (raw == null) return const SceneEvidence.unsupported();

      final hand = wantHand
          ? await _channel.invokeMethod<double>('detectHand', {'path': path})
          : 0.0;

      return SceneEvidence(
        supported: true,
        labels: Map<String, double>.from(raw),
        handConfidence: hand ?? 0,
      );
    } on MissingPluginException {
      // Android, or a build without the bridge.
      return const SceneEvidence.unsupported();
    } on PlatformException {
      return const SceneEvidence.unsupported();
    }
  }
}
