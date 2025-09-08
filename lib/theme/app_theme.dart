import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. REFINED COLOR PALETTE
  // Primary & Accent Colors (Vibrant but controlled)
  static const Color primary = Color(0xFF6A5AE0); // A more sophisticated purple
  static const Color accentNeon = Color(0xFF00F5D4); // Bright, modern teal
  static const Color accentPink = Color(0xFFF72585); // Punchy magenta

  // Neutral Colors (The foundation)
  static const Color lightBackground = Color(0xFFF8F9FA); // Clean off-white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white for cards
  static const Color lightText = Color(0xFF212529); // Dark, readable text
  static const Color lightTextSecondary = Color(0xFF6C757D); // Muted gray text
  static const Color lightBorder = Color(0xFFE9ECEF); // Subtle border

  static const Color darkBackground = Color(0xFF121212); // True dark background
  static const Color darkSurface =
      Color(0xFF1E1E1E); // Slightly lighter surface
  static const Color darkText = Color(0xFFE9ECEF); // Soft white text
  static const Color darkTextSecondary =
      Color(0xFFADB5BD); // Muted light gray text
  static const Color darkBorder = Color(0xFF343A40); // Subtle dark border

  // System Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // 2. MODERN TYPOGRAPHY SETUP
  static final _lightTextTheme = GoogleFonts.manropeTextTheme(
    const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: lightText),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: lightText),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: lightText),
      bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: lightText),
      bodyMedium: TextStyle(color: lightTextSecondary),
      labelLarge: TextStyle(fontWeight: FontWeight.w600), // For buttons
    ),
  );

  static final _darkTextTheme = GoogleFonts.manropeTextTheme(
    const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: darkText),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: darkText),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: darkText),
      bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: darkText),
      bodyMedium: TextStyle(color: darkTextSecondary),
      labelLarge: TextStyle(fontWeight: FontWeight.w600), // For buttons
    ),
  );

  // 3. SOFTER CORNER RADIUS
  static const double _borderRadius = 12.0;
  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_borderRadius),
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accentNeon,
        background: lightBackground,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: lightText,
        onSurface: lightText,
        error: error,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: _lightTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        color: lightSurface,
        elevation: 0,
        shape: _shape.copyWith(
          side: const BorderSide(color: lightBorder, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: lightBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: lightBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: _shape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _lightTextTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentPink,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: lightSurface,
        shape: _shape,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: lightTextSecondary, width: 2),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentNeon,
        background: darkBackground,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: darkText,
        onSurface: darkText,
        error: error,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: _darkTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 0,
        shape: _shape.copyWith(
          side: const BorderSide(color: darkBorder, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: _shape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _darkTextTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentNeon,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: darkSurface,
        shape: _shape,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: darkTextSecondary, width: 2),
      ),
    );
  }

  // --- Utility Decorations ---

  // Modern gradient decoration
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
        gradient: const LinearGradient(
          colors: [primary, accentPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
      );

  // Glassmorphism effect for dark theme
  static BoxDecoration get glassmorphismDecoration => BoxDecoration(
        color: const Color(0x1AFFFFFF), // Translucent white
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: const Color(0x33FFFFFF),
          width: 1.5,
        ),
      );
}
