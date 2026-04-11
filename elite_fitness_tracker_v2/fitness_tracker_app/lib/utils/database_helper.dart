// lib/utils/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout_log.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('elite_fitness.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dayNumber INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        durationMinutes INTEGER DEFAULT 0,
        notes TEXT,
        feelingRating INTEGER DEFAULT 0,
        energyLevel INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutLogId INTEGER NOT NULL,
        exerciseName TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (workoutLogId) REFERENCES workout_logs(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE set_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseLogId INTEGER NOT NULL,
        setNumber INTEGER NOT NULL,
        weight REAL,
        reps INTEGER,
        durationSeconds INTEGER,
        completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (exerciseLogId) REFERENCES exercise_logs(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE body_metrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        weight REAL,
        bodyFatPercent REAL,
        chestCm REAL,
        waistCm REAL,
        hipsCm REAL,
        armCm REAL,
        thighCm REAL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        startDate TEXT NOT NULL,
        totalDays INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('app_settings', {'key': 'plan_start_date', 'value': '2025-04-10'});
    await db.insert('app_settings', {'key': 'plan_total_days', 'value': '84'});
    await db.insert('app_settings', {'key': 'notifications_enabled', 'value': 'true'});
    await db.insert('app_settings', {'key': 'notification_time', 'value': '07:00'});
    await db.insert('app_settings', {'key': 'user_weight_kg', 'value': '68'});
    await db.insert('app_settings', {'key': 'user_height_cm', 'value': '165'});
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE workout_logs ADD COLUMN feelingRating INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE workout_logs ADD COLUMN energyLevel INTEGER DEFAULT 0');
    }
  }

  // ── WORKOUT LOGS ──────────────────────────────────────────────────────────

  Future<int> insertWorkoutLog(WorkoutLog log) async {
    final db = await database;
    return await db.insert('workout_logs', log.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<WorkoutLog?> getWorkoutLogByDay(int dayNumber) async {
    final db = await database;
    final maps = await db.query('workout_logs',
        where: 'dayNumber = ?', whereArgs: [dayNumber]);
    if (maps.isEmpty) return null;
    final log = WorkoutLog.fromMap(maps.first);
    final exerciseLogs = await getExerciseLogsForWorkout(log.id!);
    return log.copyWith(exerciseLogs: exerciseLogs);
  }

  Future<int> updateWorkoutLog(WorkoutLog log) async {
    final db = await database;
    return await db.update('workout_logs', log.toMap(),
        where: 'id = ?', whereArgs: [log.id]);
  }

  Future<List<WorkoutLog>> getAllCompletedLogs() async {
    final db = await database;
    final maps = await db.query('workout_logs',
        where: 'completed = 1', orderBy: 'date DESC');
    return maps.map((m) => WorkoutLog.fromMap(m)).toList();
  }

  Future<int> getCompletedCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM workout_logs WHERE completed = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCurrentStreak() async {
    final db = await database;
    final logs = await db.query('workout_logs',
        where: 'completed = 1', orderBy: 'date DESC');
    if (logs.isEmpty) return 0;

    int streak = 0;
    DateTime? prevDate;

    for (final log in logs) {
      final date = DateTime.parse(log['date'] as String);
      // Skip rest days (type doesn't need tracking for streak)
      if (prevDate == null) {
        final today = DateTime.now();
        final diff = today.difference(date).inDays;
        if (diff > 1) break; // Gap of more than 1 day breaks streak
        streak++;
        prevDate = date;
      } else {
        final diff = prevDate.difference(date).inDays;
        if (diff <= 1) {
          streak++;
          prevDate = date;
        } else {
          break;
        }
      }
    }
    return streak;
  }

  // ── EXERCISE LOGS ─────────────────────────────────────────────────────────

  Future<int> insertExerciseLog(ExerciseLog log) async {
    final db = await database;
    return await db.insert('exercise_logs', log.toMap()..remove('id'));
  }

  Future<List<ExerciseLog>> getExerciseLogsForWorkout(int workoutLogId) async {
    final db = await database;
    final maps = await db.query('exercise_logs',
        where: 'workoutLogId = ?', whereArgs: [workoutLogId]);
    final logs = <ExerciseLog>[];
    for (final m in maps) {
      final exLog = ExerciseLog.fromMap(m);
      final sets = await getSetLogsForExercise(exLog.id!);
      logs.add(ExerciseLog(
        id: exLog.id,
        workoutLogId: exLog.workoutLogId,
        exerciseName: exLog.exerciseName,
        completed: exLog.completed,
        sets: sets,
        notes: exLog.notes,
      ));
    }
    return logs;
  }

  Future<int> updateExerciseLog(ExerciseLog log) async {
    final db = await database;
    return await db.update('exercise_logs', log.toMap(),
        where: 'id = ?', whereArgs: [log.id]);
  }

  // ── SET LOGS ──────────────────────────────────────────────────────────────

  Future<int> insertSetLog(SetLog log) async {
    final db = await database;
    return await db.insert('set_logs', log.toMap()..remove('id'));
  }

  Future<List<SetLog>> getSetLogsForExercise(int exerciseLogId) async {
    final db = await database;
    final maps = await db.query('set_logs',
        where: 'exerciseLogId = ?', whereArgs: [exerciseLogId],
        orderBy: 'setNumber ASC');
    return maps.map((m) => SetLog.fromMap(m)).toList();
  }

  Future<int> updateSetLog(SetLog log) async {
    final db = await database;
    return await db.update('set_logs', log.toMap(),
        where: 'id = ?', whereArgs: [log.id]);
  }

  // ── BODY METRICS ──────────────────────────────────────────────────────────

  Future<int> insertBodyMetric(BodyMetric metric) async {
    final db = await database;
    return await db.insert('body_metrics', metric.toMap()..remove('id'));
  }

  Future<List<BodyMetric>> getAllBodyMetrics() async {
    final db = await database;
    final maps = await db.query('body_metrics', orderBy: 'date ASC');
    return maps.map((m) => BodyMetric.fromMap(m)).toList();
  }

  Future<BodyMetric?> getLatestBodyMetric() async {
    final db = await database;
    final maps = await db.query('body_metrics', orderBy: 'date DESC', limit: 1);
    if (maps.isEmpty) return null;
    return BodyMetric.fromMap(maps.first);
  }

  // ── SETTINGS ──────────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('app_settings',
        where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('app_settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DateTime> getPlanStartDate() async {
    final val = await getSetting('plan_start_date');
    return val != null ? DateTime.parse(val) : DateTime(2025, 4, 10);
  }

  Future<int> getPlanTotalDays() async {
    final val = await getSetting('plan_total_days');
    return val != null ? int.parse(val) : 84;
  }

  // ── CUSTOM PLANS ──────────────────────────────────────────────────────────

  Future<int> insertCustomPlan(CustomPlan plan) async {
    final db = await database;
    return await db.insert('custom_plans', plan.toMap()..remove('id'));
  }

  Future<List<CustomPlan>> getAllCustomPlans() async {
    final db = await database;
    final maps = await db.query('custom_plans', orderBy: 'createdAt DESC');
    return maps.map((m) => CustomPlan.fromMap(m)).toList();
  }

  Future<void> setActivePlan(int planId) async {
    final db = await database;
    await db.update('custom_plans', {'isActive': 0}); // deactivate all
    await db.update('custom_plans', {'isActive': 1},
        where: 'id = ?', whereArgs: [planId]);
  }

  // ── STATS ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    final completed = await getCompletedCount();
    final streak = await getCurrentStreak();
    final totalMinutes = await db.rawQuery(
        'SELECT SUM(durationMinutes) as total FROM workout_logs WHERE completed = 1');
    final avgRating = await db.rawQuery(
        'SELECT AVG(feelingRating) as avg FROM workout_logs WHERE completed = 1 AND feelingRating > 0');

    return {
      'completedWorkouts': completed,
      'currentStreak': streak,
      'totalMinutes': Sqflite.firstIntValue(totalMinutes) ?? 0,
      'avgRating': (avgRating.first['avg'] as double?) ?? 0.0,
    };
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
