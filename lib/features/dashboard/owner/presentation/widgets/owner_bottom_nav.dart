import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class OwnerBottomNav extends StatelessWidget {
  const OwnerBottomNav({
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

      indicatorColor: AppColors.primary,

      height: 72,

      labelBehavior:
      NavigationDestinationLabelBehavior.alwaysShow,

      destinations: [
        NavigationDestination(
          icon: const Icon(
            Icons.dashboard_outlined,
          ),
          selectedIcon: const Icon(
            Icons.dashboard_rounded,
            color: AppColors.textInverse,
          ),
          label: 'Dashboard',
        ),

        NavigationDestination(
          icon: const Icon(
            Icons.groups_outlined,
          ),
          selectedIcon: const Icon(
            Icons.groups_rounded,
            color: AppColors.textInverse,
          ),
          label: 'Members',
        ),

        NavigationDestination(
          icon: const Icon(
            Icons.account_balance_wallet_outlined,
          ),
          selectedIcon: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.textInverse,
          ),
          label: 'Finance',
        ),

        NavigationDestination(
          icon: const Icon(
            Icons.settings_outlined,
          ),
          selectedIcon: const Icon(
            Icons.settings_rounded,
            color: AppColors.textInverse,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}