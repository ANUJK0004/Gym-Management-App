import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/owner_settings_provider.dart';

class EditOperatingHoursSheet extends ConsumerStatefulWidget {
  const EditOperatingHoursSheet({
    super.key,
    required this.initialHours,
  });

  final String initialHours;

  @override
  ConsumerState<EditOperatingHoursSheet> createState() =>
      _EditOperatingHoursSheetState();
}

class _EditOperatingHoursSheetState
    extends ConsumerState<EditOperatingHoursSheet> {
  late final TextEditingController _customController;
  late String _selectedPreset;
  bool _isSaving = false;

  final List<String> _presets = const [
    '5:00 AM - 11:00 PM',
    '6:00 AM - 10:00 PM',
    '6:00 AM - 12:00 AM',
    'Open 24/7 (24 Hours)',
    'Custom Hours',
  ];

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();

    if (_presets.contains(widget.initialHours)) {
      _selectedPreset = widget.initialHours;
    } else {
      _selectedPreset = 'Custom Hours';
      _customController.text = widget.initialHours;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _saveHours() async {
    final chosen = _selectedPreset == 'Custom Hours'
        ? _customController.text.trim()
        : _selectedPreset;

    if (chosen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify operating hours'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await ref
          .read(ownerSettingsControllerProvider.notifier)
          .updateOperatingHours(chosen);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Operating hours updated to $chosen'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operating Hours',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select your regular gym operational schedule or define custom timings.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ..._presets.map((preset) {
            final isSelected = _selectedPreset == preset;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.owner.withValues(alpha: 0.12)
                    : AppColors.surface,
                borderRadius: AppRadius.radiusMD,
                border: Border.all(
                  color: isSelected
                      ? AppColors.owner
                      : AppColors.border.withValues(alpha: 0.5),
                  width: isSelected ? 1.2 : 0.6,
                ),
              ),
              child: ListTile(
                dense: true,
                title: Text(
                  preset,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? AppColors.owner : AppColors.textHint,
                  size: 20,
                ),
                onTap: () {
                  setState(() {
                    _selectedPreset = preset;
                  });
                },
              ),
            );
          }),
          if (_selectedPreset == 'Custom Hours') ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'e.g. 5:30 AM - 10:30 PM (Mon-Sat)',
                prefixIcon: Icon(Icons.access_time_rounded, size: 20),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.owner,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _isSaving ? null : _saveHours,
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text('Save Operating Hours'),
            ),
          ),
        ],
      ),
    );
  }
}
