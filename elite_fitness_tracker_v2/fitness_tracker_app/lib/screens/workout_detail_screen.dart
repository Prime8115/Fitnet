// lib/screens/workout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../data/workout_data.dart';
import '../utils/app_theme.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutDay workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final Map<String, bool> _completedExercises = {};
  final Stopwatch _stopwatch = Stopwatch();
  late Stream<int> _timerStream;
  bool _workoutStarted = false;
  int _elapsedSeconds = 0;
  int _feelingRating = 4;
  int _energyLevel = 4;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
    // Initialize exercise completion map
    for (final section in widget.workout.sections) {
      for (final exercise in section.exercises) {
        _completedExercises[exercise.name] = false;
      }
    }
    for (final ex in widget.workout.coreFinisher) {
      _completedExercises[ex.name] = false;
    }
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _notesController.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (widget.workout.type) {
      case WorkoutType.push: return AppColors.push;
      case WorkoutType.pull: return AppColors.pull;
      case WorkoutType.legs: return AppColors.legs;
      case WorkoutType.combat: return AppColors.cyan;
      case WorkoutType.fullBody: return AppColors.violet;
      case WorkoutType.rest: return AppColors.mute;
      case WorkoutType.deload: return AppColors.pink;
    }
  }

  int get _totalExercises => _completedExercises.length;
  int get _doneExercises => _completedExercises.values.where((v) => v).length;
  double get _exerciseProgress =>
      _totalExercises > 0 ? _doneExercises / _totalExercises : 0;

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleExercise(String name) {
    HapticFeedback.lightImpact();
    setState(() => _completedExercises[name] = !(_completedExercises[name] ?? false));
  }

  void _startWorkout() {
    HapticFeedback.mediumImpact();
    setState(() => _workoutStarted = true);
    _stopwatch.start();
    // Update timer every second
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted && _stopwatch.isRunning) {
        setState(() => _elapsedSeconds = _stopwatch.elapsed.inSeconds);
      }
    });
  }

  void _showCompleteDialog() {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card2,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _CompleteWorkoutSheet(
        workout: widget.workout,
        durationMinutes: _stopwatch.elapsed.inMinutes,
        initialFeeling: _feelingRating,
        initialEnergy: _energyLevel,
        notesController: _notesController,
        onComplete: (feeling, energy, notes) async {
          _stopwatch.stop();
          final provider = Provider.of<FitnessProvider>(context, listen: false);
          await provider.markWorkoutComplete(
            dayNumber: widget.workout.dayNumber,
            durationMinutes: _stopwatch.elapsed.inMinutes.clamp(1, 999),
            feelingRating: feeling,
            energyLevel: energy,
            notes: notes,
          );
          if (mounted) {
            Navigator.pop(ctx);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(children: [
                  Text('💪  Workout complete! Great job!',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                ]),
                backgroundColor: AppColors.lime,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = Provider.of<FitnessProvider>(context)
        .isDayCompleted(widget.workout.dayNumber);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar ──
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.card2, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border2)),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
              ),
            ),
            actions: [
              if (isCompleted)
                Container(
                  margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lime.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lime.withOpacity(0.4)),
                  ),
                  child: const Center(child: Text('COMPLETED ✓',
                    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9,
                      color: AppColors.lime, letterSpacing: 1))),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_typeColor.withOpacity(0.18), AppColors.bg],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _typeColor.withOpacity(0.4)),
                        ),
                        child: Text('WEEK ${widget.workout.weekNumber} · ${widget.workout.phaseLabel}',
                          style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9,
                            color: _typeColor, letterSpacing: 1)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('DAY ${widget.workout.dayNumber}',
                          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9,
                            color: AppColors.dim, letterSpacing: 1)),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(widget.workout.label,
                      style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32,
                        color: _typeColor, letterSpacing: 2)),
                    Text(widget.workout.focus,
                      style: const TextStyle(fontSize: 12, color: AppColors.dim)),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Timer / Start ──
                  if (!isCompleted) _WorkoutTimer(
                    workoutStarted: _workoutStarted,
                    elapsedSeconds: _elapsedSeconds,
                    onStart: _startWorkout,
                    typeColor: _typeColor,
                    formatTime: _formatTime,
                  ),

                  // ── Exercise Progress ──
                  if (_workoutStarted) ...[
                    const SizedBox(height: 14),
                    _ExerciseProgress(done: _doneExercises, total: _totalExercises,
                      progress: _exerciseProgress, typeColor: _typeColor),
                  ],

                  const SizedBox(height: 18),

                  // ── Warm Up ──
                  if (widget.workout.warmup.isNotEmpty) ...[
                    _WarmupCard(warmup: widget.workout.warmup),
                    const SizedBox(height: 18),
                  ],

                  // ── Exercise Sections ──
                  ...widget.workout.sections.map((section) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(name: section.name, typeColor: _typeColor),
                      const SizedBox(height: 8),
                      ...section.exercises.map((ex) => _ExerciseItem(
                        exercise: ex,
                        isCompleted: _completedExercises[ex.name] ?? false,
                        typeColor: _typeColor,
                        onTap: () => _toggleExercise(ex.name),
                      )),
                      const SizedBox(height: 14),
                    ],
                  )),

                  // ── Core Finisher ──
                  if (widget.workout.coreFinisher.isNotEmpty) ...[
                    _CoreFinisherSection(
                      exercises: widget.workout.coreFinisher,
                      completed: _completedExercises,
                      onToggle: _toggleExercise,
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ── Complete Button ──
                  if (!isCompleted && _workoutStarted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showCompleteDialog,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('MARK WORKOUT COMPLETE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _doneExercises == _totalExercises
                              ? AppColors.lime : _typeColor,
                          foregroundColor: _doneExercises == _totalExercises
                              ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontFamily: 'BebasNeue', fontSize: 18, letterSpacing: 2),
                        ),
                      ),
                    ),
                  ] else if (!isCompleted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showCompleteDialog,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Mark as Done Without Timer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.dim,
                          side: const BorderSide(color: AppColors.border2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── FAB to start ──
      floatingActionButton: !_workoutStarted && !isCompleted
          ? FloatingActionButton.extended(
              onPressed: _startWorkout,
              backgroundColor: _typeColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('START', style: TextStyle(
                fontFamily: 'BebasNeue', fontSize: 18, letterSpacing: 2)),
            )
          : null,
    );
  }
}

// ── Workout Timer ─────────────────────────────────────────────────────────────

class _WorkoutTimer extends StatelessWidget {
  final bool workoutStarted;
  final int elapsedSeconds;
  final VoidCallback onStart;
  final Color typeColor;
  final String Function(int) formatTime;

  const _WorkoutTimer({required this.workoutStarted, required this.elapsedSeconds,
    required this.onStart, required this.typeColor, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border2),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_rounded, color: typeColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ELAPSED TIME', style: TextStyle(
                  fontFamily: 'JetBrainsMono', fontSize: 9,
                  color: AppColors.mute, letterSpacing: 2)),
                Text(
                  workoutStarted ? formatTime(elapsedSeconds) : '00:00',
                  style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32,
                    color: typeColor, letterSpacing: 2),
                ),
              ],
            ),
          ),
          if (!workoutStarted)
            ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('START'),
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor, foregroundColor: Colors.white),
            ),
        ],
      ),
    );
  }
}

// ── Exercise Progress ─────────────────────────────────────────────────────────

class _ExerciseProgress extends StatelessWidget {
  final int done, total;
  final double progress;
  final Color typeColor;
  const _ExerciseProgress({required this.done, required this.total,
    required this.progress, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border2)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('EXERCISES', style: TextStyle(fontFamily: 'JetBrainsMono',
            fontSize: 9, color: AppColors.mute, letterSpacing: 2)),
          Text('$done / $total', style: TextStyle(color: typeColor,
            fontFamily: 'JetBrainsMono', fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress, backgroundColor: AppColors.border2,
            valueColor: AlwaysStoppedAnimation(typeColor), minHeight: 6),
        ),
      ]),
    );
  }
}

// ── Warmup Card ───────────────────────────────────────────────────────────────

class _WarmupCard extends StatelessWidget {
  final String warmup;
  const _WarmupCard({required this.warmup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: AppColors.amber, width: 3)),
      ),
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('WARM-UP', style: TextStyle(fontFamily: 'JetBrainsMono',
            fontSize: 9, color: AppColors.amber, letterSpacing: 2)),
          const SizedBox(height: 3),
          Text(warmup, style: const TextStyle(fontSize: 12, color: AppColors.dim, height: 1.4)),
        ])),
      ]),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String name;
  final Color typeColor;
  const _SectionHeader({required this.name, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: typeColor.withOpacity(0.2)),
      ),
      child: Text(name, style: TextStyle(fontFamily: 'JetBrainsMono',
        fontSize: 9, color: typeColor, letterSpacing: 2)),
    );
  }
}

// ── Exercise Item ─────────────────────────────────────────────────────────────

class _ExerciseItem extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final Color typeColor;
  final VoidCallback onTap;

  const _ExerciseItem({required this.exercise, required this.isCompleted,
    required this.typeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.lime.withOpacity(0.06)
              : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? AppColors.lime.withOpacity(0.3)
                : AppColors.border),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.lime : AppColors.border2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCompleted ? AppColors.lime : AppColors.border2),
            ),
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.black, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise.name,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isCompleted ? AppColors.dim : AppColors.text,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.mute,
              )),
            if (exercise.note != null) ...[
              const SizedBox(height: 2),
              Text(exercise.note!, style: const TextStyle(
                fontSize: 11, color: AppColors.mute)),
            ],
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(exercise.muscleGroup,
                style: const TextStyle(fontSize: 10, color: AppColors.mute)),
            ),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(exercise.sets,
              style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12,
                color: isCompleted ? AppColors.lime : typeColor,
                fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }
}

// ── Core Finisher Section ─────────────────────────────────────────────────────

class _CoreFinisherSection extends StatelessWidget {
  final List<Exercise> exercises;
  final Map<String, bool> completed;
  final Function(String) onToggle;

  const _CoreFinisherSection({
    required this.exercises, required this.completed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lime.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lime.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('⬡', style: TextStyle(color: AppColors.lime, fontSize: 16)),
          const SizedBox(width: 8),
          const Text('CORE FINISHER', style: TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 10,
            color: AppColors.lime, letterSpacing: 2)),
        ]),
        const SizedBox(height: 10),
        ...exercises.map((ex) => GestureDetector(
          onTap: () => onToggle(ex.name),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: (completed[ex.name] ?? false) ? AppColors.lime : AppColors.border2,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: (completed[ex.name] ?? false)
                    ? const Icon(Icons.check_rounded, color: Colors.black, size: 12)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(ex.name,
                style: TextStyle(fontSize: 13,
                  color: (completed[ex.name] ?? false) ? AppColors.dim : AppColors.text,
                  decoration: (completed[ex.name] ?? false) ? TextDecoration.lineThrough : null))),
              Text(ex.sets, style: const TextStyle(
                fontFamily: 'JetBrainsMono', fontSize: 11, color: AppColors.lime)),
            ]),
          ),
        )),
      ]),
    );
  }
}

// ── Complete Workout Sheet ────────────────────────────────────────────────────

class _CompleteWorkoutSheet extends StatefulWidget {
  final WorkoutDay workout;
  final int durationMinutes;
  final int initialFeeling;
  final int initialEnergy;
  final TextEditingController notesController;
  final Function(int feeling, int energy, String notes) onComplete;

  const _CompleteWorkoutSheet({
    required this.workout, required this.durationMinutes,
    required this.initialFeeling, required this.initialEnergy,
    required this.notesController, required this.onComplete,
  });

  @override
  State<_CompleteWorkoutSheet> createState() => _CompleteWorkoutSheetState();
}

class _CompleteWorkoutSheetState extends State<_CompleteWorkoutSheet> {
  late int _feeling;
  late int _energy;

  @override
  void initState() {
    super.initState();
    _feeling = widget.initialFeeling;
    _energy = widget.initialEnergy;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border2,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('WORKOUT COMPLETE! 💪', style: TextStyle(
            fontFamily: 'BebasNeue', fontSize: 26, color: AppColors.lime, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('${widget.durationMinutes} min · Day ${widget.workout.dayNumber}',
            style: const TextStyle(color: AppColors.dim, fontSize: 13)),
          const SizedBox(height: 20),

          // Feeling rating
          const Text('HOW DID IT FEEL?', style: TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 9,
            color: AppColors.mute, letterSpacing: 2)),
          const SizedBox(height: 8),
          Row(children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _feeling = i + 1),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(['😫','😕','😐','😊','🔥'][i],
                style: TextStyle(fontSize: _feeling == i + 1 ? 32 : 24)),
            ),
          ))),
          const SizedBox(height: 16),

          // Energy level
          const Text('ENERGY LEVEL', style: TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 9,
            color: AppColors.mute, letterSpacing: 2)),
          const SizedBox(height: 8),
          Row(children: List.generate(5, (i) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _energy = i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 36,
                margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                decoration: BoxDecoration(
                  color: _energy >= i + 1
                      ? AppColors.amber.withOpacity(0.3)
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _energy >= i + 1 ? AppColors.amber : AppColors.border2),
                ),
                child: Center(child: Text('${i + 1}',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    color: _energy >= i + 1 ? AppColors.amber : AppColors.mute,
                    fontWeight: FontWeight.w700))),
              ),
            ),
          ))),
          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: widget.notesController,
            maxLines: 2,
            style: const TextStyle(color: AppColors.text, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Notes, PRs, how you felt... (optional)',
              prefixIcon: Icon(Icons.notes_rounded, color: AppColors.mute, size: 18),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onComplete(_feeling, _energy, widget.notesController.text),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('SAVE WORKOUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lime, foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontFamily: 'BebasNeue', fontSize: 18, letterSpacing: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
