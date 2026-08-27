import 'package:flutter/material.dart';

import '../../domain/entities/trainer_dashboard_data.dart';

class TrainerScheduleCard extends StatelessWidget {
  const TrainerScheduleCard({
    super.key,
    required this.dashboard,
    required this.onViewSchedule,
  });

  final TrainerDashboardData dashboard;
  final VoidCallback onViewSchedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2B48),
            Color(0xFF0C2036),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E436E),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------
          // TITLE: TODAY'S SCHEDULE
          // ------------------------------------------------
          const Text(
            "TODAY'S SCHEDULE",
            style: TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // STAT METRICS (3 COLUMNS)
          // ------------------------------------------------
          Row(
            children: [
              // Sessions
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${dashboard.todaySessionsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sessions',
                      style: TextStyle(
                        color: Color(0xFF8E9DAE),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Clients
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${dashboard.todayClientsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Clients',
                      style: TextStyle(
                        color: Color(0xFF8E9DAE),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Active Hours
              Expanded(
                child: Column(
                  children: [
                    Text(
                      dashboard.todayActiveHours,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF8E9DAE),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // VIEW SCHEDULE BUTTON
          // ------------------------------------------------
          Material(
            color: const Color(0xFF38BDF8),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onViewSchedule,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 48,
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Schedule',
                      style: TextStyle(
                        color: Color(0xFF0B132B),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Color(0xFF0B132B),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
