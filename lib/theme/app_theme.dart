import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Cool Modern Color Palette - Enhanced Cyberpunk inspired
  static const Color primaryNeon =
      Color(0xFF06B6D4); // Cool cyan (modern & softer)
  static const Color primaryPurple =
      Color.fromARGB(255, 100, 101, 163); // Elegant indigo-violet
  static const Color primaryPink =
      Color(0xFFF472B6); // Soft hot pink (less harsh)
  static const Color accentGreen = Color(0xFF34D399); // Fresh emerald-green
  static const Color accentOrange = Color(0xFFF97316); // Warm modern orange
  static const Color electricBlue = Color(0xFF3B82F6); // Vivid modern blue
  static const Color neonGreen =
      Color(0xFF22C55E); // Balanced green (less neon)
  static const Color hotMagenta =
      Color(0xFFE879F9); // Bright magenta with depth

  // Status colors
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFD700);
  static const Color error = Color(0xFFFF073A);
  static const Color info = Color(0xFF00D4FF);

  // Light theme colors - Clean and modern

// Light theme colors - Clean and modern
  static const Color lightSurface = Color(0xFFFAFAFB); // Soft white surface
  static const Color lightBackground =
      Color(0xFFF3F4F6); // Light gray background
  static const Color lightCard = Color(0xFFFFFFFF); // Pure white card
  static const Color lightText = Color(0xFF111827); // Deep neutral text
  static const Color lightTextSecondary = Color(0xFF4B5563); // Muted gray text
  static const Color lightBorder = Color(0xFFE5E7EB); // Subtle card borders
  static const Color lightAccent = Color(0xFF3B82F6); // Modern blue accent

  // Dark theme colors - Deep space theme
  static const Color darkSurface = Color(0xFF0D1117); // Near-black base
  static const Color darkBackground =
      Color(0xFF161B22); // Slightly lighter background
  static const Color darkCard =
      Color(0xFF1E2530); // Card containers with subtle contrast
  static const Color darkCardGlass =
      Color(0x33FFFFFF); // Translucent glassmorphism overlay
  static const Color darkAccent =
      Color(0xFF58A6FF); // Cool blue accent (GitHub-style)
  static const Color darkAccentSecondary =
      Color(0xFF3FB950); // Vibrant green accent
  static const Color darkText = Color(0xFFFFFFFF); // Primary text
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Muted gray text
  static const Color darkBorder = Color(0xFF30363D); // Subtle borders/dividers

  // Cool gradient combinations with stops for smoother transitions
  static const List<Color> neonGradient = [
    Color.fromARGB(255, 0, 200, 200),
    primaryPurple
  ];
  static const List<Color> sunsetGradient = [primaryPink, accentOrange];
  static const List<Color> forestGradient = [accentGreen, primaryPurple];
  static const List<Color> spaceGradient = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0F3460)
  ];
  static const List<Color> electricGradient = [electricBlue, primaryNeon];
  static const List<Color> magentaGradient = [hotMagenta, primaryPink];
  static const List<Color> matrixGradient = [neonGreen, accentGreen];
  static const List<Color> cyberpunkGradient = [
    primaryNeon,
    primaryPurple,
    primaryPink
  ];

  // Light Theme - Clean and modern with subtle neon accents
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.light,
        primary: primaryPurple,
        secondary: accentGreen,
        surface: lightSurface,
        background: lightBackground,
      ),
      scaffoldBackgroundColor: lightBackground,

      // Modern typography without Google Fonts
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: lightText,
          fontWeight: FontWeight.w900,
          fontSize: 32,
          letterSpacing: -1.0,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          color: lightText,
          fontWeight: FontWeight.w800,
          fontSize: 24,
          letterSpacing: -0.6,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: lightText,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: lightText,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: -0.1,
        ),
        bodyLarge: TextStyle(
          color: lightText,
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: lightTextSecondary,
          fontSize: 13,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: lightTextSecondary,
          fontSize: 11,
          height: 1.4,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: lightText,
          letterSpacing: -0.8,
        ),
        toolbarHeight: 80,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardTheme(
        color: lightCard,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),

      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: lightCard,
        collapsedBackgroundColor: lightCard,
        textColor: lightText,
        collapsedTextColor: lightText,
        iconColor: primaryPurple,
        collapsedIconColor: lightTextSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: lightText,
        iconColor: primaryPurple,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        dense: true,
        minVerticalPadding: 0,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        iconSize: 26,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryNeon,
        linearTrackColor: Colors.grey[200],
        circularTrackColor: Colors.grey[200],
      ),

      dialogTheme: DialogTheme(
        backgroundColor: lightCard,
        elevation: 24,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: lightText,
          letterSpacing: -0.4,
        ),
        contentTextStyle: TextStyle(
          fontSize: 15,
          color: lightTextSecondary,
          height: 1.6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 40, 172, 10), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(
          color: lightTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),

      iconTheme: const IconThemeData(
        color: primaryPurple,
        size: 24,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.green;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: accentOrange, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primaryPurple.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // Dark Theme - Cyberpunk/Space theme with neon accenthists
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNeon,
        brightness: Brightness.dark,
        primary: primaryNeon,
        secondary: primaryPink,
        surface: darkSurface,
        background: darkBackground,
      ),
      scaffoldBackgroundColor: darkBackground,

      // Futuristic typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkText,
          fontWeight: FontWeight.w900,
          fontSize: 32,
          letterSpacing: -1.2,
          height: 1.0,
        ),
        headlineMedium: TextStyle(
          color: darkText,
          fontWeight: FontWeight.w800,
          fontSize: 24,
          letterSpacing: -0.8,
          height: 1.1,
        ),
        titleLarge: TextStyle(
          color: darkText,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.4,
        ),
        titleMedium: TextStyle(
          color: darkText,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          color: darkText,
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: darkTextSecondary,
          fontSize: 13,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: darkTextSecondary,
          fontSize: 11,
          height: 1.4,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: darkText,
          letterSpacing: -1.0,
        ),
        toolbarHeight: 80,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shadowColor: primaryNeon.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(
            color: primaryNeon.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),

      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: darkCard,
        collapsedBackgroundColor: darkCard,
        textColor: darkText,
        collapsedTextColor: darkText,
        iconColor: primaryNeon,
        collapsedIconColor: darkTextSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: darkText,
        iconColor: primaryNeon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        dense: true,
        minVerticalPadding: 0,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryNeon,
        foregroundColor: darkSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        iconSize: 26,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryNeon,
        linearTrackColor: Colors.grey[800],
        circularTrackColor: Colors.grey[800],
      ),

      dialogTheme: DialogTheme(
        backgroundColor: darkCard,
        elevation: 24,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: darkText,
          letterSpacing: -0.4,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 15,
          color: darkTextSecondary,
          height: 1.6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(
            color: primaryNeon.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 21, 172, 59), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(
          color: darkTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: Colors.grey[600]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),

      iconTheme: const IconThemeData(
        color: primaryNeon,
        size: 24,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.green;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(darkSurface),
        side: const BorderSide(color: primaryNeon, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: darkSurface,
          elevation: 8,
          shadowColor: primaryNeon.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNeon,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // Progress bar colors based on completion percentage
  static Color getProgressColor(double progress, bool isDark) {
    if (progress == 0.0) {
      return isDark ? Colors.grey[600]! : Colors.grey[400]!;
    } else if (progress < 0.3) {
      return error;
    } else if (progress < 0.7) {
      return warning;
    } else if (progress < 1.0) {
      return info;
    } else {
      return success;
    }
  }

  // Dismissible background colors
  static Color get editBackgroundColor => primaryPurple;
//  hunting for that color
  static Color get deleteBackgroundColor => error;

  // Task completion text style
  static TextStyle getTaskTextStyle(bool isCompleted, bool isDark) {
    final baseColor = isDark ? darkText : lightText;
    return TextStyle(
      color: isCompleted ? Colors.grey[500] : baseColor,
      decoration: isCompleted ? TextDecoration.lineThrough : null,
      decorationColor: Colors.grey[500],
      fontSize: 15,
      fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
      letterSpacing: 0.2,
    );
  }

  // Cool gradient decorations with consistent 3px border radius
  static BoxDecoration get neonGradientDecoration => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: neonGradient,
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(3),
      );

  static BoxDecoration get sunsetGradientDecoration => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: sunsetGradient,
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(3),
      );

  static BoxDecoration get spaceGradientDecoration => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: spaceGradient,
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(3),
      );

  // Glassmorphism effect for dark theme
  static BoxDecoration get glassmorphismDecoration => BoxDecoration(
        color: darkCardGlass,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: primaryNeon.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryNeon.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Modern card shadow for light theme
  static List<BoxShadow> get modernCardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          spreadRadius: 0,
          offset: const Offset(0, 1),
        ),
      ];

  // Neon glow effect for dark theme
  static List<BoxShadow> get neonGlowShadow => [
        BoxShadow(
          color: primaryNeon.withOpacity(0.2),
          blurRadius: 15,
          spreadRadius: 0,
          offset: const Offset(0, 0),
        ),
        BoxShadow(
          color: primaryNeon.withOpacity(0.08),
          blurRadius: 30,
          spreadRadius: 0,
          offset: const Offset(0, 0),
        ),
      ];
}
