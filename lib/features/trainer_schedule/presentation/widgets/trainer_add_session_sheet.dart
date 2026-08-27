import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trainer_schedule_provider.dart';

class TrainerAddSessionSheet extends ConsumerStatefulWidget {
  const TrainerAddSessionSheet({
    super.key,
    this.targetDate,
  });

  final DateTime? targetDate;

  static Future<void> show(
    BuildContext context, {
    DateTime? targetDate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TrainerAddSessionSheet(targetDate: targetDate),
    );
  }

  @override
  ConsumerState<TrainerAddSessionSheet> createState() =>
      _TrainerAddSessionSheetState();
}

class _TrainerAddSessionSheetState
    extends ConsumerState<TrainerAddSessionSheet> {
  // Available Options
  final List<String> _clients = [
    'Sarah Chen',
    'Marcus King',
    'Emma Davis',
    'Jake Wilson',
    'Lisa Park',
  ];

  final List<String> _sessionTypes = [
    'Strength Training',
    'HIIT Training',
    'Cardio & Core',
    'Hypertrophy',
    'Flexibility & Mobility',
    'Assessment',
    'Powerlifting',
    'Circuit Training',
  ];

  final List<String> _timeSlots = [
    '7:00 AM',
    '7:30 AM',
    '8:00 AM',
    '8:30 AM',
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM',
    '5:30 PM',
    '6:00 PM',
  ];

  final List<int> _durations = [30, 45, 60, 75, 90];

  // Selected State (initialized to defaults matching screenshot)
  String _selectedClient = 'Lisa Park';
  String _selectedSessionType = 'Assessment';
  String _selectedTimeSlot = '9:30 AM';
  int _selectedDuration = 75;
  final TextEditingController _notesController = TextEditingController();

  final ScrollController _timeSlotScrollController = ScrollController();

  @override
  void dispose() {
    _notesController.dispose();
    _timeSlotScrollController.dispose();
    super.dispose();
  }

  void _onAddSession() {
    if (_selectedClient.isEmpty ||
        _selectedSessionType.isEmpty ||
        _selectedTimeSlot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required session fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ref.read(trainerScheduleProvider.notifier).addSession(
          clientName: _selectedClient,
          workoutType: _selectedSessionType,
          timeSlot: _selectedTimeSlot,
          durationMinutes: _selectedDuration,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          date: widget.targetDate,
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF161922),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 0.8),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$_selectedSessionType for $_selectedClient added to schedule! 🗓️',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: Color(0xFF13161F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: Color(0xFF262C3A), width: 0.8),
          left: BorderSide(color: Color(0xFF262C3A), width: 0.8),
          right: BorderSide(color: Color(0xFF262C3A), width: 0.8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------
          // DRAG HANDLE
          // ------------------------------------------------
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF333B4E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------
          // HEADER (TITLE + CLOSE BUTTON)
          // ------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Add Session',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E222D),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ------------------------------------------------
          // SCROLLABLE FORM BODY
          // ------------------------------------------------
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CLIENT SECTION
                  _buildSectionHeader('CLIENT'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _clients.map((client) {
                      final isSelected = _selectedClient == client;
                      return _buildChoiceChip(
                        label: client,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedClient = client;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 2. SESSION TYPE SECTION
                  _buildSectionHeader('SESSION TYPE'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sessionTypes.map((type) {
                      final isSelected = _selectedSessionType == type;
                      return _buildChoiceChip(
                        label: type,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedSessionType = type;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 3. TIME SLOT SECTION (WITH SCROLLBAR / GRID)
                  _buildSectionHeader('TIME SLOT'),
                  const SizedBox(height: 8),
                  Container(
                    height: 135,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1218),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF262C3A),
                        width: 0.8,
                      ),
                    ),
                    child: Scrollbar(
                      controller: _timeSlotScrollController,
                      thumbVisibility: true,
                      radius: const Radius.circular(4),
                      child: GridView.builder(
                        controller: _timeSlotScrollController,
                        padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _timeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = _timeSlots[index];
                          final isSelected = _selectedTimeSlot == slot;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTimeSlot = slot;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF1E222D),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                slot,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF0B132B)
                                      : const Color(0xFFCBD5E1),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4. DURATION SECTION
                  _buildSectionHeader('DURATION'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _durations.map((duration) {
                      final isSelected = _selectedDuration == duration;
                      return _buildChoiceChip(
                        label: '$duration min',
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedDuration = duration;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 5. NOTES (OPTIONAL) SECTION
                  _buildSectionHeader('NOTES (OPTIONAL)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Session goals, focus areas...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13.5,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F1218),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF262C3A),
                          width: 0.8,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF262C3A),
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF38BDF8),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ------------------------------------------------
                  // ACTION BUTTON: ADD TO SCHEDULE
                  // ------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onAddSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: const Color(0xFF0B132B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Add to Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF8E9DAE),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF38BDF8) : const Color(0xFF1E222D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF38BDF8) : const Color(0xFF262C3A),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0B132B) : const Color(0xFFCBD5E1),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
