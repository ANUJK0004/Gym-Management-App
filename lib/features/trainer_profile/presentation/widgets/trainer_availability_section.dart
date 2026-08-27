import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trainer_profile.dart';
import '../providers/trainer_profile_provider.dart';

class TrainerAvailabilitySection extends ConsumerWidget {
  const TrainerAvailabilitySection({
    super.key,
    required this.availability,
  });

  final TrainerAvailability availability;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------
        // SECTION TITLE
        // ------------------------------------------------
        const Text(
          'AVAILABILITY',
          style: TextStyle(
            color: Color(0xFF8E9DAE),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------
        // GROUPED AVAILABILITY CARD
        // ------------------------------------------------
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161922),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF262C3A),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              // 1. Working Hours
              _AvailabilityRow(
                iconWidget: const Text('⏱️', style: TextStyle(fontSize: 18)),
                title: 'Working Hours',
                value: availability.workingHours,
                onTap: () => _editAvailabilityField(
                  context,
                  ref,
                  title: 'Working Hours',
                  currentValue: availability.workingHours,
                  onSave: (val) {
                    ref
                        .read(trainerProfileControllerProvider.notifier)
                        .updateAvailability(workingHours: val);
                  },
                ),
              ),

              const Divider(
                height: 1,
                thickness: 0.8,
                color: Color(0xFF222734),
                indent: 52,
                endIndent: 16,
              ),

              // 2. Days Available
              _AvailabilityRow(
                iconWidget: const Text('📅', style: TextStyle(fontSize: 18)),
                title: 'Days Available',
                value: availability.daysAvailable,
                onTap: () => _editAvailabilityField(
                  context,
                  ref,
                  title: 'Days Available',
                  currentValue: availability.daysAvailable,
                  onSave: (val) {
                    ref
                        .read(trainerProfileControllerProvider.notifier)
                        .updateAvailability(daysAvailable: val);
                  },
                ),
              ),

              const Divider(
                height: 1,
                thickness: 0.8,
                color: Color(0xFF222734),
                indent: 52,
                endIndent: 16,
              ),

              // 3. Session Duration
              _AvailabilityRow(
                iconWidget: const Text('⏱️', style: TextStyle(fontSize: 18)),
                title: 'Session Duration',
                value: availability.sessionDuration,
                onTap: () => _editAvailabilityField(
                  context,
                  ref,
                  title: 'Session Duration',
                  currentValue: availability.sessionDuration,
                  onSave: (val) {
                    ref
                        .read(trainerProfileControllerProvider.notifier)
                        .updateAvailability(sessionDuration: val);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editAvailabilityField(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String currentValue,
    required ValueChanged<String> onSave,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161922),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF262C3A), width: 0.8),
          ),
          title: Text(
            'Edit $title',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter $title',
              hintStyle: const TextStyle(color: Color(0xFF8E9DAE)),
              filled: true,
              fillColor: const Color(0xFF0D0F14),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8E9DAE)),
              ),
            ),
            FilledButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isNotEmpty) {
                  onSave(trimmed);
                }
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0B132B),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AvailabilityRow extends StatelessWidget {
  const _AvailabilityRow({
    required this.iconWidget,
    required this.title,
    required this.value,
    this.onTap,
  });

  final Widget iconWidget;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              iconWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF8E9DAE),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF64748B),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
