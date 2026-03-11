import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Telegram-style blue accent
  static const Color primary = Color(0xFF0088CC);

  static const Color lightBackground = Color(0xFFE6F0FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1C1E);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightBorder = Color(0xFFE0E0E0);

  static const Color darkBackground = Color(0xFF050816);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkText = Color(0xFFE4E4E6);
  static const Color darkTextSecondary = Color(0xFF9A9A9E);
  static const Color darkBorder = Color(0xFF2C2C2E);

  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5AC8FA);

  // Corner radius (used across the app)
  static const double radius = 18.0;

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

  static const double _borderRadius = radius;
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
        backgroundColor: Colors.transparent,
        foregroundColor: lightText,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: Colors.white70.withOpacity(0.18),
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: _shape.copyWith(
          side: BorderSide(
            color: Colors.white.withOpacity(0.35),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.18),
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
        backgroundColor: Colors.white.withOpacity(0.22),
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
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: Colors.white10.withOpacity(0.12),
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.6),
        shape: _shape.copyWith(
          side: BorderSide(
            color: Colors.white.withOpacity(0.18),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white10.withOpacity(0.12),
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
        backgroundColor: Colors.white10.withOpacity(0.16),
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
