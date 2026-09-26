// Runs the real photo-mission heuristics over a folder of real photographs
// and prints what each one scored, so the thresholds can be set from evidence
// instead of from fixtures we invented.
//
// Usage:
//   dart run tool/calibrate_missions.dart <folder>
//
// Expected layout — one subfolder per case, named `<mission>_<should>`:
//
//   photos/
//     grass_pass/      real grass, hand in shot
//     grass_fail/      green rug, green shirt, houseplant, painted wall
//     sky_pass/        actual sky, clear and overcast
//     sky_fail/        white ceiling, bright window, pale wall
//     bed_pass/        a made bed
//     bed_fail/        unmade bed, carpet, blank wall
//
// Every JPEG/PNG in each folder is scored. The summary reports how many
// photos land the right way with the current thresholds, so a change can be
// judged rather than guessed.
//
// This runs the *heuristic* half only — Apple Vision needs a device, and its
// contribution is reported separately by the in-app debug path.
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const analysisSize = 128;

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/calibrate_missions.dart <folder>');
    exitCode = 64;
    return;
  }

  final root = Directory(args.first);
  if (!root.existsSync()) {
    stderr.writeln('No such folder: ${root.path}');
    exitCode = 66;
    return;
  }

  var totalCorrect = 0;
  var totalScored = 0;

  for (final entry in root.listSync().whereType<Directory>()) {
    final name = entry.path.split(Platform.pathSeparator).last;
    final parts = name.split('_');
    if (parts.length < 2) continue;
    final mission = parts.first;
    final shouldPass = parts.last == 'pass';

    final photos = entry
        .listSync()
        .whereType<File>()
        .where(
          (f) => const [
            '.jpg',
            '.jpeg',
            '.png',
            '.heic',
          ].any((ext) => f.path.toLowerCase().endsWith(ext)),
        )
        .toList();
    if (photos.isEmpty) continue;

    stdout.writeln(
      '\n=== $name (${photos.length} photos, '
      'expect ${shouldPass ? "PASS" : "FAIL"}) ===',
    );

    var correct = 0;
    for (final photo in photos) {
      final image = await _load(photo.path);
      if (image == null) {
        stdout.writeln('  ${_short(photo.path)}: UNREADABLE');
        continue;
      }

      final metrics = _measure(image);
      final passed = switch (mission) {
        'grass' => metrics.greenRatio > 0.35 && metrics.texture >= 6.0,
        'sky' =>
          metrics.blueRatio > 0.45 ||
              (metrics.overcastRatio > 0.45 && metrics.brightensUpward),
        'bed' =>
          metrics.brightness > 45 &&
              metrics.brightness < 225 &&
              metrics.texture >= 5.0 &&
              metrics.texture <= 45.0,
        _ => false,
      };

      final right = passed == shouldPass;
      if (right) correct++;
      totalScored++;

      stdout.writeln(
        '  ${right ? "ok  " : "MISS"} ${_short(photo.path).padRight(28)} '
        'pass=$passed  bright=${metrics.brightness.toStringAsFixed(1)}  '
        'texture=${metrics.texture.toStringAsFixed(2)}  '
        'green=${metrics.greenRatio.toStringAsFixed(3)}  '
        'blue=${metrics.blueRatio.toStringAsFixed(3)}  '
        'overcast=${metrics.overcastRatio.toStringAsFixed(3)}  '
        'up=${metrics.brightensUpward}',
      );
    }

    totalCorrect += correct;
    stdout.writeln('  --> $correct/${photos.length} correct');
  }

  stdout.writeln('\n========================================');
  stdout.writeln('TOTAL: $totalCorrect/$totalScored correct');
  if (totalScored > 0) {
    final pct = (totalCorrect / totalScored * 100).toStringAsFixed(1);
    stdout.writeln('Accuracy: $pct%');
  }
  stdout.writeln(
    '\nRows marked MISS are where the current thresholds disagree with\n'
    'reality. Tune against these, then re-run. Remember a false FAIL on a\n'
    'real photo is worse than a false PASS on a fake one.',
  );
}

String _short(String path) => path.split(Platform.pathSeparator).last;

Future<img.Image?> _load(String path) async {
  try {
    final decoded = img.decodeImage(await File(path).readAsBytes());
    if (decoded == null) return null;
    final scale = analysisSize / math.max(decoded.width, decoded.height);
    return img.copyResize(
      decoded,
      width: math.max(1, (decoded.width * scale).round()),
      height: math.max(1, (decoded.height * scale).round()),
    );
  } on Exception {
    return null;
  }
}

class _Metrics {
  const _Metrics({
    required this.brightness,
    required this.texture,
    required this.greenRatio,
    required this.blueRatio,
    required this.overcastRatio,
    required this.brightensUpward,
  });

  final double brightness;
  final double texture;
  final double greenRatio;
  final double blueRatio;
  final double overcastRatio;
  final bool brightensUpward;
}

/// Mirrors PhotoMissionVerifier's measurements exactly. If that changes,
/// change this too — a calibration tool that measures something different
/// from the shipping code is worse than no tool at all.
_Metrics _measure(img.Image photo) {
  final topRows = math.max(1, (photo.height * 0.4).floor());
  var greenish = 0;
  var blueLead = 0;
  var brightDesaturated = 0;
  var brightness = 0.0;
  var topBrightness = 0.0;
  var bottomBrightness = 0.0;
  var samples = 0;
  var topSamples = 0;
  var bottomSamples = 0;

  for (var y = 0; y < photo.height; y++) {
    for (var x = 0; x < photo.width; x++) {
      final p = photo.getPixel(x, y);
      final r = p.r.toDouble();
      final g = p.g.toDouble();
      final b = p.b.toDouble();
      final value = (r + g + b) / 3;

      brightness += value;
      samples++;
      if (g > r * 1.08 && g > b * 1.08) greenish++;

      if (y < topRows) {
        topBrightness += value;
        topSamples++;
        if (b > r * 1.05 && b > g * 0.95) blueLead++;
        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
        if (value > 175 && saturation < 0.25) brightDesaturated++;
      } else {
        bottomBrightness += value;
        bottomSamples++;
      }
    }
  }

  var texture = 0.0;
  var textureSamples = 0;
  for (var y = 1; y < photo.height; y++) {
    for (var x = 1; x < photo.width; x++) {
      final p = photo.getPixel(x, y);
      final left = photo.getPixel(x - 1, y);
      final above = photo.getPixel(x, y - 1);
      final value = (p.r + p.g + p.b) / 3;
      texture +=
          ((value - (left.r + left.g + left.b) / 3).abs() +
              (value - (above.r + above.g + above.b) / 3).abs()) /
          2;
      textureSamples++;
    }
  }

  final meanTop = topBrightness / topSamples;
  final meanBottom = bottomSamples == 0
      ? meanTop
      : bottomBrightness / bottomSamples;

  return _Metrics(
    brightness: brightness / samples,
    texture: textureSamples == 0 ? 0 : texture / textureSamples,
    greenRatio: greenish / samples,
    blueRatio: blueLead / topSamples,
    overcastRatio: brightDesaturated / topSamples,
    brightensUpward: meanTop > meanBottom * 1.15,
  );
}
