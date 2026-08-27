import 'package:flutter/material.dart';

import '../../domain/entities/trainer_profile.dart';

class TrainerMonthlyMetricsCard extends StatelessWidget {
  const TrainerMonthlyMetricsCard({
    super.key,
    required this.metrics,
  });

  final TrainerMonthlyMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          // 1. CARD TITLE
          // ------------------------------------------------
          const Text(
            'This Month',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------
          // 2. 2x2 GRID OF METRICS
          // ------------------------------------------------
          Row(
            children: [
              // Top-Left: Sessions Completed (Green)
              Expanded(
                child: _MetricTile(
                  valueWidget: Text(
                    '${metrics.sessionsCompleted}',
                    style: const TextStyle(
                      color: Color(0xFF4ADE80), // Green
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.3,
                    ),
                  ),
                  label: 'Sessions Completed',
                ),
              ),

              const SizedBox(width: 12),

              // Top-Right: Client Retention (Cyan)
              Expanded(
                child: _MetricTile(
                  valueWidget: Text(
                    '${metrics.clientRetentionPercentage}%',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8), // Cyan
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.3,
                    ),
                  ),
                  label: 'Client Retention',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Bottom-Left: Avg Session Rating (Amber Star)
              Expanded(
                child: _MetricTile(
                  valueWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        metrics.avgSessionRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFFFBBF24), // Amber
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFBBF24),
                        size: 20,
                      ),
                    ],
                  ),
                  label: 'Avg Session Rating',
                ),
              ),

              const SizedBox(width: 12),

              // Bottom-Right: New Clients (Pink/Purple)
              Expanded(
                child: _MetricTile(
                  valueWidget: Text(
                    '+${metrics.newClientsCount}',
                    style: const TextStyle(
                      color: Color(0xFFC084FC), // Pink/Purple
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.3,
                    ),
                  ),
                  label: 'New Clients',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.valueWidget,
    required this.label,
  });

  final Widget valueWidget;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B202D), // Inner tile dark background
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          valueWidget,
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8E9DAE),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
