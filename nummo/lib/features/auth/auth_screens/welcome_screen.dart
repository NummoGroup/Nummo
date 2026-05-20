import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nummo/shared/widgets/custom_button.dart';
import 'package:nummo/features/auth/auth_screens/register_screen.dart'; 
import 'package:nummo/features/auth/auth_screens/login_screen.dart'; 


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFF8DE2FF), 
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los botones a lo ancho
            children: [
              
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bienvenido...',
                  style: GoogleFonts.lexend(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              
              const Spacer(), 

              Container(
                height: 250,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),

              const SizedBox(height: 40), 

              Text(
                '¿Listo para emprender\neste viaje?', // \n hace un salto de línea
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const Spacer(), // Otro resorte para empujar los botones hacia abajo

              CustomButton(
                text: 'Iniciar Sesión',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(), // <-- Aquí llamas a tu pantalla
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Text(
                '¿No tienes una cuenta?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  color: Colors.blueAccent, 
                  fontSize: 12,
                  fontWeight: FontWeight.w600
                ),
              ),

              const SizedBox(height: 8),

              CustomButton(
                text: 'Registrarse',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(), // <-- Aquí llamas a tu pantalla
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}