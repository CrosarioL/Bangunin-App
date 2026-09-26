import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/haptics.dart';
import '../theme/app_colors.dart';

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
    this.animateIdle = true,
    this.interactive = true,
    this.tapPose = MascotPose.crowing,
  });

  final MascotPose pose;
  final double size;

  /// Alternate happy/flap-down keyframes for a wing-flap loop.
  final bool flap;

  /// Disable when a parent already owns the meaningful motion (for example,
  /// the alarm pulse or active camera scanner) so two loops do not compete.
  final bool animateIdle;

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
    if (reduceMotion || !widget.animateIdle) {
      _idle.stop();
    } else if (!_idle.isAnimating) {
      _idle.repeat();
    }

    return Semantics(
      button: widget.interactive,
      label: 'Bangunin',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.interactive ? _onTap : null,
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: Listenable.merge([_idle, _bounce]),
            builder: (context, _) {
              // Idle: soft sine bob (and a whisper of tilt) so the bird is
              // never a static sticker.
              final t = _idle.value * 2 * math.pi;
              final canIdle = !reduceMotion && widget.animateIdle;
              final bob = canIdle ? math.sin(t) * widget.size * 0.03 : 0.0;
              final tilt = canIdle ? math.sin(t) * 0.02 : 0.0;

              // Tap reaction: a springy squash-jump.
              final b = Curves.elasticOut.transform(_bounce.value);
              final jump = !reduceMotion && (_reacting || _bounce.isAnimating)
                  ? -widget.size * 0.16 * math.sin(_bounce.value * math.pi)
                  : 0.0;
              final scale = reduceMotion
                  ? 1.0
                  : 1 + (_reacting ? 0.12 * (1 - b) : 0.0);

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
              } else if (widget.flap && canIdle && _idle.value < flapWindow) {
                // Two full beats across the window: wings down on the
                // down-stroke, back up on the recovery.
                final beat = math.sin(_idle.value / flapWindow * 4 * math.pi);
                frame = beat > 0 ? MascotPose.flapDown : widget.pose;
                // The down-stroke pushes the bird up a touch.
                flutterLift = -beat.clamp(0.0, 1.0) * widget.size * 0.03;
              } else {
                frame = widget.pose;
              }

              return SizedBox.square(
                dimension: widget.size,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    if (_reacting && !reduceMotion)
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _MascotSparklePainter(_bounce.value),
                        ),
                      ),
                    Transform.translate(
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
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MascotSparklePainter extends CustomPainter {
  const _MascotSparklePainter(this.progress);

  final double progress;

  static const _colors = [
    AppColors.primary,
    AppColors.cyan,
    AppColors.sunsetCoral,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOutCubic.transform(progress);
    final opacity = math.sin(progress * math.pi).clamp(0.0, 1.0);
    final center = size.center(Offset.zero);
    for (var i = 0; i < 10; i++) {
      final angle = i / 10 * math.pi * 2 - math.pi / 2;
      final radius = size.shortestSide * (.3 + eased * .2);
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final paint = Paint()
        ..color = _colors[i % _colors.length].withValues(alpha: opacity)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      if (i.isEven) {
        canvas.drawCircle(point, 2.5 + (1 - eased) * 2, paint);
      } else {
        final tangent = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(
          point - tangent * 4,
          point + tangent * (5 + eased * 4),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MascotSparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
