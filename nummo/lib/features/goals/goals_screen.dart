import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'goal_model.dart';
import 'goal_provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva barra'),
      ),
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
                    final confirmed1 = await _confirm(
                      context,
                      title: 'Eliminar barra de XP',
                      content: 'Vas a eliminar “${goal.title}”.',
                      confirmText: 'Eliminar',
                      cancelText: 'Cancelar',
                    );
                    if (confirmed1 != true) return;

                    final confirmed2 = await _confirm(
                      context,
                      title: 'Confirmación final',
                      content:
                          '¿Confirmas que deseas eliminarla? Esta acción no se puede deshacer.',
                      confirmText: 'Sí, eliminar',
                      cancelText: 'No',
                    );
                    if (confirmed2 != true) return;

                    await context.read<GoalProvider>().deleteGoal(goal.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Eliminada: ${goal.title}')),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
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
                            'Cantidad de hitos (mín. 4, incluye meta final)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDeadline == null
                                ? 'Sin deadline'
                                : 'Deadline: ' +
                                      selectedDeadline!
                                          .toLocal()
                                          .toString()
                                          .split(' ')
                                          .first,
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

                    final safeMilestones = milestonesCount < 4
                        ? 4
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

class _GoalRow extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onDelete;
  const _GoalRow({required this.goal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
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
      child: Row(
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
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: const Color(0xFFE87DA5),
          ),
        ],
      ),
    );
  }
}
