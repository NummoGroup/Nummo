import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final bool isPassword;
  final Widget? suffixIcon; 
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.label,
    this.isRequired = false,
    this.isPassword = false, 
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white, // 2. TEXTOS EN BLANCO
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.black87), 
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(196, 200, 225, 236), 
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none, 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), 
              borderSide: const BorderSide(color: Color.fromARGB(255, 47, 189, 255), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}