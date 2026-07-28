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

  final double weightChange;
  final double bodyFatChange;
  final double muscleMassChange;

  final int workoutChange;

  final List<WeeklyActivity> weeklyActivity;

  final List<PersonalRecord> personalRecords;

  int get completedWorkouts => totalWorkouts;

  int get monthlyWorkoutChange => workoutChange;

  int get todayIndex {
    final weekday = DateTime.now().weekday;

    // Monday = 0
    return weekday - 1;
  }

  List<String> get weekDays => const [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];
}

class WeeklyActivity {
  const WeeklyActivity({
    required this.day,
    required this.workouts,
  });

  final String day;
  final int workouts;

  double get chartValue {
    if (workouts <= 0) {
      return 0.05;
    }

    // Maximum visual scale of 5 workouts.
    return (workouts / 5).clamp(0.05, 1.0);
  }
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