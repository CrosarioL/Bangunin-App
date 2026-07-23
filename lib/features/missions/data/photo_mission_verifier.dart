import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../domain/mission_type.dart';

/// Result of verifying a mission photo.
enum PhotoVerdict { pass, fail, invalidImage }

/// On-device photo verification using pixel statistics — no image ever
/// leaves the device (matching the product's privacy posture). Heuristics:
///
/// * Sky: the upper region must be bright and blue-dominant.
/// * Grass: the frame must be green-dominant.
/// * Bed: a lit, detailed frame (paired with on-device semantic labeling in
///   the mission page so a random bright photo cannot pass).
/// * Object hunt: color-histogram similarity against the registered
///   reference photo.
///
/// A production upgrade path is an on-device labeler (e.g. ML Kit) behind
/// this same interface.
class PhotoMissionVerifier {
  const PhotoMissionVerifier();

  static const _analysisSize = 96;

  Future<PhotoVerdict> verify(
    MissionType mission,
    String photoPath, {
    String? referencePath,
  }) async {
    final photo = await _load(photoPath);
    if (photo == null) return PhotoVerdict.invalidImage;

    switch (mission) {
      case MissionType.skyPhoto:
        return _verifySky(photo);
      case MissionType.grassPhoto:
        return _verifyGrass(photo);
      case MissionType.makeBed:
        return _verifyBed(photo);
      case MissionType.objectHunt:
        if (referencePath == null) return PhotoVerdict.fail;
        final reference = await _load(referencePath);
        if (reference == null) return PhotoVerdict.invalidImage;
        return _verifyObject(photo, reference);
      case MissionType.none:
      case MissionType.squats:
      case MissionType.pushups:
        return PhotoVerdict.fail;
    }
  }

  Future<img.Image?> _load(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final decoded = await compute(_decodeAndResize, bytes);
      return decoded;
    } on Exception {
      return null;
    }
  }

  static img.Image? _decodeAndResize(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    return img.copyResize(decoded, width: _analysisSize, height: _analysisSize);
  }

  PhotoVerdict _verifySky(img.Image photo) {
    // Sample the top 40% of the frame.
    var blueScore = 0.0;
    var brightness = 0.0;
    var samples = 0;
    for (var y = 0; y < (photo.height * 0.4).floor(); y++) {
      for (var x = 0; x < photo.width; x++) {
        final p = photo.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        brightness += (r + g + b) / 3;
        // Blue sky: blue channel leads; overcast sky: bright and desaturated.
        final saturation = _saturation(r, g, b);
        if (b > r * 1.05 && b > g * 0.95) blueScore++;
        if ((r + g + b) / 3 > 175 && saturation < 0.25) blueScore++;
        samples++;
      }
    }
    brightness /= samples;
    final ratio = blueScore / samples;
    return (ratio > 0.45 && brightness > 60)
        ? PhotoVerdict.pass
        : PhotoVerdict.fail;
  }

  PhotoVerdict _verifyGrass(img.Image photo) {
    var greenish = 0;
    var samples = 0;
    for (var y = 0; y < photo.height; y++) {
      for (var x = 0; x < photo.width; x++) {
        final p = photo.getPixel(x, y);
        if (p.g > p.r * 1.08 && p.g > p.b * 1.08) greenish++;
        samples++;
      }
    }
    return (greenish / samples > 0.35) ? PhotoVerdict.pass : PhotoVerdict.fail;
  }

  PhotoVerdict _verifyBed(img.Image photo) {
    // Reject pocket/blown-out images and flat blank surfaces. Semantic bed
    // recognition is performed separately by ImageLabelService.
    var brightness = 0.0;
    var squared = 0.0;
    var samples = 0;
    for (var y = 0; y < photo.height; y++) {
      for (var x = 0; x < photo.width; x++) {
        final p = photo.getPixel(x, y);
        final value = (p.r + p.g + p.b) / 3;
        brightness += value;
        squared += value * value;
        samples++;
      }
    }
    brightness /= samples;
    final variance = squared / samples - brightness * brightness;
    return (brightness > 40 && brightness < 235 && variance > 180)
        ? PhotoVerdict.pass
        : PhotoVerdict.fail;
  }

  PhotoVerdict _verifyObject(img.Image photo, img.Image reference) {
    final a = _histogram(photo);
    final b = _histogram(reference);
    return _cosineSimilarity(a, b) > 0.60
        ? PhotoVerdict.pass
        : PhotoVerdict.fail;
  }

  /// 4x4x4 RGB histogram, normalized.
  List<double> _histogram(img.Image photo) {
    final bins = List<double>.filled(64, 0);
    for (var y = 0; y < photo.height; y++) {
      for (var x = 0; x < photo.width; x++) {
        final p = photo.getPixel(x, y);
        final index =
            (p.r.toInt() >> 6) * 16 +
            (p.g.toInt() >> 6) * 4 +
            (p.b.toInt() >> 6);
        bins[index]++;
      }
    }
    final total = photo.width * photo.height;
    return [for (final bin in bins) bin / total];
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0;
    return dot / (math.sqrt(normA) * math.sqrt(normB));
  }

  double _saturation(double r, double g, double b) {
    final maxC = math.max(r, math.max(g, b));
    final minC = math.min(r, math.min(g, b));
    return maxC == 0 ? 0 : (maxC - minC) / maxC;
  }
}
