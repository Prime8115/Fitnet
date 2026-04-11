// lib/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fitness_provider.dart';
import '../data/workout_data.dart';
import '../utils/app_theme.dart';
import 'workout_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedWeek = 0;

  final List<String> _weekLabels = List.generate(12, (i) => 'WK ${i + 1}');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, vsync: this);
    // Jump to current week
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FitnessProvider>(context, listen: false);
      final currentWeek = ((provider.currentDayNumber - 1) ~/ 7).clamp(0, 11);
      _tabController.animateTo(currentWeek);
      setState(() => _selectedWeek = currentWeek);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.bg,
                title: const Text('84-DAY CALENDAR', style: TextStyle(
                  fontFamily: 'BebasNeue', fontSize: 22,
                  color: Colors.white, letterSpacing: 3)),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: AppColors.red,
                      indicatorWeight: 2,
                      labelColor: AppColors.red,
                      unselectedLabelColor: AppColors.mute,
                      labelStyle: const TextStyle(
                        fontFamily: 'JetBrainsMono', fontSize: 10, letterSpacing: 1),
                      tabs: _weekLabels.map((l) => Tab(text: l)).toList(),
                      onTap: (i) => setState(() => _selectedWeek = i),
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: List.generate(12, (weekIdx) {
                final startDay = weekIdx * 7 + 1;
                final days = List.generate(7, (i) {
                  final dayNum = startDay + i;
                  if (dayNum > provider.planTotalDays) return null;
                  return provider.getWorkoutForDay(dayNum);
                });

                final weekDays = days.where((d) => d != null).cast<WorkoutDay>().toList();
                final weekCompleted = weekDays.where(
                  (d) => d.type != WorkoutType.rest && provider.isDayCompleted(d.dayNumber)).length;
                final weekTraining = weekDays.where(
                  (d) => d.type != WorkoutType.rest).length;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Week header
                            _WeekHeader(
                              weekNum: weekIdx + 1,
                              completed: weekCompleted,
                              total: weekTraining,
                              phase: weekDays.isNotEmpty ? weekDays.first.phaseLabel : '',
                              isDeload: weekDays.any((d) => d.isDeload),
                            ),
                            const SizedBox(height: 14),

                            // Days list
                            ...List.generate(7, (i) {
                              final workout = days[i];
                              if (workout == null) return const SizedBox.shrink();
                              return _DayCard(
                                workout: workout,
                                isCompleted: provider.isDayCompleted(workout.dayNumber),
                                isToday: workout.dayNumber == provider.currentDayNumber,
                                typeColor: _typeColor(workout.type),
                                onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (_) => WorkoutDetailScreen(workout: workout))),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

// ── Week Header ───────────────────────────────────────────────────────────────

class _WeekHeader extends StatelessWidget {
  final int weekNum;
  final int completed, total;
  final String phase;
  final bool isDeload;

  const _WeekHeader({
    required this.weekNum, required this.completed,
    required this.total, required this.phase, required this.isDeload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDeload
            ? AppColors.pink.withOpacity(0.3)
            : AppColors.border2),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isDeload
                  ? AppColors.pink.withOpacity(0.12)
                  : AppColors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(
              isDeload ? '🩷' : 'W$weekNum',
              style: TextStyle(
                fontFamily: 'BebasNeue', fontSize: isDeload ? 22 : 18,
                color: isDeload ? AppColors.pink : AppColors.red,
              ),
            )),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('WEEK $weekNum', style: const TextStyle(
                  fontFamily: 'BebasNeue', fontSize: 18,
                  color: Colors.white, letterSpacing: 1)),
                if (isDeload) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.pink.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.pink.withOpacity(0.3)),
                    ),
                    child: const Text('DELOAD', style: TextStyle(
                      fontFamily: 'JetBrainsMono', fontSize: 8,
                      color: AppColors.pink, letterSpacing: 1)),
                  ),
                ],
              ]),
              Text(phase, style: const TextStyle(
                fontFamily: 'JetBrainsMono', fontSize: 10,
                color: AppColors.mute, letterSpacing: 1)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$completed/$total', style: const TextStyle(
              fontFamily: 'BebasNeue', fontSize: 22,
              color: AppColors.lime, letterSpacing: 1)),
            const Text('DONE', style: TextStyle(
              fontFamily: 'JetBrainsMono', fontSize: 8,
              color: AppColors.mute, letterSpacing: 2)),
          ]),
        ],
      ),
    );
  }
}

// ── Day Card ──────────────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  final WorkoutDay workout;
  final bool isCompleted;
  final bool isToday;
  final Color typeColor;
  final VoidCallback onTap;

  const _DayCard({
    required this.workout, required this.isCompleted,
    required this.isToday, required this.typeColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isToday
              ? typeColor.withOpacity(0.08)
              : isCompleted
                  ? AppColors.lime.withOpacity(0.05)
                  : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? typeColor.withOpacity(0.5)
                : isCompleted
                    ? AppColors.lime.withOpacity(0.25)
                    : AppColors.border,
            width: isToday ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Date column
            SizedBox(
              width: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(workout.date).toUpperCase(),
                    style: const TextStyle(fontFamily: 'JetBrainsMono',
                      fontSize: 9, color: AppColors.mute, letterSpacing: 1),
                  ),
                  Text(
                    workout.date.day.toString(),
                    style: TextStyle(
                      fontFamily: 'BebasNeue', fontSize: 26,
                      color: isToday ? typeColor : AppColors.dim,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(workout.date).toUpperCase(),
                    style: const TextStyle(fontFamily: 'JetBrainsMono',
                      fontSize: 9, color: AppColors.mute, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 44,
              color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 14)),

            // Workout info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(workout.type.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(workout.label,
                      style: TextStyle(
                        fontFamily: 'BebasNeue', fontSize: 16,
                        color: isCompleted ? AppColors.dim : typeColor,
                        letterSpacing: 1,
                      ))),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('TODAY', style: TextStyle(
                          fontFamily: 'JetBrainsMono', fontSize: 8,
                          color: typeColor, letterSpacing: 1)),
                      ),
                  ]),
                  Text(workout.focus,
                    style: const TextStyle(fontSize: 11, color: AppColors.mute),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Day ${workout.dayNumber}',
                    style: const TextStyle(fontFamily: 'JetBrainsMono',
                      fontSize: 9, color: AppColors.mute, letterSpacing: 1)),
                ],
              ),
            ),

            // Status
            Column(children: [
              if (isCompleted)
                const Icon(Icons.check_circle_rounded, color: AppColors.lime, size: 22)
              else if (workout.type == WorkoutType.rest)
                const Icon(Icons.hotel_rounded, color: AppColors.mute, size: 22)
              else
                Icon(Icons.arrow_forward_ios_rounded, color: typeColor, size: 14),
            ]),
          ],
        ),
      ),
    );
  }
}
