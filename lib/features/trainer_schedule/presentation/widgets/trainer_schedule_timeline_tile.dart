import 'package:flutter/material.dart';

import '../../domain/entities/trainer_schedule_session.dart';

class TrainerScheduleTimelineTile extends StatelessWidget {
  const TrainerScheduleTimelineTile({
    super.key,
    required this.session,
    required this.isFirst,
    required this.isLast,
    this.onTap,
  });

  final TrainerScheduleSession session;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Parse time into time number and AM/PM parts if possible
    final timeParts = session.timeSlot.split(' ');
    final timeNum = timeParts.isNotEmpty ? timeParts[0] : session.timeSlot;
    final timeAmPm = timeParts.length > 1 ? timeParts[1] : '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ------------------------------------------------
          // LEFT AXIS: TIME + TIMELINE DOT & LINE
          // ------------------------------------------------
          SizedBox(
            width: 58,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time digits and AM/PM
                SizedBox(
                  width: 38,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      Text(
                        timeNum,
                        style: const TextStyle(
                          color: Color(0xFF8E9DAE),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        timeAmPm,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical timeline indicator & dot
                Expanded(
                  child: Column(
                    children: [
                      // Top vertical line
                      Expanded(
                        flex: isFirst ? 0 : 1,
                        child: Container(
                          width: 1.5,
                          color: isFirst
                              ? Colors.transparent
                              : const Color(0xFF262C3A),
                        ),
                      ),

                      // Status indicator dot
                      _buildIndicatorDot(),

                      // Bottom vertical line
                      Expanded(
                        flex: isLast ? 0 : 3,
                        child: Container(
                          width: 1.5,
                          color: isLast
                              ? Colors.transparent
                              : const Color(0xFF262C3A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ------------------------------------------------
          // RIGHT: SESSION CARD CONTAINER
          // ------------------------------------------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161922),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: session.isNext
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF262C3A),
                        width: session.isNext ? 1.2 : 0.8,
                      ),
                      boxShadow: session.isNext
                          ? [
                              BoxShadow(
                                color: const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.12),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Client name & workout type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                session.clientName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                session.workoutType,
                                style: const TextStyle(
                                  color: Color(0xFF8E9DAE),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Status badge / Duration badge
                        _buildStatusBadge(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorDot() {
    if (session.isCompleted) {
      // Hollow grey circle
      return Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF475569),
            width: 2,
          ),
          color: const Color(0xFF0D0F14),
        ),
      );
    } else if (session.isNext) {
      // Solid bright cyan circle
      return Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF38BDF8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    } else {
      // Solid bright lime green circle
      return Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF4ADE80),
        ),
      );
    }
  }

  Widget _buildStatusBadge() {
    if (session.isCompleted) {
      return const Text(
        '✓ Done',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      );
    } else if (session.isNext) {
      return const Text(
        '→ Next',
        style: TextStyle(
          color: Color(0xFF38BDF8),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      );
    } else {
      return Text(
        '${session.durationMinutes} min',
        style: const TextStyle(
          color: Color(0xFF4ADE80),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      );
    }
  }
}
