import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'goal_model.dart';
import 'goal_provider.dart';
import '../../shared/widgets/screen_wrapper.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Metas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva barra'),
      ),
      body: ScreenWrapper(
        child: SafeArea(
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
                  'Todavía no tienes barras de XP. Crea una nueva.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = goals[index];
                return _GoalRow(
                  goal: goal,
                  onDelete: () async {
                    final goalRef = goal;
                    if (!context.mounted) return;
                    final confirmed1 = await _confirm(
                      context,
                      title: 'Eliminar barra de XP',
                      content: 'Vas a eliminar "${goalRef.title}".',
                      confirmText: 'Eliminar',
                      cancelText: 'Cancelar',
                    );
                    if (confirmed1 != true) return;

                    if (!context.mounted) return;
                    final confirmed2 = await _confirm(
                      context,
                      title: 'Confirmación final',
                      content:
                          '¿Confirmas que deseas eliminarla? Esta acción no se puede deshacer.',
                      confirmText: 'Sí, eliminar',
                      cancelText: 'No',
                    );
                    if (confirmed2 != true) return;

                    if (!context.mounted) return;
                    await context.read<GoalProvider>().deleteGoal(goalRef.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Eliminada: ${goalRef.title}')),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
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

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5BA4CF),
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final currentCtrl = TextEditingController(text: '0');
    final targetCtrl = TextEditingController(text: '100');
    final milestonesCtrl = TextEditingController(text: '4');

    DateTime? selectedDeadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Crear nueva barra de XP'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la meta',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: currentCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Monto actual (\$)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: targetCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Monto objetivo (\$)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: milestonesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText:
                            'Cantidad de hitos (mín. 2, incluye meta final)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDeadline == null
                                ? 'Sin deadline'
                                : 'Deadline: ${selectedDeadline!.toLocal().toString().split(' ').first}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final now = DateTime.now();
                            final firstDate = DateTime(
                              now.year - 1,
                              now.month,
                              now.day,
                            );
                            final lastDate = DateTime(now.year + 10);
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: firstDate,
                              lastDate: lastDate,
                              initialDate: selectedDeadline ?? now,
                            );
                            if (picked != null) {
                              setState(() => selectedDeadline = picked);
                            }
                          },
                          child: const Text('Elegir'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final currentAmount = double.tryParse(
                      currentCtrl.text.trim(),
                    );
                    final targetAmount = double.tryParse(
                      targetCtrl.text.trim(),
                    );
                    final milestonesCount = int.tryParse(
                      milestonesCtrl.text.trim(),
                    );

                    if (title.isEmpty ||
                        currentAmount == null ||
                        targetAmount == null ||
                        milestonesCount == null) {
                      return;
                    }

                    final safeMilestones = milestonesCount < 2
                        ? 2
                        : milestonesCount;
                    if (targetAmount <= 0) return;

                    final goal = GoalModel(
                      id: 'temp',
                      title: title,
                      targetAmount: targetAmount,
                      currentAmount: currentAmount,
                      milestonesCount: safeMilestones,
                      deadline: selectedDeadline,
                      reachedMilestonesCount: 0,
                    );

                    await context.read<GoalProvider>().addGoal(goal);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5BA4CF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GoalRow extends StatefulWidget {
  final GoalModel goal;
  final VoidCallback onDelete;
  const _GoalRow({required this.goal, required this.onDelete});

  @override
  State<_GoalRow> createState() => _GoalRowState();
}

class _GoalRowState extends State<_GoalRow> {
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5BA4CF).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(goal.progressPercentage * 100).toStringAsFixed(1)}% progreso',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline),
                color: const Color(0xFFE87DA5),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
