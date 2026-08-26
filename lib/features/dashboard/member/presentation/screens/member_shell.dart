import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../profile/presentation/screens/profile_screen.dart';
import '../../../../progress/presentation/screens/progress_screen.dart';
import '../../../../workout/presentation/screens/workout_screen.dart';
import '../providers/member_shell_provider.dart';
import '../widgets/dashboard_bottom_nav.dart';
import 'member_home_screen.dart';

class MemberShell extends ConsumerWidget {
  const MemberShell({
    super.key,
  });

  static const List<Widget> _pages = [
    MemberHomeScreen(),
    WorkoutScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(memberNavIndexProvider);

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          ref.read(memberNavIndexProvider.notifier).setIndex(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: DashboardBottomNav(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            ref.read(memberNavIndexProvider.notifier).setIndex(index);
          },
        ),
      ),
    );
  }
}