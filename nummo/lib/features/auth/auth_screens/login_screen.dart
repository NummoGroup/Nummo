import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nummo/features/dashboard/dashboard_screen.dart';

import 'package:nummo/shared/widgets/custom_button.dart';
import 'package:nummo/shared/widgets/input_field.dart';
import 'package:nummo/features/auth/auth_provider.dart';
import 'package:nummo/features/auth/auth_screens/forgot_password_screen.dart'; // <-- Importamos la pantalla nueva

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // --- VALIDACIÓN DE 6 CARACTERES ---
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final success = await authProvider.login(email, password);

    if (success && mounted) {
      // SOLUCIÓN AL BUCLE: Destruye el login/welcome y setea el Dashboard como nueva raíz limpia
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF8DE2FF),
      body: SafeArea(
        child: SingleChildScrollView( // <-- Agregado para que no tire error de pantalla chica
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Iniciar Sesión:',
                  style: GoogleFonts.lexend(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(height: 40),
              
              CustomInputField(
                label: 'Correo Electrónico',
                isRequired: true,
                controller: _emailController,
              ),
              
              CustomInputField(
                label: 'Contraseña',
                isRequired: true,
                controller: _passwordController,
                isPassword: true,
              ),

              if (authProvider.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    authProvider.error!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              // --- BOTÓN DE OLVIDÉ MI CONTRASEÑA ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Ingresar',
                      onPressed: _handleLogin,
                    ),
                    
              const SizedBox(height: 16),

              // --- BOTÓN DE GOOGLE CON MANEJO DE ERRORES ---
              CustomButton(
                text: 'Iniciar con Google',
                onPressed: () async {
                  final success = await context.read<AuthProvider>().loginWithGoogle();
                  if (success && context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  } else if (context.mounted) {
                    // Si falla, te tira el cartel avisando
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.read<AuthProvider>().error ?? 'Error con Google. ¿Configuraste el SHA-1?')),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),
              
              CustomButton(
                text: 'Volver',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}