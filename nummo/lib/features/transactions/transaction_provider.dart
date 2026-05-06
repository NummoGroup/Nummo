import 'dart:async';
import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get balance => _service.balance;

  List<TransactionModel> get incomes =>
      _transactions.where((t) => t.type == 'income').toList();

  List<TransactionModel> get expenses =>
      _transactions.where((t) => t.type == 'expense').toList();

  TransactionProvider(this._service) {
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    await _service.init();
    _transactions = _service.getAllTransactions();
    _subscription = _service.transactionsStream.listen((transactions) {
      _transactions = transactions;
      notifyListeners();
    });
    _setLoading(false);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _setLoading(true);
    await _service.addTransaction(transaction);
    _setLoading(false);
  }

  Future<void> deleteTransaction(String id) async {
    await _service.deleteTransaction(id);
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
