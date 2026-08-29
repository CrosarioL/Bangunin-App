// Processes raw mascot pose PNGs (chick on solid navy, from Higgsfield)
// into app-ready assets:
//   1. flood-fills the solid navy background to TRANSPARENT (from the
//      canvas edges, so navy inside the artwork is untouched),
//   2. trims to the content bounding box with a small padding,
//   3. resizes to 512px (app assets) and 280px (web embeds).
//
// Run: dart run tool/process_mascot_poses.dart
// In:  marketing/brand/poses_raw/<name>.png
// Out: assets/mascot/<name>.png (512) + marketing/brand/poses_web/<name>.png (280)
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final rawDir = Directory('marketing/brand/poses_raw');
  final appDir = Directory('assets/mascot')..createSync(recursive: true);
  final webDir = Directory('marketing/brand/poses_web')
    ..createSync(recursive: true);

  for (final entity in rawDir.listSync()) {
    if (entity is! File || !entity.path.endsWith('.png')) continue;
    final name = entity.uri.pathSegments.last;
    // Raw Higgsfield PNGs are opaque RGB (no alpha channel) — force RGBA
    // so setPixel(transparent) actually clears alpha instead of writing
    // black into a non-existent channel.
    final decoded = img.decodePng(entity.readAsBytesSync())!;
    final image = decoded.convert(numChannels: 4);

    _makeBackgroundTransparent(image);
    final trimmed = _trimToContent(image, padding: 40);

    File(
      '${appDir.path}/$name',
    ).writeAsBytesSync(img.encodePng(img.copyResize(trimmed, width: 512)));
    File(
      '${webDir.path}/$name',
    ).writeAsBytesSync(img.encodePng(img.copyResize(trimmed, width: 280)));
    stdout.writeln(
      'Processed $name '
      '(content ${trimmed.width}x${trimmed.height})',
    );
  }
}

/// Flood-fills from every edge pixel: anything within tolerance of the
/// corner color becomes fully transparent. The chick's own palette
/// (yellow/orange/white/black) never matches navy, so only background goes.
void _makeBackgroundTransparent(img.Image image) {
  final corner = image.getPixel(0, 0);
  bool isBackground(img.Pixel p) =>
      (p.r - corner.r).abs() < 26 &&
      (p.g - corner.g).abs() < 26 &&
      (p.b - corner.b).abs() < 26;

  final visited = List.generate(
    image.height,
    (_) => List.filled(image.width, false),
  );
  final queue = <(int, int)>[];

  void seed(int x, int y) {
    if (x < 0 || y < 0 || x >= image.width || y >= image.height) return;
    if (visited[y][x]) return;
    if (!isBackground(image.getPixel(x, y))) return;
    visited[y][x] = true;
    queue.add((x, y));
  }

  for (var x = 0; x < image.width; x++) {
    seed(x, 0);
    seed(x, image.height - 1);
  }
  for (var y = 0; y < image.height; y++) {
    seed(0, y);
    seed(image.width - 1, y);
  }

  final clear = img.ColorRgba8(0, 0, 0, 0);
  while (queue.isNotEmpty) {
    final (x, y) = queue.removeLast();
    image.setPixel(x, y, clear);
    seed(x + 1, y);
    seed(x - 1, y);
    seed(x, y + 1);
    seed(x, y - 1);
  }
}

img.Image _trimToContent(img.Image image, {required int padding}) {
  var minX = image.width, minY = image.height, maxX = 0, maxY = 0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a > 8) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX <= minX || maxY <= minY) return image;
  minX = (minX - padding).clamp(0, image.width - 1);
  minY = (minY - padding).clamp(0, image.height - 1);
  maxX = (maxX + padding).clamp(0, image.width - 1);
  maxY = (maxY + padding).clamp(0, image.height - 1);
  return img.copyCrop(
    image,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
}
