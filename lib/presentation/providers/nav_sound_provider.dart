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

  // Initialize asynchronously — NavSoundPlayer handles failures gracefully.
  player.initialize();

  // Keep volume in sync with the setting (re-runs when the setting changes).
  ref.listen(navSoundLevelProvider, (previous, next) {
    final level = next.value ?? AppConstants.defaultNavSoundLevel;
    player.setVolume(level);
  });

  ref.listen(playbackProvider, (previous, next) {
    player.setSuppressed(next.isPlaying);
  });

  // Apply current volume immediately.
  final currentLevel = ref.read(navSoundLevelProvider).value ?? AppConstants.defaultNavSoundLevel;
  player.setVolume(currentLevel);
  player.setSuppressed(ref.read(playbackProvider).isPlaying);

  ref.onDispose(player.dispose);

  return player;
}
