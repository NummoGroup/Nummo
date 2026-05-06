import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../transactions/transaction_provider.dart';
import '../savings/savings_screen.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del provider
    final transactionProvider = context.watch<TransactionProvider>();
    
    // Calculamos el total de gastos para mostrar en el centro
    final listaDeGastos = transactionProvider.expenses;

// Sumamos los montos de todos los gastos en esa lista
final double totalGastos = listaDeGastos.fold(0.0, (sum, item) => sum + item.amount);
    // Para el gráfico circular, calculamos un progreso basado en un presupuesto
    // Si no tienes presupuesto definido, puedes usar un valor estático o base 1000
    double budget = 1000.0; 
    double progress = (totalGastos / budget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF81D4FA), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Si implementas carga desde base de datos remota, iría aquí
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Gastos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Ingresos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildDropdown('Julio'),
                    const SizedBox(width: 10),
                    _buildDropdown('2026'),
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
                        child: CircularProgressIndicator(
                          // Ahora el valor es dinámico según el gasto real
                          value: progress, 
                          strokeWidth: 35,
                          backgroundColor: Colors.pink[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF06292)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            // Conectamos el total dinámico con 2 decimales
                            '\$${totalGastos.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const Text('Total', style: TextStyle(color: Colors.black54)),
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
                          // Acción para abrir formulario de nuevo gasto
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo gasto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black26),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SavingsScreen()),
                          );
                        },
                        icon: const Icon(Icons.savings_rounded),
                        label: const Text('Ver Ahorros'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF195B2), 
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 35),

                const Text(
                  'Gastos por categoría',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 15),

                // Generamos la lista de categorías dinámicamente desde el Provider
                // Si tienes un mapa de categorías en tu provider, podrías usar un ListView aquí
                _buildCategoryItem('Educación', const Color(0xFF91FFB5), '150.00'),
                _buildCategoryItem('Comidas y bebidas', const Color(0xFFCE93D8), '230.50'),
                _buildCategoryItem('Transporte', const Color(0xFFFF8A80), '45.00'),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ]
      ),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 5),
          const Icon(Icons.keyboard_arrow_down, size: 20),
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
        trailing: Text('\$$amount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}