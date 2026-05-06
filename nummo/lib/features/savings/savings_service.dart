import 'package:hive_flutter/hive_flutter.dart';
import 'savings_model.dart';

class SavingsService {
  static const String _boxName = 'savings_v2';
  static const String _savingsKey = 'current_savings';
  late Box<Savings> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Savings>(_boxName);
    if (!_box.containsKey(_savingsKey)) {
      await _box.put(_savingsKey, Savings());
    }
  }

  Savings getSavings() {
    return _box.get(_savingsKey) ?? Savings();
  }

  Future<void> updateSavings(Savings savings) async {
    await _box.put(_savingsKey, savings);
  }

  Future<void> dispose() async {
    await _box.close();
  }
}
