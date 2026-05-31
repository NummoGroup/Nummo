import 'package:hive/hive.dart';
import 'reminder_model.dart';

class ReminderService {
  static const String _boxName = 'reminders';
  late Box<ReminderModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ReminderModel>(_boxName);
  }

  List<ReminderModel> getReminders() {
    return _box.values.toList();
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await _box.put(reminder.id, reminder);
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _box.put(reminder.id, reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _box.delete(id);
  }

  Future<void> dispose() async {
    await _box.close();
  }
}