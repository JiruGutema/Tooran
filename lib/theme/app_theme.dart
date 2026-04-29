import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tooran design tokens — "warm paper / deep ink".
class AppTheme {
  // ── Light: warm paper ───────────────────────────────────────────────
  static const Color lBg = Color(0xFFF5F1E8);
  static const Color lSurface = Color(0xFFFBF7EE);
  static const Color lSurface2 = Color(0xFFFFFFFF);
  static const Color lInk = Color(0xFF1F1B16);
  static const Color lInk2 = Color(0xFF4A4339);
  static const Color lInk3 = Color(0xFF8A8275);
  static const Color lInk4 = Color(0xFFC8BFA9);
  static const Color lPrimary = Color(0xFFC8553D); // clay
  static const Color lPrimarySoft = Color(0xFFE8D0C5);
  static const Color lSuccess = Color(0xFF6A8C57);
  static const Color lWarning = Color(0xFFD08A3C);
  static const Color lError = Color(0xFFB5482F);

  // ── Dark: deep ink ──────────────────────────────────────────────────
  static const Color dBg = Color(0xFF0E0C09);
  static const Color dSurface = Color(0xFF1A1612);
  static const Color dSurface2 = Color(0xFF211C16);
  static const Color dInk = Color(0xFFF2EAD8);
  static const Color dInk2 = Color(0xFFC9C0AD);
  static const Color dInk3 = Color(0xFF8C8473);
  static const Color dInk4 = Color(0xFF4F4A3F);
  static const Color dPrimary = Color(0xFFE8B65A); // ember gold
  static const Color dPrimarySoft = Color(0xFF3A2F1A);
  static const Color dSuccess = Color(0xFF9CBB7E);
  static const Color dWarning = Color(0xFFE0A865);
  static const Color dError = Color(0xFFD87359);

  // Legacy alias (still referenced in some places)
  static const Color primary = lPrimary;
  static const Color success = lSuccess;
  static const Color warning = lWarning;
  static const Color error = lError;

  // ── Radii ───────────────────────────────────────────────────────────
  static const double rXs = 6;
  static const double rSm = 10;
  static const double rMd = 14;
  static const double rLg = 20;
  static const double rXl = 28;
  static const double radius = rMd; // legacy alias

  // ── Hairlines ───────────────────────────────────────────────────────
  static Color hairline(bool dark) =>
      dark ? const Color(0x14F2EAD8) : const Color(0x1A1F1B16);
  static Color hairlineStrong(bool dark) =>
      dark ? const Color(0x29F2EAD8) : const Color(0x2E1F1B16);

  // ── Font families (bundled) ─────────────────────────────────────────
  static const String fDisplay = 'InstrumentSerif';
  static const String fBody = 'Inter';
  static const String fMono = 'JetBrainsMono';

  // ── Typography ──────────────────────────────────────────────────────
  static TextStyle display({double size = 28, Color? color, FontStyle? style}) =>
      TextStyle(
        fontFamily: fDisplay,
        fontSize: size,
        fontWeight: FontWeight.w400,
        letterSpacing: -size * 0.01,
        height: 1.05,
        color: color,
        fontStyle: style,
      );

  static TextStyle body({double size = 15, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: fBody,
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        letterSpacing: -size * 0.005,
        height: 1.45,
        color: color,
      );

  static TextStyle mono({double size = 11, Color? color, double letter = 0.14}) =>
      TextStyle(
        fontFamily: fMono,
        fontSize: size,
        fontWeight: FontWeight.w400,
        letterSpacing: letter * size / 11,
        color: color,
      );

  static TextStyle eyebrow(Color color) => TextStyle(
        fontFamily: fMono,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
        color: color,
      );

  // ── ThemeData builders ──────────────────────────────────────────────
  static TextTheme _textTheme(bool dark) {
    final ink = dark ? dInk : lInk;
    final ink2 = dark ? dInk2 : lInk2;
    final ink3 = dark ? dInk3 : lInk3;
    final base = ThemeData(brightness: dark ? Brightness.dark : Brightness.light)
        .textTheme
        .apply(fontFamily: fBody);
    return base.copyWith(
      headlineLarge: display(size: 38, color: ink),
      headlineMedium: display(size: 30, color: ink),
      titleLarge: display(size: 24, color: ink),
      titleMedium: AppTheme.body(size: 16, color: ink, weight: FontWeight.w500),
      titleSmall: AppTheme.body(size: 14, color: ink, weight: FontWeight.w600),
      bodyLarge: AppTheme.body(size: 15, color: ink),
      bodyMedium: AppTheme.body(size: 14, color: ink2),
      bodySmall: AppTheme.body(size: 13, color: ink3),
      labelLarge: AppTheme.body(size: 14, color: ink, weight: FontWeight.w500),
      labelMedium: mono(size: 11, color: ink3),
      labelSmall: mono(size: 10, color: ink3),
    );
  }

  static ThemeData get lightTheme => _build(false);
  static ThemeData get darkTheme => _build(true);

  static ThemeData _build(bool dark) {
    final bg = dark ? dBg : lBg;
    final surface = dark ? dSurface : lSurface;
    final ink = dark ? dInk : lInk;
    final ink2 = dark ? dInk2 : lInk2;
    final ink3 = dark ? dInk3 : lInk3;
    final ink4 = dark ? dInk4 : lInk4;
    final primary = dark ? dPrimary : lPrimary;
    final errorC = dark ? dError : lError;
    final hl = hairline(dark);
    final hlStrong = hairlineStrong(dark);
    final tt = _textTheme(dark);

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      dividerColor: hl,
      colorScheme: ColorScheme(
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: dark ? dBg : Colors.white,
        secondary: ink,
        onSecondary: bg,
        surface: surface,
        onSurface: ink,
        surfaceContainerHighest: dark ? dSurface2 : lSurface2,
        onSurfaceVariant: ink3,
        outline: hlStrong,
        outlineVariant: hl,
        error: errorC,
        onError: Colors.white,
        background: bg,
        onBackground: ink,
        shadow: Colors.black,
      ),
      textTheme: tt,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: bg,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: display(size: 22, color: ink),
        systemOverlayStyle:
            dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: hl, width: 1),
          borderRadius: BorderRadius.circular(rMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        labelStyle: eyebrow(ink3),
        floatingLabelStyle: eyebrow(ink3),
        hintStyle: display(size: 22, color: ink4, style: FontStyle.italic),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: hlStrong, width: 1.5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: hlStrong, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTheme.body(size: 15, weight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink2,
          side: BorderSide(color: hlStrong, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTheme.body(size: 15, weight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink2,
          textStyle: AppTheme.body(size: 14, weight: FontWeight.w500),
        ),
      ),
      iconTheme: IconThemeData(color: ink2, size: 20),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink2,
          shape: const CircleBorder(),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ink,
        foregroundColor: bg,
        elevation: 4,
        focusElevation: 4,
        hoverElevation: 6,
        extendedTextStyle:
            AppTheme.body(size: 15, weight: FontWeight.w500, color: bg),
        shape: const StadiumBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rLg),
          side: BorderSide(color: hl, width: 1),
        ),
        titleTextStyle: display(size: 24, color: ink),
        contentTextStyle: AppTheme.body(size: 14, color: ink2),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        side: BorderSide(color: ink4, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
        elevation: 0,
        modalBackgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: AppTheme.body(size: 14, color: bg),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        actionTextColor: primary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rMd),
          side: BorderSide(color: hl, width: 1),
        ),
        textStyle: AppTheme.body(size: 14, color: ink),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: ink2,
        textColor: ink,
        titleTextStyle: AppTheme.body(size: 15, color: ink),
        subtitleTextStyle: AppTheme.body(size: 13, color: ink3),
      ),
      splashColor: primary.withOpacity(0.06),
      highlightColor: primary.withOpacity(0.04),
    );
  }
}
