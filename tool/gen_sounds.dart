// Generates the bundled alarm sounds as 16-bit mono WAV files.
// Run: dart run tool/gen_sounds.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const sampleRate = 22050;

void main() {
  // Classic: insistent double-beep, 880 Hz.
  writeWav(
    'assets/sounds/classic.wav',
    renderPattern([
      for (var i = 0; i < 4; i++) ...[
        Tone(880, 0.18),
        Silence(0.08),
        Tone(880, 0.18),
        Silence(0.45),
      ],
    ]),
  );

  // Sunrise: gentle rising arpeggio.
  writeWav(
    'assets/sounds/sunrise.wav',
    renderPattern([
      for (final freq in [392.0, 494.0, 587.0, 784.0]) ...[
        Tone(freq, 0.35, fadeIn: 0.05, fadeOut: 0.1),
        Silence(0.1),
      ],
      Silence(0.6),
    ]),
  );

  // Pulse: low urgent thump.
  writeWav(
    'assets/sounds/pulse.wav',
    renderPattern([
      for (var i = 0; i < 6; i++) ...[
        Tone(220, 0.12, fadeOut: 0.08),
        Silence(0.22),
      ],
      Silence(0.4),
    ]),
  );

  stdout.writeln('Wrote assets/sounds/{classic,sunrise,pulse}.wav');
}

sealed class Segment {
  double get seconds;
}

class Tone extends Segment {
  Tone(this.freq, this.seconds, {this.fadeIn = 0.01, this.fadeOut = 0.03});
  final double freq;
  @override
  final double seconds;
  final double fadeIn;
  final double fadeOut;
}

class Silence extends Segment {
  Silence(this.seconds);
  @override
  final double seconds;
}

List<int> renderPattern(List<Segment> segments) {
  final samples = <int>[];
  for (final segment in segments) {
    final count = (segment.seconds * sampleRate).round();
    if (segment is Silence) {
      samples.addAll(List.filled(count, 0));
      continue;
    }
    final tone = segment as Tone;
    for (var i = 0; i < count; i++) {
      final t = i / sampleRate;
      var amp = 0.75;
      final fadeInSamples = tone.fadeIn * sampleRate;
      final fadeOutSamples = tone.fadeOut * sampleRate;
      if (i < fadeInSamples) amp *= i / fadeInSamples;
      if (count - i < fadeOutSamples) amp *= (count - i) / fadeOutSamples;
      samples.add(
        (math.sin(2 * math.pi * tone.freq * t) * amp * 32767).round(),
      );
    }
  }
  return samples;
}

void writeWav(String path, List<int> samples) {
  final dataSize = samples.length * 2;
  final bytes = BytesBuilder();
  void str(String s) => bytes.add(s.codeUnits);
  void u32(int v) => bytes.add(
    Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little),
  );
  void u16(int v) => bytes.add(
    Uint8List(2)..buffer.asByteData().setUint16(0, v, Endian.little),
  );

  str('RIFF');
  u32(36 + dataSize);
  str('WAVE');
  str('fmt ');
  u32(16);
  u16(1); // PCM
  u16(1); // mono
  u32(sampleRate);
  u32(sampleRate * 2);
  u16(2);
  u16(16);
  str('data');
  u32(dataSize);
  final data = Int16List.fromList(samples);
  bytes.add(data.buffer.asUint8List());

  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes.toBytes());
}
