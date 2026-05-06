import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_service.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/user_model.dart';
import 'features/auth/auth_screens/welcome_screen.dart';

import 'features/goals/goal_service.dart';
import 'features/goals/goal_provider.dart';
import 'features/goals/goal_model.dart';

import 'features/savings/savings_service.dart';
import 'features/savings/savings_provider.dart';
import 'features/savings/savings_model.dart';

import 'features/transactions/transaction_service.dart';
import 'features/transactions/transaction_provider.dart';
import 'features/transactions/transaction_model.dart';

import 'features/dashboard/dashboard_screen.dart';
import 'features/goals/goals_screen.dart';
import 'features/savings/savings_screen.dart';
import 'features/transactions/transactions_screen.dart';
import 'core/theme/app_theme.dart';

import 'core/utils/hive_debug.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();

  // Registrar adapters
  Hive.registerAdapter(GoalModelAdapter());
  Hive.registerAdapter(SavingsAdapter()); // Asegurate que este es el que usa el typeId: 4
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(UserAdapter());

  // Crear instancias de servicios
  final authService = AuthService();
  final goalService = GoalService();
  final savingsService = SavingsService();
  final transactionService = TransactionService();

  await dumpHiveToConsole();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => GoalProvider(goalService)),
        ChangeNotifierProvider(create: (_) => SavingsProvider(savingsService)),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(transactionService),
        ),
      ],
      child: const NummoApp(),
    ),
  );
}

class NummoApp extends StatelessWidget {
  const NummoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nummo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // CORRECCIÓN: Solo una propiedad 'home'. 
      // Usamos SavingsScreen directamente para que puedas ver los cambios.
      home: const AuthWrapper(), 
      // home: const AuthWrapper(), // Descomenta esta línea cuando quieras volver al flujo normal
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/dashboard': (context) => const MainScreen(),
      },
    );
  }
}

/// AuthWrapper decide si mostrar Welcome o la app principal
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return authProvider.isAuthenticated
        ? const MainScreen()
        : const WelcomeScreen();
  }
}

/// MainScreen con BottomNavigationBar para las pantallas principales
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    GoalsScreen(),
    SavingsScreen(),
    TransactionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Metas'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Ahorros'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Movimientos',
          ),
        ],
      ),
    );
  }
}