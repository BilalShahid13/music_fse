import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_enums.dart';
import '../constants/app_constants.dart';

// =============================================================================
// AppThemeExtension — custom semantic tokens not covered by ColorScheme
// =============================================================================

/// Holds custom semantic theme tokens not modeled directly by Flutter's
/// built-in color and text theme buckets.
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
    required this.brandWordmark,
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

  // Brand text treatment for the shell rail wordmark.
  final TextStyle brandWordmark;

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
    TextStyle? brandWordmark,
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
      brandWordmark: brandWordmark ?? this.brandWordmark,
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
      brandWordmark:
          TextStyle.lerp(brandWordmark, other.brandWordmark, t) ??
          brandWordmark,
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
  static const Color _darkTextTertiary = Color(0xFF697385);
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
    required AccentTextColorSetting accentTextColor,
    required AppFontSetting appFont,
    required Brightness brightness,
    double uiScale = 1.0,
  }) {
    final isDark = brightness == Brightness.dark;

    final ext = isDark ? _darkExtension(accentColor) : _lightExtension(accentColor);
    final onAccent = resolveOnAccentColor(accentColor, accentTextColor);
    final colorScheme = isDark
        ? _darkColorScheme(accentColor, onAccent: onAccent)
        : _lightColorScheme(accentColor, onAccent: onAccent);

    final textTheme = _buildTextTheme(
      colorScheme,
      appFont: appFont,
      uiScale: uiScale,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      switchTheme: _switchTheme(colorScheme, ext),
      filledButtonTheme: FilledButtonThemeData(
        style: _accentButtonStyle(colorScheme),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _accentButtonStyle(colorScheme),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _accentButtonStyle(colorScheme, compact: true),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _accentButtonStyle(colorScheme),
      ),
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

  static SwitchThemeData _switchTheme(
    ColorScheme colorScheme,
    AppThemeExtension ext,
  ) {
    return SwitchThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      trackOutlineWidth: const WidgetStatePropertyAll(1.5),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        final isSelected = states.contains(WidgetState.selected);

        if (isDisabled) {
          return isSelected
              ? colorScheme.onPrimary.withValues(alpha: 0.45)
              : ext.textTertiary.withValues(alpha: 0.5);
        }

        return isSelected ? colorScheme.primary : colorScheme.onSurface;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        final isSelected = states.contains(WidgetState.selected);

        if (isDisabled) {
          return isSelected
              ? colorScheme.primary.withValues(alpha: 0.16)
              : ext.bgInput.withValues(alpha: 0.7);
        }

        return isSelected ? Colors.transparent : ext.bgInput;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        final isSelected = states.contains(WidgetState.selected);

        if (isDisabled) {
          return ext.borderSubtle;
        }

        return isSelected
            ? colorScheme.primary
            : ext.textTertiary.withValues(alpha: 0.7);
      }),
    );
  }

  static ButtonStyle _accentButtonStyle(
    ColorScheme colorScheme, {
    bool compact = false,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.btnRadius),
    );

    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        compact
            ? const Size(48, AppConstants.minFocusableSize)
            : const Size(88, AppConstants.minFocusableSize),
      ),
      padding: WidgetStatePropertyAll(
        compact
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      shape: WidgetStatePropertyAll(shape),
      side: WidgetStateProperty.resolveWith((states) {
        final borderColor = states.contains(WidgetState.disabled)
            ? colorScheme.outlineVariant
            : colorScheme.primary;
        return BorderSide(color: borderColor, width: 1.5);
      }),
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.transparent;
        }
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed)) {
          return colorScheme.primary;
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.outlineVariant;
        }
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed)) {
          return colorScheme.onPrimary;
        }
        return colorScheme.primary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.onPrimary.withValues(alpha: 0.14);
        }
        return null;
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // ColorScheme
  // ---------------------------------------------------------------------------

  static Color resolveOnAccentColor(
    Color accent,
    AccentTextColorSetting accentTextColor,
  ) {
    switch (accentTextColor) {
      case AccentTextColorSetting.dark:
        return Colors.black;
      case AccentTextColorSetting.light:
        return Colors.white;
      case AccentTextColorSetting.auto:
        return _bestOnAccent(accent);
    }
  }

  static Color _bestOnAccent(Color accent) {
    const black = Colors.black;
    const white = Colors.white;

    final blackContrast = _contrastRatio(accent, black);
    final whiteContrast = _contrastRatio(accent, white);

    return blackContrast >= whiteContrast ? black : white;
  }

  static double _contrastRatio(Color a, Color b) {
    final luminanceA = a.computeLuminance();
    final luminanceB = b.computeLuminance();
    final lighter = math.max(luminanceA, luminanceB);
    final darker = math.min(luminanceA, luminanceB);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static ColorScheme _darkColorScheme(
    Color accent, {
    required Color onAccent,
  }) => ColorScheme(
        brightness: Brightness.dark,
        primary: accent,
        onPrimary: onAccent,
        secondary: accent,
        onSecondary: onAccent,
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

  static ColorScheme _lightColorScheme(
    Color accent, {
    required Color onAccent,
  }) => ColorScheme(
        brightness: Brightness.light,
        primary: accent,
      onPrimary: onAccent,
        secondary: accent,
      onSecondary: onAccent,
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

  static TextTheme _buildTextTheme(
    ColorScheme scheme, {
    required AppFontSetting appFont,
    double uiScale = 1.0,
  }) {
    final base = _fontTextTheme(appFont).copyWith(
      // Display — page titles (28sp Bold)
      displayLarge: _fontStyle(
        appFont,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: -0.5,
      ),
      // Headline — section headers (24sp SemiBold)
      headlineLarge: _fontStyle(
        appFont,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        letterSpacing: -0.3,
      ),
      // Title Large — Now Playing title (22sp SemiBold)
      titleLarge: _fontStyle(
        appFont,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        letterSpacing: -0.2,
      ),
      // Title Medium — section titles, dialog titles (18sp SemiBold)
      titleMedium: _fontStyle(
        appFont,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // Title Small — card titles, song titles (14sp SemiBold)
      titleSmall: _fontStyle(
        appFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // Body Large — primary body text (16sp Regular)
      bodyLarge: _fontStyle(
        appFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      // Body Medium — default body (14sp Regular)
      bodyMedium: _fontStyle(
        appFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      // Body Small — captions, secondary meta (13sp Regular)
      bodySmall: _fontStyle(
        appFont,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      // Label Large — buttons, nav items (14sp Medium)
      labelLarge: _fontStyle(
        appFont,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      // Label Medium — subtitles, durations (12sp Medium)
      labelMedium: _fontStyle(
        appFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
      // Label Small — section headers uppercase (11sp SemiBold)
      labelSmall: _fontStyle(
        appFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
        letterSpacing: 1.0,
      ),
    );
    return _scaleTextTheme(base, uiScale);
  }

  static TextTheme _fontTextTheme(AppFontSetting appFont) => switch (appFont) {
        AppFontSetting.inter => GoogleFonts.interTextTheme(),
        AppFontSetting.poppins => GoogleFonts.poppinsTextTheme(),
        AppFontSetting.roboto => GoogleFonts.robotoTextTheme(),
        AppFontSetting.nunitoSans => GoogleFonts.nunitoSansTextTheme(),
      };

  static TextStyle _fontStyle(
    AppFontSetting appFont, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) =>
      switch (appFont) {
        AppFontSetting.inter => GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            letterSpacing: letterSpacing,
          ),
        AppFontSetting.poppins => GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            letterSpacing: letterSpacing,
          ),
        AppFontSetting.roboto => GoogleFonts.roboto(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            letterSpacing: letterSpacing,
          ),
        AppFontSetting.nunitoSans => GoogleFonts.nunitoSans(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            letterSpacing: letterSpacing,
          ),
      };

  static TextTheme _scaleTextTheme(TextTheme theme, double scaleFactor) {
    if (scaleFactor == 1.0) {
      return theme;
    }

    TextStyle? scaleStyle(TextStyle? style) {
      final fontSize = style?.fontSize;
      if (style == null || fontSize == null) {
        return style;
      }
      return style.copyWith(fontSize: fontSize * scaleFactor);
    }

    return theme.copyWith(
      displayLarge: scaleStyle(theme.displayLarge),
      displayMedium: scaleStyle(theme.displayMedium),
      displaySmall: scaleStyle(theme.displaySmall),
      headlineLarge: scaleStyle(theme.headlineLarge),
      headlineMedium: scaleStyle(theme.headlineMedium),
      headlineSmall: scaleStyle(theme.headlineSmall),
      titleLarge: scaleStyle(theme.titleLarge),
      titleMedium: scaleStyle(theme.titleMedium),
      titleSmall: scaleStyle(theme.titleSmall),
      bodyLarge: scaleStyle(theme.bodyLarge),
      bodyMedium: scaleStyle(theme.bodyMedium),
      bodySmall: scaleStyle(theme.bodySmall),
      labelLarge: scaleStyle(theme.labelLarge),
      labelMedium: scaleStyle(theme.labelMedium),
      labelSmall: scaleStyle(theme.labelSmall),
    );
  }

  static TextStyle _brandWordmarkStyle(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: -0.2,
        height: 1.0,
      );

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
        brandWordmark: _brandWordmarkStyle(_darkTextPrimary),
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
        brandWordmark: _brandWordmarkStyle(_lightTextPrimary),
      );
}
