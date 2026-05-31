import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../transactions/transaction_provider.dart';
import '../transactions/transactions_screen.dart';
import '../savings/savings_screen.dart';
import 'menu_screens/charts_screen.dart';
import 'menu_screens/help_screen.dart';
import 'menu_screens/profile_screen.dart';
import 'menu_screens/reminders_screen.dart';
import 'menu_screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _mostrarGastos = true;

  late String _selectedMonth;
  late String _selectedYear;

  final List<String> _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  late final List<String> _years;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = _months[now.month - 1];
    _years = List.generate(6, (index) => (now.year - 2 + index).toString());
    _selectedYear = now.year.toString();
  }

  // Función para pasar del mes en texto al número (ej: 'Julio' -> 7)
  int _getMonthNumber(String month) {
    return _months.indexOf(month) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final allTransactions = transactionProvider.transactions;

    final selectedMonthNum = _getMonthNumber(_selectedMonth);
    final selectedYearNum = int.parse(_selectedYear);

    final filteredTransactions = allTransactions.where((t) {
      return t.date.month == selectedMonthNum && t.date.year == selectedYearNum;
    }).toList();

    double totalAmount = 0.0;
    Map<String, double> dataByCategory = {};

    for (var t in filteredTransactions) {
      bool isTargetType = _mostrarGastos
          ? t.type == 'expense'
          : t.type == 'income';

      if (isTargetType) {
        totalAmount += t.amount;
        dataByCategory[t.category] =
            (dataByCategory[t.category] ?? 0.0) + t.amount;
      }
    }

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_outline,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _mostrarGastos = true;
                        });
                      },
                      child: Text(
                        'Gastos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _mostrarGastos = false;
                        });
                      },
                      child: Text(
                        'Ingresos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildMonthDropdown(),
                    const SizedBox(width: 10),
                    _buildYearDropdown(),
                  ],
                ),
                const SizedBox(height: 30),

                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: CustomPaint(
                          painter: PieChartPainter(
                            dataByCategory: dataByCategory,
                            total: totalAmount,
                            getColor: _categoryColor,
                            defaultColor: _mostrarGastos
                                ? Colors.pink[100]!
                                : Colors.green[100]!,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Total',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TransactionsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text(
                          _mostrarGastos ? 'Nuevo gasto' : 'Nuevo ingreso',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color,
                          side: const BorderSide(color: Colors.black26),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.savings_rounded),
                        label: const Text('Ver Ahorros'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF81D4FA),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                Text(
                  _mostrarGastos
                      ? 'Gastos por categoría'
                      : 'Ingresos por categoría',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 15),

                if (dataByCategory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _mostrarGastos
                          ? 'Aún no hay gastos registrados en este mes.'
                          : 'Aún no hay ingresos registrados en este mes.',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  )
                else
                  Column(
                    children:
                        (dataByCategory.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value)))
                            .map(
                              (entry) => _buildCategoryItem(
                                entry.key,
                                _categoryColor(entry.key),
                                entry.value.toStringAsFixed(2),
                              ),
                            )
                            .toList(),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMonth,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedMonth = newValue);
            }
          },
          items: _months.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedYear,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedYear = newValue);
            }
          },
          items: _years.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF81D4FA)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 35,
                    color: Color(0xFF1A237E),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Menú Nummo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Gráficos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChartsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Recordatorios'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RemindersScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ayuda'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, Color color, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          '\$$amount',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'comida':
      case 'comidas y bebidas':
        return const Color(0xFFCE93D8);
      case 'transporte':
        return const Color(0xFFFF8A80);
      case 'renta':
        return const Color.fromARGB(255, 67, 124, 150);
      case 'educación':
      case 'educacion':
        return const Color(0xFF91FFB5);
      case 'salario':
        return const Color(0xFF80CBC4);
      case 'ahorros':
        return const Color(0xFF4DB6AC);
      default:
        return const Color(0xFF90A4AE);
    }
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> dataByCategory;
  final double total;
  final Color Function(String) getColor;
  final Color defaultColor;

  PieChartPainter({
    required this.dataByCategory,
    required this.total,
    required this.getColor,
    required this.defaultColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 35
      ..strokeCap = StrokeCap.butt;

    if (total == 0 || dataByCategory.isEmpty) {
      paint.color = defaultColor;
      canvas.drawArc(rect, 0, 2 * pi, false, paint);
      return;
    }

    double startAngle = -pi / 2;

    dataByCategory.forEach((category, amount) {
      final sweepAngle = (amount / total) * 2 * pi;
      paint.color = getColor(category);

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) => true;
}
