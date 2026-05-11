
import 'package:hive/hive.dart';
import 'goal_model.dart'; // Asegúrate de haber creado el modelo primero

class GoalService {
  // Nombre de la caja (box) para Hive
  static const String _boxName = 'goals_box';

  // Abrir la caja de Hive
  Future<Box<Goal>> get _box async => await Hive.openBox<Goal>(_boxName);

  // CREAR: Guardar una nueva meta
  Future<void> createGoal(Goal goal) async {
    final box = await _box;
    await box.put(goal.id, goal);
  }

  // LEER: Obtener todas las metas guardadas
  Future<List<Goal>> getGoals() async {
    final box = await _box;
    return box.values.toList();
  }

  // ACTUALIZAR: Modificar una meta existente (ej. actualizar el monto actual)
  Future<void> updateGoal(Goal goal) async {
    final box = await _box;
    if (box.containsKey(goal.id)) {
      await box.put(goal.id, goal);
    }
  }

  // ELIMINAR: Borrar una meta por su ID
  Future<void> deleteGoal(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  // LÓGICA DE INTERACCIÓN: Actualizar progreso desde ahorros
  // Este método permite inyectar dinero de 'savings' a una meta específica
  Future<void> addAmountToGoal(String id, double amount) async {
    final box = await _box;
    final goal = box.get(id);
    if (goal != null) {
      goal.currentAmount += amount;
      await box.put(id, goal);
    }
  }
}