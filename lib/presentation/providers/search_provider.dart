import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/debouncer.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/settings_repository.dart';
import 'repository_providers.dart';
import 'use_case_providers.dart';

part 'search_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Snapshot of the search screen's state.
@immutable
final class SearchState {
  const SearchState({
    this.query = '',
    this.results = const SearchResults(
      songs: [],
      albums: [],
      artists: [],
      playlists: [],
    ),
    this.isSearching = false,
    this.history = const [],
  });

  final String query;
  final SearchResults results;
  final bool isSearching;

  /// Most-recent search queries, newest first. Capped at
  /// [AppConstants.searchHistoryMax].
  final List<String> history;

  bool get hasQuery => query.trim().isNotEmpty;

  SearchState copyWith({
    String? query,
    SearchResults? results,
    bool? isSearching,
    List<String>? history,
  }) =>
      SearchState(
        query: query ?? this.query,
        results: results ?? this.results,
        isSearching: isSearching ?? this.isSearching,
        history: history ?? this.history,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchState && other.query == query && other.isSearching == isSearching && listEquals(other.history, history);

  @override
  int get hashCode => Object.hash(query, isSearching, history);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Manages the search bar, live results, and search history.
///
/// Search is debounced at 300 ms so a query fires only after the user pauses
/// typing. History is persisted to [SettingsRepository] as a JSON-encoded list.
@Riverpod(keepAlive: true)
class SearchNotifier extends _$SearchNotifier {
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  static const String _historyKey = SettingsKeys.searchHistory;

  final Debouncer _debouncer = Debouncer(delay: _debounceDuration);

  @override
  SearchState build() {
    ref.onDispose(_debouncer.dispose);
    _loadHistory();
    return const SearchState();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Updates the search query and schedules a debounced search.
  void onQueryChanged(String query) {
    state = state.copyWith(query: query, isSearching: query.trim().isNotEmpty);
    if (query.trim().isEmpty) {
      _debouncer.cancel();
      state = state.copyWith(
        results: const SearchResults(
          songs: [],
          albums: [],
          artists: [],
          playlists: [],
        ),
        isSearching: false,
      );
      return;
    }
    _debouncer(() => _executeSearch(query.trim()));
  }

  /// Clears the search query and results without touching history.
  void clearSearch() {
    _debouncer.cancel();
    state = const SearchState(history: []).copyWith(history: state.history);
  }

  /// Re-runs the active query so result rows reflect external changes such as
  /// favorite toggles.
  Future<void> refreshCurrentQuery() async {
    final query = state.query.trim();
    if (query.isEmpty) return;

    state = state.copyWith(isSearching: true);
    await _executeSearch(query);
  }

  /// Adds [query] to the history and persists it.
  ///
  /// Moves [query] to the top if it already exists.
  Future<void> addToHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final newHistory = [
      trimmed,
      ...state.history.where((h) => h != trimmed),
    ].take(AppConstants.searchHistoryMax).toList();

    state = state.copyWith(history: newHistory);
    await _persistHistory(newHistory);
  }

  /// Removes a single [query] from history.
  Future<void> removeFromHistory(String query) async {
    final newHistory = state.history.where((h) => h != query).toList();
    state = state.copyWith(history: newHistory);
    await _persistHistory(newHistory);
  }

  /// Clears all search history.
  Future<void> clearHistory() async {
    state = state.copyWith(history: []);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.remove(_historyKey);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _executeSearch(String query) async {
    final useCase = ref.read(searchLibraryProvider);
    final result = await useCase.call(query);
    // Only apply results if the query hasn't changed in the meantime.
    if (state.query.trim() != query) return;
    result.when(
      success: (results) {
        state = state.copyWith(results: results, isSearching: false);
      },
      failure: (error) {
        AppLogger.error(
          'SearchNotifier: search failed',
          tag: 'SearchNotifier',
          error: error,
        );
        state = state.copyWith(isSearching: false);
      },
    );
  }

  Future<void> _loadHistory() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getString(_historyKey);
    final raw = result.valueOrNull;
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final history = decoded.cast<String>().take(AppConstants.searchHistoryMax).toList();
      state = state.copyWith(history: history);
    } catch (e) {
      AppLogger.warn(
        'SearchNotifier: could not parse search history',
        tag: 'SearchNotifier',
      );
    }
  }

  Future<void> _persistHistory(List<String> history) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setString(_historyKey, jsonEncode(history));
  }
}

// ---------------------------------------------------------------------------
// Convenience typed result providers
// ---------------------------------------------------------------------------

/// Song results from the current search.
@riverpod
List<Song> searchSongResults(Ref ref) => ref.watch(searchProvider).results.songs;

/// Album results from the current search.
@riverpod
List<Album> searchAlbumResults(Ref ref) => ref.watch(searchProvider).results.albums;

/// Artist results from the current search.
@riverpod
List<Artist> searchArtistResults(Ref ref) => ref.watch(searchProvider).results.artists;

/// Playlist results from the current search.
@riverpod
List<Playlist> searchPlaylistResults(Ref ref) => ref.watch(searchProvider).results.playlists;
