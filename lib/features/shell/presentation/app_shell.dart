import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../alarms/presentation/widgets/alarms_off_gate.dart';
import '../../tutorial/presentation/providers/tutorial_provider.dart';
import '../../tutorial/presentation/widgets/coach_mark_overlay.dart';

/// GlobalKeys exposed so the coach-mark overlay can find the target widgets.
final fabKey = GlobalKey(debugLabel: 'fab');
final streakTabKey = GlobalKey(debugLabel: 'streakTab');
final settingsTabKey = GlobalKey(debugLabel: 'settingsTab');

/// Height of the floating tab bar, and its minimum gap to the screen edge.
const kShellNavHeight = 80.0;
const _kShellNavBottomGap = 10.0;

/// How far a page's floating button must sit above its own bottom edge to
/// clear the floating tab bar (which the pages extend behind), on any phone:
/// the bar's height plus the home-indicator inset it sits on.
double shellFabBottomPadding(BuildContext context) {
  // The device's own inset: inside the page, the shell Scaffold has already
  // consumed it for the tab bar, so the local MediaQuery reports zero.
  final inset = MediaQueryData.fromView(View.of(context)).viewPadding.bottom;
  return kShellNavHeight +
      (inset > _kShellNavBottomGap ? inset : _kShellNavBottomGap);
}

/// Bottom-tab scaffold hosting the three top-level destinations. The floating
/// glass capsule leaves the sunset visible all the way to the screen edge.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    // Two frames: the first lays out the Scaffold + FAB, the second lets
    // the overlay read their GlobalKeys safely.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final done = ref.read(tutorialCompletedProvider);
        if (!done && mounted) {
          setState(() => _showTutorial = true);
        }
      });
    });
  }

  void _onTutorialComplete() {
    ref.read(tutorialCompletedProvider.notifier).markCompleted();
    if (mounted) setState(() => _showTutorial = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(tutorialCompletedProvider, (prev, next) {
      if (prev == true && next == false) {
        setState(() => _showTutorial = true);
      }
    });

    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffold = Scaffold(
      body: widget.shell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, _kShellNavBottomGap),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? AppColors.glass : AppColors.glassLight,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .12)
                  : AppColors.outlineLight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.nightTop.withValues(alpha: .3),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: NavigationBar(
              height: kShellNavHeight,
              selectedIndex: widget.shell.currentIndex,
              onDestinationSelected: (index) {
                Haptics.selection();
                widget.shell.goBranch(
                  index,
                  initialLocation: index == widget.shell.currentIndex,
                );
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.alarm_rounded),
                  label: l10n.tabAlarms,
                ),
                NavigationDestination(
                  key: streakTabKey,
                  icon: const Icon(Icons.local_fire_department_rounded),
                  label: l10n.tabStats,
                ),
                NavigationDestination(
                  key: settingsTabKey,
                  icon: const Icon(Icons.settings_rounded),
                  label: l10n.tabSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!_showTutorial) return AlarmsOffGate(child: scaffold);

    return AlarmsOffGate(
      child: Stack(
        children: [
          scaffold,
          CoachMarkOverlay(
            onComplete: _onTutorialComplete,
            steps: [
              CoachMarkStep(
                targetKey: null,
                title: '\u{1F44B} Welcome to Bangunin!',
                body:
                    'I\'m here to help you build a morning routine you\'ll actually love. Let\'s take a quick tour!',
              ),
              CoachMarkStep(
                targetKey: fabKey,
                title: '\u{271A}  Create your alarm',
                body:
                    'Tap this button to set a new alarm. Pick your time, choose a mission, and you\'re set!',
                bubblePosition: BubblePosition.above,
              ),
              CoachMarkStep(
                targetKey: streakTabKey,
                title: '\u{1F525}  Track your streak',
                body:
                    'See how many days in a row you\'ve woken up on time. Keep the streak alive!',
                bubblePosition: BubblePosition.above,
              ),
              CoachMarkStep(
                targetKey: settingsTabKey,
                title: '\u{2699}\u{FE0F}  Settings & support',
                body:
                    'Find your subscription, privacy policy, terms, and contact support here.',
                bubblePosition: BubblePosition.above,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
