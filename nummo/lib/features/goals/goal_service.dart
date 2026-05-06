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
    if (goal != null) {
      goal.currentAmount += amount;
      await goal.save();
      _notify();
    }
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
