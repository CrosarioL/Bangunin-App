import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The shared sunrise glass card. Content remains high-contrast, while the
/// background color and warm horizon can breathe through the surface.
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

    final face = color ?? (isDark ? AppColors.glass : AppColors.glassLight);
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
                BoxShadow(
                  color: AppColors.nightTop.withValues(alpha: .28),
                  offset: const Offset(0, 10),
                  blurRadius: 28,
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
