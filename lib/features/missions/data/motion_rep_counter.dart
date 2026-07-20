import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// Counts exercise reps (squats/pushups) from the accelerometer while the
/// user holds the phone. A rep is one full down-up oscillation: the vertical
/// acceleration magnitude must cross below a low threshold and back above a
/// high threshold, with debouncing so shakes don't count.
class MotionRepCounter {
  MotionRepCounter({
    required this.targetReps,
    Stream<UserAccelerometerEvent>? events,
  }) : _events = events ?? userAccelerometerEventStream();

  final int targetReps;
  final Stream<UserAccelerometerEvent> _events;

  final _repsController = StreamController<int>.broadcast();
  StreamSubscription<UserAccelerometerEvent>? _sub;

  int _reps = 0;
  bool _inDip = false;
  DateTime _lastRepAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const _dipThreshold = 2.4; // m/s^2 below resting.
  static const _riseThreshold = 1.0;
  static const _minRepInterval = Duration(milliseconds: 700);

  Stream<int> get reps => _repsController.stream;

  int get currentReps => _reps;

  bool get isComplete => _reps >= targetReps;

  void start() {
    _sub ??= _events.listen(_onEvent);
  }

  void _onEvent(UserAccelerometerEvent event) {
    if (_reps >= targetReps) return;
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (!_inDip && magnitude > _dipThreshold) {
      _inDip = true;
    } else if (_inDip && magnitude < _riseThreshold) {
      final now = DateTime.now();
      if (now.difference(_lastRepAt) >= _minRepInterval) {
        _reps++;
        _lastRepAt = now;
        _repsController.add(_reps);
      }
      _inDip = false;
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _repsController.close();
  }
}
