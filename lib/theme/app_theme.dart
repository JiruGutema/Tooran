import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One side (light or dark) of a color theme.
class Palette {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color ink4;
  final Color primary;
  final Color primarySoft;
  final Color onPrimary;
  final Color success;
  final Color warning;
  final Color error;

  const Palette({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.primary,
    required this.primarySoft,
    this.onPrimary = Colors.white,
    required this.success,
    required this.warning,
    required this.error,
  });

  Color get hairline => ink.withValues(alpha: 0.08);
  Color get hairlineStrong => ink.withValues(alpha: 0.16);
}

/// How cards are drawn: thin border, soft shadow, or a tinted fill.
enum CardStyle { outlined, elevated, filled }

/// A complete look: colors for both brightnesses, corner radius, card style.
class ThemePreset {
  final String id;
  final Palette light;
  final Palette dark;
  final double radius;
  final CardStyle cards;

  const ThemePreset({
    required this.id,
    required this.light,
    required this.dark,
    required this.radius,
    required this.cards,
  });
}

/// Corner overrides chosen in Settings (null = the theme's own radius).
enum CornerStyle { theme, sharp, rounded, round }

const _success = Color(0xFF16A34A);
const _successDark = Color(0xFF4ADE80);
const _warning = Color(0xFFD97706);
const _warningDark = Color(0xFFFBBF24);
const _error = Color(0xFFDC2626);
const _errorDark = Color(0xFFF87171);

/// The built-in themes. The first one is the default.
const List<ThemePreset> themePresets = [
  ThemePreset(
    id: 'horizon',
    radius: 16,
    cards: CardStyle.elevated,
    light: Palette(
      bg: Color(0xFFF4F6FB), surface: Color(0xFFFFFFFF), surface2: Color(0xFFEEF1F8),
      ink: Color(0xFF0F172A), ink2: Color(0xFF334155), ink3: Color(0xFF64748B), ink4: Color(0xFFCBD5E1),
      primary: Color(0xFF4F46E5), primarySoft: Color(0xFFE0E7FF),
      success: _success, warning: _warning, error: _error,
    ),
    dark: Palette(
      bg: Color(0xFF0B0F19), surface: Color(0xFF131A2A), surface2: Color(0xFF1B2438),
      ink: Color(0xFFF1F5F9), ink2: Color(0xFFCBD5E1), ink3: Color(0xFF94A3B8), ink4: Color(0xFF475569),
      primary: Color(0xFF818CF8), primarySoft: Color(0xFF312E81), onPrimary: Color(0xFF0B0F19),
      success: _successDark, warning: _warningDark, error: _errorDark,
    ),
  ),
  ThemePreset(
    id: 'ocean',
    radius: 20,
    cards: CardStyle.filled,
    light: Palette(
      bg: Color(0xFFF0F7FA), surface: Color(0xFFFFFFFF), surface2: Color(0xFFE3F0F5),
      ink: Color(0xFF0B2530), ink2: Color(0xFF2E4A56), ink3: Color(0xFF5F7C88), ink4: Color(0xFFBFD3DB),
      primary: Color(0xFF0284C7), primarySoft: Color(0xFFE0F2FE),
      success: _success, warning: _warning, error: _error,
    ),
    dark: Palette(
      bg: Color(0xFF061A22), surface: Color(0xFF0C2630), surface2: Color(0xFF12323E),
      ink: Color(0xFFE6F4F8), ink2: Color(0xFFB5D0DA), ink3: Color(0xFF7FA2AF), ink4: Color(0xFF355663),
      primary: Color(0xFF38BDF8), primarySoft: Color(0xFF0C4A6E), onPrimary: Color(0xFF061A22),
      success: _successDark, warning: _warningDark, error: _errorDark,
    ),
  ),
  ThemePreset(
    id: 'forest',
    radius: 12,
    cards: CardStyle.outlined,
    light: Palette(
      bg: Color(0xFFF3F6F1), surface: Color(0xFFFFFFFF), surface2: Color(0xFFE8EFE4),
      ink: Color(0xFF14231A), ink2: Color(0xFF34483B), ink3: Color(0xFF667A6C), ink4: Color(0xFFC4D2C6),
      primary: Color(0xFF2F855A), primarySoft: Color(0xFFDCEFE3),
      success: Color(0xFF2F855A), warning: _warning, error: _error,
    ),
    dark: Palette(
      bg: Color(0xFF0B130E), surface: Color(0xFF131E17), surface2: Color(0xFF1A2A20),
      ink: Color(0xFFE8F2EB), ink2: Color(0xFFBFD3C5), ink3: Color(0xFF86A08E), ink4: Color(0xFF3A4F41),
      primary: Color(0xFF5FCB8E), primarySoft: Color(0xFF1F4D33), onPrimary: Color(0xFF0B130E),
      success: Color(0xFF5FCB8E), warning: _warningDark, error: _errorDark,
    ),
  ),
  ThemePreset(
    id: 'sunset',
    radius: 18,
    cards: CardStyle.elevated,
    light: Palette(
      bg: Color(0xFFFFF5F8), surface: Color(0xFFFFFFFF), surface2: Color(0xFFFCE7EF),
      ink: Color(0xFF2A1019), ink2: Color(0xFF5A3441), ink3: Color(0xFF8F6573), ink4: Color(0xFFEBCAD6),
      primary: Color(0xFFDB2777), primarySoft: Color(0xFFFCE7F3),
      success: _success, warning: _warning, error: _error,
    ),
    dark: Palette(
      bg: Color(0xFF170A10), surface: Color(0xFF22111A), surface2: Color(0xFF2D1723),
      ink: Color(0xFFFBE9F1), ink2: Color(0xFFE3BFD0), ink3: Color(0xFFA9849A), ink4: Color(0xFF5A3A4B),
      primary: Color(0xFFF472B6), primarySoft: Color(0xFF5B1438), onPrimary: Color(0xFF170A10),
      success: _successDark, warning: _warningDark, error: _errorDark,
    ),
  ),
  ThemePreset(
    id: 'lavender',
    radius: 24,
    cards: CardStyle.filled,
    light: Palette(
      bg: Color(0xFFF7F5FF), surface: Color(0xFFFFFFFF), surface2: Color(0xFFEFEBFD),
      ink: Color(0xFF1E1535), ink2: Color(0xFF443A63), ink3: Color(0xFF776D93), ink4: Color(0xFFD5CFEA),
      primary: Color(0xFF7C3AED), primarySoft: Color(0xFFEDE9FE),
      success: _success, warning: _warning, error: _error,
    ),
    dark: Palette(
      bg: Color(0xFF0F0B1A), surface: Color(0xFF181229), surface2: Color(0xFF221A38),
      ink: Color(0xFFF1EDFF), ink2: Color(0xFFCFC6EC), ink3: Color(0xFF978DB5), ink4: Color(0xFF463D63),
      primary: Color(0xFFA78BFA), primarySoft: Color(0xFF3B2A6B), onPrimary: Color(0xFF0F0B1A),
      success: _successDark, warning: _warningDark, error: _errorDark,
    ),
  ),
  ThemePreset(
    id: 'graphite',
    radius: 8,
    cards: CardStyle.outlined,
    light: Palette(
      bg: Color(0xFFF5F5F5), surface: Color(0xFFFFFFFF), surface2: Color(0xFFEDEDED),
      ink: Color(0xFF111111), ink2: Color(0xFF3A3A3A), ink3: Color(0xFF6E6E6E), ink4: Color(0xFFCFCFCF),
      primary: Color(0xFF111111), primarySoft: Color(0xFFE5E5E5),
      success: _success, warning: _warning, error: _error,
    ),
    dark: Palette(
      bg: Color(0xFF0A0A0A), surface: Color(0xFF161616), surface2: Color(0xFF1F1F1F),
      ink: Color(0xFFF5F5F5), ink2: Color(0xFFC8C8C8), ink3: Color(0xFF8A8A8A), ink4: Color(0xFF3D3D3D),
      primary: Color(0xFFF5F5F5), primarySoft: Color(0xFF2A2A2A), onPrimary: Color(0xFF0A0A0A),
      success: _successDark, warning: _warningDark, error: _errorDark,
    ),
  ),
];

ThemePreset presetById(String? id) =>
    themePresets.firstWhere((p) => p.id == id, orElse: () => themePresets.first);

/// Marks ThemeData with the active look, so a change of corners or card
/// style (which may not change any color) still rebuilds dependents.
class TooranStyle extends ThemeExtension<TooranStyle> {
  final String presetId;
  final double radius;
  final CardStyle cards;
  const TooranStyle(this.presetId, this.radius, this.cards);

  @override
  TooranStyle copyWith() => this;

  @override
  TooranStyle lerp(TooranStyle? other, double t) => other ?? this;

  @override
  bool operator ==(Object other) =>
      other is TooranStyle && other.presetId == presetId && other.radius == radius && other.cards == cards;

  @override
  int get hashCode => Object.hash(presetId, radius, cards);
}

/// Tooran design tokens. Colors, radii and card style follow the active
/// [ThemePreset] (see [apply]); text styles are shared by every theme.
class AppTheme {
  static ThemePreset _preset = themePresets.first;
  static double _radius = themePresets.first.radius;
  static CardStyle _cards = themePresets.first.cards;

  static ThemePreset get preset => _preset;

  /// Extra font families to try for glyphs Inter lacks (emoji). Empty in the
  /// app — phones fall back to their system fonts; the screenshot tool sets
  /// it because the test renderer has no system fallback.
  static List<String>? fontFallback;
  static CardStyle get cards => _cards;

  /// Sets the active look. Call before building [lightTheme]/[darkTheme].
  static void apply({String? presetId, CornerStyle corners = CornerStyle.theme, CardStyle? cardStyle}) {
    _preset = presetById(presetId);
    _radius = switch (corners) {
      CornerStyle.theme => _preset.radius,
      CornerStyle.sharp => 6,
      CornerStyle.rounded => 14,
      CornerStyle.round => 24,
    };
    _cards = cardStyle ?? _preset.cards;
  }

  static Palette palette(bool dark) => dark ? _preset.dark : _preset.light;

  // ── Colors (light "l…" / dark "d…") ─────────────────────────────────
  static Color get lBg => _preset.light.bg;
  static Color get lSurface => _preset.light.surface;
  static Color get lSurface2 => _preset.light.surface2;
  static Color get lInk => _preset.light.ink;
  static Color get lInk2 => _preset.light.ink2;
  static Color get lInk3 => _preset.light.ink3;
  static Color get lInk4 => _preset.light.ink4;
  static Color get lPrimary => _preset.light.primary;
  static Color get lPrimarySoft => _preset.light.primarySoft;
  static Color get lSuccess => _preset.light.success;
  static Color get lWarning => _preset.light.warning;
  static Color get lError => _preset.light.error;

  static Color get dBg => _preset.dark.bg;
  static Color get dSurface => _preset.dark.surface;
  static Color get dSurface2 => _preset.dark.surface2;
  static Color get dInk => _preset.dark.ink;
  static Color get dInk2 => _preset.dark.ink2;
  static Color get dInk3 => _preset.dark.ink3;
  static Color get dInk4 => _preset.dark.ink4;
  static Color get dPrimary => _preset.dark.primary;
  static Color get dPrimarySoft => _preset.dark.primarySoft;
  static Color get dSuccess => _preset.dark.success;
  static Color get dWarning => _preset.dark.warning;
  static Color get dError => _preset.dark.error;

  static Color hairline(bool dark) => palette(dark).hairline;
  static Color hairlineStrong(bool dark) => palette(dark).hairlineStrong;

  // ── Radii (scaled from the theme's base radius) ─────────────────────
  static double get rXs => (_radius * 0.45).clamp(4, 12);
  static double get rSm => _radius * 0.7;
  static double get rMd => _radius;
  static double get rLg => _radius * 1.3;
  static double get rXl => (_radius * 1.6).clamp(12, 32);
  static double get radius => rMd;

  /// Card background + border/shadow for the active card style.
  static BoxDecoration card(bool dark, {bool emphasized = false, double? radius}) {
    final p = palette(dark);
    final r = BorderRadius.circular(radius ?? rMd);
    switch (_cards) {
      case CardStyle.outlined:
        return BoxDecoration(
          color: p.surface,
          borderRadius: r,
          border: Border.all(color: emphasized ? p.hairlineStrong : p.hairline, width: 1),
        );
      case CardStyle.elevated:
        return BoxDecoration(
          color: p.surface,
          borderRadius: r,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.35 : (emphasized ? 0.10 : 0.06)),
              blurRadius: emphasized ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case CardStyle.filled:
        return BoxDecoration(
          color: emphasized ? p.surface : p.surface2,
          borderRadius: r,
        );
    }
  }

  // ── Typography (Inter everywhere) ───────────────────────────────────
  static const String fBody = 'Inter';
  static const String fDisplay = fBody;
  static const String fMono = fBody;

  /// Headings. Sizes passed in are "visual" sizes from the original
  /// design scale; they're mapped to a tighter sans-serif size here.
  static TextStyle display({double size = 28, Color? color, FontStyle? style}) {
    final s = size * 0.8;
    return TextStyle(
      fontFamily: fBody,
      fontFamilyFallback: fontFallback,
      fontSize: s,
      fontWeight: FontWeight.w600,
      letterSpacing: -s * 0.02,
      height: 1.2,
      color: color,
      fontStyle: style == FontStyle.italic ? FontStyle.normal : style,
    );
  }

  static TextStyle body({double size = 15, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: fBody,
        fontFamilyFallback: fontFallback,
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        letterSpacing: -size * 0.005,
        height: 1.45,
        color: color,
      );

  /// Small numbers and meta text: tabular figures so amounts line up.
  static TextStyle mono({double size = 11, Color? color, double letter = 0}) =>
      TextStyle(
        fontFamily: fBody,
        fontFamilyFallback: fontFallback,
        fontSize: size + 1,
        fontWeight: FontWeight.w500,
        letterSpacing: letter,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Section labels.
  static TextStyle eyebrow(Color color) => TextStyle(
        fontFamily: fBody,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: color,
      );

  // ── ThemeData builders ──────────────────────────────────────────────
  static ThemeData get lightTheme => _build(false);
  static ThemeData get darkTheme => _build(true);

  static ThemeData _build(bool dark) {
    final p = palette(dark);
    final bg = p.bg;
    final surface = p.surface;
    final ink = p.ink;
    final ink2 = p.ink2;
    final ink3 = p.ink3;
    final ink4 = p.ink4;
    final primary = p.primary;
    final hl = p.hairline;
    final hlStrong = p.hairlineStrong;
    final brightness = dark ? Brightness.dark : Brightness.light;
    final base = ThemeData(brightness: brightness).textTheme.apply(fontFamily: fBody);
    final tt = base.copyWith(
      headlineLarge: display(size: 38, color: ink),
      headlineMedium: display(size: 30, color: ink),
      titleLarge: display(size: 24, color: ink),
      titleMedium: body(size: 16, color: ink, weight: FontWeight.w500),
      titleSmall: body(size: 14, color: ink, weight: FontWeight.w600),
      bodyLarge: body(size: 15, color: ink),
      bodyMedium: body(size: 14, color: ink2),
      bodySmall: body(size: 13, color: ink3),
      labelLarge: body(size: 14, color: ink, weight: FontWeight.w500),
      labelMedium: mono(size: 11, color: ink3),
      labelSmall: mono(size: 10, color: ink3),
    );
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(rSm));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fBody,
      fontFamilyFallback: fontFallback,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      dividerColor: hl,
      extensions: [TooranStyle(_preset.id, _radius, _cards)],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: p.onPrimary,
        primaryContainer: p.primarySoft,
        onPrimaryContainer: ink,
        secondary: primary,
        onSecondary: p.onPrimary,
        secondaryContainer: p.primarySoft,
        onSecondaryContainer: ink,
        surface: surface,
        onSurface: ink,
        surfaceContainerHighest: p.surface2,
        surfaceContainerHigh: p.surface2,
        surfaceContainer: surface,
        surfaceContainerLow: surface,
        onSurfaceVariant: ink3,
        outline: hlStrong,
        outlineVariant: hl,
        error: p.error,
        onError: Colors.white,
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
        systemOverlayStyle: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: _cards == CardStyle.outlined ? BorderSide(color: hl, width: 1) : BorderSide.none,
          borderRadius: BorderRadius.circular(rMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        labelStyle: eyebrow(ink3),
        floatingLabelStyle: eyebrow(primary),
        hintStyle: body(size: 16, color: ink4),
        border: UnderlineInputBorder(borderSide: BorderSide(color: hlStrong, width: 1.5)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: hlStrong, width: 1.5)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary, width: 2)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: p.onPrimary,
          elevation: 0,
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: body(size: 15, weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink2,
          side: BorderSide(color: hlStrong, width: 1),
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: body(size: 15, weight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: buttonShape,
          textStyle: body(size: 14, weight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: p.primarySoft,
          selectedForegroundColor: ink,
          foregroundColor: ink2,
          side: BorderSide(color: hlStrong),
          shape: buttonShape,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface2,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rSm)),
        labelStyle: body(size: 13.5, color: ink2, weight: FontWeight.w500),
      ),
      iconTheme: IconThemeData(color: ink2, size: 20),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ink2, shape: const CircleBorder()),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: p.onPrimary,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 5,
        extendedTextStyle: body(size: 15, weight: FontWeight.w600, color: p.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rLg)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rLg)),
        titleTextStyle: display(size: 24, color: ink),
        contentTextStyle: body(size: 14, color: ink2),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
        elevation: 2,
        width: 304,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(rLg)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rXs)),
        side: BorderSide(color: ink4, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(p.onPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onPrimary : ink3,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : p.surface2,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
        elevation: 0,
        modalBackgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(rXl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: body(size: 14, color: bg),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rSm)),
        actionTextColor: p.primarySoft,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: surface,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
        textStyle: body(size: 14, color: ink),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: ink2,
        textColor: ink,
        titleTextStyle: body(size: 15, color: ink),
        subtitleTextStyle: body(size: 13, color: ink3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rSm)),
      ),
      splashColor: primary.withValues(alpha: 0.08),
      highlightColor: primary.withValues(alpha: 0.05),
    );
  }
}
