import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// Counts deliberate shakes from the accelerometer for the Shake mission.
///
/// A shake is a spike in gravity-free acceleration above [_peak], counted on
/// the way up. The counter then has to fall back below [_rearm] before the
/// next one can count, so one violent jolt is one shake, not five. Waving
/// the phone gently in bed doesn't reach the threshold; the point is that
/// it takes an arm's worth of effort.
class ShakeCounter {
  ShakeCounter({
    required this.target,
    Stream<UserAccelerometerEvent>? events,
    DateTime Function()? clock,
  }) : _events = events ?? userAccelerometerEventStream(),
       _clock = clock ?? DateTime.now;

  final int target;
  final Stream<UserAccelerometerEvent> _events;
  final DateTime Function() _clock;

  final _shakes = StreamController<int>.broadcast();
  StreamSubscription<UserAccelerometerEvent>? _sub;

  int _count = 0;
  bool _armed = true;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const _peak = 14.0; // m/s², gravity removed.
  static const _rearm = 5.0;
  static const _minInterval = Duration(milliseconds: 150);

  Stream<int> get shakes => _shakes.stream;

  int get count => _count;

  bool get isComplete => _count >= target;

  void start() {
    _sub ??= _events.listen(_onEvent);
  }

  void _onEvent(UserAccelerometerEvent event) {
    if (isComplete) return;
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    if (_armed && magnitude >= _peak) {
      final now = _clock();
      if (now.difference(_lastAt) < _minInterval) return;
      _armed = false;
      _lastAt = now;
      _count++;
      _shakes.add(_count);
    } else if (!_armed && magnitude < _rearm) {
      _armed = true;
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _shakes.close();
  }
}
