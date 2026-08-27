import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../profile/presentation/screens/profile_screen.dart';
import 'package:sweatsync/features/trainer_schedule/presentation/screens/trainer_schedule_screen.dart';
import '../providers/trainer_shell_provider.dart';
import '../widgets/trainer_bottom_nav.dart';
import 'trainer_clients_screen.dart';
import 'trainer_home_screen.dart';

class TrainerShell extends ConsumerWidget {
  const TrainerShell({super.key});

  static const List<Widget> _screens = [
    TrainerHomeScreen(),
    TrainerScheduleScreen(),
    TrainerClientsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(trainerNavIndexProvider);

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          ref.read(trainerNavIndexProvider.notifier).setIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0F14),
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: TrainerBottomNav(
          currentIndex: currentIndex,
          onChanged: (index) {
            ref.read(trainerNavIndexProvider.notifier).setIndex(index);
          },
        ),
      ),
    );
  }
}