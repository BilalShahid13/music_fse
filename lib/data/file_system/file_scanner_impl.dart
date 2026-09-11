import 'dart:async';
import 'dart:io';

import '../../core/constants/app_constants.dart';
import '../../core/utils/library_file_utils.dart';
import '../../core/utils/logger.dart';
import '../../domain/services/file_scanner.dart';

/// [FileScanner] implementation using [dart:io] directory listing.
///
/// - Scans recursively with `followLinks: false` to avoid symlink cycles.
/// - Silently skips directories that throw [FileSystemException] (e.g. due to
///   permission denial) and logs a warning.
/// - Only yields files whose extension (lowercased) is in
///   [AppConstants.supportedAudioExtensions].
final class FileScannerImpl implements FileScanner {
  const FileScannerImpl();

  @override
  Stream<String> scanDirectories(List<String> directories) async* {
    for (final dirPath in directories) {
      yield* _scanOne(dirPath);
    }
  }

  Stream<String> _scanOne(String dirPath) {
    final controller = StreamController<String>();

    _traverse(dirPath, controller).whenComplete(controller.close);

    return controller.stream;
  }

  Future<void> _traverse(
    String dirPath,
    StreamController<String> controller,
  ) async {
    final dir = Directory(dirPath);

    if (!dir.existsSync()) {
      AppLogger.warn(
        'Scan folder does not exist, skipping: $dirPath',
        tag: 'FileScanner',
      );
      return;
    }

    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        if (shouldIgnoreLibraryFilePath(entity.path)) continue;

        final ext = _extension(entity.path);
        if (AppConstants.supportedAudioExtensions.contains(ext)) {
          controller.add(normalizeLibraryFilePath(entity.path));
        }
      }
    } on FileSystemException catch (e) {
      AppLogger.warn(
        'Permission error scanning $dirPath: ${e.message}',
        tag: 'FileScanner',
      );
    }
  }

  /// Returns the lowercased file extension including the leading dot, or an
  /// empty string if there is no extension.
  static String _extension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '';
    return path.substring(dot).toLowerCase();
  }
}
