import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nummo/shared/widgets/custom_button.dart';
import 'package:nummo/shared/widgets/input_field.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:nummo/features/reminders/reminder_model.dart';
import 'package:nummo/features/reminders/reminder_provider.dart';
import 'package:nummo/shared/widgets/screen_wrapper.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  // Configuración del calendario
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final TextEditingController _reminderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _reminderController.dispose();
    super.dispose();
  }

  // Obtener recordatorios de un día específico desde el provider
  List<ReminderModel> _getRemindersForDay(DateTime day, List<ReminderModel> allReminders) {
    // Normalizamos para comparar fechas sin horas
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return allReminders.where((reminder) {
      final reminderDate = DateTime(
        reminder.date.year,
        reminder.date.month,
        reminder.date.day,
      );
      return isSameDay(reminderDate, normalizedDay);
    }).toList();
  }

  // Lógica para guardar el recordatorio
  void _addReminder() {
    if (_reminderController.text.isEmpty || _selectedDay == null) return;

    final provider = Provider.of<ReminderProvider>(context, listen: false);
    
    // Normalizamos la fecha seleccionada
    final normalizedDay = DateTime(
      _selectedDay!.year, 
      _selectedDay!.month, 
      _selectedDay!.day
    );

    provider.addReminder(_reminderController.text, normalizedDay);

    _reminderController.clear();
    Navigator.pop(context); // Cierra el Modal
  }

  // Lógica para eliminar un recordatorio
  void _deleteReminder(ReminderModel reminder) {
    final provider = Provider.of<ReminderProvider>(context, listen: false);
    provider.deleteReminder(reminder.id);
  }

  // Modal para agregar recordatorio al tocar el FAB
  void _showAddReminderModal() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nuevo Recordatorio',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              CustomInputField(
                label: '¿Qué debes pagar? (Ej: Luz, Facultad)',
                isRequired: true,
                controller: _reminderController,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Guardar Recordatorio',
                onPressed: _addReminder,
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
      ),
      body: ScreenWrapper(
        child: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          if (reminderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allReminders = reminderProvider.reminders;
          final remindersForSelectedDay = _getRemindersForDay(
            _selectedDay ?? _focusedDay, 
            allReminders
          );

          return Column(
            children: [
              // 1. El Calendario
              TableCalendar<ReminderModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getRemindersForDay(day, allReminders), 
                startingDayOfWeek: StartingDayOfWeek.monday,
                
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary, 
                    shape: BoxShape.circle,
                  ),
                ),
                
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              
              const SizedBox(height: 16),
              
              Expanded(
                child: remindersForSelectedDay.isEmpty
                    ? Center(
                        child: Text(
                          'No hay recordatorios para este día.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: remindersForSelectedDay.length,
                        itemBuilder: (context, index) {
                          final reminder = remindersForSelectedDay[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                Icons.notifications_active,
                                color: reminder.isCompleted
                                    ? Colors.grey
                                    : theme.colorScheme.secondary,
                              ),
                              title: Text(
                                reminder.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: reminder.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteReminder(reminder),
                              ),
                              onTap: () {
                                reminderProvider.toggleReminderCompletion(reminder);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      ),
      // Botón flotante para agregar
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderModal,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
