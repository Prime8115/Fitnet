// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fitness_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              const SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.bg,
                title: Text('SETTINGS', style: TextStyle(
                  fontFamily: 'BebasNeue', fontSize: 22,
                  color: Colors.white, letterSpacing: 3)),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile
                      _ProfileCard(provider: provider),
                      const SizedBox(height: 20),

                      // Plan Status
                      _PlanStatusCard(provider: provider),
                      const SizedBox(height: 20),

                      // EXTEND / MODIFY PLAN
                      _SectionHeader(title: 'PLAN MANAGEMENT'),
                      const SizedBox(height: 12),
                      _PlanManagementSection(provider: provider),
                      const SizedBox(height: 20),

                      // New Cycle (post 84 days)
                      _SectionHeader(title: 'NEW CYCLE'),
                      const SizedBox(height: 12),
                      _NewCycleSection(provider: provider),
                      const SizedBox(height: 20),

                      // About
                      _SectionHeader(title: 'ABOUT'),
                      const SizedBox(height: 12),
                      _AboutCard(),
                      const SizedBox(height: 40),
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

// ── Profile Card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final FitnessProvider provider;
  const _ProfileCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final dayNum = provider.currentDayNumber.clamp(1, provider.planTotalDays);
    final phase = dayNum <= 28 ? 1 : dayNum <= 56 ? 2 : 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.red.withOpacity(0.15), AppColors.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.red, width: 2)),
          child: const Center(child: Text('⚡', style: TextStyle(fontSize: 26))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ELITE ATHLETE', style: TextStyle(
            fontFamily: 'BebasNeue', fontSize: 22,
            color: Colors.white, letterSpacing: 2)),
          Text('5\'5 · 68kg · 28 yrs', style: const TextStyle(
            fontSize: 12, color: AppColors.dim)),
          const SizedBox(height: 4),
          Text('Day $dayNum · Phase $phase · ${provider.planTotalDays}-Day Plan',
            style: const TextStyle(fontFamily: 'JetBrainsMono',
              fontSize: 10, color: AppColors.amber, letterSpacing: 1)),
        ])),
      ]),
    );
  }
}

// ── Plan Status Card ──────────────────────────────────────────────────────────

class _PlanStatusCard extends StatelessWidget {
  final FitnessProvider provider;
  const _PlanStatusCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final startDate = provider.planStartDate;
    final endDate = startDate.add(Duration(days: provider.planTotalDays - 1));
    final completed = provider.logs.values.where((l) => l.completed).length;
    final remaining = (provider.planTotalDays - provider.currentDayNumber + 1).clamp(0, 999);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CURRENT PLAN', style: TextStyle(
          fontFamily: 'JetBrainsMono', fontSize: 9,
          color: AppColors.mute, letterSpacing: 2)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _InfoTile(
            label: 'START', value: DateFormat('d MMM').format(startDate), color: AppColors.cyan)),
          Expanded(child: _InfoTile(
            label: 'END', value: DateFormat('d MMM').format(endDate), color: AppColors.red)),
          Expanded(child: _InfoTile(
            label: 'DONE', value: '$completed', color: AppColors.lime)),
          Expanded(child: _InfoTile(
            label: 'LEFT', value: '$remaining days', color: AppColors.amber)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: provider.overallProgress,
            backgroundColor: AppColors.border2,
            valueColor: const AlwaysStoppedAnimation(AppColors.red),
            minHeight: 6),
        ),
        const SizedBox(height: 6),
        Text('${(provider.overallProgress * 100).toStringAsFixed(1)}% complete',
          style: const TextStyle(fontFamily: 'JetBrainsMono',
            fontSize: 10, color: AppColors.amber)),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InfoTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontFamily: 'BebasNeue',
        fontSize: 18, color: color, letterSpacing: 1)),
      Text(label, style: const TextStyle(fontFamily: 'JetBrainsMono',
        fontSize: 8, color: AppColors.mute, letterSpacing: 1)),
    ]);
  }
}

// ── Plan Management ───────────────────────────────────────────────────────────

class _PlanManagementSection extends StatelessWidget {
  final FitnessProvider provider;
  const _PlanManagementSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _SettingsTile(
        icon: Icons.add_circle_rounded,
        iconColor: AppColors.cyan,
        title: 'Extend Current Plan',
        subtitle: 'Add more weeks after Day 84',
        onTap: () => _showExtendDialog(context, provider),
      ),
      const SizedBox(height: 8),
      _SettingsTile(
        icon: Icons.edit_calendar_rounded,
        iconColor: AppColors.violet,
        title: 'Modify Start Date',
        subtitle: 'Change when the plan begins',
        onTap: () => _showModifyDateDialog(context, provider),
      ),
      const SizedBox(height: 8),
      _SettingsTile(
        icon: Icons.info_rounded,
        iconColor: AppColors.amber,
        title: 'Deload Weeks',
        subtitle: 'Week 4 & Week 8 — 40% volume reduction',
        onTap: null,
      ),
    ]);
  }

  void _showExtendDialog(BuildContext context, FitnessProvider provider) {
    int extraWeeks = 4;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.card2,
          title: const Text('EXTEND PLAN', style: TextStyle(
            fontFamily: 'BebasNeue', fontSize: 24, color: Colors.white, letterSpacing: 2)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('How many extra weeks would you like to add?',
              style: TextStyle(color: AppColors.dim, fontSize: 13)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                onPressed: () => setState(() => extraWeeks = (extraWeeks - 1).clamp(1, 52)),
                icon: const Icon(Icons.remove_circle_rounded, color: AppColors.red)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: BorderRadius.circular(10)),
                child: Text('$extraWeeks weeks', style: const TextStyle(
                  fontFamily: 'BebasNeue', fontSize: 24, color: AppColors.amber, letterSpacing: 1)),
              ),
              IconButton(
                onPressed: () => setState(() => extraWeeks = (extraWeeks + 1).clamp(1, 52)),
                icon: const Icon(Icons.add_circle_rounded, color: AppColors.lime)),
            ]),
            const SizedBox(height: 8),
            Text('Total: ${provider.planTotalDays + extraWeeks * 7} days',
              style: const TextStyle(fontFamily: 'JetBrainsMono',
                fontSize: 11, color: AppColors.dim)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.mute))),
            ElevatedButton(
              onPressed: () async {
                await provider.extendPlan(additionalDays: extraWeeks * 7);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Plan extended by $extraWeeks weeks! 🎯'),
                    backgroundColor: AppColors.cyan,
                    behavior: SnackBarBehavior.floating));
                }
              },
              child: const Text('EXTEND'),
            ),
          ],
        ),
      ),
    );
  }

  void _showModifyDateDialog(BuildContext context, FitnessProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.planStartDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: AppTheme.darkTheme.copyWith(
          colorScheme: AppTheme.darkTheme.colorScheme.copyWith(primary: AppColors.red)),
        child: child!,
      ),
    );

    if (picked != null && context.mounted) {
      await provider.startNewPlanCycle(
        newStartDate: picked,
        days: provider.planTotalDays,
        planName: 'Modified Plan',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Plan updated from ${DateFormat('d MMM yyyy').format(picked)}'),
          backgroundColor: AppColors.violet,
          behavior: SnackBarBehavior.floating));
      }
    }
  }
}

// ── New Cycle ─────────────────────────────────────────────────────────────────

class _NewCycleSection extends StatelessWidget {
  final FitnessProvider provider;
  const _NewCycleSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.amber.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.amber.withOpacity(0.25))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('After 84 Days — Start Fresh', style: TextStyle(
                fontFamily: 'BebasNeue', fontSize: 18,
                color: Colors.white, letterSpacing: 1)),
              Text('Begin a new 84-day cycle with harder targets',
                style: TextStyle(fontSize: 12, color: AppColors.dim)),
            ])),
          ]),
          const SizedBox(height: 16),
          const Text('Your new cycle can include:', style: TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 10,
            color: AppColors.mute, letterSpacing: 1)),
          const SizedBox(height: 8),
          ...[
            '• Higher weights across all lifts (+10–15%)',
            '• More advanced combat combinations',
            '• Additional muscle group isolation work',
            '• 6-day training instead of rest on Sunday',
            '• Sport-specific skills (muay thai, boxing)',
          ].map((t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.dim)))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showNewCycleDialog(context, provider),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('START NEW 84-DAY CYCLE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber, foregroundColor: Colors.black,
                textStyle: const TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2)),
            ),
          ),
        ]),
      ),
    ]);
  }

  void _showNewCycleDialog(BuildContext context, FitnessProvider provider) async {
    final newStart = provider.planStartDate.add(Duration(days: provider.planTotalDays));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card2,
        title: const Text('NEW CYCLE', style: TextStyle(
          fontFamily: 'BebasNeue', fontSize: 24, color: Colors.white, letterSpacing: 2)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Start a new 84-day transformation cycle. Your current progress will be saved but the daily plan will reset.',
            style: TextStyle(color: AppColors.dim, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.amber.withOpacity(0.3))),
            child: Column(children: [
              const Text('NEW CYCLE STARTS', style: TextStyle(
                fontFamily: 'JetBrainsMono', fontSize: 9,
                color: AppColors.mute, letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(DateFormat('d MMMM yyyy').format(newStart),
                style: const TextStyle(fontFamily: 'BebasNeue',
                  fontSize: 22, color: AppColors.amber, letterSpacing: 2)),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.mute))),
          ElevatedButton(
            onPressed: () async {
              await provider.startNewPlanCycle(
                newStartDate: newStart,
                days: 84,
                planName: 'Cycle 2 — Advanced',
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('🏆 New cycle started! Let\'s go!'),
                  backgroundColor: AppColors.amber,
                  behavior: SnackBarBehavior.floating));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber, foregroundColor: Colors.black),
            child: const Text('START CYCLE 2'),
          ),
        ],
      ),
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon, required this.iconColor,
    required this.title, required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border2)),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            Text(subtitle, style: const TextStyle(
              fontSize: 12, color: AppColors.mute)),
          ])),
          if (onTap != null)
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.mute, size: 14),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: const TextStyle(
        fontFamily: 'BebasNeue', fontSize: 16,
        color: Colors.white, letterSpacing: 2)),
      const SizedBox(width: 10),
      const Expanded(child: Divider(color: AppColors.border2)),
    ]);
  }
}

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('⚡', style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Text('Elite Fitness Tracker', style: TextStyle(
            fontFamily: 'BebasNeue', fontSize: 20, color: Colors.white, letterSpacing: 2)),
        ]),
        const SizedBox(height: 8),
        const Text('Version 1.0.0', style: TextStyle(
          fontFamily: 'JetBrainsMono', fontSize: 10, color: AppColors.mute)),
        const SizedBox(height: 8),
        const Text('84-day transformation program covering all muscle groups: Push, Pull, Legs, Combat conditioning, Full body power. Includes shadow boxing, kickboxing, and sandbag training.',
          style: TextStyle(fontSize: 12, color: AppColors.dim, height: 1.5)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 6, children: [
          'Phase 1: Foundation', 'Phase 2: Intensity',
          'Phase 3: Peak Shred', 'Deload Weeks',
          'Body Metrics', 'Progress Charts',
          'New Cycles', 'Plan Extension',
        ].map((f) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(4)),
          child: Text(f, style: const TextStyle(
            fontSize: 10, color: AppColors.dim)),
        )).toList()),
      ]),
    );
  }
}
