import '../entities/album.dart';
import '../entities/artist.dart';
import '../entities/playlist.dart';
import '../entities/song.dart';

/// Aggregated results from a cross-entity library search.
///
/// All four collections are populated in parallel when [SearchLibrary] is
/// called. Any collection may be empty if there are no matching results.
final class SearchResults {
  const SearchResults({
    required this.songs,
    required this.albums,
    required this.artists,
    required this.playlists,
  });

  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;

  /// Convenience accessor — true if all collections are empty.
  bool get isEmpty => songs.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty;

  /// Total number of results across all collections.
  int get totalCount => songs.length + albums.length + artists.length + playlists.length;
}
