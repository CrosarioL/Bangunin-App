import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// App-wide dawn backdrop: deep pre-sunrise navy, a warm horizon and soft
/// atmospheric shapes. It gives every route one recognizable Bangunin
/// world while camera missions are free to replace it with their live feed.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, .48, .78, 1],
              colors: isDark
                  ? const [
                      AppColors.nightTop,
                      AppColors.nightMid,
                      Color(0xFFB45B5C),
                      AppColors.background,
                    ]
                  : const [
                      Color(0xFF84C9F5),
                      Color(0xFFFFD6A2),
                      Color(0xFFFFB36B),
                      Color(0xFFAEB6D4),
                    ],
            ),
          ),
        ),
        IgnorePointer(child: CustomPaint(painter: _DawnPainter(isDark))),
        child,
      ],
    );
  }
}

class _DawnPainter extends CustomPainter {
  const _DawnPainter(this.isDark);

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: isDark ? .28 : .46),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .78, size.height * .66),
              radius: size.width * .62,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * .78, size.height * .66),
      size.width * .62,
      glow,
    );

    final haze = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? .055 : .16);
    for (var i = 0; i < 5; i++) {
      final x = size.width * (.08 + i * .23);
      final y = size.height * (.2 + math.sin(i * 1.8) * .07);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: size.width * .32,
          height: size.height * .035,
        ),
        haze,
      );
    }

    final ridge = Path()
      ..moveTo(0, size.height * .79)
      ..lineTo(size.width * .18, size.height * .7)
      ..lineTo(size.width * .38, size.height * .78)
      ..lineTo(size.width * .62, size.height * .67)
      ..lineTo(size.width, size.height * .8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      ridge,
      Paint()..color = AppColors.nightTop.withValues(alpha: isDark ? .5 : .2),
    );
  }

  @override
  bool shouldRepaint(_DawnPainter oldDelegate) => oldDelegate.isDark != isDark;
}
