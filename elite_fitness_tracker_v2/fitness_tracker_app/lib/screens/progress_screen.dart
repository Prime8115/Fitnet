// lib/screens/progress_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fitness_provider.dart';
import '../models/workout_log.dart';
import '../utils/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.bg,
                title: const Text('PROGRESS', style: TextStyle(
                    fontFamily: 'BebasNeue', fontSize: 22,
                    color: Colors.white, letterSpacing: 3)),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(44),
                  child: Container(
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.red,
                      labelColor: AppColors.red,
                      unselectedLabelColor: AppColors.mute,
                      labelStyle: const TextStyle(
                          fontFamily: 'JetBrainsMono', fontSize: 10, letterSpacing: 1),
                      tabs: const [
                        Tab(text: 'OVERVIEW'),
                        Tab(text: 'BODY METRICS'),
                        Tab(text: 'HISTORY'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(provider: provider),
                _BodyMetricsTab(provider: provider),
                _HistoryTab(provider: provider),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final FitnessProvider provider;
  const _OverviewTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = provider.stats;
    final weeklyData = provider.getWeeklyCompletion();
    final phaseBreakdown = provider.phaseBreakdown;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatsGrid(stats: stats, provider: provider),
          const SizedBox(height: 20),
          _SectionTitle(title: 'WEEKLY COMPLETION'),
          const SizedBox(height: 12),
          _WeeklyChart(weeklyData: weeklyData),
          const SizedBox(height: 20),
          _SectionTitle(title: 'PHASE BREAKDOWN'),
          const SizedBox(height: 12),
          _PhaseBreakdown(phaseBreakdown: phaseBreakdown),
          const SizedBox(height: 20),
          _SectionTitle(title: 'WORKOUT TYPES COMPLETED'),
          const SizedBox(height: 12),
          _WorkoutTypeDistribution(provider: provider),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  final FitnessProvider provider;
  const _StatsGrid({required this.stats, required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalMinutes = stats['totalMinutes'] ?? 0;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final avgRating = (stats['avgRating'] ?? 0.0) as double;

    return Column(children: [
      Row(children: [
        Expanded(child: _BigStatCard(
          value: '${stats['completedWorkouts'] ?? 0}',
          label: 'WORKOUTS DONE',
          sublabel: 'of ${provider.planTotalDays} total',
          color: AppColors.lime, icon: '✅',
        )),
        const SizedBox(width: 10),
        Expanded(child: _BigStatCard(
          value: '${stats['currentStreak'] ?? 0}',
          label: 'DAY STREAK',
          sublabel: 'consecutive days',
          color: AppColors.amber, icon: '🔥',
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _BigStatCard(
          value: '${hours}h ${minutes}m',
          label: 'TOTAL TRAINED',
          sublabel: '$totalMinutes minutes',
          color: AppColors.cyan, icon: '⏱️',
        )),
        const SizedBox(width: 10),
        Expanded(child: _BigStatCard(
          value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
          label: 'AVG RATING',
          sublabel: 'out of 5',
          color: AppColors.violet, icon: '⭐',
        )),
      ]),
    ]);
  }
}

class _BigStatCard extends StatelessWidget {
  final String value, label, sublabel, icon;
  final Color color;
  const _BigStatCard({required this.value, required this.label,
    required this.sublabel, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const Spacer(),
          Container(width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ]),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(
            fontFamily: 'BebasNeue', fontSize: 28, color: color, letterSpacing: 1)),
        Text(label, style: const TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 9,
            color: Colors.white, letterSpacing: 1)),
        Text(sublabel, style: const TextStyle(fontSize: 11, color: AppColors.mute)),
      ]),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  const _WeeklyChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border2)),
      child: Column(children: [
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyData.map((w) {
              final completed = w['completed'] as int;
              final total = w['total'] as int;
              final ratio = total > 0 ? completed / total : 0.0;
              final color = ratio >= 1.0 ? AppColors.lime
                  : ratio > 0.5 ? AppColors.amber
                  : ratio > 0 ? AppColors.orange
                  : AppColors.border2;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (completed > 0) Text('$completed',
                          style: TextStyle(fontFamily: 'JetBrainsMono',
                              fontSize: 8, color: color)),
                      const SizedBox(height: 2),
                      Container(
                        height: (ratio * 80).clamp(4.0, 80.0),
                        decoration: BoxDecoration(color: color,
                            borderRadius: BorderRadius.circular(3)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: weeklyData.map((w) => Expanded(
          child: Center(child: Text('W${w['week']}',
              style: const TextStyle(fontFamily: 'JetBrainsMono',
                  fontSize: 7, color: AppColors.mute))),
        )).toList()),
      ]),
    );
  }
}

class _PhaseBreakdown extends StatelessWidget {
  final Map<String, int> phaseBreakdown;
  const _PhaseBreakdown({required this.phaseBreakdown});

  @override
  Widget build(BuildContext context) {
    final colors = {'Phase 1': AppColors.cyan, 'Phase 2': AppColors.violet, 'Phase 3': AppColors.red};
    return Column(
      children: phaseBreakdown.entries.map((e) {
        final color = colors[e.key] ?? AppColors.dim;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(e.key.toUpperCase(), style: const TextStyle(
                  fontFamily: 'JetBrainsMono', fontSize: 10,
                  color: AppColors.dim, letterSpacing: 1)),
              Text('${e.value} sessions', style: TextStyle(
                  fontFamily: 'JetBrainsMono', fontSize: 10, color: color)),
            ]),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: (e.value / 20.0).clamp(0.0, 1.0),
                backgroundColor: AppColors.border2,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6),
            ),
          ]),
        );
      }).toList(),
    );
  }
}

class _WorkoutTypeDistribution extends StatelessWidget {
  final FitnessProvider provider;
  const _WorkoutTypeDistribution({required this.provider});

  @override
  Widget build(BuildContext context) {
    final typeCount = <String, int>{};
    provider.logs.values.where((l) => l.completed).forEach((log) {
      final workout = provider.getWorkoutForDay(log.dayNumber);
      if (workout != null) {
        final typeName = workout.type.displayName;
        typeCount[typeName] = (typeCount[typeName] ?? 0) + 1;
      }
    });

    if (typeCount.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border2)),
        child: const Center(child: Text('No workouts completed yet',
            style: TextStyle(color: AppColors.mute))),
      );
    }

    final typeColors = {
      'Push Day': AppColors.push, 'Pull Day': AppColors.pull,
      'Leg Day': AppColors.legs, 'Combat & Core': AppColors.cyan,
      'Full Body Power': AppColors.violet, 'Active Rest': AppColors.mute,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border2)),
      child: Column(children: typeCount.entries.map((e) {
        final color = typeColors[e.key] ?? AppColors.dim;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(e.key,
                style: const TextStyle(fontSize: 13, color: AppColors.text))),
            Text('${e.value}x', style: TextStyle(
                fontFamily: 'JetBrainsMono', fontSize: 12,
                color: color, fontWeight: FontWeight.w700)),
          ]),
        );
      }).toList()),
    );
  }
}

// ── Body Metrics Tab ──────────────────────────────────────────────────────────

class _BodyMetricsTab extends StatelessWidget {
  final FitnessProvider provider;
  const _BodyMetricsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAddMetricSheet(context, provider),
            icon: const Icon(Icons.add_rounded),
            label: const Text('LOG BODY METRICS'),
          ),
        ),
        const SizedBox(height: 20),
        if (provider.bodyMetrics.isNotEmpty) ...[
          _SectionTitle(title: 'LATEST METRICS'),
          const SizedBox(height: 12),
          _LatestMetricsCard(metric: provider.bodyMetrics.last),
          const SizedBox(height: 20),
          if (provider.bodyMetrics.length > 1) ...[
            _SectionTitle(title: 'WEIGHT PROGRESS'),
            const SizedBox(height: 12),
            _WeightChart(metrics: provider.bodyMetrics),
            const SizedBox(height: 20),
          ],
          _SectionTitle(title: 'HISTORY'),
          const SizedBox(height: 12),
          ...provider.bodyMetrics.reversed.map((m) => _MetricHistoryCard(metric: m)),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border2)),
            child: const Column(children: [
              Text('📏', style: TextStyle(fontSize: 40)),
              SizedBox(height: 12),
              Text('Track Your Transformation', style: TextStyle(
                  fontFamily: 'BebasNeue', fontSize: 20,
                  color: Colors.white, letterSpacing: 2)),
              SizedBox(height: 6),
              Text('Log your weight and body measurements to see your progress over time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.dim, fontSize: 12, height: 1.5)),
            ]),
          ),
        ],
        const SizedBox(height: 32),
      ]),
    );
  }

  void _showAddMetricSheet(BuildContext context, FitnessProvider provider) {
    final weightCtrl = TextEditingController();
    final bfCtrl = TextEditingController();
    final chestCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final armCtrl = TextEditingController();
    final thighCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card2,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border2,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('LOG MEASUREMENTS', style: TextStyle(
                fontFamily: 'BebasNeue', fontSize: 22,
                color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _MetricInput(ctrl: weightCtrl, label: 'Weight (kg)', hint: '68.0')),
              const SizedBox(width: 12),
              Expanded(child: _MetricInput(ctrl: bfCtrl, label: 'Body Fat %', hint: '18.0')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _MetricInput(ctrl: chestCtrl, label: 'Chest (cm)', hint: '95')),
              const SizedBox(width: 12),
              Expanded(child: _MetricInput(ctrl: waistCtrl, label: 'Waist (cm)', hint: '80')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _MetricInput(ctrl: armCtrl, label: 'Arm (cm)', hint: '35')),
              const SizedBox(width: 12),
              Expanded(child: _MetricInput(ctrl: thighCtrl, label: 'Thigh (cm)', hint: '55')),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final metric = BodyMetric(
                    date: DateTime.now(),
                    weight: double.tryParse(weightCtrl.text),
                    bodyFatPercent: double.tryParse(bfCtrl.text),
                    chestCm: double.tryParse(chestCtrl.text),
                    waistCm: double.tryParse(waistCtrl.text),
                    armCm: double.tryParse(armCtrl.text),
                    thighCm: double.tryParse(thighCtrl.text),
                  );
                  await provider.addBodyMetric(metric);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('SAVE MEASUREMENTS'),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}

class _MetricInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  const _MetricInput({required this.ctrl, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

class _LatestMetricsCard extends StatelessWidget {
  final BodyMetric metric;
  const _LatestMetricsCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border2)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('LATEST', style: TextStyle(fontFamily: 'JetBrainsMono',
              fontSize: 9, color: AppColors.mute, letterSpacing: 2)),
          Text(DateFormat('d MMM yyyy').format(metric.date),
              style: const TextStyle(fontFamily: 'JetBrainsMono',
                  fontSize: 10, color: AppColors.dim)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          if (metric.weight != null) Expanded(child: _MetricTile(
              label: 'WEIGHT', value: '${metric.weight}kg', color: AppColors.amber)),
          if (metric.bodyFatPercent != null) Expanded(child: _MetricTile(
              label: 'BODY FAT', value: '${metric.bodyFatPercent}%', color: AppColors.red)),
          if (metric.chestCm != null) Expanded(child: _MetricTile(
              label: 'CHEST', value: '${metric.chestCm}cm', color: AppColors.cyan)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          if (metric.waistCm != null) Expanded(child: _MetricTile(
              label: 'WAIST', value: '${metric.waistCm}cm', color: AppColors.lime)),
          if (metric.armCm != null) Expanded(child: _MetricTile(
              label: 'ARM', value: '${metric.armCm}cm', color: AppColors.violet)),
          if (metric.thighCm != null) Expanded(child: _MetricTile(
              label: 'THIGH', value: '${metric.thighCm}cm', color: AppColors.orange)),
        ]),
      ]),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MetricTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontFamily: 'BebasNeue',
          fontSize: 20, color: color, letterSpacing: 1)),
      Text(label, style: const TextStyle(fontFamily: 'JetBrainsMono',
          fontSize: 8, color: AppColors.mute, letterSpacing: 1)),
    ]);
  }
}

class _WeightChart extends StatelessWidget {
  final List<BodyMetric> metrics;
  const _WeightChart({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final weightData = metrics.where((m) => m.weight != null).toList();
    if (weightData.isEmpty) return const SizedBox.shrink();
    final minW = weightData.map((m) => m.weight!).reduce((a, b) => a < b ? a : b);
    final maxW = weightData.map((m) => m.weight!).reduce((a, b) => a > b ? a : b);
    final range = (maxW - minW).clamp(1.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${minW.toStringAsFixed(1)} kg', style: const TextStyle(
              fontFamily: 'JetBrainsMono', fontSize: 9, color: AppColors.lime)),
          Text('${maxW.toStringAsFixed(1)} kg', style: const TextStyle(
              fontFamily: 'JetBrainsMono', fontSize: 9, color: AppColors.red)),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weightData.map((m) {
              final ratio = (m.weight! - minW) / range;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    height: (ratio * 60 + 4).clamp(4.0, 64.0),
                    decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(3)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

class _MetricHistoryCard extends StatelessWidget {
  final BodyMetric metric;
  const _MetricHistoryCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('📏', style: TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(DateFormat('d MMMM yyyy').format(metric.date),
              style: const TextStyle(fontSize: 13, color: AppColors.text,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text([
            if (metric.weight != null) '${metric.weight}kg',
            if (metric.bodyFatPercent != null) '${metric.bodyFatPercent}% BF',
            if (metric.waistCm != null) 'Waist: ${metric.waistCm}cm',
          ].join(' · '), style: const TextStyle(fontSize: 11, color: AppColors.mute)),
        ])),
      ]),
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final FitnessProvider provider;
  const _HistoryTab({required this.provider});

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
    final completedLogs = provider.logs.values
        .where((l) => l.completed).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (completedLogs.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🏋️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('No workouts yet!', style: TextStyle(
              fontFamily: 'BebasNeue', fontSize: 22, color: Colors.white)),
          SizedBox(height: 6),
          Text('Complete your first workout to see history here.',
              style: TextStyle(color: AppColors.dim, fontSize: 13)),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: completedLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final log = completedLogs[i];
        final workout = provider.getWorkoutForDay(log.dayNumber);
        if (workout == null) return const SizedBox.shrink();
        final typeColor = _typeColor(workout.type);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border2)),
          child: Row(children: [
            Container(width: 44, height: 44,
                decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(workout.type.emoji,
                    style: const TextStyle(fontSize: 20)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(workout.label, style: TextStyle(fontFamily: 'BebasNeue',
                  fontSize: 16, color: typeColor, letterSpacing: 1)),
              Text(DateFormat('EEE, d MMM').format(log.date),
                  style: const TextStyle(fontSize: 12, color: AppColors.dim)),
              Text('Day ${log.dayNumber} · ${log.durationMinutes}min',
                  style: const TextStyle(fontFamily: 'JetBrainsMono',
                      fontSize: 9, color: AppColors.mute)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (log.feelingRating > 0)
                Text(['😫','😕','😐','😊','🔥'][log.feelingRating - 1],
                    style: const TextStyle(fontSize: 18)),
              const Icon(Icons.check_circle_rounded, color: AppColors.lime, size: 18),
            ]),
          ]),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: const TextStyle(fontFamily: 'BebasNeue',
          fontSize: 16, color: Colors.white, letterSpacing: 2)),
      const SizedBox(width: 10),
      const Expanded(child: Divider(color: AppColors.border2)),
    ]);
  }
}
