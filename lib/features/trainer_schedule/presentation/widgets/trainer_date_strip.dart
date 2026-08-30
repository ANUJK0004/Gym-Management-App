import 'package:flutter/material.dart';

class TrainerDateStrip extends StatelessWidget {
  const TrainerDateStrip({
    super.key,
    required this.selectedDate,
    required this.weekStartDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final DateTime weekStartDate;
  final ValueChanged<DateTime> onDateSelected;

  static const List<String> _shortWeekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate the 7 days of the current week (Monday through Sunday)
    final weekDays = List.generate(7, (index) {
      return weekStartDate.add(Duration(days: index));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------
        // HORIZONTAL CURRENT WEEK DATE PILLS
        // ------------------------------------------------
        SizedBox(
          height: 74,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) {
              final isSelected = day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;

              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;

              final isPast = day.isBefore(today);

              final dayName = _shortWeekdays[day.weekday - 1];
              final dayNumber = '${day.day}';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: GestureDetector(
                    onTap: () => onDateSelected(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF38BDF8)
                            : (isPast
                                ? const Color(0xFF13161F)
                                : const Color(0xFF161922)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF38BDF8)
                              : (isToday
                                  ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
                                  : const Color(0xFF262C3A)),
                          width: isSelected ? 1.5 : (isToday ? 1.0 : 0.8),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF0B132B)
                                  : (isPast
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF8E9DAE)),
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dayNumber,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF0B132B)
                                  : (isPast
                                      ? const Color(0xFF94A3B8)
                                      : Colors.white),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (isToday && !isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFF38BDF8),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
