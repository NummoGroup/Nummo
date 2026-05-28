import 'dart:async';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'goal_model.dart';

class GoalService {
  static const String _boxName = 'goals';
  late Box<GoalModel> _box;
  final _uuid = const Uuid();

  final _goalsController = StreamController<List<GoalModel>>.broadcast();
  Stream<List<GoalModel>> get goalsStream => _goalsController.stream;

  Future<void> init() async {
    _box = await Hive.openBox<GoalModel>(_boxName);
    _notify();
  }

  Future<void> createGoal(GoalModel goal) async {
    final newGoal = goal.copyWith(id: _uuid.v4());
    await _box.put(newGoal.id, newGoal);
    _notify();
  }

  Future<void> updateProgress(String id, double amount) async {
    final goal = _box.get(id);
    if (goal == null) return;

    goal.currentAmount += amount;

    // Recalcular hitos alcanzados según el progreso.
    // milestonesCount incluye la meta final.
    // Ej: milestonesCount=4 => umbrales 25%, 50%, 75%, 100%.
    final safeMilestones = goal.milestonesCount < 2 ? 2 : goal.milestonesCount;

    double newProgress = goal.progressPercentage;

    int newReached;
    if (goal.targetAmount <= 0) {
      newReached = 0;
    } else {
      // Cuántos umbrales <= progreso actual.
      // Umbral i (1..safeMilestones) => i/safeMilestones
      newReached = (newProgress * safeMilestones).floor();
      newReached = newReached.clamp(0, safeMilestones);
      // Si newProgress es exactamente 1.0, floor(1*safeMilestones)=safeMilestones.
    }

    // Guardar milestonesCount por consistencia (si venía mal).
    if (goal.milestonesCount != safeMilestones) {
      // milestonesCount es final, así que no lo podemos cambiar aquí.
      // En caso de datos viejos, forzamos interpretación con safeMilestones
      // dejando milestonesCount como estaba.
    }

    // alcanzamos 0..milestonesCount
    goal.reachedMilestonesCount = newReached;

    await goal.save();
    _notify();
  }

  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
    _notify();
  }

  List<GoalModel> getAllGoals() {
    return _box.values.toList();
  }

  void _notify() {
    _goalsController.add(_box.values.toList());
  }

  Future<void> dispose() async {
    await _goalsController.close();
    await _box.close();
  }
}
