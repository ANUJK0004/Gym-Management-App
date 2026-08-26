import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../../dashboard/member/presentation/providers/member_dashboard_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/current_user_profile_provider.dart';
import '../providers/profile_edit_provider.dart';

class EditProfileScreen
    extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen>
  createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<EditProfileScreen> {

  late final TextEditingController
  _nameController;

  late final TextEditingController
  _heightController;

  late final TextEditingController
  _weightController;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
          text:
          widget.profile.displayName ??
              '',
        );

    _heightController =
        TextEditingController(
          text: widget.profile.height
              ?.toString() ??
              '',
        );

    _weightController =
        TextEditingController(
          text: widget.profile.weight
              ?.toString() ??
              '',
        );

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      ref
          .read(profileEditProvider.notifier)
          .initialize(
        widget.profile,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    final notifier =
    ref.read(
      profileEditProvider.notifier,
    );

    notifier.setDisplayName(
      _nameController.text,
    );

    notifier.setHeight(
      double.tryParse(
        _heightController.text,
      ),
    );

    notifier.setWeight(
      double.tryParse(
        _weightController.text,
      ),
    );

    try {
      await notifier.saveProfile();

      ref.invalidate(
        currentUserProfileProvider,
      );
      ref.invalidate(
        progressProvider,
      );
      ref.invalidate(
        memberDashboardProvider,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text('Failed to save profile: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(profileEditProvider);

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        title:
        const Text('Edit Profile'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(22),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Text(
                'Personal Information',
                style:
                AppTextStyles.titleMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                _nameController,

                decoration:
                const InputDecoration(
                  labelText:
                  'Display Name',
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Text(
                'Gender',
                style:
                AppTextStyles.bodyMedium,
              ),

              const SizedBox(
                height: 8,
              ),

              DropdownButtonFormField<
                  String>(
                initialValue:
                state.gender,

                decoration:
                const InputDecoration(
                  border:
                  OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'Male',
                    child:
                    Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child:
                    Text('Female'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child:
                    Text('Other'),
                  ),
                ],

                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(
                      profileEditProvider
                          .notifier,
                    )
                        .setGender(value);
                  }
                },
              ),

              const SizedBox(
                height: 24,
              ),

              Text(
                'Body Information',
                style:
                AppTextStyles.titleMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                _heightController,

                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                const InputDecoration(
                  labelText:
                  'Height (cm)',
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                _weightController,

                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                const InputDecoration(
                  labelText:
                  'Weight (kg)',
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Text(
                'Fitness Information',
                style:
                AppTextStyles.titleMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              DropdownButtonFormField<
                  String>(
                initialValue:
                state.fitnessGoal,

                decoration:
                const InputDecoration(
                  labelText:
                  'Fitness Goal',
                ),

                items: const [
                  DropdownMenuItem(
                    value:
                    'Weight Loss',
                    child:
                    Text(
                      'Weight Loss',
                    ),
                  ),
                  DropdownMenuItem(
                    value:
                    'Muscle Gain',
                    child:
                    Text(
                      'Muscle Gain',
                    ),
                  ),
                  DropdownMenuItem(
                    value:
                    'General Fitness',
                    child:
                    Text(
                      'General Fitness',
                    ),
                  ),
                  DropdownMenuItem(
                    value:
                    'Build Muscle',
                    child:
                    Text(
                      'Build Muscle',
                    ),
                  ),
                ],

                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(
                      profileEditProvider
                          .notifier,
                    )
                        .setFitnessGoal(
                      value,
                    );
                  }
                },
              ),

              const SizedBox(
                height: 16,
              ),

              DropdownButtonFormField<
                  String>(
                initialValue:
                state.activityLevel,

                decoration:
                const InputDecoration(
                  labelText:
                  'Activity Level',
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'Beginner',
                    child:
                    Text('Beginner'),
                  ),
                  DropdownMenuItem(
                    value:
                    'Intermediate',
                    child:
                    Text(
                      'Intermediate',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Advanced',
                    child:
                    Text('Advanced'),
                  ),
                ],

                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(
                      profileEditProvider
                          .notifier,
                    )
                        .setActivityLevel(
                      value,
                    );
                  }
                },
              ),

              const SizedBox(
                height: 32,
              ),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed:
                  state.isSaving
                      ? null
                      : _saveProfile,

                  child:
                  state.isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                    ),
                  )
                      : const Text(
                    'Save Changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}