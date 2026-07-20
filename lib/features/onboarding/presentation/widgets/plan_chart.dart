import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';

/// A 30-day "improvement" curve for the plan-reveal step: an animated
/// ease-out drift from today's (worse) wake time down to the user's goal.
class PlanChart extends StatelessWidget {
  const PlanChart({super.key, required this.nowLabel, required this.goalLabel});

  /// Formatted clock string for the drifted "current" wake time, e.g. "8:10 AM".
  final String nowLabel;

  /// Formatted clock string for the wake goal, e.g. "7:00 AM".
  final String goalLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Semantics(
      label: 'From $nowLabel to $goalLabel in 30 days',
      child: ExcludeSemantics(
        child: SizedBox(
          height: 220,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) {
              return CustomPaint(
                painter: _PlanChartPainter(
                  progress: progress,
                  gridColor: theme.colorScheme.surfaceContainerHighest,
                  axisTextColor: theme.colorScheme.onSurfaceVariant,
                  nowLabel: nowLabel,
                  goalLabel: goalLabel,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.planChartDay1,
                            style: theme.textTheme.labelSmall!.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            l10n.planChartDay30,
                            style: theme.textTheme.labelSmall!.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlanChartPainter extends CustomPainter {
  _PlanChartPainter({
    required this.progress,
    required this.gridColor,
    required this.axisTextColor,
    required this.nowLabel,
    required this.goalLabel,
  });

  final double progress;
  final Color gridColor;
  final Color axisTextColor;
  final String nowLabel;
  final String goalLabel;

  @override
  void paint(Canvas canvas, Size size) {
    // Reserve room at the bottom for the day-axis labels drawn by the
    // Column overlay, and a little at the top for the "now" chip.
    const topInset = 36.0;
    const bottomInset = 40.0;
    final chartHeight = size.height - topInset - bottomInset;
    final chartWidth = size.width;

    final startY = topInset;
    final endY = topInset + chartHeight * 0.55;

    // Faint horizontal grid lines behind the curve.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = topInset + chartHeight * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    Offset pointAt(double t) {
      final x = chartWidth * t;
      // Ease-out cubic drift so the curve falls fast then settles near goal.
      final eased = 1 - (1 - t) * (1 - t) * (1 - t);
      final y = startY + (endY - startY) * eased;
      return Offset(x, y);
    }

    const steps = 60;

    // Clip progressively for the reveal animation.
    final visibleT = progress.clamp(0.0, 1.0).toDouble();
    final linePath = Path()..moveTo(0, startY);
    final visibleSteps = (steps * visibleT).round();
    for (var i = 1; i <= visibleSteps; i++) {
      final t = i / steps;
      final p = pointAt(t);
      linePath.lineTo(p.dx, p.dy);
    }
    final lastPoint = pointAt(visibleT);
    if (visibleSteps < steps) linePath.lineTo(lastPoint.dx, lastPoint.dy);

    // Gradient fill under the visible curve (same shape as the line, closed
    // down to the chart floor).
    final fillPath = Path()..moveTo(0, startY);
    for (var i = 1; i <= visibleSteps; i++) {
      final t = i / steps;
      final p = pointAt(t);
      fillPath.lineTo(p.dx, p.dy);
    }
    if (visibleSteps < steps) fillPath.lineTo(lastPoint.dx, lastPoint.dy);
    fillPath
      ..lineTo(lastPoint.dx, topInset + chartHeight)
      ..lineTo(0, topInset + chartHeight)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.20),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, topInset, chartWidth, chartHeight));
    canvas.drawPath(fillPath, fillPaint);

    // The curve itself.
    final linePaint = Paint()
      ..color = AppColors.primaryDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Dashed goal line.
    final dashPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 1.5;
    const dashWidth = 6.0;
    const dashGap = 5.0;
    var dashX = 0.0;
    while (dashX < chartWidth) {
      canvas.drawLine(
        Offset(dashX, endY),
        Offset((dashX + dashWidth).clamp(0.0, chartWidth), endY),
        dashPaint,
      );
      dashX += dashWidth + dashGap;
    }

    // Start dot ("now").
    final startDotPaint = Paint()..color = AppColors.primaryDeep;
    canvas.drawCircle(Offset(0, startY), 5, startDotPaint);

    // End dot, only once the curve has (nearly) arrived.
    if (visibleT > 0.05) {
      final endDotPaint = Paint()
        ..color = AppColors.success.withValues(alpha: visibleT.clamp(0, 1));
      canvas.drawCircle(lastPoint, 5, endDotPaint);
    }

    _drawChip(canvas, Offset(0, startY - 22), nowLabel, AppColors.primaryDeep);
    if (visibleT > 0.9) {
      _drawChip(
        canvas,
        Offset(chartWidth, endY - 22),
        goalLabel,
        AppColors.success,
        alignRight: true,
      );
    }
  }

  void _drawChip(
    Canvas canvas,
    Offset anchor,
    String text,
    Color color, {
    bool alignRight = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignRight ? anchor.dx - painter.width : anchor.dx;
    painter.paint(canvas, Offset(dx, anchor.dy));
  }

  @override
  bool shouldRepaint(covariant _PlanChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.axisTextColor != axisTextColor ||
        oldDelegate.nowLabel != nowLabel ||
        oldDelegate.goalLabel != goalLabel;
  }
}
