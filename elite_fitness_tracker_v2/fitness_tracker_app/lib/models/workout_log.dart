// lib/models/workout_log.dart

class WorkoutLog {
  final int? id;
  final int dayNumber;
  final DateTime date;
  final bool completed;
  final DateTime? completedAt;
  final int durationMinutes;
  final String? notes;
  final List<ExerciseLog> exerciseLogs;
  final int feelingRating; // 1-5
  final int energyLevel;  // 1-5

  WorkoutLog({
    this.id,
    required this.dayNumber,
    required this.date,
    required this.completed,
    this.completedAt,
    this.durationMinutes = 0,
    this.notes,
    required this.exerciseLogs,
    this.feelingRating = 0,
    this.energyLevel = 0,
  });

  WorkoutLog copyWith({
    int? id,
    bool? completed,
    DateTime? completedAt,
    int? durationMinutes,
    String? notes,
    List<ExerciseLog>? exerciseLogs,
    int? feelingRating,
    int? energyLevel,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      dayNumber: dayNumber,
      date: date,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      feelingRating: feelingRating ?? this.feelingRating,
      energyLevel: energyLevel ?? this.energyLevel,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayNumber': dayNumber,
    'date': date.toIso8601String(),
    'completed': completed ? 1 : 0,
    'completedAt': completedAt?.toIso8601String(),
    'durationMinutes': durationMinutes,
    'notes': notes,
    'feelingRating': feelingRating,
    'energyLevel': energyLevel,
  };

  factory WorkoutLog.fromMap(Map<String, dynamic> map) => WorkoutLog(
    id: map['id'],
    dayNumber: map['dayNumber'],
    date: DateTime.parse(map['date']),
    completed: map['completed'] == 1,
    completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    durationMinutes: map['durationMinutes'] ?? 0,
    notes: map['notes'],
    exerciseLogs: [],
    feelingRating: map['feelingRating'] ?? 0,
    energyLevel: map['energyLevel'] ?? 0,
  );
}

class ExerciseLog {
  final int? id;
  final int workoutLogId;
  final String exerciseName;
  final bool completed;
  final List<SetLog> sets;
  final String? notes;

  ExerciseLog({
    this.id,
    required this.workoutLogId,
    required this.exerciseName,
    required this.completed,
    required this.sets,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'workoutLogId': workoutLogId,
    'exerciseName': exerciseName,
    'completed': completed ? 1 : 0,
    'notes': notes,
  };

  factory ExerciseLog.fromMap(Map<String, dynamic> map) => ExerciseLog(
    id: map['id'],
    workoutLogId: map['workoutLogId'],
    exerciseName: map['exerciseName'],
    completed: map['completed'] == 1,
    sets: [],
    notes: map['notes'],
  );
}

class SetLog {
  final int? id;
  final int exerciseLogId;
  final int setNumber;
  final double? weight; // kg
  final int? reps;
  final int? durationSeconds;
  final bool completed;

  SetLog({
    this.id,
    required this.exerciseLogId,
    required this.setNumber,
    this.weight,
    this.reps,
    this.durationSeconds,
    required this.completed,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'exerciseLogId': exerciseLogId,
    'setNumber': setNumber,
    'weight': weight,
    'reps': reps,
    'durationSeconds': durationSeconds,
    'completed': completed ? 1 : 0,
  };

  factory SetLog.fromMap(Map<String, dynamic> map) => SetLog(
    id: map['id'],
    exerciseLogId: map['exerciseLogId'],
    setNumber: map['setNumber'],
    weight: map['weight']?.toDouble(),
    reps: map['reps'],
    durationSeconds: map['durationSeconds'],
    completed: map['completed'] == 1,
  );
}

// Body metrics tracking
class BodyMetric {
  final int? id;
  final DateTime date;
  final double? weight; // kg
  final double? bodyFatPercent;
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  final double? armCm;
  final double? thighCm;
  final String? notes;

  BodyMetric({
    this.id,
    required this.date,
    this.weight,
    this.bodyFatPercent,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.armCm,
    this.thighCm,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'weight': weight,
    'bodyFatPercent': bodyFatPercent,
    'chestCm': chestCm,
    'waistCm': waistCm,
    'hipsCm': hipsCm,
    'armCm': armCm,
    'thighCm': thighCm,
    'notes': notes,
  };

  factory BodyMetric.fromMap(Map<String, dynamic> map) => BodyMetric(
    id: map['id'],
    date: DateTime.parse(map['date']),
    weight: map['weight']?.toDouble(),
    bodyFatPercent: map['bodyFatPercent']?.toDouble(),
    chestCm: map['chestCm']?.toDouble(),
    waistCm: map['waistCm']?.toDouble(),
    hipsCm: map['hipsCm']?.toDouble(),
    armCm: map['armCm']?.toDouble(),
    thighCm: map['thighCm']?.toDouble(),
    notes: map['notes'],
  );
}

// Custom plan (for post-84-day plans or modifications)
class CustomPlan {
  final int? id;
  final String name;
  final String description;
  final DateTime startDate;
  final int totalDays;
  final DateTime createdAt;
  final bool isActive;

  CustomPlan({
    this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.totalDays,
    required this.createdAt,
    required this.isActive,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'totalDays': totalDays,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive ? 1 : 0,
  };

  factory CustomPlan.fromMap(Map<String, dynamic> map) => CustomPlan(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    startDate: DateTime.parse(map['startDate']),
    totalDays: map['totalDays'],
    createdAt: DateTime.parse(map['createdAt']),
    isActive: map['isActive'] == 1,
  );
}
