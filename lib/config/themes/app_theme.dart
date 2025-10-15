import 'package:flutter/material.dart';

class AppTheme {
  // Colores IPN Guinda
  static const Color ipnGuinda = Color(0xFF6B2E5F);
  static const Color ipnGuindaLight = Color(0xFF8B4E7F);
  static const Color ipnGuindaDark = Color(0xFF4B1E3F);

  // Colores ESCOM Azul
  static const Color escomAzul = Color(0xFF003D6D);
  static const Color escomAzulLight = Color(0xFF005D9D);
  static const Color escomAzulDark = Color(0xFF002D4D);

  // Tema Guinda Claro
  static ThemeData guindaLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: ipnGuinda,
        secondary: ipnGuindaLight,
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        error: Colors.red.shade700,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ipnGuinda,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ipnGuinda,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: const IconThemeData(
        color: ipnGuinda,
      ),
    );
  }

  // Tema Guinda Oscuro
  static ThemeData guindaDark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: ipnGuindaLight,
        secondary: ipnGuinda,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: Colors.red.shade300,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ipnGuindaDark,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ipnGuindaLight,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: const IconThemeData(
        color: ipnGuindaLight,
      ),
    );
  }

  // Tema Azul Claro
  static ThemeData azulLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: escomAzul,
        secondary: escomAzulLight,
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        error: Colors.red.shade700,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: escomAzul,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: escomAzul,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: const IconThemeData(
        color: escomAzul,
      ),
    );
  }

  // Tema Azul Oscuro
  static ThemeData azulDark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: escomAzulLight,
        secondary: escomAzul,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: Colors.red.shade300,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: escomAzulDark,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: escomAzulLight,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: const IconThemeData(
        color: escomAzulLight,
      ),
    );
  }
}