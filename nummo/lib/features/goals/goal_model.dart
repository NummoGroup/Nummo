import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 0)
class GoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  double currentAmount;

  // Cantidad de hitos/miniobjetivos dentro de la barra.
  // Incluye el objetivo final.
  @HiveField(4)
  final int milestonesCount;

  // Fecha límite para cumplir el ahorro (puede ser null).
  @HiveField(5)
  final DateTime? deadline;

  // Persistimos cuántos hitos están alcanzados.
  // 0 = ninguno. milestonesCount = todos (incluye meta final).
  @HiveField(6)
  int reachedMilestonesCount;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.milestonesCount,
    required this.deadline,
    required this.reachedMilestonesCount,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
    id: json['id'] as String,
    title: json['title'] as String,
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num).toDouble(),
    milestonesCount: (json['milestonesCount'] as num?)?.toInt() ?? 4,
    deadline: json['deadline'] == null
        ? null
        : DateTime.parse(json['deadline'] as String),
    reachedMilestonesCount:
        (json['reachedMilestonesCount'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'milestonesCount': milestonesCount,
    'reachedMilestonesCount': reachedMilestonesCount,
    'deadline': deadline?.toIso8601String(),
  };

  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => currentAmount >= targetAmount;

  GoalModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    int? milestonesCount,
    DateTime? deadline,
    int? reachedMilestonesCount,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      milestonesCount: milestonesCount ?? this.milestonesCount,
      deadline: deadline ?? this.deadline,
      reachedMilestonesCount:
          reachedMilestonesCount ?? this.reachedMilestonesCount,
    );
  }
}

class MilestoneEvent {
  final String goalId;
  final String goalTitle;
  final int milestoneIndex;
  final int totalMilestones;
  final bool isComplete;

  MilestoneEvent({
    required this.goalId,
    required this.goalTitle,
    required this.milestoneIndex,
    required this.totalMilestones,
    required this.isComplete,
  });
}
