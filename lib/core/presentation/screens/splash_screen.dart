import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../features/profile/presentation/providers/current_user_profile_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final role = profileAsync.value?.role;

    Color progressColor;
    switch (role) {
      case 'trainer':
        progressColor = AppColors.trainer;
        break;
      case 'owner':
        progressColor = AppColors.owner;
        break;
      case 'member':
      default:
        progressColor = AppColors.primary;
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
      ),
    );
  }
}