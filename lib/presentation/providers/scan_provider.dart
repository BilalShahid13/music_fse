import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/logger.dart';
import '../../domain/usecases/scan_library.dart';
import 'home_provider.dart';
import 'library_provider.dart';
import 'use_case_providers.dart';

part 'scan_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Immutable snapshot of a library scan operation.
@immutable
final class ScanState {
  const ScanState({
    this.isScanning = false,
    this.found = 0,
    this.processed = 0,
    this.total = 0,
    this.currentFile,
    this.inaccessibleFolders = const [],
    this.isComplete = false,
    this.hasError = false,
  });

  /// True while the scan is actively running.
  final bool isScanning;

  /// Audio files discovered so far.
  final int found;

  /// Files whose metadata has been extracted and saved.
  final int processed;

  /// Total files to process (equals [found] once discovery phase is done).
  final int total;

  /// Path of the file currently being processed, for progress display.
  final String? currentFile;

  /// Paths of folders that could not be accessed (permission denied, etc.).
  final List<String> inaccessibleFolders;

  /// True when the scan has finished successfully.
  final bool isComplete;

  /// True when the scan ended with an unrecoverable error.
  final bool hasError;

  double get progressFraction => total == 0 ? 0.0 : (processed / total).clamp(0.0, 1.0);

  ScanState copyWith({
    bool? isScanning,
    int? found,
    int? processed,
    int? total,
    Object? currentFile = _sentinel,
    List<String>? inaccessibleFolders,
    bool? isComplete,
    bool? hasError,
  }) =>
      ScanState(
        isScanning: isScanning ?? this.isScanning,
        found: found ?? this.found,
        processed: processed ?? this.processed,
        total: total ?? this.total,
        currentFile: currentFile == _sentinel ? this.currentFile : currentFile as String?,
        inaccessibleFolders: inaccessibleFolders ?? this.inaccessibleFolders,
        isComplete: isComplete ?? this.isComplete,
        hasError: hasError ?? this.hasError,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanState &&
          other.isScanning == isScanning &&
          other.found == found &&
          other.processed == processed &&
          other.total == total &&
          other.currentFile == currentFile &&
          other.isComplete == isComplete &&
          other.hasError == hasError &&
          listEquals(other.inaccessibleFolders, inaccessibleFolders);

  @override
  int get hashCode => Object.hash(
        isScanning,
        found,
        processed,
        total,
        currentFile,
        isComplete,
        hasError,
        Object.hashAll(inaccessibleFolders),
      );
}

const Object _sentinel = Object();

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Drives library scanning and exposes live progress via [ScanState].
///
/// Call [startScan] to initiate a scan. Only one scan may run at a time — a
/// second call while scanning is in progress is a no-op.
@Riverpod(keepAlive: true)
class ScanNotifier extends _$ScanNotifier {
  StreamSubscription<ScanProgress>? _subscription;

  @override
  ScanState build() {
    ref.onDispose(_cancelSubscription);
    return const ScanState();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Starts a full library scan.
  ///
  /// No-op if a scan is already in progress.
  Future<void> startScan() async {
    if (state.isScanning) return;
    await _cancelSubscription();

    state = const ScanState(isScanning: true);

    try {
      final useCase = await ref.read(scanLibraryProvider.future);
      final stream = useCase.call();

      _subscription = stream.listen(
        _onProgress,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e, st) {
      AppLogger.error(
        'ScanNotifier: failed to start scan',
        tag: 'ScanNotifier',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(isScanning: false, hasError: true);
    }
  }

  /// Starts an incremental scan — only processes new, modified, and deleted
  /// files since the last scan.
  Future<void> startIncrementalScan() async {
    if (state.isScanning) return;
    await _cancelSubscription();

    state = const ScanState(isScanning: true);

    try {
      final useCase = await ref.read(scanLibraryProvider.future);
      final stream = useCase.call(incremental: true);

      _subscription = stream.listen(
        _onProgress,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e, st) {
      AppLogger.error(
        'ScanNotifier: failed to start incremental scan',
        tag: 'ScanNotifier',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(isScanning: false, hasError: true);
    }
  }

  /// Cancels an in-progress scan and resets to idle.
  Future<void> cancelScan() async {
    await _cancelSubscription();
    state = state.copyWith(isScanning: false);
  }

  /// Scans a specific set of file paths without a full library scan.
  ///
  /// Used for targeted operations like drag-and-drop. No-op if a scan is
  /// already in progress.
  Future<void> scanSpecificFiles(List<String> filePaths) async {
    if (state.isScanning || filePaths.isEmpty) return;
    await _cancelSubscription();

    state = const ScanState(isScanning: true);

    try {
      final useCase = await ref.read(scanLibraryProvider.future);
      final stream = useCase.scanFiles(filePaths);

      _subscription = stream.listen(
        _onProgress,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e, st) {
      AppLogger.error(
        'ScanNotifier: failed to scan specific files',
        tag: 'ScanNotifier',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(isScanning: false, hasError: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Stream callbacks
  // ---------------------------------------------------------------------------

  void _onProgress(ScanProgress progress) {
    state = state.copyWith(
      found: progress.found,
      processed: progress.processed,
      total: progress.total,
      currentFile: progress.currentFile,
    );
  }

  void _onError(Object error, StackTrace st) {
    AppLogger.error(
      'ScanNotifier: scan error',
      tag: 'ScanNotifier',
      error: error,
      stackTrace: st,
    );
    // Don't abort — scan_library emits errors per-file and continues.
    // Only mark hasError if the caller decides to surface it.
  }

  void _onDone() {
    state = state.copyWith(
      isScanning: false,
      isComplete: true,
      currentFile: null,
    );
    _subscription = null;
    _refreshLibrary();
    AppLogger.info('ScanNotifier: scan complete', tag: 'ScanNotifier');
  }

  // ---------------------------------------------------------------------------
  // Post-scan refresh
  // ---------------------------------------------------------------------------

  /// Invalidates all library providers so their next read fetches fresh data.
  void _refreshLibrary() {
    ref.invalidate(songsProvider);
    ref.invalidate(albumsProvider);
    ref.invalidate(artistsProvider);
    ref.invalidate(genresProvider);
    // Home page providers fetch from the DB independently — they must also
    // be invalidated so the home screen reflects the newly scanned library.
    ref.invalidate(recentlyPlayedProvider);
    ref.invalidate(mostPlayedProvider);
    ref.invalidate(recentlyAddedProvider);
    ref.invalidate(libraryStatsProvider);
    ref.invalidate(recommendationsProvider);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> _cancelSubscription() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
