import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/settings_repository.dart';
import 'repository_providers.dart';

part 'settings_provider.g.dart';

// ---------------------------------------------------------------------------
// Helper — generic read/write wrapper used by every notifier below.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Auto Scan
// ---------------------------------------------------------------------------

/// Whether the library should be re-scanned automatically on launch.
@Riverpod(keepAlive: true)
class AutoScanNotifier extends _$AutoScanNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.autoScan);
    return result.valueOrNull ?? true;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(SettingsKeys.autoScan, value: value);
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'AutoScanNotifier: set failed',
        tag: 'AutoScanNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gapless Playback
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class GaplessPlaybackNotifier extends _$GaplessPlaybackNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.gaplessPlayback);
    return result.valueOrNull ?? false;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(SettingsKeys.gaplessPlayback, value: value);
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'GaplessPlaybackNotifier: set failed',
        tag: 'GaplessPlaybackNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Resume On Launch
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class ResumeOnLaunchNotifier extends _$ResumeOnLaunchNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.resumeOnLaunch);
    return result.valueOrNull ?? true;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(SettingsKeys.resumeOnLaunch, value: value);
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'ResumeOnLaunchNotifier: set failed',
        tag: 'ResumeOnLaunchNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gamepad Enabled
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class GamepadEnabledNotifier extends _$GamepadEnabledNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.gamepadEnabled);
    return result.valueOrNull ?? true;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(SettingsKeys.gamepadEnabled, value: value);
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'GamepadEnabledNotifier: set failed',
        tag: 'GamepadEnabledNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animate Focus Scrolling
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class AnimateFocusScrollingNotifier extends _$AnimateFocusScrollingNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.animateFocusScrolling);
    return result.valueOrNull ?? true;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(SettingsKeys.animateFocusScrolling, value: value);
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'AnimateFocusScrollingNotifier: set failed',
        tag: 'AnimateFocusScrollingNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini Player Art Background
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class MiniPlayerArtBackgroundNotifier extends _$MiniPlayerArtBackgroundNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.miniPlayerArtBackground);
    return result.valueOrNull ?? true;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(
      SettingsKeys.miniPlayerArtBackground,
      value: value,
    );
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'MiniPlayerArtBackgroundNotifier: set failed',
        tag: 'MiniPlayerArtBackgroundNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav Sound Level (0.0 – 1.0)
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class NavSoundEnabledNotifier extends _$NavSoundEnabledNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.navSoundEnabled);
    return result.valueOrNull ?? AppConstants.defaultNavSoundEnabled;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(SettingsKeys.navSoundEnabled, value: value);
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'NavSoundEnabledNotifier: set failed',
        tag: 'NavSoundEnabledNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav Sound Level (0.0 – 1.0)
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class NavSoundLevelNotifier extends _$NavSoundLevelNotifier {
  @override
  Future<double> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getDouble(SettingsKeys.navSoundLevel);
    return result.valueOrNull ?? AppConstants.defaultNavSoundLevel;
  }

  Future<void> set(double value) async {
    // Clamp to a valid range.
    final clamped = value.clamp(0.0, 1.0);
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setDouble(SettingsKeys.navSoundLevel, clamped);
    result.when(
      success: (_) => state = AsyncData(clamped),
      failure: (e) => AppLogger.error(
        'NavSoundLevelNotifier: set failed',
        tag: 'NavSoundLevelNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Close to Tray
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class CloseToTrayNotifier extends _$CloseToTrayNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.closeToTray);
    return result.valueOrNull ?? true;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(SettingsKeys.closeToTray, value: value);
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'CloseToTrayNotifier: set failed',
        tag: 'CloseToTrayNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Close to Tray Prompted (first-time dialog tracking)
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class CloseToTrayPromptedNotifier extends _$CloseToTrayPromptedNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.closeToTrayPrompted);
    return result.valueOrNull ?? false;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(SettingsKeys.closeToTrayPrompted, value: value);
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'CloseToTrayPromptedNotifier: set failed',
        tag: 'CloseToTrayPromptedNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Start with OS
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class StartWithOsNotifier extends _$StartWithOsNotifier {
  @override
  Future<bool> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getBool(SettingsKeys.startWithOS);
    return result.valueOrNull ?? false;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setBool(SettingsKeys.startWithOS, value: value);
    result.when(
      success: (_) => state = AsyncData(value),
      failure: (e) => AppLogger.error(
        'StartWithOsNotifier: set failed',
        tag: 'StartWithOsNotifier',
        error: e,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Crossfade Seconds (0 = disabled)
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class CrossfadeSecondsNotifier extends _$CrossfadeSecondsNotifier {
  @override
  Future<int> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getInt(SettingsKeys.crossfadeSeconds);
    return result.valueOrNull ?? 0;
  }

  /// Sets the crossfade duration in whole seconds.
  ///
  /// [seconds] must be in [0, 12]. 0 disables crossfade.
  Future<void> set(int seconds) async {
    final clamped = seconds.clamp(0, 12);
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setInt(SettingsKeys.crossfadeSeconds, clamped);
    result.when(
      success: (_) => state = AsyncData(clamped),
      failure: (e) => AppLogger.error(
        'CrossfadeSecondsNotifier: set failed',
        tag: 'CrossfadeSecondsNotifier',
        error: e,
      ),
    );
  }
}
