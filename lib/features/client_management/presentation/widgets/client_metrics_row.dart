import 'package:flutter/material.dart';

class ClientMetricsRow extends StatelessWidget {
  const ClientMetricsRow({
    super.key,
    required this.totalClients,
    required this.sessionsPerWeek,
    required this.avgProgress,
  });

  final int totalClients;
  final int sessionsPerWeek;
  final int avgProgress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            value: '$totalClients',
            valueColor: const Color(0xFF38BDF8),
            label: 'Clients',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            value: '$sessionsPerWeek',
            valueColor: const Color(0xFF4ADE80),
            label: 'Sessions/wk',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            value: '$avgProgress%',
            valueColor: const Color(0xFFFB923C),
            label: 'Avg Progress',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.valueColor,
    required this.label,
  });

  final String value;
  final Color valueColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8E9DAE),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
