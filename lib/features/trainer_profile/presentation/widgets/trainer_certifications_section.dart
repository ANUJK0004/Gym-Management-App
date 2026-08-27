import 'package:flutter/material.dart';

import '../../domain/entities/trainer_profile.dart';

class TrainerCertificationsSection extends StatelessWidget {
  const TrainerCertificationsSection({
    super.key,
    required this.certifications,
  });

  final List<TrainerCertification> certifications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------
        // SECTION TITLE
        // ------------------------------------------------
        const Text(
          'CERTIFICATIONS',
          style: TextStyle(
            color: Color(0xFF8E9DAE),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------
        // LIST OF CERTIFICATION TILES
        // ------------------------------------------------
        ...certifications.map((cert) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF262C3A),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  // 1. Emoji / Icon
                  Text(
                    cert.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),

                  const SizedBox(width: 14),

                  // 2. Title and Year
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Obtained ${cert.obtainedYear}',
                          style: const TextStyle(
                            color: Color(0xFF8E9DAE),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Verified Green Checkmark
                  if (cert.isVerified)
                    const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF4ADE80), // Vibrant green
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
