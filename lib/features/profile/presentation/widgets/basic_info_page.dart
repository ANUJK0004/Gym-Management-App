import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/design_system/inputs/app_date_picker_field.dart';
import 'package:sweatsync/design_system/inputs/app_text_field.dart';
import 'package:sweatsync/design_system/cards/selection_card.dart';

import '../providers/profile_setup_provider.dart';

class BasicInfoPage extends ConsumerStatefulWidget {
  const BasicInfoPage({
    super.key,
  });

  @override
  ConsumerState<BasicInfoPage> createState() =>
      _BasicInfoPageState();
}

class _BasicInfoPageState
    extends ConsumerState<BasicInfoPage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    final profile = ref.read(profileSetupProvider);

    _nameController = TextEditingController(
      text: profile.displayName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileSetupProvider);
    final notifier = ref.read(
      profileSetupProvider.notifier,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'This information helps us personalize your fitness journey.',
          ),

          const SizedBox(height: 32),

          AppTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            textInputAction: TextInputAction.next,
            onChanged: notifier.setDisplayName,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter your name';
              }

              return null;
            },
          ),

          const SizedBox(height: 24),

          AppDatePickerField(
            label: 'Date of Birth',
            value: profile.dateOfBirth,
            onChanged: (date) {
              if (date != null) {
                notifier.setDateOfBirth(date);
              }
            },
          ),

          const SizedBox(height: 32),

          const Text(
            'Gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Male',
            icon: Icons.male,
            selected: profile.gender == 'Male',
            onTap: () {
              notifier.setGender('Male');
            },
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Female',
            icon: Icons.female,
            selected: profile.gender == 'Female',
            onTap: () {
              notifier.setGender('Female');
            },
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Other',
            icon: Icons.person_outline,
            selected: profile.gender == 'Other',
            onTap: () {
              notifier.setGender('Other');
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}