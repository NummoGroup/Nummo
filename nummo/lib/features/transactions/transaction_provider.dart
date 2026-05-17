import 'package:flutter/foundation.dart';
import 'transaction_model.dart';
import 'transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service;
  final List<TransactionModel> transactions = [];

  TransactionProvider(this._service);

  Future<void> init() async {
    await _service.init();
    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    transactions.clear();
    final stored = await _service.getTransactions();
    transactions.addAll(stored);
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _service.addTransaction(transaction);
    transactions.add(transaction);
    notifyListeners();
    try {
      print(
        'TransactionProvider: added transaction ${transaction.id} amount=${transaction.amount}',
      );
    } catch (_) {}
  }

  List<TransactionModel> get incomes =>
      transactions.where((transaction) => transaction.isIncome).toList();

  List<TransactionModel> get expenses =>
      transactions.where((transaction) => transaction.isExpense).toList();

  double get totalIncome =>
      incomes.fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get totalExpense =>
      expenses.fold(0.0, (sum, transaction) => sum + transaction.amount);

  int get incomeCount => incomes.length;

  int get expenseCount => expenses.length;

  double get balance => totalIncome - totalExpense;

  Map<String, double> get incomesByCategory {
    final Map<String, double> categoryTotals = {};
    for (final transaction in incomes) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    return categoryTotals;
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> categoryTotals = {};
    for (final transaction in expenses) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    return categoryTotals;
  }
}
