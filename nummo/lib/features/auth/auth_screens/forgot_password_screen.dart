import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nummo/shared/widgets/custom_button.dart';
import 'package:nummo/shared/widgets/input_field.dart';
import 'package:nummo/features/auth/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu correo')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    // Llamamos a la función que conecta con Firebase
    final success = await authProvider.resetPassword(email);

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Correo Enviado'),
          content: Text('Se ha enviado un enlace de restablecimiento a $email. Revisa tu bandeja de entrada o spam.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context); // Te devuelve al Login
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Error al enviar el correo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF8DE2FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Recuperar Clave:',
                style: GoogleFonts.lexend(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const Spacer(),
              CustomInputField(
                label: 'Ingresa tu Correo Electrónico',
                isRequired: true,
                controller: _emailController,
              ),
              const Spacer(),
              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(text: 'Enviar Correo', onPressed: _handleReset),
              const SizedBox(height: 16),
              CustomButton(text: 'Volver', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}