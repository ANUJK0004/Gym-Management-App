import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../providers/owner_settings_provider.dart';
import '../widgets/admin_account_tile.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: settingsAsync.when(
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },

          error: (error, stackTrace) {
            return Center(
              child: Text(
                'Unable to load settings.\n$error',
                textAlign: TextAlign.center,
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

                      OwnerBusinessHeader(
                        businessName:
                            settings?.gymName ?? 'GymSync Fitness Center',
                        address: settings?.address ?? '123 Fitness Ave, Makati',
                        isVerified: settings?.isVerified ?? true,
                        logoUrl: settings?.logoUrl,
                        onEdit: () {
                          context.push(AppRoutes.ownerGymManagement);
                        },
                      ),

                      const SizedBox(height: 22),

                      OwnerSettingsSection(
                        title: 'GYM OPERATIONS',
                        children: [
                          OwnerSettingsTile(
                            icon: Icons.access_time_rounded,
                            title: 'Operating Hours',
                            value: '5:00 AM - 11:00 PM',
                            onTap: () {},
                          ),

                          OwnerSettingsTile(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            value: settings?.address ?? 'Not set',
                            onTap: () {
                              context.push(AppRoutes.ownerGymManagement);
                            },
                          ),

                          OwnerSettingsTile(
                            icon: Icons.phone_outlined,
                            title: 'Contact Number',
                            value: settings?.phone ?? 'Not set',
                            onTap: () {},
                          ),

                          OwnerSettingsTile(
                            icon: Icons.language_rounded,
                            title: 'Website',
                            value: settings?.website ?? 'Not set',
                            showDivider: false,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      OwnerSettingsSection(
                        title: 'MEMBERSHIP PLANS',
                        children: [
                          MembershipPlanSettingsCard(
                            planName: 'Premium Plan',
                            price: '₹2,800/mo',
                            onTap: () {
                              context.push(AppRoutes.ownerMembershipPlans);
                            },
                          ),

                          MembershipPlanSettingsCard(
                            planName: 'Standard Plan',
                            price: '₹1,800/mo',
                            onTap: () {
                              context.push(AppRoutes.ownerMembershipPlans);
                            },
                          ),

                          MembershipPlanSettingsCard(
                            planName: 'Basic Plan',
                            price: '₹1,200/mo',
                            onTap: () {
                              context.push(AppRoutes.ownerMembershipPlans);
                            },
                          ),

                          MembershipPlanSettingsCard(
                            planName: "Add New Plan",
                            price: "",
                            isAddNew: true,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height:22),

                      OwnerSettingsSection(

                        title:"SYSTEM SETTINGS",

                        children:[

                          SystemSettingSwitchTile(

                            icon: Icons.notifications,

                            title:"Push Notifications",

                            subtitle:"Alerts for new members & payments",

                            value:true,

                            onChanged:(v){},

                          ),

                          SystemSettingSwitchTile(

                            icon: Icons.autorenew,

                            title:"Auto-Renew",

                            subtitle:"Auto-renew expiring memberships",

                            value:true,

                            onChanged:(v){},

                          ),

                          SystemSettingSwitchTile(

                            icon: Icons.dark_mode,

                            title:"Dark Mode",

                            subtitle:"App-wide dark theme",

                            value:true,

                            onChanged:(v){},

                          ),

                          SystemSettingSwitchTile(

                            icon: Icons.build,

                            title:"Maintenance Mode",

                            subtitle:"Restrict member access temporarily",

                            value:false,

                            onChanged:(v){},

                            showDivider:false,

                          ),
                        ],
                      ),

                      const SizedBox(height:22),

                      OwnerSettingsSection(

                        title:"ADMIN ACCOUNT",

                        children:[

                          AdminAccountTile(

                            icon: Icons.lock,

                            title:"Change Password",

                            onTap:(){},

                          ),

                          AdminAccountTile(

                            icon: Icons.groups,

                            title:"Manage Admin Accounts",

                            onTap:(){},

                          ),

                          AdminAccountTile(

                            icon: Icons.receipt_long,

                            title:"Audit Log",

                            onTap:(){},

                          ),

                          AdminAccountTile(

                            icon: Icons.backup,

                            title:"Backup Data",

                            showDivider:false,

                            onTap:(){},

                          ),
                        ],
                      ),

                      const SizedBox(height:26),

                      LogoutButton(

                        onPressed: (){

                          // Sign out later

                        },

                      ),

                      const SizedBox(height:18),

                      Center(

                        child: Text(

                          "GymSync Admin Console v2.1.0",

                          style: AppTextStyles.labelMedium.copyWith(

                            color: AppColors.textSecondary,

                          ),

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
    return Column(
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
    );
  }
}
