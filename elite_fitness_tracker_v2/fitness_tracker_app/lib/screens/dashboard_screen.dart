// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fitness_provider.dart';
import '../data/workout_data.dart';
import '../utils/app_theme.dart';
import 'workout_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(child: CircularProgressIndicator(color: AppColors.red)),
          );
        }

        final today = provider.todayWorkout;
        final dayNum = provider.currentDayNumber;
        final stats = provider.stats;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              // ── App Bar ──
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.bg,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0x28F03A47), AppColors.bg],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono', fontSize: 10,
                            color: AppColors.mute, letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text('YOUR TRAINING', style: TextStyle(
                          fontFamily: 'BebasNeue', fontSize: 36,
                          color: Colors.white, letterSpacing: 3,
                        )),
                        Text('DAY ${dayNum.clamp(1, provider.planTotalDays)} OF ${provider.planTotalDays}',
                          style: const TextStyle(
                            fontFamily: 'BebasNeue', fontSize: 36,
                            color: AppColors.red, letterSpacing: 3,
                          )),
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
                      // ── Progress Bar ──
                      _ProgressSection(provider: provider),
                      const SizedBox(height: 20),

                      // ── Stats Row ──
                      _StatsRow(stats: stats, provider: provider),
                      const SizedBox(height: 20),

                      // ── Today's Workout Card ──
                      if (today != null) ...[
                        const _SectionTitle(title: "TODAY'S WORKOUT"),
                        const SizedBox(height: 10),
                        _TodayWorkoutCard(workout: today, provider: provider),
                        const SizedBox(height: 20),
                      ] else ...[
                        _PlanCompleteCard(provider: provider),
                        const SizedBox(height: 20),
                      ],

                      // ── Upcoming Days ──
                      const _SectionTitle(title: 'UPCOMING'),
                      const SizedBox(height: 10),
                      _UpcomingDays(provider: provider),
                      const SizedBox(height: 20),

                      // ── Phase Info ──
                      if (today != null) _PhaseInfoCard(workout: today),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Progress Section ──────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final FitnessProvider provider;
  const _ProgressSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final completed = provider.logs.values.where((l) => l.completed).length;
    final total = provider.planTotalDays;
    final pct = (completed / total * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('OVERALL PROGRESS', style: TextStyle(
                fontFamily: 'JetBrainsMono', fontSize: 10,
                color: AppColors.mute, letterSpacing: 2,
              )),
              Text('$completed / $total days',
                style: const TextStyle(fontSize: 12, color: AppColors.dim, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: provider.overallProgress,
              backgroundColor: AppColors.border2,
              valueColor: const AlwaysStoppedAnimation(AppColors.red),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$pct% complete', style: const TextStyle(
                fontFamily: 'JetBrainsMono', fontSize: 10, color: AppColors.amber)),
              Row(children: [
                _PhaseChip(label: 'P1', active: provider.currentDayNumber <= 28),
                const SizedBox(width: 6),
                _PhaseChip(label: 'P2', active: provider.currentDayNumber > 28 && provider.currentDayNumber <= 56),
                const SizedBox(width: 6),
                _PhaseChip(label: 'P3', active: provider.currentDayNumber > 56),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final String label;
  final bool active;
  const _PhaseChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.red.withOpacity(0.2) : AppColors.border,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: active ? AppColors.red : AppColors.border2),
      ),
      child: Text(label, style: TextStyle(
        fontFamily: 'JetBrainsMono', fontSize: 9,
        color: active ? AppColors.red : AppColors.mute,
        letterSpacing: 1,
      )),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  final FitnessProvider provider;
  const _StatsRow({required this.stats, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(
          value: '${stats['completedWorkouts'] ?? 0}',
          label: 'COMPLETED',
          color: AppColors.lime,
          icon: Icons.check_circle_rounded,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          value: '${stats['currentStreak'] ?? 0}🔥',
          label: 'STREAK',
          color: AppColors.amber,
          icon: Icons.local_fire_department_rounded,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          value: '${((stats['totalMinutes'] ?? 0) / 60).toStringAsFixed(0)}h',
          label: 'TRAINED',
          color: AppColors.cyan,
          icon: Icons.timer_rounded,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _StatCard({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(
            fontFamily: 'BebasNeue', fontSize: 26,
            color: color, letterSpacing: 1,
          )),
          Text(label, style: const TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 8,
            color: AppColors.mute, letterSpacing: 1.5,
          )),
        ],
      ),
    );
  }
}

// ── Today's Workout Card ──────────────────────────────────────────────────────

class _TodayWorkoutCard extends StatelessWidget {
  final WorkoutDay workout;
  final FitnessProvider provider;
  const _TodayWorkoutCard({required this.workout, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isCompleted = provider.isDayCompleted(workout.dayNumber);
    final typeColor = _workoutColor(workout.type);

    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? AppColors.lime : typeColor.withOpacity(0.5),
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [typeColor.withOpacity(0.15), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: typeColor.withOpacity(0.4)),
                    ),
                    child: Center(child: Text(workout.type.emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(workout.label, style: TextStyle(
                          fontFamily: 'BebasNeue', fontSize: 22,
                          color: typeColor, letterSpacing: 2,
                        )),
                        Text(workout.focus, style: const TextStyle(
                          fontSize: 11, color: AppColors.dim)),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.lime.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.lime.withOpacity(0.4)),
                      ),
                      child: const Text('DONE ✓', style: TextStyle(
                        fontFamily: 'JetBrainsMono', fontSize: 9,
                        color: AppColors.lime, letterSpacing: 1,
                      )),
                    ),
                ],
              ),
            ),
            // Exercise Preview
            if (workout.type != WorkoutType.rest) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    ...workout.sections.take(2).expand((s) =>
                      s.exercises.take(2).map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4, height: 4,
                              decoration: BoxDecoration(
                                color: typeColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(e.name, style: const TextStyle(
                              fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w500))),
                            Text(e.sets, style: const TextStyle(
                              fontFamily: 'JetBrainsMono', fontSize: 11, color: AppColors.dim)),
                          ],
                        ),
                      ))
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.more_horiz, color: AppColors.mute, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '+${workout.sections.fold(0, (sum, s) => sum + s.exercises.length) - 4} more exercises',
                          style: const TextStyle(fontSize: 11, color: AppColors.mute),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // CTA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCompleted
                    ? AppColors.lime.withOpacity(0.08)
                    : typeColor.withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                      color: isCompleted ? AppColors.lime : typeColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCompleted ? 'VIEW WORKOUT' : 'START WORKOUT',
                      style: TextStyle(
                        fontFamily: 'BebasNeue', fontSize: 16,
                        color: isCompleted ? AppColors.lime : typeColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                      color: isCompleted ? AppColors.lime : typeColor, size: 16),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _workoutColor(WorkoutType t) {
    switch (t) {
      case WorkoutType.push: return AppColors.push;
      case WorkoutType.pull: return AppColors.pull;
      case WorkoutType.legs: return AppColors.legs;
      case WorkoutType.combat: return AppColors.cyan;
      case WorkoutType.fullBody: return AppColors.violet;
      case WorkoutType.rest: return AppColors.mute;
      case WorkoutType.deload: return AppColors.pink;
    }
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(
          fontFamily: 'BebasNeue', fontSize: 18,
          color: Colors.white, letterSpacing: 2,
        )),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.border2, height: 1)),
      ],
    );
  }
}

// ── Upcoming Days ─────────────────────────────────────────────────────────────

class _UpcomingDays extends StatelessWidget {
  final FitnessProvider provider;
  const _UpcomingDays({required this.provider});

  @override
  Widget build(BuildContext context) {
    final currentDay = provider.currentDayNumber;
    final nextDays = List.generate(5, (i) => currentDay + 1 + i)
        .where((d) => d <= provider.planTotalDays)
        .toList();

    if (nextDays.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: nextDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final dayNum = nextDays[i];
          final workout = provider.getWorkoutForDay(dayNum);
          if (workout == null) return const SizedBox.shrink();
          final typeColor = _typeColor(workout.type);
          final isCompleted = provider.isDayCompleted(dayNum);

          return GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout))),
            child: Container(
              width: 80,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.lime.withOpacity(0.08) : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted ? AppColors.lime.withOpacity(0.3) : AppColors.border2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(workout.type.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text('Day $dayNum', style: const TextStyle(
                    fontFamily: 'JetBrainsMono', fontSize: 9,
                    color: AppColors.mute, letterSpacing: 1,
                  )),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('EEE').format(workout.date),
                    style: TextStyle(fontSize: 11, color: typeColor, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _typeColor(WorkoutType t) {
    switch (t) {
      case WorkoutType.push: return AppColors.push;
      case WorkoutType.pull: return AppColors.pull;
      case WorkoutType.legs: return AppColors.legs;
      case WorkoutType.combat: return AppColors.cyan;
      case WorkoutType.fullBody: return AppColors.violet;
      case WorkoutType.rest: return AppColors.mute;
      case WorkoutType.deload: return AppColors.pink;
    }
  }
}

// ── Phase Info Card ───────────────────────────────────────────────────────────

class _PhaseInfoCard extends StatelessWidget {
  final WorkoutDay workout;
  const _PhaseInfoCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final phaseDescriptions = {
      1: 'Foundation phase: Master form, build base strength. 3×10–12 reps, 60–90s rest.',
      2: 'Intensity phase: Supersets, heavier loads, 45–60s rest. Definition emerges.',
      3: 'Peak shred: Max intensity, triple sets, strength peaks. Six-pack fully visible.',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border2),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('P${workout.phase}', style: const TextStyle(
                fontFamily: 'BebasNeue', fontSize: 20,
                color: AppColors.amber, letterSpacing: 1,
              )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.phaseLabel, style: const TextStyle(
                  fontFamily: 'JetBrainsMono', fontSize: 10,
                  color: AppColors.amber, letterSpacing: 1,
                )),
                const SizedBox(height: 3),
                Text(phaseDescriptions[workout.phase] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.dim, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan Complete Card ────────────────────────────────────────────────────────

class _PlanCompleteCard extends StatelessWidget {
  final FitnessProvider provider;
  const _PlanCompleteCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.amber.withOpacity(0.15), AppColors.red.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amber.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('PROGRAM COMPLETE!', style: TextStyle(
            fontFamily: 'BebasNeue', fontSize: 28,
            color: AppColors.amber, letterSpacing: 3,
          )),
          const SizedBox(height: 8),
          const Text('You have completed your 84-day transformation. Ready for the next cycle?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.dim, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to settings to start new plan
              DefaultTabController.of(context);
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text('START NEW CYCLE'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber,
              foregroundColor: Colors.black),
          ),
        ],
      ),
    );
  }
}
