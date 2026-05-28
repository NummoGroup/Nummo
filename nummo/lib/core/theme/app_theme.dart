import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
  // Constantes de diseño para mantener la consistencia (Bordes premium)
  static const double _borderRadius = 16.0;

  // Paleta de Colores - Modo Claro
  static const Color _lightPrimary = Color.fromARGB(255, 47, 189, 255);    // Azul profundo institucional
  static const Color _lightSecondary = Color(0xFFF06292);  // Rosa energético para gamificación
  static const Color _lightAccent = Color(0xFF81D4FA);     // Celeste claro para balances
  static const Color _lightBackground = Color(0xFFF8F9FA); // Gris neutro muy limpio

  // Paleta de Colores - Modo Oscuro
  static const Color _darkPrimary = Color(0xFF9FA8DA);
  static const Color _darkSecondary = Color(0xFFF48FB1);
  static const Color _darkBackground = Color(0xFF121212);

  /// --- TEMA CLARO ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightBackground,
    
    // Configuración de la paleta semántica
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
      primary: _lightPrimary,
      secondary: _lightSecondary,
      tertiary: _lightAccent,
      surface: Colors.white,
    ),

    textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme).copyWith(
      headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: _lightPrimary),
      titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, color: _lightPrimary),
    ),

    // AppBar limpio, plano y transparente por defecto
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: _lightPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Tarjetas (Card) estilizadas con sombras suaves
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        side: BorderSide(color: Colors.black.withOpacity(0.04), width: 1),
      ),
    ),

    // Configuración global de los ElevatedButton (Ej: CustomButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightSecondary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Configuración global de OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimary,
        side: BorderSide(color: _lightPrimary.withOpacity(0.2), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Configuración del BottomNavigationBar para que luzca integrado
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _lightPrimary,
      unselectedItemColor: Colors.black38,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

  );

  /// --- TEMA OSCURO ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackground,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: const Color(0xFF1E1E1E),
    ),

    textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkSecondary,
        foregroundColor: const Color(0xFF121212),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimary,
        side: BorderSide(color: _darkPrimary.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: _darkPrimary,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
    ),
  );
}