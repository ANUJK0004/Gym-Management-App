import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trainer_profile.dart';
import '../providers/trainer_profile_provider.dart';

class EditTrainerProfileSheet extends ConsumerStatefulWidget {
  const EditTrainerProfileSheet({
    super.key,
    required this.profile,
  });

  final TrainerProfile profile;

  static void show(BuildContext context, TrainerProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTrainerProfileSheet(profile: profile),
    );
  }

  @override
  ConsumerState<EditTrainerProfileSheet> createState() =>
      _EditTrainerProfileSheetState();
}

class _EditTrainerProfileSheetState
    extends ConsumerState<EditTrainerProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _experienceController;
  late List<String> _specializations;
  final TextEditingController _specController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _titleController = TextEditingController(text: widget.profile.title);
    _emailController = TextEditingController(text: widget.profile.email);
    _experienceController = TextEditingController(
      text: widget.profile.experienceYears.toString(),
    );
    _specializations = List.from(widget.profile.specializations);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    _specController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final parts = name.split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();

    final exp = double.tryParse(_experienceController.text.trim()) ??
        widget.profile.experienceYears;

    final updated = widget.profile.copyWith(
      name: name,
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : widget.profile.title,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : widget.profile.email,
      initials: initials,
      experienceYears: exp,
      specializations: _specializations,
    );

    ref.read(trainerProfileControllerProvider.notifier).updateProfile(updated);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF1E222D),
        content: Text(
          'Profile updated successfully! ✨',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
      decoration: const BoxDecoration(
        color: Color(0xFF161922),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3547),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Edit Trainer Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E2433),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF8E9DAE),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInputField('Full Name', _nameController, 'e.g. Coach Mike Torres',
                fieldKey: const Key('edit_trainer_name_field')),
            const SizedBox(height: 14),

            _buildInputField('Title / Subtitle', _titleController, 'e.g. Senior Personal Trainer',
                fieldKey: const Key('edit_trainer_title_field')),
            const SizedBox(height: 14),

            _buildInputField('Email Address', _emailController, 'e.g. mike.torres@gymsync.com',
                fieldKey: const Key('edit_trainer_email_field'),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),

            _buildInputField('Experience (Years)', _experienceController, 'e.g. 3.2',
                fieldKey: const Key('edit_trainer_exp_field'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 18),

            // Specializations
            const Text(
              'Specializations',
              style: TextStyle(
                color: Color(0xFF8E9DAE),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specializations.map((spec) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C2438),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1D4A6E)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        spec,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _specializations.remove(spec);
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Add Specialization field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _specController,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Add specialization (e.g. CrossFit)',
                      hintStyle: const TextStyle(color: Color(0xFF8E9DAE)),
                      filled: true,
                      fillColor: const Color(0xFF0D0F14),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF262C3A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final text = _specController.text.trim();
                    if (text.isNotEmpty && !_specializations.contains(text)) {
                      setState(() {
                        _specializations.add(text);
                        _specController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle, color: Color(0xFF38BDF8)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF0B132B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    Key? fieldKey,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E9DAE),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFF0D0F14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF262C3A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF38BDF8)),
            ),
          ),
        ),
      ],
    );
  }
}
