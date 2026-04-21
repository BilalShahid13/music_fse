import 'dart:developer' as developer;

/// Structured logger for the app.
///
/// Replaces `print()`. All logging goes through `dart:developer`'s `log()`
/// which is visible in the DevTools console and is stripped in release builds
/// when not observed.
///
/// Usage:
/// ```dart
/// AppLogger.info('Library scan complete', tag: 'ScanWorker');
/// AppLogger.error('Playback failed', error: e, stackTrace: st);
/// ```
abstract final class AppLogger {
  static const String _defaultTag = 'MusicFSE';

  /// Verbose debug information — only useful during development.
  static void debug(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag,
      level: 500,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// General informational messages about app state changes.
  static void info(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag,
      level: 800,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Something unexpected happened but the app can continue.
  static void warn(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// A recoverable or unrecoverable error occurred.
  static void error(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
