import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 5)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final bool isCompleted;

  ReminderModel({
    required this.id,
    required this.title,
    required this.date,
    this.isCompleted = false,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}