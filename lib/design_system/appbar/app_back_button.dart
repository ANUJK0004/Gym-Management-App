import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../features/dashboard/member/presentation/providers/member_shell_provider.dart';
import '../../features/dashboard/owner/presentation/providers/owner_shell_provider.dart';
import '../../features/profile/presentation/providers/current_user_profile_provider.dart';

class AppBackButton extends ConsumerWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.fallbackRoute,
    this.icon = Icons.arrow_back_ios_new_rounded,
    this.iconColor,
  });

  final VoidCallback? onPressed;
  final String? fallbackRoute;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _handleBack(context, ref),
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _handleBack(BuildContext context, WidgetRef ref) {
    if (onPressed != null) {
      onPressed!();
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    if (fallbackRoute != null) {
      if (fallbackRoute == AppRoutes.home) {
        ref.read(memberNavIndexProvider.notifier).setIndex(0);
      } else if (fallbackRoute == AppRoutes.ownerHome) {
        ref.read(ownerNavIndexProvider.notifier).setIndex(0);
      }
      context.go(fallbackRoute!);
      return;
    }

    final role = ref.read(currentUserProfileProvider).value?.role;
    if (role == 'owner') {
      ref.read(ownerNavIndexProvider.notifier).setIndex(0);
      context.go(AppRoutes.ownerHome);
    } else if (role == 'trainer') {
      context.go(AppRoutes.trainerHome);
    } else {
      ref.read(memberNavIndexProvider.notifier).setIndex(0);
      context.go(AppRoutes.home);
    }
  }
}