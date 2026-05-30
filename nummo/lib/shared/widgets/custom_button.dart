import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text; 
  final VoidCallback onPressed; 

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 47, 189, 255), // Color estilo Welcome Screen (Violeta moderno)
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52), // Altura más estilizada (no tan grande)
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // Bordes más redondeados
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}