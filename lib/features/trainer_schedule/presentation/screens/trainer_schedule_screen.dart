import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/trainer/presentation/providers/trainer_shell_provider.dart';
import '../../domain/entities/trainer_schedule_session.dart';
import '../providers/trainer_schedule_provider.dart';
import '../widgets/trainer_add_session_sheet.dart';
import '../widgets/trainer_date_strip.dart';
import '../widgets/trainer_schedule_timeline_tile.dart';

class TrainerScheduleScreen extends ConsumerWidget {
  const TrainerScheduleScreen({super.key});

  static const List<String> _fullWeekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatFullDate(DateTime date) {
    final weekday = _fullWeekdays[date.weekday - 1];
    final month = _monthNames[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(trainerScheduleProvider);
    final scheduleNotifier = ref.read(trainerScheduleProvider.notifier);

    final selectedDateStr = _formatFullDate(scheduleState.selectedDate);
    final sessions = scheduleState.sessionsForSelectedDate;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ------------------------------------------------
              // BACK BUTTON (<)
              // ------------------------------------------------
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    ref.read(trainerNavIndexProvider.notifier).setIndex(0);
                  }
                },
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

              const SizedBox(height: 12),

              // ------------------------------------------------
              // HEADER ROW (TITLE + SUBTITLE & "+ Add Session")
              // ------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & formatted date subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selectedDateStr,
                        style: const TextStyle(
                          color: Color(0xFF8E9DAE),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // "+ Add Session" Button
                  Material(
                    color: const Color(0xFF0C2438),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () {
                        TrainerAddSessionSheet.show(
                          context,
                          targetDate: scheduleState.selectedDate,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C2438),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF1D4A6E),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Color(0xFF38BDF8),
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Add Session',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // DATE STRIP & WEEK NAVIGATION SCRUBBER
              // ------------------------------------------------
              TrainerDateStrip(
                selectedDate: scheduleState.selectedDate,
                weekStartDate: scheduleState.weekStartDate,
                onDateSelected: scheduleNotifier.selectDate,
                onPreviousWeek: scheduleNotifier.previousWeek,
                onNextWeek: scheduleNotifier.nextWeek,
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // TIMELINE OF SESSIONS / EMPTY STATE
              // ------------------------------------------------
              Expanded(
                child: sessions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xFF161922),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFF64748B),
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No sessions scheduled',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Take a rest or tap + Add Session to create one.',
                              style: TextStyle(
                                color: Color(0xFF8E9DAE),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                TrainerAddSessionSheet.show(
                                  context,
                                  targetDate: scheduleState.selectedDate,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38BDF8),
                                foregroundColor: const Color(0xFF0B132B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text(
                                'Add Session',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 20),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final item = sessions[index];
                          return TrainerScheduleTimelineTile(
                            session: item,
                            isFirst: index == 0,
                            isLast: index == sessions.length - 1,
                            onTap: () {
                              _showSessionOptionsSheet(
                                context,
                                item,
                                scheduleNotifier,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionOptionsSheet(
    BuildContext context,
    TrainerScheduleSession session,
    TrainerScheduleNotifier notifier,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF161922),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333B4E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.clientName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${session.workoutType} • ${session.timeSlot} (${session.durationMinutes} min)',
                          style: const TextStyle(
                            color: Color(0xFF8E9DAE),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (session.notes != null && session.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1218),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF262C3A),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'Notes: ${session.notes}',
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  session.isCompleted
                      ? Icons.undo_rounded
                      : Icons.check_circle_outline_rounded,
                  color: const Color(0xFF38BDF8),
                ),
                title: Text(
                  session.isCompleted
                      ? 'Mark as Incomplete'
                      : 'Mark as Completed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  notifier.toggleSessionCompleted(session.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
