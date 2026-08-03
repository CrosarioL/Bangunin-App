import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../domain/mission_type.dart';

/// Why a photo mission did or did not pass.
///
/// The user is told the specific reason, never just "failed". A mission you
/// cannot debug at 5am is a mission people uninstall the app over.
enum PhotoFailure {
  /// The file could not be decoded.
  invalidImage,

  /// Too dark to judge anything.
  tooDark,

  /// Blown out, or pointed at a light.
  tooBright,

  /// Flat colour with no texture: a wall, a screen, a duvet in one tone.
  notEnoughTexture,

  /// The dominant colour is right but the surface is not (a green shirt is
  /// green; grass is green *and* noisy at a fine scale).
  surfaceDoesNotLookRight,

  /// Frames in a live capture were identical — a photograph of a photograph,
  /// or the lens is covered.
  sceneNotLive,

  /// Object Hunt: not enough resemblance to the registered reference.
  doesNotMatchReference,

  /// Object Hunt has no reference registered yet.
  missingReference,
}

/// Outcome of verifying a mission photo.
class PhotoVerification {
  const PhotoVerification.pass() : passed = true, failure = null;
  const PhotoVerification.fail(PhotoFailure this.failure) : passed = false;

  final bool passed;
  final PhotoFailure? failure;
}

/// On-device photo checks. No image ever leaves the device and nothing is
/// retained beyond the caller's temporary file.
///
/// **These are heuristics, and the wording around them must stay honest.**
/// They are deliberately built to reject the obvious cheats rather than to
/// claim proof:
///
///  * *Grass* is no longer "enough green pixels" — a green shirt or a painted
///    wall passes that trivially. It now also requires fine-scale texture,
///    which flat coloured surfaces do not have.
///  * *Sky* no longer accepts any bright desaturated frame. The old overcast
///    clause meant a white ceiling passed, so you could complete it without
///    leaving bed. It now requires either genuine blue dominance or an
///    overcast frame that also brightens towards the top of the image.
///  * *Bed* requires structure and a plausible exposure, and is described to
///    the user as a rough check, because that is what it is.
///  * *Object Hunt* compares a 3x3 grid of local histograms rather than one
///    global histogram, so "same room, different angle, object absent" no
///    longer sails through.
///
/// Multi-frame [verifyLive] adds a liveness check: several frames captured a
/// moment apart must differ slightly (hand shake, sensor noise, moving
/// foliage) but not wildly. A photo of a photo is suspiciously identical.
///
/// Known ceiling: none of this is a classifier. It cannot tell grass from a
/// green carpet with a busy weave. See
/// `marketing/research/MISSION_MODEL_EVALUATION.md` for the bundled-model
/// question.
class PhotoMissionVerifier {
  const PhotoMissionVerifier();

  static const _analysisSize = 128;

  /// Frames whose mean absolute difference falls below this are treated as
  /// the same static image rather than a live scene.
  static const _livenessMinDelta = 0.9;

  /// Above this the "frames" are of different scenes entirely.
  static const _livenessMaxDelta = 60.0;

  Future<PhotoVerification> verify(
    MissionType mission,
    String photoPath, {
    String? referencePath,
  }) async {
    final photo = await _load(photoPath);
    if (photo == null) {
      return const PhotoVerification.fail(PhotoFailure.invalidImage);
    }

    switch (mission) {
      case MissionType.skyPhoto:
        return _verifySky(photo);
      case MissionType.grassPhoto:
        return _verifyGrass(photo);
      case MissionType.makeBed:
        return _verifyBed(photo);
      case MissionType.objectHunt:
        if (referencePath == null) {
          return const PhotoVerification.fail(PhotoFailure.missingReference);
        }
        final reference = await _load(referencePath);
        if (reference == null) {
          return const PhotoVerification.fail(PhotoFailure.invalidImage);
        }
        return _verifyObject(photo, reference);
      case MissionType.none:
      case MissionType.squats:
      case MissionType.pushups:
        return const PhotoVerification.fail(PhotoFailure.invalidImage);
    }
  }

  /// Verifies a short burst of frames instead of a single still.
  ///
  /// Every frame must pass the mission check, and the burst as a whole must
  /// look live. This is what makes "point the camera at a picture of grass"
  /// meaningfully harder than it is with one frame.
  Future<PhotoVerification> verifyLive(
    MissionType mission,
    List<String> framePaths, {
    String? referencePath,
  }) async {
    if (framePaths.isEmpty) {
      return const PhotoVerification.fail(PhotoFailure.invalidImage);
    }

    final frames = <img.Image>[];
    for (final path in framePaths) {
      final frame = await _load(path);
      if (frame == null) {
        return const PhotoVerification.fail(PhotoFailure.invalidImage);
      }
      frames.add(frame);
    }

    if (frames.length > 1 && !_looksLive(frames)) {
      return const PhotoVerification.fail(PhotoFailure.sceneNotLive);
    }

    // Every frame must independently satisfy the mission, so a single lucky
    // frame in a burst is not enough.
    for (final path in framePaths) {
      final result = await verify(mission, path, referencePath: referencePath);
      if (!result.passed) return result;
    }
    return const PhotoVerification.pass();
  }

  /// True when consecutive frames differ by a small but non-zero amount.
  bool _looksLive(List<img.Image> frames) {
    for (var i = 1; i < frames.length; i++) {
      final delta = _meanAbsoluteDifference(frames[i - 1], frames[i]);
      if (delta < _livenessMinDelta || delta > _livenessMaxDelta) return false;
    }
    return true;
  }

  double _meanAbsoluteDifference(img.Image a, img.Image b) {
    var total = 0.0;
    var samples = 0;
    for (var y = 0; y < a.height; y++) {
      for (var x = 0; x < a.width; x++) {
        final p = a.getPixel(x, y);
        final q = b.getPixel(x, y);
        total +=
            ((p.r - q.r).abs() + (p.g - q.g).abs() + (p.b - q.b).abs()) / 3;
        samples++;
      }
    }
    return samples == 0 ? 0 : total / samples;
  }

  Future<img.Image?> _load(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return await compute(_decodeAndResize, bytes);
    } on Exception {
      return null;
    }
  }

  static img.Image? _decodeAndResize(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    // Preserve aspect ratio; a square squash distorts the local-texture
    // measurements the grass and bed checks depend on.
    final scale = _analysisSize / math.max(decoded.width, decoded.height);
    return img.copyResize(
      decoded,
      width: math.max(1, (decoded.width * scale).round()),
      height: math.max(1, (decoded.height * scale).round()),
    );
  }

  PhotoVerification _verifySky(img.Image photo) {
    final topRows = math.max(1, (photo.height * 0.4).floor());
    var blueLead = 0;
    var brightDesaturated = 0;
    var topBrightness = 0.0;
    var bottomBrightness = 0.0;
    var topSamples = 0;
    var bottomSamples = 0;

    for (var y = 0; y < photo.height; y++) {
      for (var x = 0; x < photo.width; x++) {
        final p = photo.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final value = (r + g + b) / 3;

        if (y < topRows) {
          topBrightness += value;
          topSamples++;
          if (b > r * 1.05 && b > g * 0.95) blueLead++;
          if (value > 175 && _saturation(r, g, b) < 0.25) brightDesaturated++;
        } else {
          bottomBrightness += value;
          bottomSamples++;
        }
      }
    }

    final meanTop = topBrightness / topSamples;
    if (meanTop < 60) {
      return const PhotoVerification.fail(PhotoFailure.tooDark);
    }

    final blueRatio = blueLead / topSamples;
    if (blueRatio > 0.45) return const PhotoVerification.pass();

    // Overcast sky: bright and desaturated is not enough on its own, or a
    // white ceiling passes and the mission can be completed in bed. Real sky
    // gets brighter towards the top of the frame; a ceiling does not.
    final overcastRatio = brightDesaturated / topSamples;
    final meanBottom = bottomSamples == 0
        ? meanTop
        : bottomBrightness / bottomSamples;
    final brightensUpward = meanTop > meanBottom * 1.15;

    if (overcastRatio > 0.45 && brightensUpward) {
      return const PhotoVerification.pass();
    }
    return const PhotoVerification.fail(PhotoFailure.surfaceDoesNotLookRight);
  }

  PhotoVerification _verifyGrass(img.Image photo) {
    var greenish = 0;
    var samples = 0;
    var brightness = 0.0;

    for (var y = 0; y < photo.height; y++) {
      for (var x = 0; x < photo.width; x++) {
        final p = photo.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        brightness += (r + g + b) / 3;
        if (g > r * 1.08 && g > b * 1.08) greenish++;
        samples++;
      }
    }

    brightness /= samples;
    if (brightness < 35) {
      return const PhotoVerification.fail(PhotoFailure.tooDark);
    }
    if (brightness > 235) {
      return const PhotoVerification.fail(PhotoFailure.tooBright);
    }
    if (greenish / samples <= 0.35) {
      return const PhotoVerification.fail(PhotoFailure.surfaceDoesNotLookRight);
    }

    // Green alone is a shirt, a wall, a notebook. Grass is green *and* busy —
    // it has fine detail at the scale of blades and clumps, which flat
    // surfaces do not.
    //
    // Only texture gates the result. A hue-spread gate was tried and removed:
    // there is no real-capture data here to calibrate it against, so any
    // threshold would have been fitted to a synthetic fixture and would prove
    // nothing about actual grass. Wrongly rejecting someone standing on real
    // grass at 5am is a far worse failure than occasionally accepting a busy
    // green rug, so the conservative choice is to leave it out until it can
    // be calibrated on device.
    //
    // 6.0 is a starting value, NOT a validated one — see the calibration note
    // in marketing/research/MISSION_MODEL_EVALUATION.md before trusting it.
    final texture = _localContrast(photo);
    if (texture < 6.0) {
      return const PhotoVerification.fail(PhotoFailure.notEnoughTexture);
    }
    return const PhotoVerification.pass();
  }

  PhotoVerification _verifyBed(img.Image photo) {
    var brightness = 0.0;
    var samples = 0;
    for (var y = 0; y < photo.height; y++) {
      for (var x = 0; x < photo.width; x++) {
        final p = photo.getPixel(x, y);
        brightness += (p.r + p.g + p.b) / 3;
        samples++;
      }
    }
    brightness /= samples;

    if (brightness < 45) {
      return const PhotoVerification.fail(PhotoFailure.tooDark);
    }
    if (brightness > 225) {
      return const PhotoVerification.fail(PhotoFailure.tooBright);
    }

    // A made bed is a large, smooth-but-not-blank surface with edges where
    // the covers meet. Reject both blank frames (pointed at a wall) and
    // extremely busy ones (clutter, or a shot of the floor).
    final texture = _localContrast(photo);
    if (texture < 5.0 || texture > 45.0) {
      return const PhotoVerification.fail(PhotoFailure.notEnoughTexture);
    }
    return const PhotoVerification.pass();
  }

  PhotoVerification _verifyObject(img.Image photo, img.Image reference) {
    // A single global histogram is dominated by wall, floor and lighting, so
    // two shots of the same room match even with the object absent. Comparing
    // a 3x3 grid keeps some spatial information and forces the match to be
    // local as well as overall.
    final similarities = <double>[];
    for (var row = 0; row < 3; row++) {
      for (var column = 0; column < 3; column++) {
        similarities.add(
          _cosineSimilarity(
            _histogram(photo, row, column),
            _histogram(reference, row, column),
          ),
        );
      }
    }
    similarities.sort();
    // Median cell similarity, so one matching corner cannot carry the frame.
    final median = similarities[similarities.length ~/ 2];
    return median > 0.80
        ? const PhotoVerification.pass()
        : const PhotoVerification.fail(PhotoFailure.doesNotMatchReference);
  }

  /// Mean absolute luminance difference between neighbouring pixels — a
  /// cheap stand-in for "how much fine detail is in this frame".
  double _localContrast(img.Image photo) {
    var total = 0.0;
    var samples = 0;
    for (var y = 1; y < photo.height; y++) {
      for (var x = 1; x < photo.width; x++) {
        final p = photo.getPixel(x, y);
        final left = photo.getPixel(x - 1, y);
        final above = photo.getPixel(x, y - 1);
        final value = (p.r + p.g + p.b) / 3;
        total +=
            ((value - (left.r + left.g + left.b) / 3).abs() +
                (value - (above.r + above.g + above.b) / 3).abs()) /
            2;
        samples++;
      }
    }
    return samples == 0 ? 0 : total / samples;
  }

  /// Normalized 4x4x4 RGB histogram of one cell of a 3x3 grid.
  List<double> _histogram(img.Image photo, int row, int column) {
    final bins = List<double>.filled(64, 0);
    final cellWidth = photo.width ~/ 3;
    final cellHeight = photo.height ~/ 3;
    final startX = column * cellWidth;
    final startY = row * cellHeight;
    var total = 0;

    for (var y = startY; y < startY + cellHeight && y < photo.height; y++) {
      for (var x = startX; x < startX + cellWidth && x < photo.width; x++) {
        final p = photo.getPixel(x, y);
        final index =
            (p.r.toInt() >> 6) * 16 +
            (p.g.toInt() >> 6) * 4 +
            (p.b.toInt() >> 6);
        bins[index]++;
        total++;
      }
    }
    if (total == 0) return bins;
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
