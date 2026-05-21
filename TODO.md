# TODO - Refactor SAVINGS y GOALS (Nummo)

- [ ] 1. Actualizar `GoalModel` para soportar hitos (milestonesCount) y persistir hitos alcanzados.
- [ ] 2. Actualizar `goal_model.g.dart` (adapter Hive) para que lea/escriba los nuevos campos.
- [ ] 3. Actualizar `GoalService.updateProgress` para recalcular y actualizar hitos alcanzados al guardar.
- [ ] 4. Implementar `GoalsScreen` con UI para crear barras (title, currentAmount, targetAmount, milestonesCount>=4, deadline) y eliminar con doble confirmación.
- [ ] 5. Refactorizar `SavingsScreen` para mostrar una pantalla con todas las barras de XP/ahorro (usando GoalsProvider/GoalModel).
- [ ] 6. Implementar lógica UI de hitos: divisores en la barra y mensajes/animaciones al llegar a hitos intermedios y al hit final.
- [ ] 7. Ejecutar `flutter analyze` y corregir errores.
- [ ] 8. Ejecutar build/regeneración si aplica (build_runner) o verificar que el código compila.

