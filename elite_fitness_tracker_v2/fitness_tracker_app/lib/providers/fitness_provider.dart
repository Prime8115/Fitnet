// lib/providers/fitness_provider.dart

import 'package:flutter/foundation.dart';
import '../data/workout_data.dart';
import '../models/workout_log.dart';
import '../utils/database_helper.dart';

class FitnessProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<WorkoutDay> _plan = [];
  Map<int, WorkoutLog> _logs = {}; // dayNumber → log
  List<BodyMetric> _bodyMetrics = [];
  Map<String, dynamic> _stats = {};
  DateTime _planStartDate = DateTime(2025, 4, 10);
  int _planTotalDays = 84;
  bool _isLoading = true;
  int _selectedDayIndex = 0; // currently viewed day

  // Getters
  List<WorkoutDay> get plan => _plan;
  Map<int, WorkoutLog> get logs => _logs;
  List<BodyMetric> get bodyMetrics => _bodyMetrics;
  Map<String, dynamic> get stats => _stats;
  DateTime get planStartDate => _planStartDate;
  int get planTotalDays => _planTotalDays;
  bool get isLoading => _isLoading;
  int get selectedDayIndex => _selectedDayIndex;

  WorkoutDay? get todayWorkout {
    final today = DateTime.now();
    final dayNum = today.difference(_planStartDate).inDays + 1;
    if (dayNum < 1 || dayNum > _planTotalDays) return null;
    return _plan.isNotEmpty && dayNum <= _plan.length ? _plan[dayNum - 1] : null;
  }

  int get currentDayNumber {
    final today = DateTime.now();
    return today.difference(_planStartDate).inDays + 1;
  }

  double get overallProgress {
    if (_planTotalDays == 0) return 0;
    final completed = _logs.values.where((l) => l.completed).length;
    return completed / _planTotalDays;
  }

  WorkoutDay? getWorkoutForDay(int dayNumber) {
    if (dayNumber < 1 || dayNumber > _plan.length) return null;
    return _plan[dayNumber - 1];
  }

  WorkoutLog? getLogForDay(int dayNumber) => _logs[dayNumber];

  bool isDayCompleted(int dayNumber) => _logs[dayNumber]?.completed ?? false;

  // Initialize
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _planStartDate = await _db.getPlanStartDate();
    _planTotalDays = await _db.getPlanTotalDays();
    _plan = FitnessPlan.generatePlan(
      startDate: _planStartDate,
      totalDays: _planTotalDays,
    );

    await _loadLogs();
    await _loadBodyMetrics();
    await _loadStats();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadLogs() async {
    final allLogs = await _db.getAllCompletedLogs();
    _logs = {for (var l in allLogs) l.dayNumber: l};
  }

  Future<void> _loadBodyMetrics() async {
    _bodyMetrics = await _db.getAllBodyMetrics();
  }

  Future<void> _loadStats() async {
    _stats = await _db.getStats();
  }

  // Mark workout as complete
  Future<void> markWorkoutComplete({
    required int dayNumber,
    required int durationMinutes,
    required int feelingRating,
    required int energyLevel,
    String? notes,
  }) async {
    final existing = await _db.getWorkoutLogByDay(dayNumber);

    if (existing != null) {
      final updated = existing.copyWith(
        completed: true,
        completedAt: DateTime.now(),
        durationMinutes: durationMinutes,
        feelingRating: feelingRating,
        energyLevel: energyLevel,
        notes: notes,
      );
      await _db.updateWorkoutLog(updated);
      _logs[dayNumber] = updated;
    } else {
      final workout = getWorkoutForDay(dayNumber);
      final log = WorkoutLog(
        dayNumber: dayNumber,
        date: workout?.date ?? DateTime.now(),
        completed: true,
        completedAt: DateTime.now(),
        durationMinutes: durationMinutes,
        notes: notes,
        exerciseLogs: [],
        feelingRating: feelingRating,
        energyLevel: energyLevel,
      );
      final id = await _db.insertWorkoutLog(log);
      _logs[dayNumber] = log.copyWith(id: id);
    }

    await _loadStats();
    notifyListeners();
  }

  // Unmark workout
  Future<void> unmarkWorkoutComplete(int dayNumber) async {
    final existing = _logs[dayNumber];
    if (existing == null) return;
    final updated = existing.copyWith(completed: false, completedAt: null);
    await _db.updateWorkoutLog(updated);
    _logs[dayNumber] = updated;
    await _loadStats();
    notifyListeners();
  }

  // Add body metric
  Future<void> addBodyMetric(BodyMetric metric) async {
    await _db.insertBodyMetric(metric);
    await _loadBodyMetrics();
    notifyListeners();
  }

  // Extend or modify plan (post-84 days)
  Future<void> extendPlan({
    required int additionalDays,
    String? newPlanName,
  }) async {
    _planTotalDays += additionalDays;
    await _db.setSetting('plan_total_days', _planTotalDays.toString());

    _plan = FitnessPlan.generatePlan(
      startDate: _planStartDate,
      totalDays: _planTotalDays,
    );

    if (newPlanName != null) {
      final customPlan = CustomPlan(
        name: newPlanName,
        description: 'Extended plan: $_planTotalDays days total',
        startDate: _planStartDate,
        totalDays: _planTotalDays,
        createdAt: DateTime.now(),
        isActive: true,
      );
      await _db.insertCustomPlan(customPlan);
    }

    notifyListeners();
  }

  // Start a brand new plan cycle (post-3 months)
  Future<void> startNewPlanCycle({
    required DateTime newStartDate,
    int days = 84,
    String planName = 'Cycle 2',
  }) async {
    _planStartDate = newStartDate;
    _planTotalDays = days;

    await _db.setSetting('plan_start_date', newStartDate.toIso8601String());
    await _db.setSetting('plan_total_days', days.toString());

    _plan = FitnessPlan.generatePlan(
      startDate: newStartDate,
      totalDays: days,
    );
    _logs.clear();

    final customPlan = CustomPlan(
      name: planName,
      description: 'New $days-day cycle starting ${newStartDate.toString().split(' ')[0]}',
      startDate: newStartDate,
      totalDays: days,
      createdAt: DateTime.now(),
      isActive: true,
    );
    await _db.insertCustomPlan(customPlan);

    notifyListeners();
  }

  void setSelectedDay(int index) {
    _selectedDayIndex = index;
    notifyListeners();
  }

  // Get phase breakdown
  Map<String, int> get phaseBreakdown {
    final p1 = _logs.values.where((l) => l.completed && l.dayNumber <= 28).length;
    final p2 = _logs.values.where((l) => l.completed && l.dayNumber > 28 && l.dayNumber <= 56).length;
    final p3 = _logs.values.where((l) => l.completed && l.dayNumber > 56).length;
    return {'Phase 1': p1, 'Phase 2': p2, 'Phase 3': p3};
  }

  // Get weekly completion for chart
  List<Map<String, dynamic>> getWeeklyCompletion() {
    final weeks = <Map<String, dynamic>>[];
    for (int w = 1; w <= (_planTotalDays ~/ 7) + 1 && w <= 12; w++) {
      final startDay = (w - 1) * 7 + 1;
      final endDay = (w * 7).clamp(1, _planTotalDays);
      int completed = 0, total = 0;
      for (int d = startDay; d <= endDay; d++) {
        final workout = getWorkoutForDay(d);
        if (workout != null && workout.type != WorkoutType.rest) {
          total++;
          if (isDayCompleted(d)) completed++;
        }
      }
      weeks.add({'week': w, 'completed': completed, 'total': total});
    }
    return weeks;
  }
}
