import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/bangunin_mascot.dart';
import '../../domain/mission_type.dart';

/// Visual identity for one mission. All missions share the same dawn/glass
/// language, but the accent, symbol and coaching copy make the task legible
/// at a glance when someone is still half asleep.
extension MissionExperience on MissionType {
  Color get experienceColor => switch (this) {
    MissionType.skyPhoto || MissionType.squats => AppColors.cyan,
    MissionType.grassPhoto => AppColors.grass,
    MissionType.makeBed => AppColors.sunsetViolet,
    MissionType.objectHunt => AppColors.primary,
    MissionType.pushups => AppColors.sunsetCoral,
    MissionType.none => AppColors.cyan,
  };

  String coachPrompt(BuildContext context) {
    final id = Localizations.localeOf(context).languageCode == 'id';
    return switch (this) {
      MissionType.skyPhoto => id ? 'Sedikit ke atas!' : 'A little higher!',
      MissionType.grassPhoto => id ? 'Dekatkan ke rumput!' : 'Find real grass!',
      MissionType.makeBed =>
        id ? 'Tunjukkan seluruh kasur!' : 'Show the whole bed!',
      MissionType.objectHunt => id ? 'Cocokkan bendanya!' : 'Match the object!',
      MissionType.squats =>
        id ? 'Seluruh badan terlihat!' : 'Keep your full body visible!',
      MissionType.pushups =>
        id ? 'Letakkan ponsel di samping!' : 'Place the phone to your side!',
      MissionType.none => '',
    };
  }
}

class AlarmActivePill extends StatelessWidget {
  const AlarmActivePill({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final id = Localizations.localeOf(context).languageCode == 'id';
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.nightTop.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCapsule),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active
                ? Icons.notifications_active_rounded
                : Icons.visibility_rounded,
            color: active ? AppColors.primary : AppColors.cyan,
            size: 18,
          ),
          const SizedBox(width: 7),
          Text(
            active
                ? (id ? 'Alarm aktif' : 'Alarm active')
                : (id ? 'Mode latihan' : 'Practice'),
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: active ? AppColors.primary : AppColors.cyan,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class MissionGlassPanel extends StatelessWidget {
  const MissionGlassPanel({
    super.key,
    required this.mission,
    required this.title,
    this.subtitle,
    this.status,
    this.statusColor,
    this.statusIcon = Icons.check_circle_rounded,
  });

  final MissionType mission;
  final String title;
  final String? subtitle;
  final String? status;
  final Color? statusColor;
  final IconData statusIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = mission.experienceColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: .12)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .16),
                  shape: BoxShape.circle,
                ),
                child: Icon(mission.icon, color: accent, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (status != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: statusColor ?? accent, size: 21),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  status!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall!.copyWith(
                    color: statusColor ?? accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class MissionGuideFrame extends StatefulWidget {
  const MissionGuideFrame({
    super.key,
    required this.mission,
    this.child,
    this.icon,
  });

  final MissionType mission;
  final Widget? child;
  final IconData? icon;

  @override
  State<MissionGuideFrame> createState() => _MissionGuideFrameState();
}

class _MissionGuideFrameState extends State<MissionGuideFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _search = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1450),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _search
        ..stop()
        ..value = .5;
    } else if (!_search.isAnimating) {
      _search.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.mission.experienceColor;
    return AnimatedBuilder(
      animation: _search,
      builder: (context, _) {
        final pulse = Curves.easeInOut.transform(_search.value);
        return CustomPaint(
          foregroundPainter: _CornerFramePainter(
            accent.withValues(alpha: .68 + pulse * .32),
            strokeWidth: 6 + pulse * 2,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ?widget.child,
              Center(
                child: Transform.scale(
                  scale: .96 + pulse * .08,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.nightTop.withValues(alpha: .32),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: .12 + pulse * .18),
                          blurRadius: 18 + pulse * 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon ?? widget.mission.icon,
                      color: accent,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MissionMascotCoach extends StatelessWidget {
  const MissionMascotCoach({super.key, required this.mission});

  final MissionType mission;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: mission.coachPrompt(context),
      child: SizedBox(
        width: 154,
        height: 126,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 4,
              top: 0,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 112),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primaryDeep),
                ),
                child: Text(
                  mission.coachPrompt(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: AppColors.nightTop,
                    height: 1.05,
                  ),
                ),
              ),
            ),
            const Positioned(
              right: -18,
              bottom: -18,
              child: BanguninMascot(
                pose: MascotPose.happy,
                size: 104,
                animateIdle: false,
                interactive: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerFramePainter extends CustomPainter {
  const _CornerFramePainter(this.color, {this.strokeWidth = 7});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    const corner = 48.0;
    const radius = 22.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, corner)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(corner, 0)
      ..moveTo(size.width - corner, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, corner)
      ..moveTo(size.width, size.height - corner)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(size.width - corner, size.height)
      ..moveTo(corner, size.height)
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, size.height - corner);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerFramePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
