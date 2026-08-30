import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

class AddMemberPersonalStep extends StatelessWidget {
  const AddMemberPersonalStep({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.selectedDateOfBirth,
    required this.selectedGender,
    required this.onDateOfBirthChanged,
    required this.onGenderChanged,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  final DateTime? selectedDateOfBirth;
  final String? selectedGender;

  final ValueChanged<DateTime?> onDateOfBirthChanged;
  final ValueChanged<String?> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('FIRST NAME'),
          const SizedBox(height: 7),
          _field(
            controller: firstNameController,
            hint: 'First name',
          ),

          const SizedBox(height: 12),

          _label('LAST NAME'),
          const SizedBox(height: 7),
          _field(
            controller: lastNameController,
            hint: 'Last name',
          ),

          const SizedBox(height: 12),

          _label('EMAIL ADDRESS'),
          const SizedBox(height: 7),
          _field(
            controller: emailController,
            hint: 'member@email.com',
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 12),

          _label('PHONE NUMBER'),
          const SizedBox(height: 7),
          _field(
            controller: phoneController,
            hint: '+63 XXX XXX XXXX',
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('BIRTHDATE'),
                    const SizedBox(height: 7),
                    _dateField(context),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('GENDER'),
                    const SizedBox(height: 7),
                    _genderSelector(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: const BorderSide(
            color: AppColors.owner,
          ),
        ),
      ),
    );
  }

  Widget _dateField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: selectedDateOfBirth ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.owner,
                ),
              ),
              child: child!,
            );
          },
        );

        if (selected != null) {
          onDateOfBirthChanged(selected);
        }
      },
      borderRadius: AppRadius.radiusMD,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDateOfBirth == null
                    ? 'dd-mm-yyyy'
                    : _formatDate(selectedDateOfBirth!),
                style: TextStyle(
                  color: selectedDateOfBirth == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderSelector() {
    const genders = [
      'Male',
      'Female',
      'Other',
    ];

    return Column(
      children: genders.map((gender) {
        final selected = selectedGender == gender;

        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: InkWell(
            onTap: () => onGenderChanged(gender),
            borderRadius: BorderRadius.circular(9),
            child: Container(
              height: 43,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.owner
                    : AppColors.background,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: selected
                      ? AppColors.owner
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected)
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.radio_button_checked,
                        size: 13,
                        color: Colors.black,
                      ),
                    ),
                  Text(
                    gender,
                    style: TextStyle(
                      color: selected
                          ? Colors.black
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}