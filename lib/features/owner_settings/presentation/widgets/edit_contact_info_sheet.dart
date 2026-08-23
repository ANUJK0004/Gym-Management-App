import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/owner_settings_provider.dart';

enum ContactEditField {
  phone,
  website,
  address,
}

class EditContactInfoSheet extends ConsumerStatefulWidget {
  const EditContactInfoSheet({
    super.key,
    required this.field,
    required this.currentValue,
  });

  final ContactEditField field;
  final String currentValue;

  @override
  ConsumerState<EditContactInfoSheet> createState() =>
      _EditContactInfoSheetState();
}

class _EditContactInfoSheetState extends ConsumerState<EditContactInfoSheet> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  String get _title {
    switch (widget.field) {
      case ContactEditField.phone:
        return 'Edit Contact Number';
      case ContactEditField.website:
        return 'Edit Gym Website';
      case ContactEditField.address:
        return 'Edit Gym Location';
    }
  }

  String get _label {
    switch (widget.field) {
      case ContactEditField.phone:
        return 'Phone Number';
      case ContactEditField.website:
        return 'Website URL';
      case ContactEditField.address:
        return 'Gym Address';
    }
  }

  IconData get _icon {
    switch (widget.field) {
      case ContactEditField.phone:
        return Icons.phone_outlined;
      case ContactEditField.website:
        return Icons.language_rounded;
      case ContactEditField.address:
        return Icons.location_on_outlined;
    }
  }

  String get _hint {
    switch (widget.field) {
      case ContactEditField.phone:
        return '+91 98765 43210';
      case ContactEditField.website:
        return 'https://mygym.com';
      case ContactEditField.address:
        return '123 Fitness Ave, Suite 400';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentValue == 'Not set' ||
              widget.currentValue == 'Not provided'
          ? ''
          : widget.currentValue,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid $_label'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final notifier = ref.read(ownerSettingsControllerProvider.notifier);
      bool success = false;

      switch (widget.field) {
        case ContactEditField.phone:
          success = await notifier.updateContactInfo(phone: text);
          break;
        case ContactEditField.website:
          success = await notifier.updateContactInfo(website: text);
          break;
        case ContactEditField.address:
          success = await notifier.updateContactInfo(address: text);
          break;
      }

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_label updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update $_label: $e'),
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
                _title,
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
            'Keep your gym\'s details up to date for your staff and members.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            style: AppTextStyles.bodyMedium,
            keyboardType: widget.field == ContactEditField.phone
                ? TextInputType.phone
                : widget.field == ContactEditField.website
                    ? TextInputType.url
                    : TextInputType.streetAddress,
            decoration: InputDecoration(
              labelText: _label,
              hintText: _hint,
              prefixIcon: Icon(_icon, size: 20),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Save $_label'),
            ),
          ),
        ],
      ),
    );
  }
}
