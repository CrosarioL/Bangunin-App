// Downsizes the master app icon for web use (nav mark + favicon) so it can
// be inlined as a small base64 data URI instead of the old placeholder
// hand-drawn SVG mark.
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final master = img.decodePng(
    File('marketing/brand/kukoo-icon-1024.png').readAsBytesSync(),
  )!;

  final nav = img.copyResize(master, width: 120, height: 120);
  File(
    'marketing/brand/kukoo-icon-120.png',
  ).writeAsBytesSync(img.encodePng(nav));

  final favicon = img.copyResize(master, width: 64, height: 64);
  File(
    'marketing/brand/kukoo-icon-64.png',
  ).writeAsBytesSync(img.encodePng(favicon));

  stdout.writeln('Wrote kukoo-icon-120.png and kukoo-icon-64.png');
}
