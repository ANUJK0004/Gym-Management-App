import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/dashboard/trainer/presentation/providers/trainer_shell_provider.dart';
import '../../domain/entities/trainer_profile.dart';
import 'edit_trainer_profile_sheet.dart';

class TrainerProfileTopBar extends ConsumerWidget {
  const TrainerProfileTopBar({
    super.key,
    required this.profile,
  });

  final TrainerProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ------------------------------------------------
        // 1. BACK BUTTON (<)
        // ------------------------------------------------
        GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              ref.read(trainerNavIndexProvider.notifier).setIndex(0);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF181C26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF262C3A),
                width: 0.8,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),

        // ------------------------------------------------
        // 2. SCREEN TITLE
        // ------------------------------------------------
        const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),

        // ------------------------------------------------
        // 3. EDIT PROFILE BUTTON (PENCIL ICON)
        // ------------------------------------------------
        GestureDetector(
          onTap: () {
            EditTrainerProfileSheet.show(context, profile);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF181C26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF262C3A),
                width: 0.8,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.edit_rounded,
              color: Color(0xFFFB923C), // Amber/Coral pencil color
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
