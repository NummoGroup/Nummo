import 'dart:async';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'transaction_model.dart';

class TransactionService {
  static const String _boxName = 'transactions';
  late Box<TransactionModel> _box;
  final _uuid = const Uuid();

  final _transactionsController =
      StreamController<List<TransactionModel>>.broadcast();
  Stream<List<TransactionModel>> get transactionsStream =>
      _transactionsController.stream;

  Future<void> init() async {
    _box = await Hive.openBox<TransactionModel>(_boxName);
    _notify();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final newTransaction = transaction.copyWith(id: _uuid.v4());
    await _box.put(newTransaction.id, newTransaction);
    _notify();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    _notify();
  }

  double get balance {
    return _box.values.fold(0.0, (sum, t) {
      return t.type == 'income' ? sum + t.amount : sum - t.amount;
    });
  }

  List<TransactionModel> getAllTransactions() {
    return _box.values.toList();
  }

  List<TransactionModel> getIncomes() {
    return _box.values.where((t) => t.type == 'income').toList();
  }

  List<TransactionModel> getExpenses() {
    return _box.values.where((t) => t.type == 'expense').toList();
  }

  void _notify() {
    _transactionsController.add(_box.values.toList());
  }

  Future<void> dispose() async {
    await _transactionsController.close();
    await _box.close();
  }
}

extension TransactionModelCopy on TransactionModel {
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
