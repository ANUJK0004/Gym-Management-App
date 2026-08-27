import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class TrainerBottomNav extends StatelessWidget {
  const TrainerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onChanged,
      backgroundColor: AppColors.surface,
      indicatorColor: const Color(0xFF38BDF8),
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.assignment_outlined,
          ),
          selectedIcon: Icon(
            Icons.assignment_rounded,
            color: AppColors.textInverse,
          ),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.calendar_month_outlined,
          ),
          selectedIcon: Icon(
            Icons.calendar_month_rounded,
            color: AppColors.textInverse,
          ),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.fitness_center_outlined,
          ),
          selectedIcon: Icon(
            Icons.fitness_center_rounded,
            color: AppColors.textInverse,
          ),
          label: 'Clients',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person_outline_rounded,
          ),
          selectedIcon: Icon(
            Icons.person_rounded,
            color: AppColors.textInverse,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
