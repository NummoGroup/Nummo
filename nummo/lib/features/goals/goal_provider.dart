import 'dart:async';
import 'package:flutter/material.dart';
import 'goal_model.dart';
import 'goal_service.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _service;
  List<GoalModel> _goals = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  MilestoneEvent? _milestoneEvent;
  bool _showCelebration = false;
  String? _celebrationGoalTitle;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  MilestoneEvent? get milestoneEvent => _milestoneEvent;
  bool get showCelebration => _showCelebration;
  String? get celebrationGoalTitle => _celebrationGoalTitle;

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
    final oldReached = _getGoalReachedCount(id);
    if (oldReached == null) return;

    await _service.updateProgress(id, amount);

    final updatedReached = _getGoalReachedCount(id);
    if (updatedReached == null) return;

    if (updatedReached > oldReached) {
      final goal = _goals.firstWhere((g) => g.id == id);
      _milestoneEvent = MilestoneEvent(
        goalId: id,
        goalTitle: goal.title,
        milestoneIndex: updatedReached - 1,
        totalMilestones: goal.milestonesCount,
        isComplete: goal.isCompleted,
      );
      if (goal.isCompleted) {
        _showCelebration = true;
        _celebrationGoalTitle = goal.title;
      }
      notifyListeners();
    }
  }

  void consumeMilestoneEvent() {
    _milestoneEvent = null;
    notifyListeners();
  }

  void dismissCelebration() {
    _showCelebration = false;
    _celebrationGoalTitle = null;
    notifyListeners();
  }

  int? _getGoalReachedCount(String id) {
    try {
      return _goals.firstWhere((g) => g.id == id).reachedMilestonesCount;
    } catch (_) {
      return null;
    }
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
