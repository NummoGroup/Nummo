import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../goals/goal_model.dart';
import '../goals/goal_provider.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ahorros XP',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: Consumer<GoalProvider>(
          builder: (context, goalProvider, _) {
            _handleMilestoneEvent(context, goalProvider);
            _handleCelebration(context, goalProvider);

            final goals = goalProvider.goals;

            if (goalProvider.isLoading && goals.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (goals.isEmpty) {
              return const Center(
                child: Text(
                  'Crea tu primera barra de XP en "Metas".',
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

  void _handleMilestoneEvent(BuildContext context, GoalProvider provider) {
    final event = provider.milestoneEvent;
    if (event == null) return;
    provider.consumeMilestoneEvent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) _showMilestoneDialog(context, event);
    });
  }

  void _handleCelebration(BuildContext context, GoalProvider provider) {
    if (!provider.showCelebration) return;
    final title = provider.celebrationGoalTitle ?? '';
    provider.dismissCelebration();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) _showCelebrationDialog(context, title);
    });
  }

  void _showMilestoneDialog(BuildContext context, MilestoneEvent event) {
    final msg = _milestonePopupMessage(event);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Hito alcanzado!'),
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Seguir'),
          ),
        ],
      ),
    );
  }

  String _milestonePopupMessage(MilestoneEvent e) {
    if (e.isComplete) return '¡Felicidades! Completaste "${e.goalTitle}" 🎉🎉🎉';
    if (e.milestoneIndex == 0) return '¡Primer hito de "${e.goalTitle}"! Sigue así 💪';
    if (e.milestoneIndex >= e.totalMilestones - 2) {
      return '¡Casi llegas a "${e.goalTitle}"! Último esfuerzo 🔥';
    }
    return '¡Hito ${e.milestoneIndex + 1}/${e.totalMilestones} en "${e.goalTitle}"! Buen trabajo ✨';
  }

  void _showCelebrationDialog(BuildContext context, String goalTitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CelebrationDialog(goalTitle: goalTitle),
    );
  }
}

class _GoalMilestonesCard extends StatefulWidget {
  final GoalModel goal;
  const _GoalMilestonesCard({required this.goal});

  @override
  State<_GoalMilestonesCard> createState() => _GoalMilestonesCardState();
}

class _GoalMilestonesCardState extends State<_GoalMilestonesCard> {
  late TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
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
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _add,
                icon: const Icon(Icons.add_circle, color: Colors.green),
                iconSize: 28,
                tooltip: 'Agregar',
              ),
              IconButton(
                onPressed: _withdraw,
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                iconSize: 28,
                tooltip: 'Retirar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _milestoneMessage() {
    final milestones = widget.goal.milestonesCount < 2
        ? 2
        : widget.goal.milestonesCount;
    final reached = widget.goal.reachedMilestonesCount.clamp(0, milestones);
    if (reached >= milestones) return '¡Felicitaciones! Lograste tu meta 🚀';
    if (reached == 0) return 'Empieza con el primer paso 💪';
    return '¡Buen progreso! $reached/$milestones hitos alcanzados ✨';
  }

  void _add() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    context.read<GoalProvider>().updateGoalProgress(widget.goal.id, amount);
  }

  void _withdraw() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    context.read<GoalProvider>().updateGoalProgress(widget.goal.id, -amount);
  }
}

class _MilestoneBar extends StatelessWidget {
  final GoalModel goal;
  const _MilestoneBar({required this.goal});

  @override
  Widget build(BuildContext context) {
    final milestones = goal.milestonesCount < 2 ? 2 : goal.milestonesCount;
    final reached = goal.reachedMilestonesCount.clamp(0, milestones);
    const double dotSize = 14;
    const double halfDot = dotSize / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: halfDot),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 7,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EEF5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: goal.progressPercentage,
                  child: Container(
                    height: 10,
                    margin: const EdgeInsets.only(top: 7),
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
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: List.generate(milestones, (i) {
                          final pos = milestones > 1
                              ? w * (i / (milestones - 1))
                              : w / 2;
                          return Positioned(
                            left: pos - halfDot,
                            top: 5,
                            child: Container(
                              width: dotSize,
                              height: dotSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < reached
                                    ? const Color(0xFFE87DA5)
                                    : Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFE87DA5)
                                      .withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }),
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
              final thresholdAmount =
                  (goal.targetAmount / milestones) * (i + 1);
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
      ),
    );
  }
}

class _CelebrationDialog extends StatefulWidget {
  final String goalTitle;
  const _CelebrationDialog({required this.goalTitle});

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉🏆🎉',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Felicidades!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completaste "${widget.goalTitle}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5BA4CF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Has alcanzado tu meta! Sigue así.🌟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GoalProvider>().dismissCelebration();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5BA4CF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '¡Seguir así!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
