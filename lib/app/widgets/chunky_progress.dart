import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A thick, rounded progress bar with a soft inner highlight on the fill —
/// the Duolingo XP-bar look. [value] is 0..1.
class ChunkyProgress extends StatelessWidget {
  const ChunkyProgress({
    super.key,
    required this.value,
    this.height = 16,
    this.color = AppColors.primary,
  });

  final double value;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track = isDark ? AppColors.surfaceEdge : AppColors.surfaceEdgeLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: track,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  heightFactor: 0.4,
                  child: Container(
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(height),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
