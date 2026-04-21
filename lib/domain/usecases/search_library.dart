import '../entities/search_results.dart';
import '../repositories/playlist_repository.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Performs a parallel cross-entity search across songs, albums, artists, and
/// playlists. Returns aggregated [SearchResults].
///
/// Each sub-search is limited to 5 results. All four queries run concurrently
/// via [Future.wait]. A failure in any individual query returns that collection
/// as empty rather than failing the whole operation.
final class SearchLibrary {
  const SearchLibrary({
    required SongRepository songRepository,
    required PlaylistRepository playlistRepository,
  })  : _songRepository = songRepository,
        _playlistRepository = playlistRepository;

  final SongRepository _songRepository;
  final PlaylistRepository _playlistRepository;

  Future<Result<SearchResults>> call(String query) async {
    if (query.trim().isEmpty) {
      return const Result.success(
        SearchResults(songs: [], albums: [], artists: [], playlists: []),
      );
    }

    // Run all four searches concurrently.
    final results = await Future.wait([
      _songRepository.searchSongs(query, limit: 5),
      _songRepository.searchAlbums(query, limit: 5),
      _songRepository.searchArtists(query, limit: 5),
      _playlistRepository.searchPlaylists(query, limit: 5),
    ]);

    // Each result is a Result<List<...>>. If it failed, treat as empty.
    final songs = (results[0] as Result).valueOrNull ?? [];
    final albums = (results[1] as Result).valueOrNull ?? [];
    final artists = (results[2] as Result).valueOrNull ?? [];
    final playlists = (results[3] as Result).valueOrNull ?? [];

    return Result.success(
      SearchResults(
        songs: List.unmodifiable(songs),
        albums: List.unmodifiable(albums),
        artists: List.unmodifiable(artists),
        playlists: List.unmodifiable(playlists),
      ),
    );
  }
}
