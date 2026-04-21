import '../../core/errors/result.dart';

/// Contract for a simple key-value settings store.
///
/// Values are persisted as strings in the database and typed at the interface
/// level. Boolean, int, and double values are stored as their string
/// representations. Complex objects should be JSON-encoded by the caller.
///
/// All keys are defined as constants in [SettingsKeys].
abstract class SettingsRepository {
  Future<Result<String?>> getString(String key);
  Future<Result<bool?>> getBool(String key);
  Future<Result<int?>> getInt(String key);
  Future<Result<double?>> getDouble(String key);

  Future<Result<void>> setString(String key, String value);
  Future<Result<void>> setBool(String key, {required bool value});
  Future<Result<void>> setInt(String key, int value);
  Future<Result<void>> setDouble(String key, double value);

  /// Deletes the setting for [key]. Subsequent reads return null.
  Future<Result<void>> remove(String key);
}

/// Canonical setting key constants. Using string literals directly
/// risks typo bugs; centralise them here.
abstract final class SettingsKeys {
  static const String accentColor = 'accent_color';
  static const String themeMode = 'theme_mode';
  static const String volume = 'volume';
  static const String crossfadeSeconds = 'crossfade_seconds';
  static const String eqEnabled = 'eq_enabled';
  static const String eqPresetId = 'eq_preset_id';
  static const String shuffle = 'shuffle';
  static const String repeatMode = 'repeat_mode';
  static const String activeEqPresetId = 'active_eq_preset_id';
  static const String sessionId = 'session_id';
  static const String onboardingComplete = 'onboarding_complete';
  static const String windowWidth = 'window_width';
  static const String windowHeight = 'window_height';
  static const String windowX = 'window_x';
  static const String windowY = 'window_y';

  // Playback behaviour
  static const String gaplessPlayback = 'gapless_playback';
  static const String resumeOnLaunch = 'resume_on_launch';

  // Scan
  static const String autoScan = 'auto_scan';

  // Gamepad / input
  static const String gamepadEnabled = 'gamepad_enabled';
  static const String navSoundLevel = 'nav_sound_level';
  static const String animateFocusScrolling = 'animate_focus_scrolling';

  // System integration
  static const String closeToTray = 'close_to_tray';
  static const String closeToTrayPrompted = 'close_to_tray_prompted';
  static const String startWithOS = 'start_with_os';

  // Search
  static const String searchHistory = 'search_history';

  // Sort preferences (per-tab: songs, albums, artists, genres, folders)
  static const String sortPrefix = 'sort_';
  static String sortByKey(String tab) => '$sortPrefix${tab}_by';
  static String sortAscKey(String tab) => '$sortPrefix${tab}_asc';
}
