import 'package:hive/hive.dart';

part 'savings_model.g.dart';

@HiveType(typeId: 4)
class Savings extends HiveObject {
  @HiveField(0)
  double totalSaved;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  List<double> depositHistory;

  Savings({
    this.totalSaved = 0.0,
    this.targetAmount = 0.0,
    List<double>? depositHistory,
  }) : depositHistory = depositHistory ?? [];

  double get progressPercentage =>
      targetAmount > 0 ? (totalSaved / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isTargetReached => totalSaved >= targetAmount && targetAmount > 0;
}
