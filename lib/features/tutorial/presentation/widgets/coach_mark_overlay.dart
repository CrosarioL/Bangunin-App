import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../../../app/widgets/primary_button.dart';

/// A single coach-mark step definition.
class CoachMarkStep {
  const CoachMarkStep({
    this.targetKey,
    required this.title,
    required this.body,
    this.bubblePosition = BubblePosition.below,
  });

  final GlobalKey? targetKey;
  final String title;
  final String body;
  final BubblePosition bubblePosition;
}

enum BubblePosition { above, below }

/// Full-screen overlay that spotlights one widget at a time and shows a
/// mascot speech-bubble beside it. Advances through [steps] on tap, then
/// calls [onComplete].
class CoachMarkOverlay extends StatefulWidget {
  const CoachMarkOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  final List<CoachMarkStep> steps;
  final VoidCallback onComplete;

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  late final AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _next() async {
    if (_current + 1 >= widget.steps.length) {
      await _anim.reverse();
      widget.onComplete();
      return;
    }
    await _anim.reverse();
    setState(() => _current++);
    _anim.forward();
  }

  void _skip() async {
    await _anim.reverse();
    widget.onComplete();
  }

  Rect? _targetRect() {
    final key = widget.steps[_current].targetKey;
    if (key == null) return null;
    final ctx = key.currentContext;
    if (ctx == null) return null;
    try {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize || !box.attached) return null;
      final offset = box.localToGlobal(Offset.zero);
      return offset & box.size;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_current];
    final rect = _targetRect();

    // If the target hasn't been fully laid out yet (e.g. during a tab switch
    // or app launch), schedule a rebuild for the next frame so we don't
    // get stuck with a blank dark screen.
    if (rect == null && step.targetKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    final isLast = _current + 1 >= widget.steps.length;
    final screenSize = MediaQuery.sizeOf(context);

    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dark scrim with a spotlight cutout.
            Positioned.fill(
              child: CustomPaint(
                painter: _SpotlightPainter(target: rect, padding: 12),
                child: const SizedBox.expand(),
              ),
            ),
            // Tap the scrim to advance.
            Positioned.fill(
              child: GestureDetector(
                onTap: _next,
                behavior: HitTestBehavior.translucent,
              ),
            ),
            // Skip button in the top-right.
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              right: 16,
              child: GestureDetector(
                onTap: _skip,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Step indicator dots.
            if (widget.steps.length > 1)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.steps.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: active ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: .3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            // The speech bubble + mascot.
            if (rect != null || step.targetKey == null)
              _buildBubble(step, rect, isLast, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(
    CoachMarkStep step,
    Rect? target,
    bool isLast,
    Size screen,
  ) {
    double? top;
    double? bottom;

    if (target == null) {
      top = screen.height / 2 - 160;
    } else {
      final putBelow = step.bubblePosition == BubblePosition.below;
      top = putBelow ? target.bottom + 24 : null;
      bottom = putBelow ? null : screen.height - target.top + 24;
    }

    return Positioned(
      left: 20,
      right: 20,
      top: top,
      bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2550),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: .5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .25),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BanguninMascot(size: 52, flap: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.title,
                        style: const TextStyle(
                          fontFamily: 'Baloo2',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  step.body,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xCCFFFFFF),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: PrimaryButton(
                    onPressed: _next,
                    label: isLast ? 'Got it!' : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({this.target, this.padding = 8});

  final Rect? target;
  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Paint()..color = const Color(0xCC000000);
    if (target == null) {
      canvas.drawRect(Offset.zero & size, scrim);
      return;
    }
    final spotlight = RRect.fromRectAndRadius(
      target!.inflate(padding),
      const Radius.circular(16),
    );
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(spotlight);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, scrim);

    // Subtle glow ring around the spotlight.
    final glow = Paint()
      ..color = AppColors.primary.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(spotlight, glow);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.target != target;
}
