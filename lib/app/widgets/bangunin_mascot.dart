import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/haptics.dart';

/// Mascot poses shipped as transparent PNGs in assets/mascot/.
enum MascotPose {
  happy('assets/mascot/happy.png'),
  flapDown('assets/mascot/flap_down.png'),
  sleeping('assets/mascot/sleeping.png'),
  crowing('assets/mascot/crowing.png'),
  celebrating('assets/mascot/celebrating.png');

  const MascotPose(this.assetPath);

  final String assetPath;
}

/// The living Bangunin chick.
///
/// Always idles with a gentle bob; [flap] additionally alternates between
/// the happy and wing-down keyframes so the bird visibly flaps. Tapping it
/// bounces the chick with a haptic and briefly swaps to [tapPose]
/// (defaults to crowing — poke the bird, it crows).
class BanguninMascot extends StatefulWidget {
  const BanguninMascot({
    super.key,
    this.pose = MascotPose.happy,
    this.size = 140,
    this.flap = false,
    this.interactive = true,
    this.tapPose = MascotPose.crowing,
  });

  final MascotPose pose;
  final double size;

  /// Alternate happy/flap-down keyframes for a wing-flap loop.
  final bool flap;

  /// Whether tapping triggers the bounce + [tapPose] reaction.
  final bool interactive;

  final MascotPose tapPose;

  @override
  State<BanguninMascot> createState() => _BanguninMascotState();
}

class _BanguninMascotState extends State<BanguninMascot>
    with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );

  bool _reacting = false;

  @override
  void dispose() {
    _idle.dispose();
    _bounce.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (!widget.interactive || _reacting) return;
    Haptics.tap();
    setState(() => _reacting = true);
    await _bounce.forward(from: 0);
    if (!mounted) return;
    setState(() => _reacting = false);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _idle.stop();
    } else if (!_idle.isAnimating) {
      _idle.repeat();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.interactive ? _onTap : null,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: Listenable.merge([_idle, _bounce]),
          builder: (context, _) {
            // Idle: soft sine bob (and a whisper of tilt) so the bird is
            // never a static sticker.
            final t = _idle.value * 2 * math.pi;
            final bob = reduceMotion ? 0.0 : math.sin(t) * widget.size * 0.03;
            final tilt = reduceMotion ? 0.0 : math.sin(t) * 0.02;

            // Tap reaction: a springy squash-jump.
            final b = Curves.elasticOut.transform(_bounce.value);
            final jump = _reacting || _bounce.isAnimating
                ? -widget.size * 0.16 * math.sin(_bounce.value * math.pi)
                : 0.0;
            final scale = 1 + (_reacting ? 0.12 * (1 - b) : 0.0);

            // Frame selection: reaction pose wins; otherwise the bird gives
            // two slow, deliberate wing-beats near the top of each idle
            // cycle, then rests. Swapping the two frames rapidly strobes —
            // it reads as spasming rather than flapping — so each beat is
            // held long enough to look like real wing movement.
            const flapWindow = 0.36;
            final MascotPose frame;
            var flutterLift = 0.0;
            if (_reacting) {
              frame = widget.tapPose;
            } else if (widget.flap &&
                !reduceMotion &&
                _idle.value < flapWindow) {
              // Two full beats across the window: wings down on the
              // down-stroke, back up on the recovery.
              final beat = math.sin(_idle.value / flapWindow * 4 * math.pi);
              frame = beat > 0 ? MascotPose.flapDown : widget.pose;
              // The down-stroke pushes the bird up a touch.
              flutterLift = -beat.clamp(0.0, 1.0) * widget.size * 0.03;
            } else {
              frame = widget.pose;
            }

            return Transform.translate(
              offset: Offset(0, bob + jump + flutterLift),
              child: Transform.rotate(
                angle: tilt,
                child: Transform.scale(
                  scale: scale,
                  child: Image.asset(
                    frame.assetPath,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
