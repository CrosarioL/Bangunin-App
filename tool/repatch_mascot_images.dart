// The first mascot injection embedded PNGs that were opaque (no alpha —
// see process_mascot_poses.dart fix), so the chick showed with a black box
// around it on the landing page. This swaps the stale base64 blobs for the
// freshly reprocessed transparent ones without re-running the full
// injection (which refuses to run twice).
//
// Run: dart run tool/repatch_mascot_images.dart
import 'dart:convert';
import 'dart:io';

String uri(String name) =>
    'data:image/png;base64,${base64Encode(File('marketing/brand/poses_web/$name.png').readAsBytesSync())}';

void main() {
  final htmlFile = File('marketing/landing/index.html');
  final html = htmlFile.readAsStringSync();

  final dataUriPattern = RegExp(r'data:image/png;base64,[A-Za-z0-9+/=]+');

  // The page has 8 base64 PNGs total: favicon + logo-mark (untouched),
  // then the 6 mascot ones in order: hero <img>, phone mockup orb <img>,
  // then the JS poses object (happy, flap, crowing, celebrating).
  final replacements = [
    uri('happy'), // hero <img id="hero-mascot">
    uri('crowing'), // phone mockup orb <img>
    uri('happy'), // JS poses.happy
    uri('flap_down'), // JS poses.flap
    uri('crowing'), // JS poses.crowing
    uri('celebrating'), // JS poses.celebrating
  ];
  const skipLeading = 2;

  final matches = dataUriPattern.allMatches(html).toList();
  if (matches.length != replacements.length + skipLeading) {
    stderr.writeln(
        'Expected ${replacements.length + skipLeading} data URIs, found ${matches.length}. Aborting.');
    exit(1);
  }

  final buffer = StringBuffer();
  var last = 0;
  for (var i = 0; i < matches.length; i++) {
    final m = matches[i];
    buffer.write(html.substring(last, m.start));
    buffer.write(i < skipLeading ? m.group(0)! : replacements[i - skipLeading]);
    last = m.end;
  }
  buffer.write(html.substring(last));

  htmlFile.writeAsStringSync(buffer.toString());
  stdout.writeln('Repatched mascot images with transparent PNGs.');
}
