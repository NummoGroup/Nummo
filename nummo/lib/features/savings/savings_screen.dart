import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../goals/goal_model.dart';
import '../goals/goal_provider.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ahorros XP')),
      body: SafeArea(
        child: Consumer<GoalProvider>(
          builder: (context, goalProvider, _) {
            final goals = goalProvider.goals;

            if (goalProvider.isLoading && goals.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (goals.isEmpty) {
              return const Center(
                child: Text(
                  'Crea tu primera barra de XP en “Metas”.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final goal = goals[index];
                return _GoalMilestonesCard(goal: goal);
              },
            );
          },
        ),
      ),
    );
  }
}

class _GoalMilestonesCard extends StatelessWidget {
  final GoalModel goal;
  const _GoalMilestonesCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5BA4CF).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MilestoneBar(goal: goal),
          const SizedBox(height: 10),
          Text(
            '\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (goal.deadline != null) ...[
            const SizedBox(height: 6),
            Text(
              'Deadline: ${goal.deadline!.toLocal().toString().split(' ').first}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
          if (goal.isCompleted) ...[
            const SizedBox(height: 8),
            const Text(
              '¡Meta alcanzada! 🎉',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE87DA5),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            _milestoneMessage(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }

  String _milestoneMessage() {
    final milestones = goal.milestonesCount < 4 ? 4 : goal.milestonesCount;
    final reached = goal.reachedMilestonesCount.clamp(0, milestones);
    if (reached >= milestones) return '¡Felicitaciones! Lograste tu meta 🚀';
    if (reached == 0) return 'Empieza con el primer paso 💪';
    return '¡Buen progreso! ${reached}/${milestones} hitos alcanzados ✨';
  }
}

class _MilestoneBar extends StatelessWidget {
  final GoalModel goal;
  const _MilestoneBar({required this.goal});

  @override
  Widget build(BuildContext context) {
    final milestones = goal.milestonesCount < 4 ? 4 : goal.milestonesCount;
    final reached = goal.reachedMilestonesCount.clamp(0, milestones);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 18,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EEF5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: goal.progressPercentage,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5BA4CF),
                        Color(0xFF87CEEB),
                        Color(0xFFF5B7D1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              // Indicadores por hitos
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    return Stack(
                      children: [
                        for (int i = 0; i < milestones; i++)
                          Positioned(
                            left: w * (i / (milestones - 1)),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < reached
                                    ? const Color(0xFFE87DA5)
                                    : Colors.white,
                                border: Border.all(
                                  color: const Color(
                                    0xFFE87DA5,
                                  ).withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(milestones, (i) {
            final thresholdAmount = (goal.targetAmount / milestones) * (i + 1);
            final isFinal = i == milestones - 1;
            final label = isFinal
                ? 'Meta'
                : '\$${thresholdAmount.toStringAsFixed(0)}';

            return Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: i < reached
                      ? const Color(0xFF1E3A5F)
                      : Colors.black.withValues(alpha: 0.35),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
