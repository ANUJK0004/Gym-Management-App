import 'package:flutter/material.dart';
import 'package:sweatsync/app/theme/app_colors.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,

      backgroundColor: AppColors.surface,

      indicatorColor: AppColors.primary,

      height: 72,

      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      destinations: [
        NavigationDestination(
          icon: const Icon(
            Icons.home_outlined,
          ),
          selectedIcon: const Icon(
            Icons.home,
            color: AppColors.textInverse,
          ),
          label: 'Home',
        ),

        NavigationDestination(
          icon: const Icon(
            Icons.fitness_center_outlined,
          ),
          selectedIcon: const Icon(
            Icons.fitness_center,
            color: AppColors.textInverse,
          ),
          label: 'Workout',
        ),

        NavigationDestination(
          icon: const Icon(
            Icons.show_chart_outlined,
          ),
          selectedIcon: const Icon(
            Icons.show_chart,
            color: AppColors.textInverse,
          ),
          label: 'Progress',
        ),

        NavigationDestination(
          icon: const Icon(
            Icons.person_outline,
          ),
          selectedIcon: const Icon(
            Icons.person,
            color: AppColors.textInverse,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}