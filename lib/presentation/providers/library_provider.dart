import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/song.dart';
import 'use_case_providers.dart';

part 'library_provider.g.dart';

// ---------------------------------------------------------------------------
// Songs
// ---------------------------------------------------------------------------

/// All songs in the library, sorted by [sortBy] / [ascending].
///
/// Invalidate (via [ref.invalidateSelf]) after a library scan completes to
/// reload the list. Consumer widgets use [select] to avoid full rebuilds.
@riverpod
class SongsNotifier extends _$SongsNotifier {
  @override
  Future<List<Song>> build({
    String sortBy = 'title',
    bool ascending = true,
  }) async {
    final useCase = ref.watch(getAllSongsProvider);
    final result = await useCase.call(sortBy: sortBy, ascending: ascending);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}

// ---------------------------------------------------------------------------
// Albums
// ---------------------------------------------------------------------------

@riverpod
class AlbumsNotifier extends _$AlbumsNotifier {
  @override
  Future<List<Album>> build({
    String sortBy = 'name',
    bool ascending = true,
  }) async {
    final useCase = ref.watch(getAllAlbumsProvider);
    final result = await useCase.call(sortBy: sortBy, ascending: ascending);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}

// ---------------------------------------------------------------------------
// Artists
// ---------------------------------------------------------------------------

@riverpod
class ArtistsNotifier extends _$ArtistsNotifier {
  @override
  Future<List<Artist>> build({
    String sortBy = 'name',
    bool ascending = true,
  }) async {
    final useCase = ref.watch(getAllArtistsProvider);
    final result = await useCase.call(sortBy: sortBy, ascending: ascending);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}

// ---------------------------------------------------------------------------
// Genres
// ---------------------------------------------------------------------------

@riverpod
class GenresNotifier extends _$GenresNotifier {
  @override
  Future<List<Genre>> build({
    String sortBy = 'name',
    bool ascending = true,
  }) async {
    final useCase = ref.watch(getAllGenresProvider);
    final result = await useCase.call(sortBy: sortBy, ascending: ascending);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}

// ---------------------------------------------------------------------------
// Folder contents
// ---------------------------------------------------------------------------

/// Songs and sub-folders at a given path.
///
/// [parentPath] null → top-level view (registered scan root folders).
@riverpod
class FolderContentsNotifier extends _$FolderContentsNotifier {
  @override
  Future<({List<String> subFolders, List<Song> songs})> build(
    String? parentPath,
  ) async {
    final useCase = ref.watch(getFolderContentsProvider);
    final result = await useCase.call(parentPath);
    return result.when(
      success: (contents) => contents,
      failure: (_) => (subFolders: <String>[], songs: <Song>[]),
    );
  }
}

// ---------------------------------------------------------------------------
// Songs by album / artist / genre
// ---------------------------------------------------------------------------

/// Songs belonging to an album, identified by [album] + [albumArtist].
@riverpod
class SongsByAlbumNotifier extends _$SongsByAlbumNotifier {
  @override
  Future<List<Song>> build(String album, String albumArtist) async {
    final useCase = ref.watch(getSongsByAlbumProvider);
    final result = await useCase.call(album, albumArtist);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}

/// Songs belonging to a given artist.
@riverpod
class SongsByArtistNotifier extends _$SongsByArtistNotifier {
  @override
  Future<List<Song>> build(String artist) async {
    final useCase = ref.watch(getSongsByArtistProvider);
    final result = await useCase.call(artist);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}

/// Songs tagged with a given genre.
@riverpod
class SongsByGenreNotifier extends _$SongsByGenreNotifier {
  @override
  Future<List<Song>> build(String genre) async {
    final useCase = ref.watch(getSongsByGenreProvider);
    final result = await useCase.call(genre);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}
