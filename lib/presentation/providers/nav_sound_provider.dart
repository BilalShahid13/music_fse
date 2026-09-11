import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../platform/nav_sounds/nav_sound_player.dart';
import 'playback_provider.dart';
import 'settings_provider.dart';

part 'nav_sound_provider.g.dart';

// ---------------------------------------------------------------------------
// NavSoundPlayerProvider — singleton NavSoundPlayer, volume kept in sync
// ---------------------------------------------------------------------------

/// Provides the application-wide [NavSoundPlayer] singleton.
///
/// Initialises the player on first access and keeps its volume synchronised
/// with [NavSoundLevelNotifier].
///
/// keepAlive: the player holds an [AudioPlayer] instance that must survive
/// for the lifetime of the app.
@Riverpod(keepAlive: true)
NavSoundPlayer navSoundPlayer(Ref ref) {
  final player = NavSoundPlayer();
  var navSoundsEnabled = AppConstants.defaultNavSoundEnabled;
  var navSoundLevel = AppConstants.defaultNavSoundLevel;
  var settingsHydrated = false;

  void syncPlayerSettings() {
    final isPlaying = ref.read(playbackProvider).isPlaying;
    player.setSuppressed(!settingsHydrated || isPlaying || !navSoundsEnabled);
  }

  player.setVolume(navSoundLevel);
  player.setSuppressed(true);
  syncPlayerSettings();

  // Initialize asynchronously — NavSoundPlayer handles failures gracefully.
  player.initialize();

  // Hydrate both settings together before unsuppressing so startup never
  // falls back to the optimistic 100% default after restore.
  unawaited(
    Future.wait<dynamic>([
      ref.read(navSoundEnabledProvider.future),
      ref.read(navSoundLevelProvider.future),
    ]).then((results) {
      navSoundsEnabled = results[0] as bool;
      navSoundLevel = results[1] as double;
      settingsHydrated = true;
      player.setVolume(navSoundLevel);
      syncPlayerSettings();
    }),
  );

  // Keep volume in sync with the setting (re-runs when the setting changes).
  ref.listen(navSoundLevelProvider, (previous, next) {
    final level = next.asData?.value;
    if (level == null) return;
    navSoundLevel = level;
    player.setVolume(level);
  });

  ref.listen(navSoundEnabledProvider, (previous, next) {
    final enabled = next.asData?.value;
    if (enabled == null) return;
    navSoundsEnabled = enabled;
    syncPlayerSettings();
  });

  ref.listen(playbackProvider, (previous, next) {
    syncPlayerSettings();
  });

  ref.onDispose(player.dispose);

  return player;
}
