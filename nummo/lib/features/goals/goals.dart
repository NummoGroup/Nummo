// features/goals/goal_model.dart
class Goal {
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount; // Este valor se actualiza desde el ahorro
  final DateTime deadline;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
  });
}