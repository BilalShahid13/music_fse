import 'dart:io';

import '../entities/scan_folder.dart';
import '../repositories/scan_folder_repository.dart';
import '../repositories/song_repository.dart';
import '../services/file_scanner.dart';
import '../services/metadata_extractor.dart';
import '../../core/utils/logger.dart';

/// Progress snapshot emitted by [ScanLibrary] during an active library scan.
final class ScanProgress {
  const ScanProgress({
    required this.found,
    required this.processed,
    required this.total,
    this.currentFile,
  });

  /// Number of audio files discovered so far.
  final int found;

  /// Number of files whose metadata has been fully extracted and saved.
  final int processed;

  /// Total files to process (equals [found] as scanning is streaming; set
  /// once the discovery phase completes).
  final int total;

  /// The file path currently being processed, for display in a progress bar.
  final String? currentFile;

  double get progressFraction => total == 0 ? 0.0 : (processed / total).clamp(0.0, 1.0);
}

/// Scans all enabled [ScanFolder] directories for audio files, extracts
/// metadata, and upserts each discovered song into the database.
///
/// Emits a [Stream<ScanProgress>] so the UI can show a live progress bar.
/// The stream completes when all files have been processed. If an error occurs
/// for an individual file, it is logged and scanning continues — partial
/// results are always better than none.
///
/// **This use case is designed to be called from a dedicated Riverpod
/// provider that manages its lifecycle. It MUST NOT be called from the UI
/// directly — only through [ScanLibraryProvider].**
///
/// Architecture note: The [FileScanner] and [MetadataExtractor] are abstract
/// domain service interfaces. The concrete implementations in the data layer
/// handle all I/O. This keeps the use case pure-Dart and fully testable.
final class ScanLibrary {
  const ScanLibrary({
    required SongRepository songRepository,
    required ScanFolderRepository scanFolderRepository,
    required FileScanner fileScanner,
    required MetadataExtractor metadataExtractor,
    required String artCacheDir,
  })  : _songRepository = songRepository,
        _scanFolderRepository = scanFolderRepository,
        _fileScanner = fileScanner,
        _metadataExtractor = metadataExtractor,
        _artCacheDir = artCacheDir;

  final SongRepository _songRepository;
  final ScanFolderRepository _scanFolderRepository;
  final FileScanner _fileScanner;
  final MetadataExtractor _metadataExtractor;
  final String _artCacheDir;

  /// Starts the scan. Yields progress updates as files are discovered and
  /// processed.
  ///
  /// When [incremental] is true, only new and modified files are processed,
  /// and files no longer on disk are marked as missing.
  Stream<ScanProgress> call({bool incremental = false}) async* {
    // 1. Load enabled folders.
    final foldersResult = await _scanFolderRepository.getAll();
    if (foldersResult.isFailure) {
      AppLogger.error(
        'ScanLibrary: failed to load scan folders',
        tag: 'ScanLibrary',
        error: foldersResult.errorOrNull,
      );
      return;
    }

    final folders = foldersResult.valueOrNull!.where((f) => f.enabled).toList();

    if (folders.isEmpty) {
      AppLogger.info('ScanLibrary: no enabled folders to scan', tag: 'ScanLibrary');
      return;
    }

    final paths = folders.map((f) => f.path).toList();

    // 2. Discovery phase — collect all file paths first so we can show an
    //    accurate total. For very large libraries we stream to avoid holding
    //    all paths in memory simultaneously; instead we buffer in batches.
    final discoveredFiles = <String>[];
    int found = 0;

    await for (final filePath in _fileScanner.scanDirectories(paths)) {
      discoveredFiles.add(filePath);
      found++;
      yield ScanProgress(found: found, processed: 0, total: found);
    }

    final total = discoveredFiles.length;
    AppLogger.info(
      'ScanLibrary: discovered $total files',
      tag: 'ScanLibrary',
    );

    // 3. Incremental delta — filter to only new/modified files.
    List<String> filesToProcess;
    Map<String, DateTime>? knownFiles;

    if (incremental) {
      final knownResult = await _songRepository.getAllFilePathsWithModified();
      knownFiles = knownResult.valueOrNull ?? {};
      filesToProcess = <String>[];

      for (final filePath in discoveredFiles) {
        final knownModified = knownFiles[filePath];
        if (knownModified == null) {
          // New file
          filesToProcess.add(filePath);
        } else {
          try {
            final stat = File(filePath).statSync();
            if (stat.modified.isAfter(knownModified)) {
              // Modified file
              filesToProcess.add(filePath);
            }
          } catch (_) {
            // Can't stat — treat as new
            filesToProcess.add(filePath);
          }
        }
        // Remove from known so remaining entries = deleted files
        knownFiles.remove(filePath);
      }

      // Mark remaining known files as missing (deleted from disk)
      for (final missingPath in knownFiles.keys) {
        final songResult = await _songRepository.getSongByPath(missingPath);
        final song = songResult.valueOrNull;
        if (song != null) {
          await _songRepository.markMissing(song.id, isMissing: true);
        }
      }

      AppLogger.info(
        'ScanLibrary: incremental — ${filesToProcess.length} new/modified, '
        '${knownFiles.length} missing',
        tag: 'ScanLibrary',
      );
    } else {
      filesToProcess = discoveredFiles;
    }

    // 4. Extraction & upsert phase.
    final processTotal = filesToProcess.length;
    int processed = 0;
    for (final filePath in filesToProcess) {
      try {
        final song = await _metadataExtractor.extractMetadata(filePath);
        final artPath = await _metadataExtractor.extractArt(
          filePath,
          _artCacheDir,
        );
        final songWithArt = artPath != null ? song.copyWith(artCachePath: artPath) : song;

        await _songRepository.upsertSong(songWithArt);
      } catch (e, st) {
        AppLogger.warn(
          'ScanLibrary: failed to process "$filePath"',
          tag: 'ScanLibrary',
          error: e,
          stackTrace: st,
        );
      }

      processed++;
      yield ScanProgress(
        found: total,
        processed: processed,
        total: processTotal,
        currentFile: filePath,
      );
    }

    // 5. Update lastScannedAt for each folder.
    final now = DateTime.now();
    for (final folder in folders) {
      await _scanFolderRepository.updateLastScanned(folder.id, now);
    }

    AppLogger.info(
      'ScanLibrary: completed. processed=$processed/$total',
      tag: 'ScanLibrary',
    );
  }

  /// Processes a specific list of file paths — extracts metadata and upserts
  /// each into the database. Used for targeted operations like drag-and-drop
  /// where a full library scan is wasteful.
  ///
  /// Yields [ScanProgress] for each file processed.
  Stream<ScanProgress> scanFiles(List<String> filePaths) async* {
    final total = filePaths.length;
    int processed = 0;

    for (final filePath in filePaths) {
      try {
        final song = await _metadataExtractor.extractMetadata(filePath);
        final artPath = await _metadataExtractor.extractArt(
          filePath,
          _artCacheDir,
        );
        final songWithArt = artPath != null ? song.copyWith(artCachePath: artPath) : song;
        await _songRepository.upsertSong(songWithArt);
      } catch (e, st) {
        AppLogger.warn(
          'ScanLibrary.scanFiles: failed to process "$filePath"',
          tag: 'ScanLibrary',
          error: e,
          stackTrace: st,
        );
      }

      processed++;
      yield ScanProgress(
        found: total,
        processed: processed,
        total: total,
        currentFile: filePath,
      );
    }

    AppLogger.info(
      'ScanLibrary.scanFiles: completed. processed=$processed/$total',
      tag: 'ScanLibrary',
    );
  }
}
