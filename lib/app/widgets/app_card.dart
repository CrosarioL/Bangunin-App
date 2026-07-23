import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The chunky surface container used for every card (Duolingo-style): a flat
/// solid fill, a thick outline, and a hard offset "lip" underneath (a
/// zero-blur shadow) so cards read as physical stacked tiles rather than
/// floating glass. [lip] can be turned off for cards that sit flush.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.lip = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool lip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppSpacing.radiusCard);

    final face =
        color ?? (isDark ? AppColors.surfaceRaised : AppColors.surfaceLight);
    final edge = isDark ? AppColors.surfaceEdge : AppColors.surfaceEdgeLight;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.outlineLight;

    return Container(
      decoration: BoxDecoration(
        color: face,
        borderRadius: radius,
        border: Border.all(color: border, width: 1.5),
        boxShadow: lip
            ? [
                // Hard, un-blurred: a solid slab peeking out the bottom.
                BoxShadow(
                  color: edge,
                  offset: const Offset(0, AppSpacing.cardLip),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      // Transparent Material on top so interactive children (ListTile,
      // InkWell) paint their tap ink here, clipped to the card.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
