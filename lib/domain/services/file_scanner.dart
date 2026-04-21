/// Contract for recursively scanning directories for audio files.
///
/// The data layer implements this using dart:io. The domain layer only depends
/// on this abstract contract so use cases remain pure Dart with no I/O imports.
///
/// Implementations MUST:
/// - Skip directories they cannot access (permission errors) without throwing.
/// - Yield only files whose extension is in [AppConstants.supportedAudioExtensions].
/// - Not follow symbolic links to avoid infinite loops.
abstract class FileScanner {
  /// Scans all [directories] recursively and yields discovered audio file paths.
  ///
  /// Errors accessing individual directories are logged and skipped.
  /// The stream completes when all directories have been fully traversed.
  Stream<String> scanDirectories(List<String> directories);
}
