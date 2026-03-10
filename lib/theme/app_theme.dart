import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF5B5FC7);

  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1C1E);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightBorder = Color(0xFFE0E0E0);

  static const Color darkBackground = Color(0xFF111113);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkText = Color(0xFFE4E4E6);
  static const Color darkTextSecondary = Color(0xFF9A9A9E);
  static const Color darkBorder = Color(0xFF2C2C2E);

  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5AC8FA);

  // Typography
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
        secondary: primary,
        background: lightBackground,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
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
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: _shape.copyWith(
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: lightBorder, width: 1),
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: _shape,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: lightTextSecondary, width: 1.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
        secondary: primary,
        background: darkBackground,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
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
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: _shape.copyWith(
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: darkBorder, width: 1),
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: _shape,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: darkTextSecondary, width: 1.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

}
