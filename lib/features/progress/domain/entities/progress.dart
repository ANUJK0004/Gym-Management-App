class Progress {
  const Progress({
    required this.userId,
    required this.currentWeight,
    required this.bodyFat,
    required this.muscleMass,
    required this.totalWorkouts,
    this.weightChange = 0,
    this.bodyFatChange = 0,
    this.muscleMassChange = 0,
    this.workoutChange = 0,
    this.weeklyActivity = const [],
    this.personalRecords = const [],
  });

  final String userId;

  final double currentWeight;
  final double bodyFat;
  final double muscleMass;

  final int totalWorkouts;

  /// Positive = increased
  /// Negative = decreased
  final double weightChange;

  final double bodyFatChange;
  final double muscleMassChange;

  /// Number of workouts compared to previous period.
  final int workoutChange;

  final List<WeeklyActivity> weeklyActivity;

  final List<PersonalRecord> personalRecords;

  /// Returns exactly 7 activity entries.
  ///
  /// Missing days are automatically filled with 0.
  List<WeeklyActivity> get normalizedWeeklyActivity {
    final result = List<WeeklyActivity>.generate(
      7,
          (index) => WeeklyActivity(
        day: _defaultDay(index),
        workouts: 0,
      ),
    );

    for (final activity in weeklyActivity) {
      final index = _dayIndex(activity.day);

      if (index != null && index >= 0 && index < 7) {
        result[index] = activity;
      }
    }

    return result;
  }

  int get todayIndex {
    // Monday = 0
    final weekday = DateTime.now().weekday;

    return weekday - 1;
  }

  static int? _dayIndex(String day) {
    switch (day.toLowerCase()) {
      case 'm':
      case 'mon':
      case 'monday':
        return 0;

      case 't':
      case 'tu':
      case 'tue':
      case 'tuesday':
        return 1;

      case 'w':
      case 'wed':
      case 'wednesday':
        return 2;

      case 'th':
      case 'thu':
      case 'thur':
      case 'thursday':
        return 3;

      case 'f':
      case 'fri':
      case 'friday':
        return 4;

      case 'sa':
      case 'sat':
      case 'saturday':
        return 5;

      case 'su':
      case 'sun':
      case 'sunday':
        return 6;

      default:
        return null;
    }
  }

  static String _defaultDay(int index) {
    const days = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return days[index];
  }
}

class WeeklyActivity {
  const WeeklyActivity({
    required this.day,
    required this.workouts,
  });

  final String day;

  /// Number of workouts completed on this day.
  final int workouts;
}

class PersonalRecord {
  const PersonalRecord({
    required this.id,
    required this.exerciseName,
    required this.weight,
    required this.date,
  });

  final String id;
  final String exerciseName;
  final double weight;
  final DateTime date;

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }
}