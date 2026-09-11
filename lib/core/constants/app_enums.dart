/// Application-level enums shared across layers.
///
/// Defined in `core/` so both the domain and presentation layers can import
/// without violating Clean Architecture's dependency rule.
library;

/// Controls which theme brightness the app uses.
///
/// Mirrors [ThemeMode] but is a domain-layer concept so it can be persisted
/// via [SettingsRepository] without depending on Flutter.
enum ThemeModeSetting {
  /// Always use the dark theme — the app default.
  dark,

  /// Always use the light theme.
  light,

  /// Follow the host OS brightness preference.
  system,
}

/// Supported app-wide font families.
enum AppFontSetting {
  /// Default UI font.
  inter,

  /// Rounded geometric sans.
  poppins,

  /// System-style sans.
  roboto,

  /// Softer rounded sans.
  nunitoSans,
}

/// Controls the foreground color used on top of the user-selected accent.
enum AccentTextColorSetting {
  /// Automatically choose the higher-contrast foreground for the accent.
  auto,

  /// Always use dark text/icons on accent surfaces.
  dark,

  /// Always use light text/icons on accent surfaces.
  light,
}
