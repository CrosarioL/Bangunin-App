import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/alarm_clip.dart';

extension ClipCategoryArt on ClipCategory {
  /// Each shelf has its own colour, so the picker reads by mood at a glance.
  List<Color> get gradient => switch (this) {
    ClipCategory.loud => const [AppColors.danger, AppColors.sunsetCoral],
    ClipCategory.funny => const [AppColors.primary, AppColors.sunsetCoral],
    ClipCategory.motivation => const [AppColors.cyan, AppColors.sunsetViolet],
    ClipCategory.calm => const [AppColors.grass, AppColors.cyan],
    ClipCategory.seasonal => const [AppColors.sunsetViolet, AppColors.primary],
  };
}

/// The generated card for an audio-only meme alarm: category gradient, big
/// emoji, title. Drawn, not shipped, so a new sound needs no artwork and
/// adds nothing to the download beyond its audio.
///
/// [bounce] (0..1) squashes and lifts the emoji; the ringing screen drives it
/// so the card jumps while the alarm plays.
class ClipArt extends StatelessWidget {
  const ClipArt({
    super.key,
    required this.clip,
    this.large = false,
    this.bounce = 0,
    this.contentAlignment = Alignment.center,
  });

  final AlarmClip clip;
  final bool large;
  final double bounce;

  /// Where the emoji and title sit on the card.
  final Alignment contentAlignment;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final colors = clip.category.gradient;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A soft radial glow keeps the flat gradient from looking empty.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -.2),
                radius: .9,
                colors: [
                  Colors.white.withValues(alpha: .28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(large ? 32 : 10),
            // Wrap at the card's width, then shrink as a whole if a long
            // name (three lines) would overflow a short card.
            child: LayoutBuilder(
              builder: (context, box) => Align(
                alignment: contentAlignment,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: box.maxWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: Offset(0, -bounce * (large ? 28 : 6)),
                          child: Transform.scale(
                            scaleX: 1 + bounce * .08,
                            scaleY: 1 - bounce * .06 + bounce * .14,
                            child: Text(
                              clip.emoji,
                              style: TextStyle(
                                fontSize: large ? 110 : 60,
                                shadows: const [
                                  Shadow(color: Colors.black26, blurRadius: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Small cards sit above their own caption, so the name would
                        // only be shown twice (and truncated). Emoji alone reads better.
                        if (large) ...[
                          const SizedBox(height: 24),
                          Text(
                            clip.title(language).toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.displaySmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen [ClipArt] behind the ringing screen for audio-only clips,
/// bouncing while the alarm rings. Holds still under Reduce Motion: a
/// jumping full-screen image aimed at someone half awake is exactly what
/// that setting is for.
class ClipArtBackground extends StatefulWidget {
  const ClipArtBackground({super.key, required this.clip});

  final AlarmClip clip;

  @override
  State<ClipArtBackground> createState() => _ClipArtBackgroundState();
}

class _ClipArtBackgroundState extends State<ClipArtBackground>
    with SingleTickerProviderStateMixin {
  late final _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _bounce.stop();
      _bounce.value = 0;
    } else if (!_bounce.isAnimating) {
      _bounce.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _bounce,
          // The upper part of the screen; the clock card sits mid-screen.
          builder: (context, _) => ClipArt(
            clip: widget.clip,
            large: true,
            contentAlignment: const Alignment(0, -.72),
            bounce: Curves.easeOut.transform(_bounce.value),
          ),
        ),
        // The whole screen takes the clip's colours, fading to the app's
        // night tone where the clock and stop controls sit.
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.clip.category.gradient.first.withValues(alpha: 0),
                  AppColors.nightTop.withValues(alpha: .35),
                  AppColors.nightTop,
                ],
                stops: const [.35, .6, .85],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
