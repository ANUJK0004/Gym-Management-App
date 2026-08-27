import 'package:flutter/material.dart';

import '../../domain/entities/trainer_profile.dart';

class TrainerProfileStats extends StatelessWidget {
  const TrainerProfileStats({
    super.key,
    required this.profile,
  });

  final TrainerProfile profile;

  @override
  Widget build(BuildContext context) {
    // Format experience value (e.g. 3.2 -> "3.2yr", 5 -> "5yr")
    final experienceStr = profile.experienceYears % 1 == 0
        ? '${profile.experienceYears.toInt()}yr'
        : '${profile.experienceYears.toStringAsFixed(1)}yr';

    return Row(
      children: [
        // ------------------------------------------------
        // 1. CLIENTS STAT CARD
        // ------------------------------------------------
        Expanded(
          child: _StatCard(
            value: '${profile.clientCount}',
            label: 'Clients',
          ),
        ),

        const SizedBox(width: 12),

        // ------------------------------------------------
        // 2. EXPERIENCE STAT CARD
        // ------------------------------------------------
        Expanded(
          child: _StatCard(
            value: experienceStr,
            label: 'Experience',
          ),
        ),

        const SizedBox(width: 12),

        // ------------------------------------------------
        // 3. SESSIONS STAT CARD
        // ------------------------------------------------
        Expanded(
          child: _StatCard(
            value: '${profile.sessionCount}',
            label: 'Sessions',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF262C3A),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF38BDF8), // Cyan number
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8E9DAE),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
