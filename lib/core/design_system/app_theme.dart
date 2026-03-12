import 'package:flutter/material.dart';
import 'color_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: ColorTokens.primary30,
      onPrimary: ColorTokens.neutral100,
      secondary: ColorTokens.secondary50,
      onSecondary: ColorTokens.neutral100,
      error: ColorTokens.error50,
      onError: ColorTokens.neutral100,
      surface: ColorTokens.neutral100,
      onSurface: ColorTokens.neutral10,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorTokens.primary30,
      foregroundColor: ColorTokens.neutral100,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ColorTokens.neutral100),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      color: ColorTokens.neutral100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      // Títulos principales
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: ColorTokens.neutral10,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorTokens.neutral10,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorTokens.neutral10,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ColorTokens.neutral10,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ColorTokens.neutral10,
      ),
      // Texto del cuerpo
      bodyLarge: TextStyle(fontSize: 16, color: ColorTokens.neutral20),
      bodyMedium: TextStyle(fontSize: 14, color: ColorTokens.neutral30),
      bodySmall: TextStyle(fontSize: 12, color: ColorTokens.neutral40),
      // Labels y texto secundario
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ColorTokens.neutral20,
      ),
      labelMedium: TextStyle(fontSize: 12, color: ColorTokens.neutral50),
      labelSmall: TextStyle(fontSize: 10, color: ColorTokens.neutral60),
    ),
    iconTheme: const IconThemeData(color: ColorTokens.neutral20, size: 24),
    drawerTheme: const DrawerThemeData(
      backgroundColor: ColorTokens.neutral100,
      elevation: 4,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: ColorTokens.neutral30,
      textColor: ColorTokens.neutral10,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[100],
      selectedColor: ColorTokens.primary30,
      labelStyle: const TextStyle(color: ColorTokens.neutral20),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.light,
      side: BorderSide(color: Colors.grey.shade300),
      checkmarkColor: Colors.white,
    ),
    badgeTheme: const BadgeThemeData(
      backgroundColor: ColorTokens.primary30,
      textColor: ColorTokens.neutral100,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorTokens.neutral100,
      selectedItemColor: ColorTokens.primary30,
      unselectedItemColor: ColorTokens.neutral70,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ColorTokens.neutral10),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(foregroundColor: ColorTokens.neutral10),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: ColorTokens.neutral100,
      titleTextStyle: TextStyle(
        color: ColorTokens.neutral10,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: ColorTokens.neutral20, fontSize: 14),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorTokens.primary10,
    colorScheme: const ColorScheme.dark(
      primary: ColorTokens.primary30,
      onPrimary: ColorTokens.neutral100,
      secondary: ColorTokens.secondary50,
      onSecondary: ColorTokens.neutral100,
      error: ColorTokens.error50,
      onError: ColorTokens.neutral100,
      surface: ColorTokens.primary20,
      onSurface: ColorTokens.neutral100,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorTokens.primary30,
      foregroundColor: ColorTokens.neutral100,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ColorTokens.neutral100),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      color: ColorTokens.primary20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      // Títulos principales
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: ColorTokens.neutral100,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorTokens.neutral100,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorTokens.neutral100,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ColorTokens.neutral100,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ColorTokens.neutral100,
      ),
      // Texto del cuerpo
      bodyLarge: TextStyle(fontSize: 16, color: ColorTokens.neutral100),
      bodyMedium: TextStyle(fontSize: 14, color: ColorTokens.neutral100),
      bodySmall: TextStyle(fontSize: 12, color: ColorTokens.neutral90),
      // Labels y texto secundario
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ColorTokens.neutral100,
      ),
      labelMedium: TextStyle(fontSize: 12, color: ColorTokens.neutral90),
      labelSmall: TextStyle(fontSize: 10, color: ColorTokens.neutral80),
    ),
    iconTheme: const IconThemeData(color: ColorTokens.neutral100, size: 24),
    drawerTheme: const DrawerThemeData(
      backgroundColor: ColorTokens.primary20,
      elevation: 4,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: ColorTokens.neutral100,
      textColor: ColorTokens.neutral100,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ColorTokens.primary20,
      selectedColor: ColorTokens.primary60,
      labelStyle: const TextStyle(color: ColorTokens.neutral100),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.dark,
      side: BorderSide(color: Colors.grey.shade600),
      checkmarkColor: Colors.white,
    ),
    badgeTheme: const BadgeThemeData(
      backgroundColor: ColorTokens.primary30,
      textColor: ColorTokens.neutral100,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorTokens.primary20,
      selectedItemColor: ColorTokens.primary60,
      unselectedItemColor: ColorTokens.neutral70,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ColorTokens.neutral100),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(foregroundColor: ColorTokens.neutral100),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: ColorTokens.primary20,
      titleTextStyle: TextStyle(
        color: ColorTokens.neutral100,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: ColorTokens.neutral90, fontSize: 14),
    ),
  );
}
