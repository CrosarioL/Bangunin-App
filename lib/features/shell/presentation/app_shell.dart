import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/l10n_ext.dart';

/// Bottom-tab scaffold hosting the three top-level destinations. The floating
/// glass capsule leaves the sunset visible all the way to the screen edge.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: shell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
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
              selectedIndex: shell.currentIndex,
              onDestinationSelected: (index) {
                Haptics.selection();
                shell.goBranch(
                  index,
                  initialLocation: index == shell.currentIndex,
                );
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
        ),
      ),
    );
  }
}
