import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/song.dart';
import 'home_provider.dart';
import 'library_provider.dart';
import 'playlist_provider.dart';
import 'search_provider.dart';
import 'use_case_providers.dart';

part 'favorites_provider.g.dart';

/// All songs marked as favorites, optionally sorted.
///
/// [sortBy] accepts: 'title' | 'artist' | 'album' | 'dateAdded'.
@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  @override
  Future<List<Song>> build({
    String sortBy = 'title',
    bool ascending = true,
  }) async {
    final useCase = ref.watch(getFavoritesProvider);
    final result = await useCase.call(sortBy: sortBy, ascending: ascending);
    return result.when(
      success: List.unmodifiable,
      failure: (error) {
        AppLogger.error(
          'FavoritesNotifier: failed to load favorites',
          tag: 'FavoritesNotifier',
          error: error,
        );
        return const [];
      },
    );
  }

  /// Toggles the favorite status of [songId].
  ///
  /// [isFavorite] is the CURRENT value — the use case flips it.
  /// Call with the current song's [Song.isFavorite] value.
  Future<void> toggleFavorite(int songId, {required bool isFavorite}) async {
    final useCase = ref.read(toggleFavoriteProvider);
    // The ToggleFavorite use case sets the value to the opposite of [isFavorite].
    final result = await useCase.call(songId, isFavorite: !isFavorite);
    result.when(
      success: (_) {
        ref.invalidateSelf();
        ref.invalidate(songsProvider);
        ref.invalidate(songsByAlbumProvider);
        ref.invalidate(songsByArtistProvider);
        ref.invalidate(songsByGenreProvider);
        ref.invalidate(folderContentsProvider);
        ref.invalidate(playlistSongsProvider);
        ref.invalidate(recentlyPlayedProvider);
        ref.invalidate(mostPlayedProvider);
        ref.invalidate(recentlyAddedProvider);
        ref.invalidate(recommendationsProvider);
        ref.read(searchProvider.notifier).refreshCurrentQuery();
      },
      failure: (error) => AppLogger.error(
        'FavoritesNotifier: toggleFavorite failed for songId=$songId',
        tag: 'FavoritesNotifier',
        error: error,
      ),
    );
  }
}
