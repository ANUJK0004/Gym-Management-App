import 'package:flutter/material.dart';

import '../../domain/entities/trainer_dashboard_data.dart';

class TrainerNextSessionCard extends StatelessWidget {
  const TrainerNextSessionCard({
    super.key,
    required this.session,
    required this.onStart,
  });

  final TrainerSession? session;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161922),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF262C3A),
            width: 0.8,
          ),
        ),
        child: const Center(
          child: Text(
            'No upcoming sessions today.',
            style: TextStyle(
              color: Color(0xFF8E9DAE),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final currentSession = session!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF262C3A),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // ------------------------------------------------
          // LEFT ICON SQUIRCLE (💪)
          // ------------------------------------------------
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF334155),
                width: 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              currentSession.iconEmoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),

          const SizedBox(width: 12),

          // ------------------------------------------------
          // MIDDLE DETAILS (NAME, WORKOUT, TIMING)
          // ------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentSession.clientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${currentSession.workoutType} • ${currentSession.durationMinutes} min',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8E9DAE),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${currentSession.startsIn} • ${currentSession.startTime}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ------------------------------------------------
          // START BUTTON (CYAN PILL)
          // ------------------------------------------------
          Material(
            color: const Color(0xFF38BDF8),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onStart,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Start',
                  style: TextStyle(
                    color: Color(0xFF0B132B),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
