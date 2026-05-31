import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'financial_provider.dart';
import '../goals/goal_provider.dart';
import '../transactions/transaction_provider.dart';
import '../savings/savings_provider.dart';
import '../../shared/widgets/screen_wrapper.dart';

class FinancialHealthScreen extends StatefulWidget {
  const FinancialHealthScreen({super.key});

  @override
  State<FinancialHealthScreen> createState() => _FinancialHealthScreenState();
}

class _FinancialHealthScreenState extends State<FinancialHealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHealth();
    });
  }

  Future<void> _calculateHealth() async {
    final transactionProvider = context.read<TransactionProvider>();
    final savingsProvider = context.read<SavingsProvider>();
    final goalProvider = context.read<GoalProvider>();
    final healthProvider = context.read<FinancialHealthProvider>();

    // Obtener transacciones
    final transactions = transactionProvider.transactions;

    // Calcular ingresos y gastos
    double totalIngresos = 0;
    double totalGastos = 0;

    for (var transaction in transactions) {
      if (transaction.isIncome) {
        totalIngresos += transaction.amount;
      } else if (transaction.isExpense) {
        totalGastos += transaction.amount;
      }
    }

    // Obtener ahorros de metas + ahorros globales (si existieran)
    final totalAhorroDeMetas = goalProvider.goals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final savings = savingsProvider.savings;
    final totalAhorro = totalAhorroDeMetas + savings.totalSaved;

    // Compras impulsivas - valor fijo de 5 por ahora
    const comprasImpulsivas = 5.0;

    // Calcular salud financiera
    await healthProvider.calculateHealth(
      ingresos: totalIngresos,
      gastos: totalGastos,
      ahorro: totalAhorro,
      comprasImpulsivas: comprasImpulsivas,
    );
  }

  Color _getHealthColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getHealthLabel(double percentage) {
    if (percentage >= 80) return 'Excelente';
    if (percentage >= 60) return 'Buena';
    if (percentage >= 40) return 'Regular';
    return 'Necesita mejorar';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Salud Financiera',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ScreenWrapper(
        child: SafeArea(
        child: Consumer<FinancialHealthProvider>(
          builder: (context, healthProvider, _) {
            if (healthProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (healthProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error al calcular salud financiera',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        healthProvider.error ?? '',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _calculateHealth,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final health = healthProvider.currentHealth;

            if (health == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.assessment_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay datos para calcular',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega transacciones o ahorros para ver tu salud financiera',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            final percentage = health.healthPercentage;
            final color = _getHealthColor(percentage);
            final label = _getHealthLabel(percentage);

            return RefreshIndicator(
              onRefresh: _calculateHealth,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Indicador circular de salud
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: CircularProgressIndicator(
                                    value: percentage / 100,
                                    strokeWidth: 12,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      color,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: color),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Última actualización: ${health.calculatedAt.toString().substring(0, 19)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Información adicional
                  Consumer<TransactionProvider>(
                    builder: (context, transactionProvider, _) {
                      final transactions = transactionProvider.transactions;
                      double totalIngresos = 0;
                      double totalGastos = 0;

                      for (var transaction in transactions) {
                        if (transaction.isIncome) {
                          totalIngresos += transaction.amount;
                        } else if (transaction.isExpense) {
                          totalGastos += transaction.amount;
                        }
                      }

                      return Consumer2<GoalProvider, SavingsProvider>(
                        builder: (context, goalProvider, savingsProvider, _) {
                          final savings = savingsProvider.savings;
                          final totalAhorroDeMetas = goalProvider.goals
                              .fold<double>(
                                0.0,
                                (sum, goal) => sum + goal.currentAmount,
                              );
                          final totalAhorro =
                              totalAhorroDeMetas + savings.totalSaved;

                          return Column(
                            children: [
                              _InfoCard(
                                title: 'Ingresos',
                                value: '\$${totalIngresos.toStringAsFixed(2)}',
                                icon: Icons.trending_up,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 12),
                              _InfoCard(
                                title: 'Gastos',
                                value: '\$${totalGastos.toStringAsFixed(2)}',
                                icon: Icons.trending_down,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              _InfoCard(
                                title: 'Ahorros',
                                value: '\$${totalAhorro.toStringAsFixed(2)}',
                                icon: Icons.savings,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 12),
                              _InfoCard(
                                title: 'Balance',
                                value:
                                    '\$${(totalIngresos - totalGastos).toStringAsFixed(2)}',
                                icon: Icons.account_balance_wallet,
                                color: totalIngresos - totalGastos >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _calculateHealth,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
