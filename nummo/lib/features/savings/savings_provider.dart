import 'package:flutter/foundation.dart';
import 'savings_service.dart';
import 'savings_model.dart';

class SavingsProvider extends ChangeNotifier {
  final SavingsService _service;
  Savings _savings = Savings();
  bool _isLoading = false;

  Savings get savings => _savings;
  double get totalSaved => _savings.totalSaved;
  double get targetAmount => _savings.targetAmount;
  List<double> get depositHistory => _savings.depositHistory;
  double get progressPercentage => _savings.progressPercentage;
  bool get isTargetReached => _savings.isTargetReached;
  bool get isLoading => _isLoading;

  SavingsProvider(this._service) {
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    await _service.init();
    _savings = _service.getSavings();
    _setLoading(false);
  }

  Future<void> addMoney(double amount) async {
    if (amount <= 0) return;

    _setLoading(true);
    _savings.totalSaved += amount;
    _savings.depositHistory.add(amount);
    await _service.updateSavings(_savings);
    _setLoading(false);
  }

  Future<void> setTarget(double amount) async {
    _setLoading(true);
    _savings.targetAmount = amount;
    await _service.updateSavings(_savings);
    _setLoading(false);
  }

  Future<void> resetSavings() async {
    _setLoading(true);
    _savings = Savings();
    await _service.updateSavings(_savings);
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
