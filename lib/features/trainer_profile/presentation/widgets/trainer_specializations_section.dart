import 'package:flutter/material.dart';

class TrainerSpecializationsSection extends StatelessWidget {
  const TrainerSpecializationsSection({
    super.key,
    required this.specializations,
  });

  final List<String> specializations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------
        // SECTION TITLE
        // ------------------------------------------------
        const Text(
          'SPECIALIZATIONS',
          style: TextStyle(
            color: Color(0xFF8E9DAE),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------
        // WRAP OF SPECIALIZATION CHIPS
        // ------------------------------------------------
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: specializations.map((spec) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8.5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0C2438), // Dark cyan/navy tint
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1D4A6E),
                  width: 1,
                ),
              ),
              child: Text(
                spec,
                style: const TextStyle(
                  color: Color(0xFF38BDF8), // Cyan text
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
