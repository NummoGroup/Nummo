import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'transaction_provider.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TransactionProvider>();
      _initializeProvider(provider);
    });
  }

  Future<void> _initializeProvider(TransactionProvider provider) async {
    await provider.init();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  static const List<String> _incomeCategories = [
    'Salario',
    'Ahorros',
    'Inversiones',
    'Otros',
  ];

  static const List<String> _expenseCategories = [
    'Comida',
    'Transporte',
    'Renta',
    'Compras',
    'Otros',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> _categoriesFor(String type) {
    return type == 'income' ? _incomeCategories : _expenseCategories;
  }

  void _openAddTransactionDialog(String type) {
    _selectedCategory = _categoriesFor(type).first;
    _amountController.clear();
    _descriptionController.clear();

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(type == 'income' ? 'Nuevo ingreso' : 'Nuevo gasto'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        //prefixText: '$',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa un monto';
                        }
                        final number = double.tryParse(
                          value.replaceAll(',', '.'),
                        );
                        if (number == null || number <= 0) {
                          return 'Ingresa un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      items: _categoriesFor(type)
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final amount = double.parse(
                        _amountController.text.replaceAll(',', '.'),
                      );
                      final transaction = TransactionModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        amount: amount,
                        type: type,
                        category: _selectedCategory ?? 'Sin categoría',
                        date: DateTime.now(),
                        description: _descriptionController.text.trim(),
                      );
                      // Use the provider from the tree to ensure we call the shared instance
                      context.read<TransactionProvider>().addTransaction(
                        transaction,
                      );
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color color, {
    String? detail,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (detail != null) ...[
              const SizedBox(height: 6),
              Text(
                detail,
                style: TextStyle(color: color.withOpacity(0.8), fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> transactions) {
    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final icon = transaction.isIncome
            ? Icons.arrow_downward
            : Icons.arrow_upward;
        final color = transaction.isIncome ? Colors.green : Colors.red;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.16),
              child: Icon(icon, color: color),
            ),
            title: Text(transaction.category),
            subtitle: Text(
              '${transaction.description.isNotEmpty ? '${transaction.description}\n' : ''}${transaction.date.toIso8601String().split('T').first}',
            ),
            trailing: Text(
              '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            isThreeLine: transaction.description.isNotEmpty,
          ),
        );
      },
    );
  }

  Widget _buildCategoriesView(
    Map<String, double> categoriesByAmount,
    Color color,
    List<TransactionModel> typeTransactions,
  ) {
    if (categoriesByAmount.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar'));
    }

    final sortedCategories = categoriesByAmount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: sortedCategories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = sortedCategories[index];
        final category = entry.key;
        final total = entry.value;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.16),
              child: Icon(Icons.category, color: color),
            ),
            title: Text(category),
            subtitle: Text(
              '\$${total.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: typeTransactions
                      .where((t) => t.category == category)
                      .toList()
                      .map(
                        (transaction) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.description.isNotEmpty
                                          ? transaction.description
                                          : 'Sin descripción',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      transaction.date
                                          .toIso8601String()
                                          .split('T')
                                          .first,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${transaction.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movimientos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openAddTransactionDialog('income'),
                          icon: const Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                          ),
                          label: const Text('Ingreso'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openAddTransactionDialog('expense'),
                          icon: const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                          ),
                          label: const Text('Gasto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Ingresos',
                        '\$${provider.totalIncome.toStringAsFixed(2)}',
                        Colors.green,
                        detail:
                            '${provider.incomeCount} ${provider.incomeCount == 1 ? 'transacción' : 'transacciones'}',
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        'Gastos',
                        '\$${provider.totalExpense.toStringAsFixed(2)}',
                        Colors.red,
                        detail:
                            '${provider.expenseCount} ${provider.expenseCount == 1 ? 'transacción' : 'transacciones'}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade400, Colors.blue.shade700],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Balance Total',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\$${provider.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: transactions.isEmpty
                        ? const Center(child: Text('No hay transacciones aún.'))
                        : DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                TabBar(
                                  tabs: const [
                                    Tab(text: 'Todas'),
                                    Tab(text: 'Ingresos'),
                                    Tab(text: 'Gastos'),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      _buildTransactionsList(transactions),
                                      _buildCategoriesView(
                                        provider.incomesByCategory,
                                        Colors.green,
                                        transactions
                                            .where((t) => t.isIncome)
                                            .toList(),
                                      ),
                                      _buildCategoriesView(
                                        provider.expensesByCategory,
                                        Colors.red,
                                        transactions
                                            .where((t) => t.isExpense)
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
