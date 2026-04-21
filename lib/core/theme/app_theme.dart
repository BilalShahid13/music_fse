import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

// =============================================================================
// AppThemeExtension — custom colors not covered by ColorScheme
// =============================================================================

/// Holds all custom semantic color tokens for the app.
///
/// Accessed via [AppThemeContext.appTheme] — never via direct field access on
/// [ThemeData].
final class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.bgDeep,
    required this.bgPrimary,
    required this.bgSurface,
    required this.bgCard,
    required this.bgCardHover,
    required this.bgInput,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderSubtle,
    required this.borderCard,
    required this.accentGlow,
    required this.btnA,
    required this.btnB,
    required this.btnX,
    required this.btnY,
    required this.destructive,
  });

  // Background layers (darkest → lightest)
  final Color bgDeep;
  final Color bgPrimary;
  final Color bgSurface;
  final Color bgCard;
  final Color bgCardHover;
  final Color bgInput;

  // Typography
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // Borders
  final Color borderSubtle;
  final Color borderCard;

  // Accent glow (used for focus glow shadow)
  final Color accentGlow;

  // Gamepad button hint colors
  final Color btnA;
  final Color btnB;
  final Color btnX;
  final Color btnY;

  // Destructive actions (delete, error)
  final Color destructive;

  @override
  AppThemeExtension copyWith({
    Color? bgDeep,
    Color? bgPrimary,
    Color? bgSurface,
    Color? bgCard,
    Color? bgCardHover,
    Color? bgInput,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? borderSubtle,
    Color? borderCard,
    Color? accentGlow,
    Color? btnA,
    Color? btnB,
    Color? btnX,
    Color? btnY,
    Color? destructive,
  }) {
    return AppThemeExtension(
      bgDeep: bgDeep ?? this.bgDeep,
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSurface: bgSurface ?? this.bgSurface,
      bgCard: bgCard ?? this.bgCard,
      bgCardHover: bgCardHover ?? this.bgCardHover,
      bgInput: bgInput ?? this.bgInput,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderCard: borderCard ?? this.borderCard,
      accentGlow: accentGlow ?? this.accentGlow,
      btnA: btnA ?? this.btnA,
      btnB: btnB ?? this.btnB,
      btnX: btnX ?? this.btnX,
      btnY: btnY ?? this.btnY,
      destructive: destructive ?? this.destructive,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      bgDeep: Color.lerp(bgDeep, other.bgDeep, t)!,
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgCardHover: Color.lerp(bgCardHover, other.bgCardHover, t)!,
      bgInput: Color.lerp(bgInput, other.bgInput, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderCard: Color.lerp(borderCard, other.borderCard, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      btnA: Color.lerp(btnA, other.btnA, t)!,
      btnB: Color.lerp(btnB, other.btnB, t)!,
      btnX: Color.lerp(btnX, other.btnX, t)!,
      btnY: Color.lerp(btnY, other.btnY, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
    );
  }
}

// =============================================================================
// BuildContext extension for ergonomic access
// =============================================================================

extension AppThemeContext on BuildContext {
  /// Returns the [AppThemeExtension] for the nearest [Theme].
  AppThemeExtension get appTheme => Theme.of(this).extension<AppThemeExtension>()!;
}

// =============================================================================
// AppTheme — factory class
// =============================================================================

/// Builds [ThemeData] for dark and light modes.
///
/// The palette comes from the HTML mockup (Sony/PS5-inspired deep navy tones).
/// Accent color is injected at build time so the user can change it in Settings
/// without restarting the app.
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // Dark palette (authoritative — from mockup CSS vars)
  // ---------------------------------------------------------------------------
  static const Color _darkBgDeep = Color(0xFF000000);
  static const Color _darkBgPrimary = Color(0xFF050810);
  static const Color _darkBgSurface = Color(0xFF0A0E17);
  static const Color _darkBgCard = Color(0xFF0F1520);
  static const Color _darkBgCardHover = Color(0xFF151D2E);
  static const Color _darkBgInput = Color(0xFF111825);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFF9EA3B0);
  static const Color _darkTextTertiary = Color(0xFF464B58);
  static const Color _darkBorderSubtle = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const Color _darkBorderCard = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)

  // ---------------------------------------------------------------------------
  // Light palette (inverted — legible on white backgrounds)
  // ---------------------------------------------------------------------------
  static const Color _lightBgDeep = Color(0xFFFFFFFF);
  static const Color _lightBgPrimary = Color(0xFFF5F6FA);
  static const Color _lightBgSurface = Color(0xFFEEF0F6);
  static const Color _lightBgCard = Color(0xFFE8EAF0);
  static const Color _lightBgCardHover = Color(0xFFDFE1EA);
  static const Color _lightBgInput = Color(0xFFEBEDF4);
  static const Color _lightTextPrimary = Color(0xFF0D0F14);
  static const Color _lightTextSecondary = Color(0xFF5A5F6E);
  static const Color _lightTextTertiary = Color(0xFFA0A5B1);
  static const Color _lightBorderSubtle = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color _lightBorderCard = Color(0x0F000000); // rgba(0,0,0,0.06)

  // ---------------------------------------------------------------------------
  // Shared semantic colors (brightness-independent)
  // ---------------------------------------------------------------------------
  static const Color _destructive = Color(0xFFFF4444);
  static const Color _btnA = Color(0xFF4CAF50);
  static const Color _btnB = Color(0xFFF44336);
  static const Color _btnX = Color(0xFF2196F3);
  static const Color _btnY = Color(0xFFFFC107);

  // ---------------------------------------------------------------------------
  // Public factory
  // ---------------------------------------------------------------------------

  /// Builds a fully configured [ThemeData].
  ///
  /// [accentColor] is user-configurable (see [AppConstants.accentColorValues]).
  /// [brightness] controls dark/light mode.
  static ThemeData buildTheme({
    required Color accentColor,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    final ext = isDark ? _darkExtension(accentColor) : _lightExtension(accentColor);
    final colorScheme = isDark ? _darkColorScheme(accentColor) : _lightColorScheme(accentColor);

    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      // No ink splash — this is a gamepad app.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      scaffoldBackgroundColor: isDark ? _darkBgPrimary : _lightBgPrimary,
      // Thin scrollbar matching mockup (4px thumb).
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(4.0),
        thumbColor: WidgetStateProperty.all(
          isDark ? _darkTextTertiary.withValues(alpha: 0.5) : _lightTextTertiary.withValues(alpha: 0.5),
        ),
        radius: const Radius.circular(2),
        thumbVisibility: WidgetStateProperty.all(false),
      ),
      extensions: [ext],
    );
  }

  // ---------------------------------------------------------------------------
  // ColorScheme
  // ---------------------------------------------------------------------------

  static ColorScheme _darkColorScheme(Color accent) => ColorScheme(
        brightness: Brightness.dark,
        primary: accent,
        onPrimary: Colors.black,
        secondary: accent,
        onSecondary: Colors.black,
        surface: _darkBgSurface,
        onSurface: _darkTextPrimary,
        surfaceContainerHighest: _darkBgCard,
        surfaceContainerHigh: _darkBgPrimary,
        surfaceContainerLow: _darkBgInput,
        outline: _darkBorderSubtle,
        onSurfaceVariant: _darkTextSecondary,
        outlineVariant: _darkTextTertiary,
        error: _destructive,
        onError: Colors.white,
      );

  static ColorScheme _lightColorScheme(Color accent) => ColorScheme(
        brightness: Brightness.light,
        primary: accent,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        surface: _lightBgSurface,
        onSurface: _lightTextPrimary,
        surfaceContainerHighest: _lightBgCard,
        surfaceContainerHigh: _lightBgPrimary,
        surfaceContainerLow: _lightBgInput,
        outline: _lightBorderSubtle,
        onSurfaceVariant: _lightTextSecondary,
        outlineVariant: _lightTextTertiary,
        error: _destructive,
        onError: Colors.white,
      );

  // ---------------------------------------------------------------------------
  // TextTheme
  // ---------------------------------------------------------------------------

  static TextTheme _buildTextTheme(ColorScheme scheme) {
    // Base text themes from Google Fonts (Inter).
    final base = GoogleFonts.interTextTheme().copyWith(
      // Display — page titles (28sp Bold)
      displayLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: -0.5,
      ),
      // Headline — section headers (24sp SemiBold)
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        letterSpacing: -0.3,
      ),
      // Title Large — Now Playing title (22sp SemiBold)
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        letterSpacing: -0.2,
      ),
      // Title Medium — section titles, dialog titles (18sp SemiBold)
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // Title Small — card titles, song titles (14sp SemiBold)
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // Body Large — primary body text (16sp Regular)
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      // Body Medium — default body (14sp Regular)
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      // Body Small — captions, secondary meta (13sp Regular)
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      // Label Large — buttons, nav items (14sp Medium)
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      // Label Medium — subtitles, durations (12sp Medium)
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
      // Label Small — section headers uppercase (11sp SemiBold)
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
        letterSpacing: 1.0,
      ),
    );
    return base;
  }

  // ---------------------------------------------------------------------------
  // AppThemeExtension instances
  // ---------------------------------------------------------------------------

  static AppThemeExtension _darkExtension(Color accent) => AppThemeExtension(
        bgDeep: _darkBgDeep,
        bgPrimary: _darkBgPrimary,
        bgSurface: _darkBgSurface,
        bgCard: _darkBgCard,
        bgCardHover: _darkBgCardHover,
        bgInput: _darkBgInput,
        textPrimary: _darkTextPrimary,
        textSecondary: _darkTextSecondary,
        textTertiary: _darkTextTertiary,
        borderSubtle: _darkBorderSubtle,
        borderCard: _darkBorderCard,
        accentGlow: accent.withValues(alpha: AppConstants.focusGlowOpacity),
        btnA: _btnA,
        btnB: _btnB,
        btnX: _btnX,
        btnY: _btnY,
        destructive: _destructive,
      );

  static AppThemeExtension _lightExtension(Color accent) => AppThemeExtension(
        bgDeep: _lightBgDeep,
        bgPrimary: _lightBgPrimary,
        bgSurface: _lightBgSurface,
        bgCard: _lightBgCard,
        bgCardHover: _lightBgCardHover,
        bgInput: _lightBgInput,
        textPrimary: _lightTextPrimary,
        textSecondary: _lightTextSecondary,
        textTertiary: _lightTextTertiary,
        borderSubtle: _lightBorderSubtle,
        borderCard: _lightBorderCard,
        accentGlow: accent.withValues(alpha: AppConstants.focusGlowOpacity),
        btnA: _btnA,
        btnB: _btnB,
        btnX: _btnX,
        btnY: _btnY,
        destructive: _destructive,
      );
}
