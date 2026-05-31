import 'package:hive/hive.dart';
import 'transaction_model.dart';

abstract class TransactionService {
  Future<void> init();
  Future<void> addTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getTransactions();
  Future<void> deleteTransaction(String id);
  Stream<List<TransactionModel>> get transactionsStream;
  Future<double> get balance;
}

class HiveTransactionService implements TransactionService {
  static const String _boxName = 'transactions';
  late Box<TransactionModel> _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox<TransactionModel>(_boxName);
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
    // Debug log to confirm write
    try {
      print('HiveTransactionService: saved transaction ${transaction.id}');
    } catch (_) {}
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    try {
      print('HiveTransactionService: deleted transaction $id');
    } catch (_) {}
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    return _box.values.toList();
  }

  @override
  Stream<List<TransactionModel>> get transactionsStream {
    return _box.watch().map((_) => _box.values.toList());
  }

  @override
  Future<double> get balance async {
    final transactions = _box.values.toList();
    final incomes = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    return incomes - expenses;
  }
}
