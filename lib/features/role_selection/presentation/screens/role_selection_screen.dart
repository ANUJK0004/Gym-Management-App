import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/enums/app_role.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 32,
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Logo
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_rounded,
                    size: 36,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'SWEATSYNC',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Gym Management & Fitness Companion',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 48),

                Text(
                  'SELECT YOUR ROLE',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 20),

                _RoleCard(
                  role: AppRole.member,
                  icon: Icons.fitness_center_rounded,
                  title: 'Member',
                  description:
                  'Track workouts, nutrition & progress',
                  onTap: () {
                    _openAuthentication(
                      context,
                      AppRole.member,
                    );
                  },
                ),

                const SizedBox(height: 14),

                _RoleCard(
                  role: AppRole.trainer,
                  icon: Icons.directions_run_rounded,
                  title: 'Trainer',
                  description:
                  'Manage clients & schedule sessions',
                  onTap: () {
                    _openAuthentication(
                      context,
                      AppRole.trainer,
                    );
                  },
                ),

                const SizedBox(height: 14),

                _RoleCard(
                  role: AppRole.owner,
                  icon: Icons.settings_rounded,
                  title: 'Owner',
                  description:
                  'Full gym management & analytics',
                  onTap: () {
                    _openAuthentication(
                      context,
                      AppRole.owner,
                    );
                  },
                ),

                const SizedBox(height: 42),

                Text(
                  'v2.1.0 • SweatSync',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAuthentication(
      BuildContext context,
      AppRole role,
      ) {
    if (role == AppRole.member) {
      context.push(
        AppRoutes.login,
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${role.name.toUpperCase()} authentication is coming next.',
        ),
      ),
    );

    // We will connect this to your existing
    // LoginScreen in the next step.
    //
    // For now this intentionally does nothing.
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final AppRole role;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(role);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLG,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: roleColor.withOpacity(0.5),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: roleColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style:
                      AppTextStyles.bodySmall.copyWith(
                        color: roleColor,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _roleColor(AppRole role) {
    switch (role) {
      case AppRole.member:
        return AppColors.primary;

      case AppRole.trainer:
        return Colors.lightBlue;

      case AppRole.owner:
        return Colors.orange;
    }
  }
}