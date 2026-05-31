import 'package:flutter/foundation.dart';
import 'reminder_service.dart';
import 'reminder_model.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _service;
  List<ReminderModel> _reminders = [];
  bool _isLoading = false;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;

  ReminderProvider(this._service) {
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    await _service.init();
    _reminders = _service.getReminders();
    _setLoading(false);
  }

  Future<void> addReminder(String title, DateTime date) async {
    _setLoading(true);
    final reminder = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: date,
    );
    await _service.addReminder(reminder);
    _reminders = _service.getReminders();
    _setLoading(false);
  }

  Future<void> toggleReminderCompletion(ReminderModel reminder) async {
    _setLoading(true);
    final updated = reminder.copyWith(isCompleted: !reminder.isCompleted);
    await _service.updateReminder(updated);
    _reminders = _service.getReminders();
    _setLoading(false);
  }

  Future<void> deleteReminder(String id) async {
    _setLoading(true);
    await _service.deleteReminder(id);
    _reminders = _service.getReminders();
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}