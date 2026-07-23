import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/l10n_ext.dart';

/// Bottom-tab scaffold hosting the three top-level destinations. Chunky and
/// solid (Duolingo-style): a flat bar with a thick top edge, no glass.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.surfaceEdge
                  : AppColors.surfaceEdgeLight,
              width: 2,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (index) {
            Haptics.selection();
            shell.goBranch(index, initialLocation: index == shell.currentIndex);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.alarm_rounded),
              label: l10n.tabAlarms,
            ),
            NavigationDestination(
              icon: const Icon(Icons.local_fire_department_rounded),
              label: l10n.tabStats,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_rounded),
              label: l10n.tabSettings,
            ),
          ],
        ),
      ),
    );
  }
}
