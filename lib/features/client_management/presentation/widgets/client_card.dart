import 'package:flutter/material.dart';

import '../../domain/entities/trainer_client.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.client,
    this.onTap,
  });

  final TrainerClient client;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161922),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF262C3A),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // 1. TOP ROW: AVATAR, NAME, GOAL & SESSIONS, STREAK
              // ------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Initials and Active Status Dot
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF334155),
                            width: 0.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          client.initials,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (client.isActive)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF161922),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Name and Goal · Plan Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          client.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8E9DAE),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Sessions count and Streak Days (e.g. 12 sessions, 8d 🔥)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${client.sessionsCount} sessions',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🔥',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            client.formattedStreak,
                            style: const TextStyle(
                              color: Color(0xFFFB923C),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // 2. PROGRESS BAR ROW
              // ------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 5.5,
                        child: LinearProgressIndicator(
                          value: client.progressValue,
                          backgroundColor: const Color(0xFF262C3A),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${client.progressPercentage}%',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // 3. BOTTOM META ROW (CALENDAR & WEIGHT)
              // ------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Next Session
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13.5,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        client.nextSession ?? 'No upcoming session',
                        style: const TextStyle(
                          color: Color(0xFF8E9DAE),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Weight (kg)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.scale_outlined,
                        size: 14.5,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        client.formattedWeight,
                        style: const TextStyle(
                          color: Color(0xFF8E9DAE),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
