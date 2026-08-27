import 'package:flutter/material.dart';

import '../../domain/entities/trainer_profile.dart';

class TrainerProfileIdentity extends StatelessWidget {
  const TrainerProfileIdentity({
    super.key,
    required this.profile,
  });

  final TrainerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ------------------------------------------------
        // 1. AVATAR WITH VERIFIED BADGE
        // ------------------------------------------------
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Color(0xFF67E8F9), // Light sky blue matching screenshot
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  profile.initials.isNotEmpty ? profile.initials : 'MT',
                  style: const TextStyle(
                    color: Color(0xFF0B132B),
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (profile.isVerified)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ADE80), // Bright green
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D0F14), // Background cutout border
                        width: 3,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF0D0F14),
                      size: 14,
                      weight: 800,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ------------------------------------------------
        // 2. COACH NAME
        // ------------------------------------------------
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 5),

        // ------------------------------------------------
        // 3. TITLE / DESIGNATION
        // ------------------------------------------------
        Text(
          profile.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF38BDF8),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 4),

        // ------------------------------------------------
        // 4. EMAIL ADDRESS
        // ------------------------------------------------
        Text(
          profile.email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8E9DAE),
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 10),

        // ------------------------------------------------
        // 5. STAR RATING & REVIEWS
        // ------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 3),
                child: Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFBBF24), // Amber star
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${profile.rating.toStringAsFixed(1)} (${profile.reviewCount} reviews)',
              style: const TextStyle(
                color: Color(0xFF8E9DAE),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
