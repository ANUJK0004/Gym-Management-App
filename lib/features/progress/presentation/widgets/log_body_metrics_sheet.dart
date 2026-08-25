import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/progress.dart';
import '../providers/progress_provider.dart';

class LogBodyMetricsBottomSheet extends ConsumerStatefulWidget {
  const LogBodyMetricsBottomSheet({
    super.key,
    this.currentProgress,
  });

  final Progress? currentProgress;

  static Future<bool?> show(
    BuildContext context, {
    Progress? currentProgress,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LogBodyMetricsBottomSheet(
          currentProgress: currentProgress,
        ),
      ),
    );
  }

  @override
  ConsumerState<LogBodyMetricsBottomSheet> createState() =>
      _LogBodyMetricsBottomSheetState();
}

class _LogBodyMetricsBottomSheetState
    extends ConsumerState<LogBodyMetricsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _bodyFatController;
  late final TextEditingController _muscleMassController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final progress = widget.currentProgress;

    _weightController = TextEditingController(
      text: (progress != null && progress.currentWeight > 0)
          ? progress.currentWeight.toStringAsFixed(1)
          : '',
    );
    _bodyFatController = TextEditingController(
      text: (progress != null && progress.bodyFat > 0)
          ? progress.bodyFat.toStringAsFixed(1)
          : '',
    );
    _muscleMassController = TextEditingController(
      text: (progress != null && progress.muscleMass > 0)
          ? progress.muscleMass.toStringAsFixed(1)
          : '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final weightText = _weightController.text.trim();
    final bodyFatText = _bodyFatController.text.trim();
    final muscleMassText = _muscleMassController.text.trim();

    if (weightText.isEmpty && bodyFatText.isEmpty && muscleMassText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one metric to update.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final weight = weightText.isNotEmpty ? double.tryParse(weightText) : null;
    final bodyFat = bodyFatText.isNotEmpty ? double.tryParse(bodyFatText) : null;
    final muscleMass =
        muscleMassText.isNotEmpty ? double.tryParse(muscleMassText) : null;

    if (weightText.isNotEmpty && (weight == null || weight <= 0 || weight > 500)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight (1 - 500 kg).'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (bodyFatText.isNotEmpty && (bodyFat == null || bodyFat < 0 || bodyFat > 100)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid body fat percentage (0 - 100%).'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (muscleMassText.isNotEmpty &&
        (muscleMass == null || muscleMass <= 0 || muscleMass > 300)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid muscle mass (1 - 300 kg).'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updateMetrics = ref.read(updateBodyMetricsProvider);
      await updateMetrics(
        weight: weight,
        bodyFat: bodyFat,
        muscleMass: muscleMass,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text(
                'Body metrics updated successfully!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF333333)),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update metrics: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: Color(0xFF2E2E2E),
            width: 1,
          ),
          left: BorderSide(
            color: Color(0xFF2E2E2E),
            width: 1,
          ),
          right: BorderSide(
            color: Color(0xFF2E2E2E),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF424242),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Header: Title & Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Log Body Metrics',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track your body changes over time',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2A2A2A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFAAAAAA),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Current Weight Field
                _buildField(
                  label: 'CURRENT WEIGHT',
                  controller: _weightController,
                  hint: 'e.g. 74.5',
                  unit: 'kg',
                  icon: Icons.monitor_weight_outlined,
                ),

                const SizedBox(height: 18),

                // Body Fat Percentage Field
                _buildField(
                  label: 'BODY FAT PERCENTAGE',
                  controller: _bodyFatController,
                  hint: 'e.g. 15.0',
                  unit: '%',
                  icon: Icons.pie_chart_outline_rounded,
                ),

                const SizedBox(height: 18),

                // Muscle Mass Field
                _buildField(
                  label: 'MUSCLE MASS',
                  controller: _muscleMassController,
                  hint: 'e.g. 36.2',
                  unit: 'kg',
                  icon: Icons.fitness_center_rounded,
                ),

                const SizedBox(height: 28),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textInverse,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.textInverse,
                            ),
                          )
                        : const Text(
                            'Save Metrics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textInverse,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String unit,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: const Color(0xFF888888),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: UnconstrainedBox(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF333333),
                    ),
                  ),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            filled: true,
            fillColor: const Color(0xFF141414),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(
                color: Color(0xFF333333),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(
                color: Color(0xFF333333),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
