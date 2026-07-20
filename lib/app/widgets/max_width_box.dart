import 'package:flutter/widgets.dart';

/// Centers [child] and caps its width once the viewport grows past a phone
/// size. Without this, every screen stretches edge-to-edge on iPad — cards,
/// body text and survey options at 1024pt wide read as unfinished rather
/// than "optimized for iPad" (a claim this product makes explicitly).
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({super.key, required this.child, this.maxWidth = 560});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
