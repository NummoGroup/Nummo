import 'dart:async';
import 'package:flutter/material.dart';
import 'goal_model.dart';
import 'goal_service.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _service;
  List<GoalModel> _goals = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;

  GoalProvider(this._service) {
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    await _service.init();
    _goals = _service.getAllGoals();
    _subscription = _service.goalsStream.listen((goals) {
      _goals = goals;
      notifyListeners();
    });
    _setLoading(false);
  }

  Future<void> addGoal(GoalModel goal) async {
    _setLoading(true);
    await _service.createGoal(goal);
    _setLoading(false);
  }

  Future<void> updateGoalProgress(String id, double amount) async {
    await _service.updateProgress(id, amount);
  }

  Future<void> deleteGoal(String id) async {
    await _service.deleteGoal(id);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
