import 'package:flutter/material.dart';

import '../../../../workout/presentation/screens/workout_screen.dart';
import '../widgets/dashboard_bottom_nav.dart';
import 'member_home_screen.dart';
import 'member_progress_screen.dart';
import 'member_profile_screen.dart';

class MemberShell extends StatefulWidget {
  const MemberShell({
    super.key,
  });

  @override
  State<MemberShell> createState() =>
      _MemberShellState();
}

class _MemberShellState
    extends State<MemberShell> {

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MemberHomeScreen(),
    WorkoutScreen(),
    MemberProgressScreen(),
    MemberProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}