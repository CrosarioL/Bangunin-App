import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A speech bubble for the mascot to "talk" through (Duolingo's Duo does
/// this constantly). A rounded chunky card with a little pointer tail on
/// one side, so the chick can greet, nudge, and celebrate in copy.
class MascotBubble extends StatelessWidget {
  const MascotBubble({
    super.key,
    required this.text,
    this.tail = TailSide.bottom,
  });

  final String text;
  final TailSide tail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final face = isDark ? AppColors.surfaceRaised : AppColors.surfaceLight;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.outlineLight;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: face,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );

    return CustomPaint(
      painter: _TailPainter(color: face, border: border, side: tail),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: tail == TailSide.bottom ? 8 : 0,
          top: tail == TailSide.top ? 8 : 0,
        ),
        child: bubble,
      ),
    );
  }
}

enum TailSide { top, bottom }

class _TailPainter extends CustomPainter {
  _TailPainter({required this.color, required this.border, required this.side});

  final Color color;
  final Color border;
  final TailSide side;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 18.0;
    const h = 9.0;
    final cx = size.width / 2;
    final path = Path();
    if (side == TailSide.bottom) {
      path.moveTo(cx - w / 2, size.height - h);
      path.lineTo(cx + w / 2, size.height - h);
      path.lineTo(cx, size.height);
    } else {
      path.moveTo(cx - w / 2, h);
      path.lineTo(cx + w / 2, h);
      path.lineTo(cx, 0);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) =>
      old.color != color || old.side != side;
}
