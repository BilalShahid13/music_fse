// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All playlists, optionally sorted.
///
/// [sortBy] accepts: 'name' | 'createdAt' | 'updatedAt' | 'songCount'.

@ProviderFor(PlaylistsNotifier)
final playlistsProvider = PlaylistsNotifierFamily._();

/// All playlists, optionally sorted.
///
/// [sortBy] accepts: 'name' | 'createdAt' | 'updatedAt' | 'songCount'.
final class PlaylistsNotifierProvider
    extends $AsyncNotifierProvider<PlaylistsNotifier, List<Playlist>> {
  /// All playlists, optionally sorted.
  ///
  /// [sortBy] accepts: 'name' | 'createdAt' | 'updatedAt' | 'songCount'.
  PlaylistsNotifierProvider._(
      {required PlaylistsNotifierFamily super.from,
      required ({
        String sortBy,
        bool ascending,
      })
          super.argument})
      : super(
          retry: null,
          name: r'playlistsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$playlistsNotifierHash();

  @override
  String toString() {
    return r'playlistsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  PlaylistsNotifier create() => PlaylistsNotifier();

  @override
  bool operator ==(Object other) {
    return other is PlaylistsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playlistsNotifierHash() => r'29e5edfe4bbc6af4a0a66da86d21dbef9354974b';

/// All playlists, optionally sorted.
///
/// [sortBy] accepts: 'name' | 'createdAt' | 'updatedAt' | 'songCount'.

final class PlaylistsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            PlaylistsNotifier,
            AsyncValue<List<Playlist>>,
            List<Playlist>,
            FutureOr<List<Playlist>>,
            ({
              String sortBy,
              bool ascending,
            })> {
  PlaylistsNotifierFamily._()
      : super(
          retry: null,
          name: r'playlistsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// All playlists, optionally sorted.
  ///
  /// [sortBy] accepts: 'name' | 'createdAt' | 'updatedAt' | 'songCount'.

  PlaylistsNotifierProvider call({
    String sortBy = 'name',
    bool ascending = true,
  }) =>
      PlaylistsNotifierProvider._(argument: (
        sortBy: sortBy,
        ascending: ascending,
      ), from: this);

  @override
  String toString() => r'playlistsProvider';
}

/// All playlists, optionally sorted.
///
/// [sortBy] accepts: 'name' | 'createdAt' | 'updatedAt' | 'songCount'.

abstract class _$PlaylistsNotifier extends $AsyncNotifier<List<Playlist>> {
  late final _$args = ref.$arg as ({
    String sortBy,
    bool ascending,
  });
  String get sortBy => _$args.sortBy;
  bool get ascending => _$args.ascending;

  FutureOr<List<Playlist>> build({
    String sortBy = 'name',
    bool ascending = true,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Playlist>>, List<Playlist>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Playlist>>, List<Playlist>>,
        AsyncValue<List<Playlist>>,
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

/// Songs belonging to [playlistId], ordered by their sort position.
///
/// This is a separate provider from [PlaylistsNotifier] so that updating
/// song membership does not force the entire playlist list to reload.

@ProviderFor(PlaylistSongsNotifier)
final playlistSongsProvider = PlaylistSongsNotifierFamily._();

/// Songs belonging to [playlistId], ordered by their sort position.
///
/// This is a separate provider from [PlaylistsNotifier] so that updating
/// song membership does not force the entire playlist list to reload.
final class PlaylistSongsNotifierProvider
    extends $AsyncNotifierProvider<PlaylistSongsNotifier, List<Song>> {
  /// Songs belonging to [playlistId], ordered by their sort position.
  ///
  /// This is a separate provider from [PlaylistsNotifier] so that updating
  /// song membership does not force the entire playlist list to reload.
  PlaylistSongsNotifierProvider._(
      {required PlaylistSongsNotifierFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'playlistSongsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$playlistSongsNotifierHash();

  @override
  String toString() {
    return r'playlistSongsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PlaylistSongsNotifier create() => PlaylistSongsNotifier();

  @override
  bool operator ==(Object other) {
    return other is PlaylistSongsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playlistSongsNotifierHash() =>
    r'b61f0ccbfbe74b35dcf495803ecf706a88059263';

/// Songs belonging to [playlistId], ordered by their sort position.
///
/// This is a separate provider from [PlaylistsNotifier] so that updating
/// song membership does not force the entire playlist list to reload.

final class PlaylistSongsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<PlaylistSongsNotifier, AsyncValue<List<Song>>,
            List<Song>, FutureOr<List<Song>>, int> {
  PlaylistSongsNotifierFamily._()
      : super(
          retry: null,
          name: r'playlistSongsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Songs belonging to [playlistId], ordered by their sort position.
  ///
  /// This is a separate provider from [PlaylistsNotifier] so that updating
  /// song membership does not force the entire playlist list to reload.

  PlaylistSongsNotifierProvider call(
    int playlistId,
  ) =>
      PlaylistSongsNotifierProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'playlistSongsProvider';
}

/// Songs belonging to [playlistId], ordered by their sort position.
///
/// This is a separate provider from [PlaylistsNotifier] so that updating
/// song membership does not force the entire playlist list to reload.

abstract class _$PlaylistSongsNotifier extends $AsyncNotifier<List<Song>> {
  late final _$args = ref.$arg as int;
  int get playlistId => _$args;

  FutureOr<List<Song>> build(
    int playlistId,
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
