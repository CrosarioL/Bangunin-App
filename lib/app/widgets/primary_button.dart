import 'package:flutter/material.dart';

import '../../core/utils/haptics.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The signature sunrise button. It retains the tactile press and haptic,
/// but uses the yellow-to-amber light of the Bangunin horizon.
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

  /// Quiet variant: surface fill + thin outline, for non-primary actions.
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
    final Color fg;
    if (!_enabled) {
      face = isDark ? AppColors.surfaceRaised : AppColors.surfaceRaisedLight;
      fg = theme.colorScheme.onSurfaceVariant;
    } else if (widget.secondary) {
      face = isDark ? AppColors.surfaceRaised : AppColors.surfaceLight;
      fg = theme.colorScheme.onSurface;
    } else {
      face = AppColors.primary;
      fg = AppColors.onPrimary;
    }

    const height = 56.0;
    // A true pill: radius is half the height, so both ends are full
    // semicircles. (The old raised "lip" slab showed only below the face,
    // flattening the bottom edge into near-square corners.)
    final shape = BorderRadius.circular(height / 2);
    final pressed = _pressed && _enabled;

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
      // Pressing sinks the button slightly and dims it, instead of dropping
      // a face onto a lip.
      child: AnimatedScale(
        scale: pressed ? .97 : 1,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: AnimatedOpacity(
            opacity: pressed ? .88 : 1,
            duration: const Duration(milliseconds: 80),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _enabled && !widget.secondary ? null : face,
                gradient: _enabled && !widget.secondary
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.horizon],
                      )
                    : null,
                borderRadius: shape,
                border: widget.secondary
                    ? Border.all(color: AppColors.cyan.withValues(alpha: .28))
                    : null,
                boxShadow: _enabled && !widget.secondary
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .22),
                          blurRadius: 20,
                        ),
                      ]
                    : null,
              ),
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
        ),
      ),
    );
  }
}
