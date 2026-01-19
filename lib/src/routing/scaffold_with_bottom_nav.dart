import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

/// Scaffold wrapper with floating 4-tab bottom navigation bar
/// Modern, translucent design with smooth transitions
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({
    super.key,
    required this.child,
  });

  // 4 Tab Navigation - Yeni yapı
  static const _destinations = [
    _NavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Ana Sayfa',
      path: '/home',
    ),
    _NavDestination(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today_rounded,
      label: 'Takvim',
      path: '/calendar',
    ),
    _NavDestination(
      icon: Icons.apps_outlined,
      selectedIcon: Icons.apps_rounded,
      label: 'Uygulamalar',
      path: '/hub',
    ),
    _NavDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Ayarlar',
      path: '/settings',
    ),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) {
        return i;
      }
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    context.go(_destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            height: 70,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _onItemTapped(context, index),
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primary.withOpacity(0.12),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 400),
            destinations: _destinations.map((dest) {
              return NavigationDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon),
                label: dest.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Navigation destination data class
class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });
}
