import 'package:equatable/equatable.dart';

class FinancialHealth extends Equatable {
  final double healthPercentage;
  final DateTime calculatedAt;

  const FinancialHealth({
    required this.healthPercentage,
    required this.calculatedAt,
  });

  factory FinancialHealth.fromJson(Map<String, dynamic> json) {
    return FinancialHealth(
      healthPercentage: (json['salud_financiera'] as num).toDouble(),
      calculatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'salud_financiera': healthPercentage};
  }

  @override
  List<Object?> get props => [healthPercentage, calculatedAt];
}
