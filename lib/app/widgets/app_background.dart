import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// App-wide backdrop. Duolingo-flat: a near-solid fill with only the
/// faintest top-to-bottom shade so screens read as clean, physical
/// surfaces rather than the old ambient-glow glass. Installed once behind
/// the router via MaterialApp.builder; scaffolds stay transparent.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF121B3C), AppColors.background]
              : const [Color(0xFFC4CAE1), AppColors.backgroundLight],
        ),
      ),
      child: child,
    );
  }
}
