import 'package:hive/hive.dart';
import '../../features/goals/goal_model.dart';
import '../../features/savings/savings_model.dart';
import '../../features/transactions/transaction_model.dart';

Future<void> dumpHiveToConsole() async {
  print('\n╔══════════════════════════════════════╗');
  print('║       DEBUG: HIVE DATABASE DUMP      ║');
  print('╚══════════════════════════════════════╝');

  try {
    // --- 1. GOALS ---
    final goalBox = Hive.isBoxOpen('goals') 
        ? Hive.box<GoalModel>('goals') 
        : await Hive.openBox<GoalModel>('goals');

    print('\n📌 GOALS (${goalBox.length} registros):');
    if (goalBox.isEmpty) {
      print('   (vacío)');
    } else {
      for (var i = 0; i < goalBox.length; i++) {
        final g = goalBox.getAt(i);
        print('   → [$i] Target: ${g?.targetAmount}, Progress: ${g?.currentAmount}');
      }
    }

    // --- 2. SAVINGS ---
    // Usamos el modelo Savings y el nombre de caja savings_v2 que definimos para el typeId: 4
    final savingsBox = Hive.isBoxOpen('savings_v2') 
        ? Hive.box<Savings>('savings_v2') 
        : await Hive.openBox<Savings>('savings_v2');

    print('\n💰 SAVINGS (${savingsBox.length} registros):');
    if (savingsBox.isEmpty) {
      print('   (vacío)');
    } else {
      for (final key in savingsBox.keys) {
        final s = savingsBox.get(key);
        if (s != null) {
          print('   → Key: $key');
          print('     Total Ahorrado: \$${s.totalSaved}');
          print('     Meta: \$${s.targetAmount}');
          print('     Depósitos: ${s.depositHistory.length} realizados');
        }
      }
    }

    // --- 3. TRANSACTIONS ---
    final transactionBox = Hive.isBoxOpen('transactions') 
        ? Hive.box<TransactionModel>('transactions') 
        : await Hive.openBox<TransactionModel>('transactions');

    print('\n📊 TRANSACTIONS (${transactionBox.length} registros):');
    if (transactionBox.isEmpty) {
      print('   (vacío)');
    } else {
      for (final t in transactionBox.values) {
        // Intentamos usar toJson si el modelo lo tiene, si no, printeamos campos básicos
        try {
          print('   → ${t.amount} | ${t.category} | ${t.date}');
        } catch (_) {
          print('   → Registro encontrado pero no se pudo formatear');
        }
      }
    }

    print('\n✅ Fin del dump correctamente ejecutado');

  } catch (e) {
    print('\n❌ Error crítico al leer Hive:');
    print('   $e');
    print('   TIP: Si el error es "lock failed", cerrá la app del todo y reiniciá.');
  }
  print('════════════════════════════════════════\n');
}