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
