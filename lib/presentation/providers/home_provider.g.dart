// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ResumeContextNotifier)
final resumeContextProvider = ResumeContextNotifierProvider._();

final class ResumeContextNotifierProvider extends $AsyncNotifierProvider<
    ResumeContextNotifier,
    ({
      Duration? lastPosition,
      Song? lastSong,
      List<QueueItem> savedQueue,
    })> {
  ResumeContextNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'resumeContextProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$resumeContextNotifierHash();

  @$internal
  @override
  ResumeContextNotifier create() => ResumeContextNotifier();
}

String _$resumeContextNotifierHash() =>
    r'038a37e48509273338d2b9817302d589e56d3f3e';

abstract class _$ResumeContextNotifier extends $AsyncNotifier<
    ({
      Duration? lastPosition,
      Song? lastSong,
      List<QueueItem> savedQueue,
    })> {
  FutureOr<
      ({
        Duration? lastPosition,
        Song? lastSong,
        List<QueueItem> savedQueue,
      })> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<
        AsyncValue<
            ({
              Duration? lastPosition,
              Song? lastSong,
              List<QueueItem> savedQueue,
            })>,
        ({
          Duration? lastPosition,
          Song? lastSong,
          List<QueueItem> savedQueue,
        })>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<
            AsyncValue<
                ({
                  Duration? lastPosition,
                  Song? lastSong,
                  List<QueueItem> savedQueue,
                })>,
            ({
              Duration? lastPosition,
              Song? lastSong,
              List<QueueItem> savedQueue,
            })>,
        AsyncValue<
            ({
              Duration? lastPosition,
              Song? lastSong,
              List<QueueItem> savedQueue,
            })>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(RecentlyPlayedNotifier)
final recentlyPlayedProvider = RecentlyPlayedNotifierProvider._();

final class RecentlyPlayedNotifierProvider
    extends $AsyncNotifierProvider<RecentlyPlayedNotifier, List<Song>> {
  RecentlyPlayedNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentlyPlayedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentlyPlayedNotifierHash();

  @$internal
  @override
  RecentlyPlayedNotifier create() => RecentlyPlayedNotifier();
}

String _$recentlyPlayedNotifierHash() =>
    r'0b233735c28b6f5aa942ab2f5f775f6bef8ca0a4';

abstract class _$RecentlyPlayedNotifier extends $AsyncNotifier<List<Song>> {
  FutureOr<List<Song>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Song>>, List<Song>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Song>>, List<Song>>,
        AsyncValue<List<Song>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MostPlayedNotifier)
final mostPlayedProvider = MostPlayedNotifierProvider._();

final class MostPlayedNotifierProvider
    extends $AsyncNotifierProvider<MostPlayedNotifier, List<Song>> {
  MostPlayedNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mostPlayedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mostPlayedNotifierHash();

  @$internal
  @override
  MostPlayedNotifier create() => MostPlayedNotifier();
}

String _$mostPlayedNotifierHash() =>
    r'6c72db826ae14b703637ece63a0470d9e6cc8082';

abstract class _$MostPlayedNotifier extends $AsyncNotifier<List<Song>> {
  FutureOr<List<Song>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Song>>, List<Song>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Song>>, List<Song>>,
        AsyncValue<List<Song>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(RecentlyAddedNotifier)
final recentlyAddedProvider = RecentlyAddedNotifierProvider._();

final class RecentlyAddedNotifierProvider
    extends $AsyncNotifierProvider<RecentlyAddedNotifier, List<Song>> {
  RecentlyAddedNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentlyAddedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentlyAddedNotifierHash();

  @$internal
  @override
  RecentlyAddedNotifier create() => RecentlyAddedNotifier();
}

String _$recentlyAddedNotifierHash() =>
    r'415991951b0dabe8dd2adbc2c958f00b745f8982';

abstract class _$RecentlyAddedNotifier extends $AsyncNotifier<List<Song>> {
  FutureOr<List<Song>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Song>>, List<Song>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Song>>, List<Song>>,
        AsyncValue<List<Song>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(LibraryStatsNotifier)
final libraryStatsProvider = LibraryStatsNotifierProvider._();

final class LibraryStatsNotifierProvider extends $AsyncNotifierProvider<
    LibraryStatsNotifier,
    ({
      int totalAlbums,
      int totalArtists,
      Duration totalDuration,
      int totalSongs,
    })> {
  LibraryStatsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'libraryStatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$libraryStatsNotifierHash();

  @$internal
  @override
  LibraryStatsNotifier create() => LibraryStatsNotifier();
}

String _$libraryStatsNotifierHash() =>
    r'31bb308033b6b81841c1c180f8a61193cd2bd1ac';

abstract class _$LibraryStatsNotifier extends $AsyncNotifier<
    ({
      int totalAlbums,
      int totalArtists,
      Duration totalDuration,
      int totalSongs,
    })> {
  FutureOr<
      ({
        int totalAlbums,
        int totalArtists,
        Duration totalDuration,
        int totalSongs,
      })> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<
        AsyncValue<
            ({
              int totalAlbums,
              int totalArtists,
              Duration totalDuration,
              int totalSongs,
            })>,
        ({
          int totalAlbums,
          int totalArtists,
          Duration totalDuration,
          int totalSongs,
        })>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<
            AsyncValue<
                ({
                  int totalAlbums,
                  int totalArtists,
                  Duration totalDuration,
                  int totalSongs,
                })>,
            ({
              int totalAlbums,
              int totalArtists,
              Duration totalDuration,
              int totalSongs,
            })>,
        AsyncValue<
            ({
              int totalAlbums,
              int totalArtists,
              Duration totalDuration,
              int totalSongs,
            })>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(RecommendationsNotifier)
final recommendationsProvider = RecommendationsNotifierProvider._();

final class RecommendationsNotifierProvider extends $AsyncNotifierProvider<
    RecommendationsNotifier, Map<String, List<Song>>> {
  RecommendationsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recommendationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recommendationsNotifierHash();

  @$internal
  @override
  RecommendationsNotifier create() => RecommendationsNotifier();
}

String _$recommendationsNotifierHash() =>
    r'53b6cace11d24b0ca462620ea8c0521e0d40dfb8';

abstract class _$RecommendationsNotifier
    extends $AsyncNotifier<Map<String, List<Song>>> {
  FutureOr<Map<String, List<Song>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<Map<String, List<Song>>>, Map<String, List<Song>>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Map<String, List<Song>>>,
            Map<String, List<Song>>>,
        AsyncValue<Map<String, List<Song>>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
