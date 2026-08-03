import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../member_management/presentation/screens/member_management_screen.dart';
import '../widgets/owner_bottom_nav.dart';
import 'owner_home_screen.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({
    super.key,
  });

  @override
  State<OwnerShell> createState() =>
      _OwnerShellState();
}

class _OwnerShellState
    extends State<OwnerShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = const [
      OwnerHomeScreen(),

      MemberManagementScreen(),

      _OwnerPlaceholderScreen(
        title: 'Finance',
      ),

      _OwnerPlaceholderScreen(
        title: 'Settings',
      ),
    ];
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar:
      OwnerBottomNav(
        currentIndex:
        _currentIndex,

        onChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _OwnerPlaceholderScreen
    extends StatelessWidget {
  const _OwnerPlaceholderScreen({
    required this.title,
  });

  final String title;

  @override
  Widget build(
      BuildContext context,
      ) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }
}