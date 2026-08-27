import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client_management_provider.dart';

class AddClientSheet extends ConsumerStatefulWidget {
  const AddClientSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddClientSheet(),
    );
  }

  @override
  ConsumerState<AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends ConsumerState<AddClientSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedGoal = '';
  String _selectedPlan = '';

  bool _isSubmitting = false;

  static const List<String> _fitnessGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Endurance',
    'Strength',
    'Toning',
    'Athletic Performance',
    'Marathon Prep',
    'Flexibility',
  ];

  static const List<String> _trainingPlans = [
    'HIIT + Cardio',
    'Hypertrophy',
    'Powerlifting',
    'Endurance',
    'Circuit Training',
    'Strength & Conditioning',
    'Yoga & Mobility',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _weightController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _ageController.text.trim().isNotEmpty &&
        _weightController.text.trim().isNotEmpty &&
        _selectedGoal.isNotEmpty &&
        _selectedPlan.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _ageController.removeListener(_onFieldChanged);
    _weightController.removeListener(_onFieldChanged);

    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      final age = int.tryParse(_ageController.text.trim());
      final weight = double.tryParse(_weightController.text.trim());

      final client = await ref.read(clientManagementProvider.notifier).addClient(
            name: name,
            email: email,
            age: age,
            weightKg: weight,
            goal: _selectedGoal,
            trainingPlan: _selectedPlan,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF38BDF8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF0B132B),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${client.name} has been added successfully!',
                    style: const TextStyle(
                      color: Color(0xFF0B132B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text('Failed to add client: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEnabled = _isFormValid && !_isSubmitting;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF141720),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ------------------------------------------------
              // TOP DRAG HANDLE
              // ------------------------------------------------
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333B4E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // HEADER ROW (TITLE + CLOSE BUTTON)
              // ------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Client',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E222D),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2A3040),
                          width: 0.8,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF8E9DAE),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ------------------------------------------------
              // 1. FULL NAME FIELD
              // ------------------------------------------------
              _buildFieldLabel('FULL NAME'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: 'e.g. Jane Doe',
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 18),

              // ------------------------------------------------
              // 2. EMAIL FIELD
              // ------------------------------------------------
              _buildFieldLabel('EMAIL'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hintText: 'jane@email.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              // ------------------------------------------------
              // 3. AGE FIELD
              // ------------------------------------------------
              _buildFieldLabel('AGE'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _ageController,
                hintText: 'e.g. 28',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 18),

              // ------------------------------------------------
              // 4. CURRENT WEIGHT FIELD
              // ------------------------------------------------
              _buildFieldLabel('CURRENT WEIGHT (kg)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _weightController,
                hintText: 'e.g. 65',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),

              const SizedBox(height: 22),

              // ------------------------------------------------
              // 5. FITNESS GOAL CHIPS
              // ------------------------------------------------
              _buildFieldLabel('FITNESS GOAL'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _fitnessGoals.map((goal) {
                  final isSelected = _selectedGoal == goal;
                  return _buildChip(
                    label: goal,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedGoal = isSelected ? '' : goal;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // ------------------------------------------------
              // 6. TRAINING PLAN CHIPS
              // ------------------------------------------------
              _buildFieldLabel('TRAINING PLAN'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _trainingPlans.map((plan) {
                  final isSelected = _selectedPlan == plan;
                  return _buildChip(
                    label: plan,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedPlan = isSelected ? '' : plan;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // 7. SUBMIT BUTTON (GREY WHEN DISABLED, CYAN WHEN VALID)
              // ------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Material(
                  key: const Key('add_client_submit_button'),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isEnabled ? _submit : null,
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF262C3A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0B132B),
                                ),
                              ),
                            )
                          : Text(
                              'Add Client',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: isEnabled
                                    ? const Color(0xFF0B132B)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF8E9DAE),
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1218),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF262C3A),
          width: 0.8,
        ),
      ),
      child: TextField(
        controller: controller,
        cursorColor: const Color(0xFF38BDF8),
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF4B5565),
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          isDense: true,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF38BDF8),
              width: 1.2,
            ),
          ),
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : const Color(0xFF1A1E28),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFF262C3A),
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF0B132B)
                  : const Color(0xFF8E9DAE),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
