import 'package:flutter/material.dart';
import 'financial_service.dart';
import 'financial_model.dart';

class FinancialHealthProvider extends ChangeNotifier {
  final FinancialHealthService _service;

  FinancialHealth? _currentHealth;
  bool _isLoading = false;
  String? _error;

  FinancialHealth? get currentHealth => _currentHealth;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FinancialHealthProvider(this._service);

  Future<void> calculateHealth({
    required double ingresos,
    required double gastos,
    required double ahorro,
    required double comprasImpulsivas,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      _currentHealth = await _service.calculateFinancialHealth(
        ingresos: ingresos,
        gastos: gastos,
        ahorro: ahorro,
        comprasImpulsivas: comprasImpulsivas,
      );
    } catch (e) {
      _error = e.toString();
      _currentHealth = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearData() {
    _currentHealth = null;
    _error = null;
    notifyListeners();
  }
}
