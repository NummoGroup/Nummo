import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nummo/features/transactions/transaction_provider.dart';
import 'package:nummo/features/transactions/transaction_model.dart';

class CategoryData {
  final String name;
  final double amount;
  final Color color;

  CategoryData(this.name, this.amount, this.color);
}

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _selectedPeriodIndex = 0; // 0: Semanal, 1: Mensual

  // Asignar un color consistente a cada categoría basado en su nombre
  Color _getColorForCategory(String category) {
    final colors = [
      Colors.orange, Colors.blue, Colors.purple, Colors.red,
      Colors.teal, Colors.green, Colors.indigo, Colors.pink,
      Colors.cyan, Colors.amber, Colors.deepOrange, Colors.lime
    ];
    int hash = category.hashCode;
    return colors[hash.abs() % colors.length];
  }

  // Lógica para filtrar las transacciones reales y convertirlas en CategoryData
  List<CategoryData> _getChartData(List<TransactionModel> transactions, bool isWeekly) {
    final now = DateTime.now();
    
    // 1. Filtrar por fecha
    final filtered = transactions.where((t) {
      if (isWeekly) {
        // Semanal: últimos 7 días
        final diff = now.difference(t.date).inDays;
        return diff <= 7 && diff >= 0;
      } else {
        // Mensual: mismo mes y año
        return t.date.year == now.year && t.date.month == now.month;
      }
    }).toList();

    // 2. Agrupar montos por categoría
    final Map<String, double> grouped = {};
    for (var t in filtered) {
      grouped[t.category] = (grouped[t.category] ?? 0) + t.amount;
    }

    // 3. Convertir a CategoryData
    return grouped.entries.map((e) {
      return CategoryData(
        e.key,
        e.value,
        _getColorForCategory(e.key),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Obtenemos el Provider (que lee de Hive)
    final provider = context.watch<TransactionProvider>();
    final isWeekly = _selectedPeriodIndex == 0;

    // Generamos la data dinámica a partir de las transacciones reales
    final expensesData = _getChartData(provider.expenses, isWeekly);
    final incomesData = _getChartData(provider.incomes, isWeekly);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Análisis'),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Gastos'),
              Tab(text: 'Ingresos'),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            // Segmented control para Semanal/Mensual
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Semanal')),
                  ButtonSegment(value: 1, label: Text('Mensual')),
                ],
                selected: {_selectedPeriodIndex},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _selectedPeriodIndex = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            // Vistas de Gastos e Ingresos
            Expanded(
              child: TabBarView(
                children: [
                  _buildAnalysisList(expensesData, context),
                  _buildAnalysisList(incomesData, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisList(List<CategoryData> data, BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No hay datos para este periodo.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Ordenar de mayor a menor para mostrar el mayor arriba
    final sortedData = List<CategoryData>.from(data)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    
    // El máximo nos sirve para que la barra más larga ocupe el 100% del ancho
    final double maxAmount = sortedData.first.amount;
    final double totalAmount = sortedData.fold(0, (sum, item) => sum + item.amount);

    // Generar datos para el gráfico de barras vertical
    List<BarChartGroupData> barGroups = List.generate(sortedData.length, (index) {
      final item = sortedData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.amount,
            color: item.color,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      children: [
        // Tarjeta de total
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Gráfico de barras vertical
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: barGroups,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index >= 0 && index < sortedData.length) {
                        String name = sortedData[index].name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            name.length > 3 ? name.substring(0, 3) : name,
                            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Por Categorías',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        // Generamos la lista de gráficos de barras horizontales
        ...sortedData.map((item) {
          final double percentage = item.amount / maxAmount;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(
                      '\$${item.amount.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    // Fondo de la barra (gris claro)
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    // Barra de color (porcentaje respecto al máximo)
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
