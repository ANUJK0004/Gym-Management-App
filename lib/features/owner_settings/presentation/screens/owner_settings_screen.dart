import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';
import 'package:sweatsync/design_system/appbar/app_back_button.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/membership_plan/domain/entities/membership_plan.dart';
import 'package:sweatsync/features/membership_plan/presentation/providers/membership_plan_provider.dart';

import '../providers/owner_settings_provider.dart';
import '../widgets/admin_account_tile.dart';
import '../widgets/audit_log_sheet.dart';
import '../widgets/backup_data_dialog.dart';
import '../widgets/edit_contact_info_sheet.dart';
import '../widgets/edit_operating_hours_sheet.dart';
import '../widgets/logout_button.dart';
import '../widgets/membership_plan_settings_card.dart';
import '../widgets/owner_business_header.dart';
import '../widgets/owner_settings_section.dart';
import '../widgets/owner_settings_tile.dart';
import '../widgets/system_setting_switch_tile.dart';

class OwnerSettingsScreen extends ConsumerWidget {
  const OwnerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(ownerSettingsProvider);
    final plansAsync = ref.watch(ownerMembershipPlansProvider);
    final authUser = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: settingsAsync.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.owner),
              ),
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 44,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unable to load settings.\n$error',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(ownerSettingsStreamProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
          data: (settings) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 20),

                      // 1. BUSINESS PROFILE HEADER
                      OwnerBusinessHeader(
                        businessName:
                            settings?.gymName ?? 'SweatSync Fitness Center',
                        address: settings?.address ?? 'Not provided',
                        isVerified: settings?.isVerified ?? true,
                        logoUrl: settings?.logoUrl,
                        onEdit: () {
                          context.push(AppRoutes.ownerGymManagement);
                        },
                      ),

                      const SizedBox(height: 22),

                      // 2. GYM OPERATIONS SECTION
                      OwnerSettingsSection(
                        title: 'GYM OPERATIONS',
                        children: [
                          OwnerSettingsTile(
                            icon: Icons.access_time_rounded,
                            title: 'Operating Hours',
                            value: settings?.operatingHoursDisplay ??
                                '5:00 AM - 11:00 PM',
                            onTap: () => _openOperatingHoursSheet(
                              context,
                              settings?.operatingHoursDisplay ??
                                  '5:00 AM - 11:00 PM',
                            ),
                          ),
                          OwnerSettingsTile(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            value: settings?.address ?? 'Not set',
                            onTap: () => _openContactSheet(
                              context,
                              ContactEditField.address,
                              settings?.address ?? '',
                            ),
                          ),
                          OwnerSettingsTile(
                            icon: Icons.phone_outlined,
                            title: 'Contact Number',
                            value: settings?.phone ?? 'Not set',
                            onTap: () => _openContactSheet(
                              context,
                              ContactEditField.phone,
                              settings?.phone ?? '',
                            ),
                          ),
                          OwnerSettingsTile(
                            icon: Icons.language_rounded,
                            title: 'Website',
                            value: settings?.website ?? 'Not set',
                            showDivider: false,
                            onTap: () => _openContactSheet(
                              context,
                              ContactEditField.website,
                              settings?.website ?? '',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // 3. MEMBERSHIP PLANS SECTION
                      OwnerSettingsSection(
                        title: 'MEMBERSHIP PLANS',
                        children: _buildMembershipPlanCards(
                          context,
                          plansAsync,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 4. SYSTEM SETTINGS SECTION
                      OwnerSettingsSection(
                        title: 'SYSTEM SETTINGS',
                        children: [
                          SystemSettingSwitchTile(
                            icon: Icons.notifications_outlined,
                            title: 'Push Notifications',
                            subtitle:
                                'Alerts for new members, check-ins & payments',
                            value: settings?.pushNotifications ?? true,
                            onChanged: (v) async {
                              await ref
                                  .read(
                                    ownerSettingsControllerProvider.notifier,
                                  )
                                  .togglePushNotifications(v);
                            },
                          ),
                          SystemSettingSwitchTile(
                            icon: Icons.autorenew_rounded,
                            title: 'Auto-Renew',
                            subtitle: 'Auto-renew expiring active memberships',
                            value: settings?.autoRenew ?? true,
                            onChanged: (v) async {
                              await ref
                                  .read(
                                    ownerSettingsControllerProvider.notifier,
                                  )
                                  .toggleAutoRenew(v);
                            },
                          ),
                          SystemSettingSwitchTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            subtitle: 'App-wide dark neon aesthetic',
                            value: settings?.darkMode ?? true,
                            onChanged: (v) async {
                              await ref
                                  .read(
                                    ownerSettingsControllerProvider.notifier,
                                  )
                                  .toggleDarkMode(v);
                            },
                          ),
                          SystemSettingSwitchTile(
                            icon: Icons.build_outlined,
                            title: 'Maintenance Mode',
                            subtitle: 'Temporarily restrict standard member access',
                            value: settings?.maintenanceMode ?? false,
                            showDivider: false,
                            onChanged: (v) {
                              if (v) {
                                _confirmMaintenanceMode(context, ref);
                              } else {
                                ref
                                    .read(
                                      ownerSettingsControllerProvider.notifier,
                                    )
                                    .toggleMaintenanceMode(false);
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // 5. ADMIN ACCOUNT SECTION
                      OwnerSettingsSection(
                        title: 'ADMIN ACCOUNT',
                        children: [
                          AdminAccountTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Change Password',
                            onTap: () => _confirmChangePassword(
                              context,
                              ref,
                              authUser?.email,
                            ),
                          ),
                          AdminAccountTile(
                            icon: Icons.groups_outlined,
                            title: 'Manage Staff & Trainers',
                            onTap: () {
                              context.push(AppRoutes.ownerTrainerManagement);
                            },
                          ),
                          AdminAccountTile(
                            icon: Icons.receipt_long_rounded,
                            title: 'Audit & Activity Log',
                            onTap: () => _openAuditLogSheet(context),
                          ),
                          AdminAccountTile(
                            icon: Icons.backup_outlined,
                            title: 'Backup Data',
                            showDivider: false,
                            onTap: () => _openBackupDialog(
                              context,
                              settings?.lastBackupAt,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // 6. LOGOUT BUTTON
                      LogoutButton(
                        onPressed: () => _confirmSignOut(context, ref),
                      ),

                      const SizedBox(height: 18),

                      // 7. FOOTER
                      Center(
                        child: Column(
                          children: [
                            Text(
                              '${settings?.gymName ?? 'SweatSync'} Admin Console v2.1.0',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Cloud Connected • All Systems Operational',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textHint,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const AppBackButton(
          fallbackRoute: AppRoutes.ownerHome,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'GymSync Admin Console',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildMembershipPlanCards(
    BuildContext context,
    AsyncValue<List<MembershipPlan>> plansAsync,
  ) {
    return plansAsync.when(
      loading: () => [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.owner),
              ),
            ),
          ),
        ),
      ],
      error: (e, _) => [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unable to load plans: $e',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
      data: (plans) {
        final List<Widget> widgets = [];

        if (plans.isEmpty) {
          widgets.add(
            MembershipPlanSettingsCard(
              planName: 'No plans created yet',
              price: '',
              subtitle: 'Tap below to add your first membership plan',
              isActive: false,
              onTap: () {
                context.push(AppRoutes.ownerMembershipPlans);
              },
            ),
          );
        } else {
          // Take top 4 plans to show in settings preview
          for (int i = 0; i < plans.length && i < 4; i++) {
            final plan = plans[i];
            final durationText = plan.durationInDays >= 30
                ? '${(plan.durationInDays / 30).round()} mo'
                : '${plan.durationInDays}d';

            widgets.add(
              MembershipPlanSettingsCard(
                planName: plan.name,
                price: '₹${plan.price.toInt()}/$durationText',
                subtitle: '${plan.durationInDays} days duration',
                isActive: plan.isActive,
                onTap: () {
                  context.push(AppRoutes.ownerMembershipPlans);
                },
              ),
            );
          }
        }

        // Add New / Manage Plans action tile
        widgets.add(
          MembershipPlanSettingsCard(
            planName: plans.isEmpty
                ? 'Create New Plan'
                : 'Manage & Add Plans (${plans.length})',
            price: '',
            isAddNew: true,
            showDivider: false,
            onTap: () {
              context.push(AppRoutes.ownerMembershipPlans);
            },
          ),
        );

        return widgets;
      },
    );
  }

  void _openOperatingHoursSheet(
    BuildContext context,
    String currentHours,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditOperatingHoursSheet(initialHours: currentHours),
    );
  }

  void _openContactSheet(
    BuildContext context,
    ContactEditField field,
    String currentValue,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditContactInfoSheet(
        field: field,
        currentValue: currentValue,
      ),
    );
  }

  void _openAuditLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuditLogSheet(),
    );
  }

  void _openBackupDialog(BuildContext context, DateTime? lastBackupAt) {
    showDialog(
      context: context,
      builder: (_) => BackupDataDialog(lastBackupAt: lastBackupAt),
    );
  }

  void _confirmMaintenanceMode(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 10),
            Text(
              'Maintenance Mode',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Enabling maintenance mode will notify all gym members and restrict regular app check-ins until turned off. Do you want to proceed?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(ownerSettingsControllerProvider.notifier)
                  .toggleMaintenanceMode(true);
            },
            child: const Text('Enable Maintenance'),
          ),
        ],
      ),
    );
  }

  void _confirmChangePassword(
    BuildContext context,
    WidgetRef ref,
    String? userEmail,
  ) {
    if (userEmail == null || userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No authenticated email address found.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: AppColors.owner),
            const SizedBox(width: 10),
            Text(
              'Reset Password',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'A password reset link will be sent to your registered admin email:\n\n$userEmail\n\nFollow the instructions in the email to set a new password.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.owner,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(authControllerProvider.notifier)
                    .resetPassword(email: userEmail);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password reset email sent to $userEmail',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send reset email: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out from the GymSync Admin Console?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

