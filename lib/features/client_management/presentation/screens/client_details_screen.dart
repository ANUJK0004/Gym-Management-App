import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trainer_client.dart';
import '../providers/client_management_provider.dart';

class ClientDetailsScreen extends ConsumerStatefulWidget {
  const ClientDetailsScreen({
    super.key,
    required this.client,
  });

  final TrainerClient client;

  @override
  ConsumerState<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends ConsumerState<ClientDetailsScreen> {
  late TrainerClient _currentClient;

  @override
  void initState() {
    super.initState();
    _currentClient = widget.client;
  }

  void _showAddNoteDialog() {
    final controller = TextEditingController(text: _currentClient.notes ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF262C3A), width: 0.8),
        ),
        title: const Text(
          'Trainer Note',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          cursorColor: const Color(0xFF38BDF8),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter observation, feedback, or plan adjustments...',
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0F1218),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF262C3A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF38BDF8)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E9DAE))),
          ),
          FilledButton(
            onPressed: () {
              final newNote = controller.text.trim();
              ref
                  .read(clientManagementProvider.notifier)
                  .updateNotes(_currentClient.id, newNote);
              setState(() {
                _currentClient = _currentClient.copyWith(notes: newNote);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF38BDF8),
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Trainer note updated! 📝',
                    style: TextStyle(
                      color: Color(0xFF0B132B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: const Color(0xFF0B132B),
            ),
            child: const Text('Save Note', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showMessagePrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF161922),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF38BDF8), size: 18),
            const SizedBox(width: 10),
            Text(
              'Opening direct chat with ${_currentClient.name}...',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep in sync with latest provider state
    final allClients = ref.watch(clientManagementProvider).clients;
    final matched = allClients.where((c) => c.id == widget.client.id).firstOrNull;
    if (matched != null) {
      _currentClient = matched;
    }

    final client = _currentClient;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // 1. BACK BUTTON (<)
              // ------------------------------------------------
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E222D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2A3040),
                      width: 0.8,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // 2. CLIENT OVERVIEW CARD (DARK BLUE GRADIENT)
              // ------------------------------------------------
              _buildOverviewCard(client),

              const SizedBox(height: 18),

              // ------------------------------------------------
              // 3. OVERALL PROGRESS & WEEKLY BAR CHART CARD
              // ------------------------------------------------
              _buildOverallProgressCard(client),

              const SizedBox(height: 22),

              // ------------------------------------------------
              // 4. KEY METRICS (2x2 GRID)
              // ------------------------------------------------
              const Text(
                'KEY METRICS',
                style: TextStyle(
                  color: Color(0xFF8E9DAE),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              _buildKeyMetricsGrid(client),

              const SizedBox(height: 22),

              // ------------------------------------------------
              // 5. TRAINER NOTES
              // ------------------------------------------------
              const Text(
                'TRAINER NOTES',
                style: TextStyle(
                  color: Color(0xFF8E9DAE),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              _buildTrainerNotesCard(client),

              const SizedBox(height: 22),

              // ------------------------------------------------
              // 6. UPCOMING SESSIONS
              // ------------------------------------------------
              const Text(
                'UPCOMING SESSIONS',
                style: TextStyle(
                  color: Color(0xFF8E9DAE),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              _buildUpcomingSessionsList(client),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // WIDGET: Overview Card (Top Blue Container)
  // --------------------------------------------------------------------------
  Widget _buildOverviewCard(TrainerClient client) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12233B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E3A5F),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          // Top Row: Avatar, Name & Goals, Streak & Message button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Squircle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3758),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF264972),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  client.initials,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Name, Plan, Goal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      client.trainingPlan,
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      client.goal,
                      style: const TextStyle(
                        color: Color(0xFF8E9DAE),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Streak & Message Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Streak Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2D42),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          client.formattedStreak,
                          style: const TextStyle(
                            color: Color(0xFFFB923C),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Message Button
                  Material(
                    color: const Color(0xFF38BDF8),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: _showMessagePrompt,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6.5,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Message',
                          style: TextStyle(
                            color: Color(0xFF0B132B),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Divider Line
          Container(
            height: 0.8,
            color: const Color(0x991E3A5F),
          ),

          const SizedBox(height: 14),

          // Bottom Stats Grid (Age, Height, Weight, Sessions)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewStat('${client.age ?? 28}', 'Age'),
              _buildOverviewStat(client.formattedHeight, 'Height'),
              _buildOverviewStat(client.formattedWeight, 'Weight'),
              _buildOverviewStat('${client.sessionsCount}', 'Sessions'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E9DAE),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // WIDGET: Overall Progress Card with Weekly Bar Chart
  // --------------------------------------------------------------------------
  Widget _buildOverallProgressCard(TrainerClient client) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final activity = client.weeklyActivity.isNotEmpty
        ? client.weeklyActivity
        : [0.55, 0.75, 0.08, 0.90, 0.72, 0.82, 0.65];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Overall Progress & 72%
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${client.progressPercentage}%',
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Horizontal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: client.progressValue,
                backgroundColor: const Color(0xFF262C3A),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF38BDF8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Weekly Activity Bar Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final val = index < activity.length ? activity[index] : 0.5;
              final isTodayFriday = index == 4; // Highlight Friday in screenshot

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: (val * 64).clamp(6.0, 64.0),
                    decoration: BoxDecoration(
                      color: isTodayFriday
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF1E3A4B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayLabels[index],
                    style: TextStyle(
                      color: isTodayFriday
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: isTodayFriday ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // WIDGET: Key Metrics 2x2 Grid
  // --------------------------------------------------------------------------
  Widget _buildKeyMetricsGrid(TrainerClient client) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                iconWidget: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0x3322C55E),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check_rounded, color: Color(0xFF4ADE80), size: 14),
                ),
                title: 'Attendance',
                value: '${client.attendanceRate}%',
                valueColor: const Color(0xFF4ADE80),
                delta: client.attendanceDelta,
                deltaColor: const Color(0xFF8E9DAE),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                iconWidget: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFFFB923C),
                  size: 20,
                ),
                title: 'Avg Intensity',
                value: '${client.avgIntensity}/10',
                valueColor: const Color(0xFFFB923C),
                delta: client.intensityDelta,
                deltaColor: const Color(0xFF8E9DAE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                iconWidget: const Icon(
                  Icons.scale_outlined,
                  color: Color(0xFFFB923C),
                  size: 18,
                ),
                title: 'Weight Change',
                value: client.formattedWeightChange,
                valueColor: const Color(0xFF38BDF8),
                delta: 'vs start',
                deltaColor: const Color(0xFF8E9DAE),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                iconWidget: const Text('🎯', style: TextStyle(fontSize: 16)),
                title: 'Goal on track',
                value: client.goalOnTrack ? 'Yes' : 'Needs Focus',
                valueColor: const Color(0xFF4ADE80),
                delta: 'On schedule',
                deltaColor: const Color(0xFF8E9DAE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // WIDGET: Trainer Notes Card
  // --------------------------------------------------------------------------
  Widget _buildTrainerNotesCard(TrainerClient client) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF262C3A),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            client.notes != null && client.notes!.isNotEmpty
                ? client.notes!
                : 'No notes added for this client yet.',
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showAddNoteDialog,
            child: const Text(
              '+ Add note',
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // WIDGET: Upcoming Sessions List
  // --------------------------------------------------------------------------
  Widget _buildUpcomingSessionsList(TrainerClient client) {
    final sessions = client.upcomingSessions.isNotEmpty
        ? client.upcomingSessions
        : [
            const ClientUpcomingSession(
              id: 'ds1',
              dayLabel: 'TOD',
              title: 'HIIT + Cardio',
              time: '11:00 AM',
              durationMinutes: 45,
            ),
            const ClientUpcomingSession(
              id: 'ds2',
              dayLabel: 'THU',
              title: 'HIIT + Cardio',
              time: '11:00 AM',
              durationMinutes: 45,
            ),
            const ClientUpcomingSession(
              id: 'ds3',
              dayLabel: 'SAT',
              title: 'Assessment',
              time: '9:00 AM',
              durationMinutes: 30,
            ),
          ];

    return Column(
      children: sessions.map((session) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF161922),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF262C3A),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              // Badge Container (TOD, THU, SAT)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF142738),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  session.dayLabel,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title and Time/Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session.timeAndDuration,
                      style: const TextStyle(
                        color: Color(0xFF8E9DAE),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Pill Button
              Material(
                color: const Color(0xFF1E222D),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF161922),
                        content: Text('Editing session: ${session.title}'),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.iconWidget,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.delta,
    required this.deltaColor,
  });

  final Widget iconWidget;
  final String title;
  final String value;
  final Color valueColor;
  final String delta;
  final Color deltaColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF262C3A),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8E9DAE),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            delta,
            style: TextStyle(
              color: deltaColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
