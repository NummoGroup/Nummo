import 'dart:async';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'goal_model.dart';

class GoalService {
  static const String _boxName = 'goals';
  late Box<GoalModel> _box;
  final _uuid = const Uuid();

  // El sistema de Streams está impecable, se queda igual
  final _goalsController = StreamController<List<GoalModel>>.broadcast();
  Stream<List<GoalModel>> get goalsStream => _goalsController.stream;

  /// Inicializa la caja de Hive de forma segura
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<GoalModel>(_boxName);
    } else {
      _box = Hive.box<GoalModel>(_boxName);
    }
    // Si la caja ya tenía metas guardadas de antes, avisamos a la app
    if (_box.isNotEmpty) {
      _notify();
    }
  }

  /// Crea una nueva meta asignándole un ID único e irrepetible
  Future<void> createGoal(GoalModel goal) async {
    final newGoal = goal.copyWith(id: _uuid.v4());
    await _box.put(newGoal.id, newGoal);
    _notify();
  }

  /// CORREGIDO: Actualiza el progreso de forma inmutable usando copyWith
  Future<void> updateProgress(String id, double amount) async {
    final goal = _box.get(id);
    if (goal != null) {
      // Creamos una COPIA de la meta con el nuevo valor sumado
      final updatedGoal = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
      
      // Reemplazamos la meta vieja por la nueva en la base de datos usando su ID
      await _box.put(id, updatedGoal);
      _notify();
    }
  }

  /// Elimina una meta de la base de datos
  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
    _notify();
  }

  /// Devuelve la lista de metas actuales
  List<GoalModel> getAllGoals() {
    return _box.values.toList();
  }

  /// Envía la lista actualizada a los providers/pantallas de forma segura
  void _notify() {
    if (!_goalsController.isClosed) {
      _goalsController.add(_box.values.toList());
    }
  }

  /// Cierra los flujos para evitar fugas de memoria (Memory Leaks)
  Future<void> dispose() async {
    await _goalsController.close();
    if (_box.isOpen) {
      await _box.close();
    }
  }
}
