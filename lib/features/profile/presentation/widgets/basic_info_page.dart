import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  late final TextEditingController
  _nameController;

  @override
  void initState() {
    super.initState();

    final profile =
    ref.read(profileSetupProvider);

    _nameController =
        TextEditingController(
          text: profile.displayName,
        );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final currentDate =
        ref.read(profileSetupProvider).dateOfBirth;

    final selectedDate =
    await showDatePicker(
      context: context,
      initialDate:
      currentDate ??
          DateTime(
            DateTime.now().year - 18,
          ),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      ref
          .read(profileSetupProvider.notifier)
          .setDateOfBirth(
        selectedDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile =
    ref.watch(profileSetupProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          const Text(
            'Let\'s get to know you',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Tell us a little about yourself '
                'to personalize your fitness journey.',
          ),

          const SizedBox(height: 32),

          TextField(
            controller: _nameController,
            onChanged: (value) {
              ref
                  .read(
                profileSetupProvider
                    .notifier,
              )
                  .setDisplayName(value);
            },
            decoration:
            const InputDecoration(
              labelText: 'Full Name',
              hintText:
              'Enter your full name',
              prefixIcon:
              Icon(Icons.person_outline),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Date of Birth',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          InkWell(
            onTap: _selectDate,
            borderRadius:
            BorderRadius.circular(12),
            child: InputDecorator(
              decoration:
              const InputDecoration(
                prefixIcon:
                Icon(
                  Icons.calendar_today_outlined,
                ),
              ),
              child: Text(
                profile.dateOfBirth == null
                    ? 'Select your date of birth'
                    : '${profile.dateOfBirth!.day}/'
                    '${profile.dateOfBirth!.month}/'
                    '${profile.dateOfBirth!.year}',
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Gender',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  label: 'Male',
                  icon: Icons.male,
                  selected:
                  profile.gender == 'male',
                  onTap: () {
                    ref
                        .read(
                      profileSetupProvider
                          .notifier,
                    )
                        .setGender('male');
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _GenderOption(
                  label: 'Female',
                  icon: Icons.female,
                  selected:
                  profile.gender ==
                      'female',
                  onTap: () {
                    ref
                        .read(
                      profileSetupProvider
                          .notifier,
                    )
                        .setGender('female');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(16),
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          vertical: 20,
        ),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Theme.of(context)
                .colorScheme
                .primary
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}