import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1E8BC3),
    scaffoldBackgroundColor: const Color(0xFF0D1B2A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1E8BC3),
      secondary: Color(0xFF26C6DA),
      surface: Color(0xFF1A2B3C),
      error: Color(0xFFCF6679),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D1B2A),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A2B3C),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A2B3C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C3E50)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C3E50)),
      ),
    ),
    dividerColor: const Color(0xFF2C3E50),
    iconTheme: const IconThemeData(color: Colors.white70),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0D1B2A),
      selectedItemColor: Color(0xFF1E8BC3),
      unselectedItemColor: Colors.white38,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? const Color(0xFF1E8BC3)
            : Colors.grey,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? const Color(0xFF1E8BC3).withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.3),
      ),
    ),
  );
}
