// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All songs in the library, sorted by [sortBy] / [ascending].
///
/// Invalidate (via [ref.invalidateSelf]) after a library scan completes to
/// reload the list. Consumer widgets use [select] to avoid full rebuilds.

@ProviderFor(SongsNotifier)
final songsProvider = SongsNotifierFamily._();

/// All songs in the library, sorted by [sortBy] / [ascending].
///
/// Invalidate (via [ref.invalidateSelf]) after a library scan completes to
/// reload the list. Consumer widgets use [select] to avoid full rebuilds.
final class SongsNotifierProvider
    extends $AsyncNotifierProvider<SongsNotifier, List<Song>> {
  /// All songs in the library, sorted by [sortBy] / [ascending].
  ///
  /// Invalidate (via [ref.invalidateSelf]) after a library scan completes to
  /// reload the list. Consumer widgets use [select] to avoid full rebuilds.
  SongsNotifierProvider._(
      {required SongsNotifierFamily super.from,
      required ({
        String sortBy,
        bool ascending,
      })
          super.argument})
      : super(
          retry: null,
          name: r'songsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$songsNotifierHash();

  @override
  String toString() {
    return r'songsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SongsNotifier create() => SongsNotifier();

  @override
  bool operator ==(Object other) {
    return other is SongsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songsNotifierHash() => r'505cc65f1e5c8eeae281c2a5e2a9589b421bd2af';

/// All songs in the library, sorted by [sortBy] / [ascending].
///
/// Invalidate (via [ref.invalidateSelf]) after a library scan completes to
/// reload the list. Consumer widgets use [select] to avoid full rebuilds.

final class SongsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            SongsNotifier,
            AsyncValue<List<Song>>,
            List<Song>,
            FutureOr<List<Song>>,
            ({
              String sortBy,
              bool ascending,
            })> {
  SongsNotifierFamily._()
      : super(
          retry: null,
          name: r'songsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// All songs in the library, sorted by [sortBy] / [ascending].
  ///
  /// Invalidate (via [ref.invalidateSelf]) after a library scan completes to
  /// reload the list. Consumer widgets use [select] to avoid full rebuilds.

  SongsNotifierProvider call({
    String sortBy = 'title',
    bool ascending = true,
  }) =>
      SongsNotifierProvider._(argument: (
        sortBy: sortBy,
        ascending: ascending,
      ), from: this);

  @override
  String toString() => r'songsProvider';
}

/// All songs in the library, sorted by [sortBy] / [ascending].
///
/// Invalidate (via [ref.invalidateSelf]) after a library scan completes to
/// reload the list. Consumer widgets use [select] to avoid full rebuilds.

abstract class _$SongsNotifier extends $AsyncNotifier<List<Song>> {
  late final _$args = ref.$arg as ({
    String sortBy,
    bool ascending,
  });
  String get sortBy => _$args.sortBy;
  bool get ascending => _$args.ascending;

  FutureOr<List<Song>> build({
    String sortBy = 'title',
    bool ascending = true,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Song>>, List<Song>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Song>>, List<Song>>,
        AsyncValue<List<Song>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              sortBy: _$args.sortBy,
              ascending: _$args.ascending,
            ));
  }
}

@ProviderFor(AlbumsNotifier)
final albumsProvider = AlbumsNotifierFamily._();

final class AlbumsNotifierProvider
    extends $AsyncNotifierProvider<AlbumsNotifier, List<Album>> {
  AlbumsNotifierProvider._(
      {required AlbumsNotifierFamily super.from,
      required ({
        String sortBy,
        bool ascending,
      })
          super.argument})
      : super(
          retry: null,
          name: r'albumsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$albumsNotifierHash();

  @override
  String toString() {
    return r'albumsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  AlbumsNotifier create() => AlbumsNotifier();

  @override
  bool operator ==(Object other) {
    return other is AlbumsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$albumsNotifierHash() => r'd2ddc31a35c13453a895d794786f6088462c59e6';

final class AlbumsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            AlbumsNotifier,
            AsyncValue<List<Album>>,
            List<Album>,
            FutureOr<List<Album>>,
            ({
              String sortBy,
              bool ascending,
            })> {
  AlbumsNotifierFamily._()
      : super(
          retry: null,
          name: r'albumsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AlbumsNotifierProvider call({
    String sortBy = 'name',
    bool ascending = true,
  }) =>
      AlbumsNotifierProvider._(argument: (
        sortBy: sortBy,
        ascending: ascending,
      ), from: this);

  @override
  String toString() => r'albumsProvider';
}

abstract class _$AlbumsNotifier extends $AsyncNotifier<List<Album>> {
  late final _$args = ref.$arg as ({
    String sortBy,
    bool ascending,
  });
  String get sortBy => _$args.sortBy;
  bool get ascending => _$args.ascending;

  FutureOr<List<Album>> build({
    String sortBy = 'name',
    bool ascending = true,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Album>>, List<Album>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Album>>, List<Album>>,
        AsyncValue<List<Album>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              sortBy: _$args.sortBy,
              ascending: _$args.ascending,
            ));
  }
}

@ProviderFor(ArtistsNotifier)
final artistsProvider = ArtistsNotifierFamily._();

final class ArtistsNotifierProvider
    extends $AsyncNotifierProvider<ArtistsNotifier, List<Artist>> {
  ArtistsNotifierProvider._(
      {required ArtistsNotifierFamily super.from,
      required ({
        String sortBy,
        bool ascending,
      })
          super.argument})
      : super(
          retry: null,
          name: r'artistsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$artistsNotifierHash();

  @override
  String toString() {
    return r'artistsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ArtistsNotifier create() => ArtistsNotifier();

  @override
  bool operator ==(Object other) {
    return other is ArtistsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$artistsNotifierHash() => r'630a00efe2083befa51ba846d5d660c1feabc502';

final class ArtistsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            ArtistsNotifier,
            AsyncValue<List<Artist>>,
            List<Artist>,
            FutureOr<List<Artist>>,
            ({
              String sortBy,
              bool ascending,
            })> {
  ArtistsNotifierFamily._()
      : super(
          retry: null,
          name: r'artistsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ArtistsNotifierProvider call({
    String sortBy = 'name',
    bool ascending = true,
  }) =>
      ArtistsNotifierProvider._(argument: (
        sortBy: sortBy,
        ascending: ascending,
      ), from: this);

  @override
  String toString() => r'artistsProvider';
}

abstract class _$ArtistsNotifier extends $AsyncNotifier<List<Artist>> {
  late final _$args = ref.$arg as ({
    String sortBy,
    bool ascending,
  });
  String get sortBy => _$args.sortBy;
  bool get ascending => _$args.ascending;

  FutureOr<List<Artist>> build({
    String sortBy = 'name',
    bool ascending = true,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Artist>>, List<Artist>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Artist>>, List<Artist>>,
        AsyncValue<List<Artist>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              sortBy: _$args.sortBy,
              ascending: _$args.ascending,
            ));
  }
}

@ProviderFor(GenresNotifier)
final genresProvider = GenresNotifierFamily._();

final class GenresNotifierProvider
    extends $AsyncNotifierProvider<GenresNotifier, List<Genre>> {
  GenresNotifierProvider._(
      {required GenresNotifierFamily super.from,
      required ({
        String sortBy,
        bool ascending,
      })
          super.argument})
      : super(
          retry: null,
          name: r'genresProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$genresNotifierHash();

  @override
  String toString() {
    return r'genresProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  GenresNotifier create() => GenresNotifier();

  @override
  bool operator ==(Object other) {
    return other is GenresNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$genresNotifierHash() => r'a2b6d4d036b8a1068180ec700b2cda2bcea2db9f';

final class GenresNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            GenresNotifier,
            AsyncValue<List<Genre>>,
            List<Genre>,
            FutureOr<List<Genre>>,
            ({
              String sortBy,
              bool ascending,
            })> {
  GenresNotifierFamily._()
      : super(
          retry: null,
          name: r'genresProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GenresNotifierProvider call({
    String sortBy = 'name',
    bool ascending = true,
  }) =>
      GenresNotifierProvider._(argument: (
        sortBy: sortBy,
        ascending: ascending,
      ), from: this);

  @override
  String toString() => r'genresProvider';
}

abstract class _$GenresNotifier extends $AsyncNotifier<List<Genre>> {
  late final _$args = ref.$arg as ({
    String sortBy,
    bool ascending,
  });
  String get sortBy => _$args.sortBy;
  bool get ascending => _$args.ascending;

  FutureOr<List<Genre>> build({
    String sortBy = 'name',
    bool ascending = true,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Genre>>, List<Genre>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Genre>>, List<Genre>>,
        AsyncValue<List<Genre>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              sortBy: _$args.sortBy,
              ascending: _$args.ascending,
            ));
  }
}

/// Songs and sub-folders at a given path.
///
/// [parentPath] null → top-level view (registered scan root folders).

@ProviderFor(FolderContentsNotifier)
final folderContentsProvider = FolderContentsNotifierFamily._();

/// Songs and sub-folders at a given path.
///
/// [parentPath] null → top-level view (registered scan root folders).
final class FolderContentsNotifierProvider extends $AsyncNotifierProvider<
    FolderContentsNotifier,
    ({
      List<Song> songs,
      List<String> subFolders,
    })> {
  /// Songs and sub-folders at a given path.
  ///
  /// [parentPath] null → top-level view (registered scan root folders).
  FolderContentsNotifierProvider._(
      {required FolderContentsNotifierFamily super.from,
      required String? super.argument})
      : super(
          retry: null,
          name: r'folderContentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$folderContentsNotifierHash();

  @override
  String toString() {
    return r'folderContentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FolderContentsNotifier create() => FolderContentsNotifier();

  @override
  bool operator ==(Object other) {
    return other is FolderContentsNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderContentsNotifierHash() =>
    r'e62e45ca41469515f6b875fc279f5f2b2d37a749';

/// Songs and sub-folders at a given path.
///
/// [parentPath] null → top-level view (registered scan root folders).

final class FolderContentsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            FolderContentsNotifier,
            AsyncValue<
                ({
                  List<Song> songs,
                  List<String> subFolders,
                })>,
            ({
              List<Song> songs,
              List<String> subFolders,
            }),
            FutureOr<
                ({
                  List<Song> songs,
                  List<String> subFolders,
                })>,
            String?> {
  FolderContentsNotifierFamily._()
      : super(
          retry: null,
          name: r'folderContentsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Songs and sub-folders at a given path.
  ///
  /// [parentPath] null → top-level view (registered scan root folders).

  FolderContentsNotifierProvider call(
    String? parentPath,
  ) =>
      FolderContentsNotifierProvider._(argument: parentPath, from: this);

  @override
  String toString() => r'folderContentsProvider';
}

/// Songs and sub-folders at a given path.
///
/// [parentPath] null → top-level view (registered scan root folders).

abstract class _$FolderContentsNotifier extends $AsyncNotifier<
    ({
      List<Song> songs,
      List<String> subFolders,
    })> {
  late final _$args = ref.$arg as String?;
  String? get parentPath => _$args;

  FutureOr<
      ({
        List<Song> songs,
        List<String> subFolders,
      })> build(
    String? parentPath,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<
        AsyncValue<
            ({
              List<Song> songs,
              List<String> subFolders,
            })>,
        ({
          List<Song> songs,
          List<String> subFolders,
        })>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<
            AsyncValue<
                ({
                  List<Song> songs,
                  List<String> subFolders,
                })>,
            ({
              List<Song> songs,
              List<String> subFolders,
            })>,
        AsyncValue<
            ({
              List<Song> songs,
              List<String> subFolders,
            })>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

/// Songs belonging to an album, identified by [album] + [albumArtist].

@ProviderFor(SongsByAlbumNotifier)
final songsByAlbumProvider = SongsByAlbumNotifierFamily._();

/// Songs belonging to an album, identified by [album] + [albumArtist].
final class SongsByAlbumNotifierProvider
    extends $AsyncNotifierProvider<SongsByAlbumNotifier, List<Song>> {
  /// Songs belonging to an album, identified by [album] + [albumArtist].
  SongsByAlbumNotifierProvider._(
      {required SongsByAlbumNotifierFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'songsByAlbumProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$songsByAlbumNotifierHash();

  @override
  String toString() {
    return r'songsByAlbumProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SongsByAlbumNotifier create() => SongsByAlbumNotifier();

  @override
  bool operator ==(Object other) {
    return other is SongsByAlbumNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songsByAlbumNotifierHash() =>
    r'68397e5ce74af1a2ebf0beab469ddee1546e7921';

/// Songs belonging to an album, identified by [album] + [albumArtist].

final class SongsByAlbumNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            SongsByAlbumNotifier,
            AsyncValue<List<Song>>,
            List<Song>,
            FutureOr<List<Song>>,
            (
              String,
              String,
            )> {
  SongsByAlbumNotifierFamily._()
      : super(
          retry: null,
          name: r'songsByAlbumProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Songs belonging to an album, identified by [album] + [albumArtist].

  SongsByAlbumNotifierProvider call(
    String album,
    String albumArtist,
  ) =>
      SongsByAlbumNotifierProvider._(argument: (
        album,
        albumArtist,
      ), from: this);

  @override
  String toString() => r'songsByAlbumProvider';
}

/// Songs belonging to an album, identified by [album] + [albumArtist].

abstract class _$SongsByAlbumNotifier extends $AsyncNotifier<List<Song>> {
  late final _$args = ref.$arg as (
    String,
    String,
  );
  String get album => _$args.$1;
  String get albumArtist => _$args.$2;

  FutureOr<List<Song>> build(
    String album,
    String albumArtist,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Song>>, List<Song>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Song>>, List<Song>>,
        AsyncValue<List<Song>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args.$1,
              _$args.$2,
            ));
  }
}

/// Songs belonging to a given artist.

@ProviderFor(SongsByArtistNotifier)
final songsByArtistProvider = SongsByArtistNotifierFamily._();

/// Songs belonging to a given artist.
final class SongsByArtistNotifierProvider
    extends $AsyncNotifierProvider<SongsByArtistNotifier, List<Song>> {
  /// Songs belonging to a given artist.
  SongsByArtistNotifierProvider._(
      {required SongsByArtistNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'songsByArtistProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$songsByArtistNotifierHash();

  @override
  String toString() {
    return r'songsByArtistProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SongsByArtistNotifier create() => SongsByArtistNotifier();

  @override
  bool operator ==(Object other) {
    return other is SongsByArtistNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songsByArtistNotifierHash() =>
    r'458262e8d8548d671115094c1ca63ec55f0bdd8d';

/// Songs belonging to a given artist.

final class SongsByArtistNotifierFamily extends $Family
    with
        $ClassFamilyOverride<SongsByArtistNotifier, AsyncValue<List<Song>>,
            List<Song>, FutureOr<List<Song>>, String> {
  SongsByArtistNotifierFamily._()
      : super(
          retry: null,
          name: r'songsByArtistProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Songs belonging to a given artist.

  SongsByArtistNotifierProvider call(
    String artist,
  ) =>
      SongsByArtistNotifierProvider._(argument: artist, from: this);

  @override
  String toString() => r'songsByArtistProvider';
}

/// Songs belonging to a given artist.

abstract class _$SongsByArtistNotifier extends $AsyncNotifier<List<Song>> {
  late final _$args = ref.$arg as String;
  String get artist => _$args;

  FutureOr<List<Song>> build(
    String artist,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Song>>, List<Song>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Song>>, List<Song>>,
        AsyncValue<List<Song>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

/// Songs tagged with a given genre.

@ProviderFor(SongsByGenreNotifier)
final songsByGenreProvider = SongsByGenreNotifierFamily._();

/// Songs tagged with a given genre.
final class SongsByGenreNotifierProvider
    extends $AsyncNotifierProvider<SongsByGenreNotifier, List<Song>> {
  /// Songs tagged with a given genre.
  SongsByGenreNotifierProvider._(
      {required SongsByGenreNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'songsByGenreProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$songsByGenreNotifierHash();

  @override
  String toString() {
    return r'songsByGenreProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SongsByGenreNotifier create() => SongsByGenreNotifier();

  @override
  bool operator ==(Object other) {
    return other is SongsByGenreNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songsByGenreNotifierHash() =>
    r'f4c974ff4f1e0c217b3bf2e856c92a3d9f7f750e';

/// Songs tagged with a given genre.

final class SongsByGenreNotifierFamily extends $Family
    with
        $ClassFamilyOverride<SongsByGenreNotifier, AsyncValue<List<Song>>,
            List<Song>, FutureOr<List<Song>>, String> {
  SongsByGenreNotifierFamily._()
      : super(
          retry: null,
          name: r'songsByGenreProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Songs tagged with a given genre.

  SongsByGenreNotifierProvider call(
    String genre,
  ) =>
      SongsByGenreNotifierProvider._(argument: genre, from: this);

  @override
  String toString() => r'songsByGenreProvider';
}

/// Songs tagged with a given genre.

abstract class _$SongsByGenreNotifier extends $AsyncNotifier<List<Song>> {
  late final _$args = ref.$arg as String;
  String get genre => _$args;

  FutureOr<List<Song>> build(
    String genre,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Song>>, List<Song>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Song>>, List<Song>>,
        AsyncValue<List<Song>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
