import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../finance/presentation/screens/finance_screen.dart';
import '../../../../member_management/presentation/screens/member_management_screen.dart';
import '../../../../owner_settings/presentation/screens/owner_settings_screen.dart';
import '../providers/owner_shell_provider.dart';
import '../widgets/owner_bottom_nav.dart';
import 'owner_home_screen.dart';

class OwnerShell extends ConsumerWidget {
  const OwnerShell({
    super.key,
  });

  static const List<Widget> _screens = [
    OwnerHomeScreen(),
    MemberManagementScreen(),
    FinanceScreen(),
    OwnerSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(ownerNavIndexProvider);

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          ref.read(ownerNavIndexProvider.notifier).setIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: OwnerBottomNav(
          currentIndex: currentIndex,
          onChanged: (index) {
            ref.read(ownerNavIndexProvider.notifier).setIndex(index);
          },
        ),
      ),
    );
  }
}