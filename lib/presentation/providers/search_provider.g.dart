// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the search bar, live results, and search history.
///
/// Search is debounced at 300 ms so a query fires only after the user pauses
/// typing. History is persisted to [SettingsRepository] as a JSON-encoded list.

@ProviderFor(SearchNotifier)
final searchProvider = SearchNotifierProvider._();

/// Manages the search bar, live results, and search history.
///
/// Search is debounced at 300 ms so a query fires only after the user pauses
/// typing. History is persisted to [SettingsRepository] as a JSON-encoded list.
final class SearchNotifierProvider
    extends $NotifierProvider<SearchNotifier, SearchState> {
  /// Manages the search bar, live results, and search history.
  ///
  /// Search is debounced at 300 ms so a query fires only after the user pauses
  /// typing. History is persisted to [SettingsRepository] as a JSON-encoded list.
  SearchNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchNotifierHash();

  @$internal
  @override
  SearchNotifier create() => SearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchNotifierHash() => r'8a6f406f876721c7755939a6109cb036450dffeb';

/// Manages the search bar, live results, and search history.
///
/// Search is debounced at 300 ms so a query fires only after the user pauses
/// typing. History is persisted to [SettingsRepository] as a JSON-encoded list.

abstract class _$SearchNotifier extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SearchState, SearchState>, SearchState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Song results from the current search.

@ProviderFor(searchSongResults)
final searchSongResultsProvider = SearchSongResultsProvider._();

/// Song results from the current search.

final class SearchSongResultsProvider
    extends $FunctionalProvider<List<Song>, List<Song>, List<Song>>
    with $Provider<List<Song>> {
  /// Song results from the current search.
  SearchSongResultsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchSongResultsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchSongResultsHash();

  @$internal
  @override
  $ProviderElement<List<Song>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Song> create(Ref ref) {
    return searchSongResults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Song> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Song>>(value),
    );
  }
}

String _$searchSongResultsHash() => r'bcd2ca5f2b58e03c5b900682f9616bb2ecb686fa';

/// Album results from the current search.

@ProviderFor(searchAlbumResults)
final searchAlbumResultsProvider = SearchAlbumResultsProvider._();

/// Album results from the current search.

final class SearchAlbumResultsProvider
    extends $FunctionalProvider<List<Album>, List<Album>, List<Album>>
    with $Provider<List<Album>> {
  /// Album results from the current search.
  SearchAlbumResultsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchAlbumResultsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchAlbumResultsHash();

  @$internal
  @override
  $ProviderElement<List<Album>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Album> create(Ref ref) {
    return searchAlbumResults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Album> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Album>>(value),
    );
  }
}

String _$searchAlbumResultsHash() =>
    r'7eecb603b38792e62cc013f2d7c945d248b5c706';

/// Artist results from the current search.

@ProviderFor(searchArtistResults)
final searchArtistResultsProvider = SearchArtistResultsProvider._();

/// Artist results from the current search.

final class SearchArtistResultsProvider
    extends $FunctionalProvider<List<Artist>, List<Artist>, List<Artist>>
    with $Provider<List<Artist>> {
  /// Artist results from the current search.
  SearchArtistResultsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchArtistResultsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchArtistResultsHash();

  @$internal
  @override
  $ProviderElement<List<Artist>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Artist> create(Ref ref) {
    return searchArtistResults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Artist> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Artist>>(value),
    );
  }
}

String _$searchArtistResultsHash() =>
    r'd79505688b28dfcc7ebfafab7479b5343c6c743e';

/// Playlist results from the current search.

@ProviderFor(searchPlaylistResults)
final searchPlaylistResultsProvider = SearchPlaylistResultsProvider._();

/// Playlist results from the current search.

final class SearchPlaylistResultsProvider
    extends $FunctionalProvider<List<Playlist>, List<Playlist>, List<Playlist>>
    with $Provider<List<Playlist>> {
  /// Playlist results from the current search.
  SearchPlaylistResultsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchPlaylistResultsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchPlaylistResultsHash();

  @$internal
  @override
  $ProviderElement<List<Playlist>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Playlist> create(Ref ref) {
    return searchPlaylistResults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Playlist> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Playlist>>(value),
    );
  }
}

String _$searchPlaylistResultsHash() =>
    r'be0d154eeea5da45564facd4477726ba231877a3';
