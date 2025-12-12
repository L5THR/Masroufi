// lib/core/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Dark Theme Colors
  static const Color primaryBlack = Color(0xFF0A0A0A);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color tertiaryGrey = Color(0xFF2A2A2A);

  // Light Theme Colors
  static const Color primaryWhite = Color(0xFFFAFAFA);
  static const Color secondaryWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFE8E8E8);

  // Accent Colors - Modern & Vibrant
  static const Color accentBlue = Color(0xFF6C63FF); // Purple-Blue
  static const Color accentGreen = Color(0xFF00D9A3); // Vibrant Teal
  static const Color accentOrange = Color(0xFFFF6B6B); // Coral Red
  static const Color accentYellow = Color(0xFFFFC107); // Warm Yellow

  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B0B0);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color textDarkGrey = Color(0xFF6B6B6B);

  // Status Colors
  static const Color errorRed = Color(0xFFFF4757);
  static const Color warningYellow = Color(0xFFFFA502);
  static const Color successGreen = Color(0xFF26DE81);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D9A3), Color(0xFF00B88D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: primaryBlack,
    brightness: Brightness.dark,
    primaryColor: accentBlue,
    colorScheme: const ColorScheme.dark(
      primary: accentBlue,
      secondary: accentGreen,
      tertiary: accentOrange,
      surface: secondaryBlack,
      error: errorRed,
      onPrimary: textWhite,
      onSecondary: textWhite,
      onSurface: textWhite,
    ),

    // AppBar Theme - More distinctive
    appBarTheme: const AppBarTheme(
      backgroundColor: secondaryBlack,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textWhite),
      titleTextStyle: TextStyle(
        color: textWhite,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),

    // Text Theme - More personality
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textWhite,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: textWhite,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        color: textWhite,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: textWhite,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: textWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: textWhite,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: textGrey,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),

    // Button Themes - More modern
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentBlue,
        foregroundColor: textWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentBlue,
        side: const BorderSide(color: accentBlue, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Input Decoration - Rounded & Modern
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tertiaryGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      hintStyle: const TextStyle(color: textGrey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: secondaryBlack,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: tertiaryGrey, width: 1),
      ),
    ),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: primaryWhite,
    brightness: Brightness.light,
    primaryColor: accentBlue,
    colorScheme: const ColorScheme.light(
      primary: accentBlue,
      secondary: accentGreen,
      tertiary: accentOrange,
      surface: secondaryWhite,
      error: errorRed,
      onPrimary: textWhite,
      onSecondary: textWhite,
      onSurface: textBlack,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: secondaryWhite,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textBlack),
      titleTextStyle: TextStyle(
        color: textBlack,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textBlack,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: textBlack,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        color: textBlack,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: textBlack,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: textBlack,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: textBlack,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: textDarkGrey,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentBlue,
        foregroundColor: textWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentBlue,
        side: const BorderSide(color: accentBlue, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      hintStyle: const TextStyle(color: textDarkGrey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: secondaryWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: lightGrey, width: 1),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: secondaryWhite,
      selectedItemColor: accentBlue,
      unselectedItemColor: textDarkGrey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
