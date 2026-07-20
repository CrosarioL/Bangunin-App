import 'package:flutter/material.dart';

import '../../core/utils/haptics.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The signature chunky push-button (Duolingo-style): a flat bold face
/// sitting on a solid darker "lip". Pressing it drops the face down onto
/// the lip so it physically compresses, with a haptic. No gradients, no
/// blur — deliberately toy-like and satisfying to hit.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.secondary = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  /// Quiet variant: surface face + outline lip, for non-primary actions.
  final bool secondary;

  final IconData? icon;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => !widget.loading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final Color face;
    final Color lip;
    final Color fg;
    if (!_enabled) {
      face = isDark ? AppColors.surfaceRaised : AppColors.surfaceRaisedLight;
      lip = isDark ? AppColors.surfaceEdge : AppColors.surfaceEdgeLight;
      fg = theme.colorScheme.onSurfaceVariant;
    } else if (widget.secondary) {
      face = isDark ? AppColors.surfaceRaised : AppColors.surfaceLight;
      lip = isDark ? AppColors.surfaceEdge : AppColors.surfaceEdgeLight;
      fg = theme.colorScheme.onSurface;
    } else {
      face = AppColors.primary;
      lip = AppColors.primaryEdge;
      fg = AppColors.onPrimary;
    }

    const faceHeight = 56.0;
    final radius = BorderRadius.circular(AppSpacing.radiusButton);
    final dropped = _pressed && _enabled;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _enabled
          ? () {
              Haptics.commit();
              widget.onPressed!();
            }
          : null,
      child: SizedBox(
        height: faceHeight + AppSpacing.buttonLip,
        width: double.infinity,
        child: Stack(
          children: [
            // The lip: a solid darker slab the face rests on.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: lip, borderRadius: radius),
              ),
            ),
            // The face: drops down onto the lip when pressed.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: dropped ? AppSpacing.buttonLip : 0,
              height: faceHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: face, borderRadius: radius),
                child: Center(
                  child: widget.loading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(fg),
                          ),
                        )
                      // scaleDown keeps a long CTA label on one line by
                      // shrinking it rather than overflowing the button.
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(widget.icon, color: fg, size: 22),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                Text(
                                  widget.label,
                                  style: theme.textTheme.titleSmall!.copyWith(
                                    color: fg,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
