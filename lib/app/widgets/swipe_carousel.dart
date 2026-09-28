import 'package:flutter/material.dart';

import '../../core/utils/haptics.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// One-card-at-a-time horizontal picker, shared by the mission and sound
/// pickers and by onboarding so all of them feel identical.
///
/// Neighbouring cards peek in at the edges (that's what tells people they
/// can swipe) and step back slightly; the focused card sits forward. Tapping
/// a neighbour brings it to the front; tapping the front card calls
/// [onTapFocused]. Dots underneath, or an "n / total" counter past a dozen.
class SwipeCarousel extends StatefulWidget {
  const SwipeCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialPage = 0,
    this.onPageChanged,
    this.onTapFocused,
    this.height = 330,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index, bool focused)
  itemBuilder;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onTapFocused;
  final double height;

  @override
  State<SwipeCarousel> createState() => _SwipeCarouselState();
}

class _SwipeCarouselState extends State<SwipeCarousel> {
  late int _page = widget.initialPage;
  late final _controller = PageController(
    initialPage: widget.initialPage,
    viewportFraction: .84,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.itemCount,
            onPageChanged: (page) {
              Haptics.selection();
              setState(() => _page = page);
              widget.onPageChanged?.call(page);
            },
            itemBuilder: (context, index) {
              final focused = index == _page;
              return AnimatedScale(
                scale: focused ? 1 : .92,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (focused) {
                        widget.onTapFocused?.call(index);
                      } else {
                        _controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    child: widget.itemBuilder(context, index, focused),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _PageIndicator(count: widget.itemCount, active: _page),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    // Past a dozen dots they turn into noise; a counter reads better.
    if (count > 12) {
      return Text(
        '${active + 1} / $count',
        style: Theme.of(
          context,
        ).textTheme.labelLarge!.copyWith(color: Colors.white70),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: .25),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}

/// The small pill in a carousel card's corner: "Current", "Most fun".
class CarouselBadge extends StatelessWidget {
  const CarouselBadge({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCapsule),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: AppColors.nightTop,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
