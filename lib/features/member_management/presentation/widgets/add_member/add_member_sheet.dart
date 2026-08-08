import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../../../gym/presentation/providers/gym_provider.dart';
import '../../providers/member_enrollment_provider.dart';
import '../../providers/member_management_provider.dart';

class AddMemberSheet extends ConsumerStatefulWidget {
  const AddMemberSheet({
    super.key,
  });

  @override
  ConsumerState<AddMemberSheet> createState() =>
      _AddMemberSheetState();
}

class _AddMemberSheetState
    extends ConsumerState<AddMemberSheet> {
  final _formKey =
  GlobalKey<FormState>();

  final _firstNameController =
  TextEditingController();

  final _lastNameController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  final _phoneController =
  TextEditingController();

  DateTime? _dateOfBirth;

  String? _gender;

  String? _fitnessGoal;

  DateTime _startDate =
  DateTime.now();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomInset,
        ),
        child: Material(
          color: AppColors.background,
          borderRadius:
          const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.fromLTRB(
              22,
              12,
              22,
              28,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildHandle(),

                  const SizedBox(
                    height: 18,
                  ),

                  _buildHeader(),

                  const SizedBox(
                    height: 26,
                  ),

                  _buildSectionTitle(
                    'Personal Information',
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller:
                          _firstNameController,
                          label:
                          'First name',
                          hint:
                          'John',
                          icon:
                          Icons
                              .person_outline_rounded,
                          validator:
                          _requiredValidator(
                            'First name',
                          ),
                          textCapitalization:
                          TextCapitalization
                              .words,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: _buildTextField(
                          controller:
                          _lastNameController,
                          label:
                          'Last name',
                          hint:
                          'Doe',
                          icon:
                          Icons
                              .person_outline_rounded,
                          validator:
                          _requiredValidator(
                            'Last name',
                          ),
                          textCapitalization:
                          TextCapitalization
                              .words,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildTextField(
                    controller:
                    _emailController,
                    label:
                    'Email',
                    hint:
                    'john@example.com',
                    icon:
                    Icons.email_outlined,
                    keyboardType:
                    TextInputType.emailAddress,
                    validator:
                    _emailValidator,
                    textInputAction:
                    TextInputAction.next,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildTextField(
                    controller:
                    _phoneController,
                    label:
                    'Phone',
                    hint:
                    'Phone number',
                    icon:
                    Icons.phone_outlined,
                    keyboardType:
                    TextInputType.phone,
                    validator:
                    _optionalPhoneValidator,
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _buildDateField(
                    label:
                    'Date of birth',
                    value:
                    _dateOfBirth,
                    icon:
                    Icons
                        .calendar_today_outlined,
                    onTap:
                    _selectDateOfBirth,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildDropdown<String>(
                    label:
                    'Gender',
                    value:
                    _gender,
                    hint:
                    'Select gender',
                    icon:
                    Icons
                        .person_outline_rounded,
                    items: const [
                      DropdownMenuItem(
                        value: 'male',
                        child:
                        Text('Male'),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child:
                        Text('Female'),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child:
                        Text('Other'),
                      ),
                    ],
                    onChanged:
                        (value) {
                      setState(() {
                        _gender =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildDropdown<String>(
                    label:
                    'Fitness goal',
                    value:
                    _fitnessGoal,
                    hint:
                    'Select fitness goal',
                    icon:
                    Icons
                        .fitness_center_outlined,
                    items: const [
                      DropdownMenuItem(
                        value:
                        'weight_loss',
                        child:
                        Text(
                          'Weight Loss',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                        'muscle_gain',
                        child:
                        Text(
                          'Muscle Gain',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                        'general_fitness',
                        child:
                        Text(
                          'General Fitness',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                        'strength',
                        child:
                        Text(
                          'Strength',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                        'endurance',
                        child:
                        Text(
                          'Endurance',
                        ),
                      ),
                    ],
                    onChanged:
                        (value) {
                      setState(() {
                        _fitnessGoal =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  _buildSectionTitle(
                    'Membership',
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildMembershipPlaceholder(),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildDateField(
                    label:
                    'Membership start date',
                    value:
                    _startDate,
                    icon:
                    Icons
                        .event_available_outlined,
                    onTap:
                    _selectStartDate,
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color:
          AppColors.textSecondary
              .withOpacity(0.25),
          borderRadius:
          BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color:
            AppColors.primary
                .withOpacity(0.12),
            borderRadius:
            AppRadius.radiusMD,
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color:
            AppColors.primary,
          ),
        ),

        const SizedBox(
          width: 14,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Add Member',
                style:
                AppTextStyles
                    .headlineMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Create a new membership enrollment',
                style:
                AppTextStyles
                    .bodySmall
                    .copyWith(
                  color:
                  AppColors
                      .textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // SECTION
  // ----------------------------------------------------------

  Widget _buildSectionTitle(
      String title,
      ) {
    return Text(
      title,
      style:
      AppTextStyles.titleMedium.copyWith(
        fontWeight:
        FontWeight.w800,
      ),
    );
  }

  // ----------------------------------------------------------
  // TEXT FIELD
  // ----------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController
    controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)?
    validator,
    TextInputType? keyboardType,
    TextInputAction?
    textInputAction,
    TextCapitalization
    textCapitalization =
        TextCapitalization.none,
  }) {
    return TextFormField(
      controller:
      controller,
      validator:
      validator,
      keyboardType:
      keyboardType,
      textInputAction:
      textInputAction,
      textCapitalization:
      textCapitalization,
      decoration:
      _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
      Icon(
        icon,
        size: 20,
      ),
      filled: true,
      fillColor:
      AppColors.surface,
      border:
      OutlineInputBorder(
        borderRadius:
        AppRadius.radiusMD,
        borderSide:
        BorderSide(
          color:
          AppColors.border,
        ),
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        AppRadius.radiusMD,
        borderSide:
        BorderSide(
          color:
          AppColors.border,
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        AppRadius.radiusMD,
        borderSide:
        const BorderSide(
          color:
          AppColors.primary,
          width: 1.4,
        ),
      ),
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        AppRadius.radiusMD,
        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        AppRadius.radiusMD,
        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,
          width: 1.4,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // DROPDOWN
  // ----------------------------------------------------------

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>>
    items,
    required ValueChanged<T?>
    onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration:
      _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }

  // ----------------------------------------------------------
  // DATE
  // ----------------------------------------------------------

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final text =
    value == null
        ? 'Select date'
        : _formatDate(value);

    return InkWell(
      onTap: onTap,
      borderRadius:
      AppRadius.radiusMD,
      child: InputDecorator(
        decoration:
        _inputDecoration(
          label: label,
          hint: text,
          icon: icon,
        ),
        child: Text(
          text,
          style:
          AppTextStyles.bodyMedium
              .copyWith(
            color: value == null
                ? AppColors
                .textSecondary
                : AppColors
                .textPrimary,
          ),
        ),
      ),
    );
  }

  String _formatDate(
      DateTime date,
      ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ----------------------------------------------------------
  // MEMBERSHIP PLACEHOLDER
  // ----------------------------------------------------------

  Widget _buildMembershipPlaceholder() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusMD,
        border: Border.all(
          color:
          AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
            BoxDecoration(
              color:
              AppColors.primary
                  .withOpacity(
                0.10,
              ),
              borderRadius:
              AppRadius.radiusSM,
            ),
            child: const Icon(
              Icons
                  .card_membership_outlined,
              color:
              AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  'Membership plan',
                  style:
                  AppTextStyles
                      .labelLarge
                      .copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'Plan selection will be connected next.',
                  style:
                  AppTextStyles
                      .bodySmall
                      .copyWith(
                    color:
                    AppColors
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color:
            AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SUBMIT
  // ----------------------------------------------------------

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed:
        _isSubmitting
            ? null
            : _submit,
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          AppColors.primary,
          foregroundColor:
          Colors.black,
          disabledBackgroundColor:
          AppColors.primary
              .withOpacity(0.45),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            AppRadius.radiusMD,
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 22,
          height: 22,
          child:
          CircularProgressIndicator(
            strokeWidth: 2.5,
            color:
            Colors.black,
          ),
        )
            : Text(
          'Continue',
          style:
          AppTextStyles
              .labelLarge
              .copyWith(
            color:
            Colors.black,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // VALIDATION
  // ----------------------------------------------------------

  String? Function(String?)
  _requiredValidator(
      String field,
      ) {
    return (value) {
      if (value == null ||
          value.trim().isEmpty) {
        return '$field is required.';
      }

      return null;
    };
  }

  String? _emailValidator(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Email is required.';
    }

    final email =
    value.trim();

    final emailRegex =
    RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(
      email,
    )) {
      return 'Enter a valid email.';
    }

    return null;
  }

  String? _optionalPhoneValidator(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return null;
    }

    if (value.trim().length <
        7) {
      return 'Enter a valid phone number.';
    }

    return null;
  }

  // ----------------------------------------------------------
  // DATE PICKERS
  // ----------------------------------------------------------

  Future<void>
  _selectDateOfBirth() async {
    final now =
    DateTime.now();

    final selected =
    await showDatePicker(
      context: context,
      initialDate:
      _dateOfBirth ??
          DateTime(
            now.year - 20,
            now.month,
            now.day,
          ),
      firstDate:
      DateTime(
        1900,
      ),
      lastDate:
      now,
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    setState(() {
      _dateOfBirth =
          selected;
    });
  }

  Future<void>
  _selectStartDate() async {
    final selected =
    await showDatePicker(
      context: context,
      initialDate:
      _startDate,
      firstDate:
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate:
      DateTime(
        DateTime.now().year + 2,
      ),
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    setState(() {
      _startDate =
          selected;
    });
  }

  // ----------------------------------------------------------
  // SUBMIT LOGIC
  // ----------------------------------------------------------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    /*
     * Membership-plan integration is intentionally not
     * hardcoded here.
     *
     * The enrollment backend requires:
     *
     * membershipPlanId
     * membershipPlanName
     * amount
     * paymentMethod
     *
     * Those values will be supplied by the membership-plan
     * integration in the next step.
     */

    _showMessage(
      'Membership plan selection is required before enrollment.',
    );
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
        Text(message),
      ),
    );
  }
}