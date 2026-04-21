import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/song.dart';
import '../../domain/entities/queue_item.dart';
import 'use_case_providers.dart';

part 'home_provider.g.dart';

// ---------------------------------------------------------------------------
// Resume context
// ---------------------------------------------------------------------------

@riverpod
class ResumeContextNotifier extends _$ResumeContextNotifier {
  @override
  Future<
      ({
        Song? lastSong,
        Duration? lastPosition,
        List<QueueItem> savedQueue,
      })> build() async {
    final useCase = ref.watch(getResumeContextProvider);
    final result = await useCase.call();
    return result.when(
      success: (ctx) => ctx,
      failure: (_) => (lastSong: null, lastPosition: null, savedQueue: const <QueueItem>[]),
    );
  }
}

// ---------------------------------------------------------------------------
// Recently played (home row — max 20)
// ---------------------------------------------------------------------------

@riverpod
class RecentlyPlayedNotifier extends _$RecentlyPlayedNotifier {
  @override
  Future<List<Song>> build() async {
    final useCase = ref.watch(getRecentlyPlayedProvider);
    final result = await useCase.call(limit: 20);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}

// ---------------------------------------------------------------------------
// Most played (home row — top 20)
// ---------------------------------------------------------------------------

@riverpod
class MostPlayedNotifier extends _$MostPlayedNotifier {
  @override
  Future<List<Song>> build() async {
    final useCase = ref.watch(getMostPlayedProvider);
    final result = await useCase.call(limit: 20);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}

// ---------------------------------------------------------------------------
// Recently added (home row — last 20)
// ---------------------------------------------------------------------------

@riverpod
class RecentlyAddedNotifier extends _$RecentlyAddedNotifier {
  @override
  Future<List<Song>> build() async {
    final useCase = ref.watch(getRecentlyAddedProvider);
    final result = await useCase.call(limit: 20);
    return result.when(
      success: List.unmodifiable,
      failure: (_) => const [],
    );
  }
}

// ---------------------------------------------------------------------------
// Library stats
// ---------------------------------------------------------------------------

@riverpod
class LibraryStatsNotifier extends _$LibraryStatsNotifier {
  @override
  Future<({int totalSongs, Duration totalDuration, int totalAlbums, int totalArtists})> build() async {
    final useCase = ref.watch(getLibraryStatsProvider);
    final result = await useCase.call();
    return result.when(
      success: (stats) => stats,
      failure: (_) => (
        totalSongs: 0,
        totalDuration: Duration.zero,
        totalAlbums: 0,
        totalArtists: 0,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recommendations
// ---------------------------------------------------------------------------

@riverpod
class RecommendationsNotifier extends _$RecommendationsNotifier {
  @override
  Future<Map<String, List<Song>>> build() async {
    final useCase = ref.watch(getRecommendationsProvider);
    final result = await useCase.call();
    return result.when(
      success: (data) => data,
      failure: (_) => const {},
    );
  }

  Future<void> regenerate() async {
    final genUseCase = ref.read(generateRecommendationsProvider);
    await genUseCase.call();
    ref.invalidateSelf();
  }
}
