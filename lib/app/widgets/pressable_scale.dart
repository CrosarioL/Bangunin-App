import 'package:flutter/material.dart';

import '../../core/utils/haptics.dart';

/// The app's signature micro-interaction: content scales to 96% while
/// pressed with a soft spring back on release, plus a light haptic.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onPressed,
    this.enableHaptics = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool enableHaptics;

  /// Announced by screen readers. Required whenever [child] has no text of
  /// its own (an icon-only tile) — a bare [GestureDetector] exposes no
  /// label, so without this the control is silent to VoiceOver/TalkBack.
  final String? semanticLabel;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    reverseDuration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _scale = Tween<double>(begin: 1, end: 0.96)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
          reverseCurve: Curves.elasticOut,
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gesture = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onPressed == null ? null : (_) => _controller.forward(),
      onTapCancel: () => _controller.reverse(),
      onTapUp: (_) => _controller.reverse(),
      onTap: widget.onPressed == null
          ? null
          : () {
              if (widget.enableHaptics) Haptics.tap();
              widget.onPressed!();
            },
      child: ScaleTransition(scale: _scale, child: widget.child),
    );

    // Callers that pass no label want the default: descendant text/icons
    // keep announcing themselves, unmodified (e.g. a plain text button).
    // Callers that pass one are asserting "this sentence replaces whatever
    // is inside" — so descendants are excluded to avoid a double reading
    // (e.g. AlarmCard supplies one merged summary instead of the card's
    // time/repeat/mission texts each being announced separately).
    final label = widget.semanticLabel;
    if (label == null) return gesture;
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: label,
      child: ExcludeSemantics(child: gesture),
    );
  }
}
