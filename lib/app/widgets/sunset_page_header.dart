import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'bangunin_mascot.dart';

/// Shared sunrise hero used by non-camera screens. It gives every major route
/// the same visual opening without making their content layouts identical.
class SunsetPageHeader extends StatefulWidget {
  const SunsetPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.wb_twilight_rounded,
    this.mascotPose = MascotPose.happy,
    this.showMascot = true,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final MascotPose mascotPose;
  final bool showMascot;
  final Widget? trailing;

  @override
  State<SunsetPageHeader> createState() => _SunsetPageHeaderState();
}

class _SunsetPageHeaderState extends State<SunsetPageHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _mascotScale;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();
    _fade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0, .62, curve: Curves.easeOut),
    );
    _slide = Tween(
      begin: const Offset(0, .07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
    _mascotScale = Tween(begin: .76, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(.18, 1, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final theme = Theme.of(context);
    final header = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 10, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.nightMid.withValues(alpha: .9),
            AppColors.glass,
            AppColors.sunsetCoral.withValues(alpha: .28),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .13)),
        boxShadow: [
          BoxShadow(
            color: AppColors.nightTop.withValues(alpha: .32),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: .14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: .3),
                    ),
                  ),
                  child: RotationTransition(
                    turns: reduceMotion
                        ? const AlwaysStoppedAnimation(0)
                        : Tween(begin: -.05, end: 0.0).animate(_entrance),
                    child: Icon(widget.icon, color: AppColors.cyan, size: 23),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.title,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.white70,
                      height: 1.3,
                    ),
                  ),
                ],
                if (widget.trailing != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  widget.trailing!,
                ],
              ],
            ),
          ),
          if (widget.showMascot)
            ScaleTransition(
              scale: reduceMotion
                  ? const AlwaysStoppedAnimation(1)
                  : _mascotScale,
              child: BanguninMascot(
                pose: widget.mascotPose,
                size: 100,
                flap: widget.mascotPose == MascotPose.happy,
              ),
            ),
        ],
      ),
    );

    if (reduceMotion) return header;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: header),
    );
  }
}
