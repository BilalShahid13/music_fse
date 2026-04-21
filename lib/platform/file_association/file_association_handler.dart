import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import '../../core/utils/logger.dart';

// ---------------------------------------------------------------------------
// FileAssociationHandler — cross-platform file-open event handling
// ---------------------------------------------------------------------------

/// Listens for OS-level "open this audio file" events, triggered when:
/// - The app is launched with a file path as a command-line argument.
/// - A running instance receives a file-open request via IPC (Windows named
///   pipe, macOS `application:openURLs:`, Linux D-Bus).
///
/// Implementations:
/// - [_WindowsFileAssociationHandler] — reads `dart:io` [Platform.executableArguments]
///   at launch, then listens on the named pipe `\\.\pipe\MusicFSE_FileOpen`.
/// - [_MacOsFileAssociationHandler] — listens on [MethodChannel]
///   `com.musicfse.player/file_association` (AppDelegate posts events).
/// - [_LinuxFileAssociationHandler] — listens on [MethodChannel]
///   `com.musicfse.player/file_association` (MPRIS/D-Bus opens).
/// - [_NoOpFileAssociationHandler] — silent fallback.
///
/// Usage:
/// ```dart
/// final handler = FileAssociationHandler.create();
/// handler.onFileRequested = (path) async { ... }; // receive file path
/// await handler.initialize();
/// // Check launch args immediately after init:
/// await handler.checkLaunchArguments();
/// ```
abstract class FileAssociationHandler {
  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  /// Returns the appropriate [FileAssociationHandler] for the current platform.
  factory FileAssociationHandler.create() {
    if (Platform.isWindows) return _WindowsFileAssociationHandler();
    if (Platform.isMacOS) return _MacOsFileAssociationHandler();
    if (Platform.isLinux) return _LinuxFileAssociationHandler();
    return _NoOpFileAssociationHandler();
  }
  // ---------------------------------------------------------------------------
  // Callback
  // ---------------------------------------------------------------------------

  /// Called when the OS requests that a specific audio file be opened.
  ///
  /// [filePath] is the absolute path to the file. The caller should:
  /// 1. Look it up in the Drift database.
  /// 2. If found → play it directly.
  /// 3. If not found → extract metadata, create a transient [Song], play it.
  void Function(String filePath)? onFileRequested;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialises platform channels / named-pipe listeners.
  /// Call once during app startup, before [checkLaunchArguments].
  Future<void> initialize();

  /// Checks whether the app was launched with an audio file path as a
  /// command-line argument and fires [onFileRequested] if so.
  ///
  /// Must be called AFTER [initialize].
  Future<void> checkLaunchArguments();

  /// Releases resources.
  Future<void> dispose();
}

// ---------------------------------------------------------------------------
// Windows implementation
// ---------------------------------------------------------------------------

/// On Windows the second instance sends its launch-time file path through a
/// named pipe (`\\.\pipe\MusicFSE_FileOpen`) and then exits. The primary
/// instance reads from that pipe continuously.
///
/// On launch, the primary instance also checks [Platform.executableArguments]
/// directly for an initial file path.
class _WindowsFileAssociationHandler implements FileAssociationHandler {
  static const String _pipeName = r'\\.\pipe\MusicFSE_FileOpen';
  static const MethodChannel _channel = MethodChannel('com.musicfse.player/file_association');

  StreamSubscription<dynamic>? _pipeSubscription;

  @override
  void Function(String filePath)? onFileRequested;

  @override
  Future<void> initialize() async {
    if (!Platform.isWindows) return;
    try {
      // Start the named-pipe server on the native side.
      await _channel.invokeMethod<void>('startPipeServer', {'pipe': _pipeName});

      // Listen for incoming file paths from the native pipe server.
      const EventChannel pipeEvents = EventChannel('com.musicfse.player/file_association_events');
      _pipeSubscription = pipeEvents.receiveBroadcastStream().listen((dynamic event) {
        if (event is String && event.isNotEmpty) {
          _dispatch(event);
        }
      });

      AppLogger.info(
        'FileAssociation (Windows): named-pipe server started at $_pipeName',
        tag: 'FileAssociation',
      );
    } on MissingPluginException {
      AppLogger.info(
        'FileAssociation (Windows): pipe server unavailable; launch-argument handling only',
        tag: 'FileAssociation',
      );
    } catch (e, st) {
      AppLogger.warn(
        'FileAssociation (Windows): failed to start pipe server',
        tag: 'FileAssociation',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> checkLaunchArguments() async {
    if (!Platform.isWindows) return;
    // Check native side for the path that was passed to this instance via argv.
    try {
      final path = await _channel.invokeMethod<String?>('getLaunchFilePath');
      if (path != null && path.isNotEmpty) {
        AppLogger.info(
          'FileAssociation (Windows): launch argument file: $path',
          tag: 'FileAssociation',
        );
        _dispatch(path);
      }
    } catch (e, st) {
      AppLogger.warn(
        'FileAssociation (Windows): checkLaunchArguments failed',
        tag: 'FileAssociation',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _pipeSubscription?.cancel();
    _pipeSubscription = null;
    try {
      await _channel.invokeMethod<void>('stopPipeServer');
    } on MissingPluginException {
      // Optional native IPC support is not present.
    } catch (e) {
      AppLogger.debug('FileAssociation (Windows): stopPipeServer failed during dispose', tag: 'FileAssociation', error: e);
    }
  }

  void _dispatch(String path) => onFileRequested?.call(path);
}

// ---------------------------------------------------------------------------
// macOS implementation
// ---------------------------------------------------------------------------

/// macOS delivers file-open events via `application(_:openURLs:)` in
/// `AppDelegate.swift`. The native side forwards them over a [MethodChannel].
class _MacOsFileAssociationHandler implements FileAssociationHandler {
  static const MethodChannel _channel = MethodChannel('com.musicfse.player/file_association');

  @override
  void Function(String filePath)? onFileRequested;

  @override
  Future<void> initialize() async {
    if (!Platform.isMacOS) return;
    _channel.setMethodCallHandler(_onMethodCall);
    AppLogger.info(
      'FileAssociation (macOS): listening on method channel',
      tag: 'FileAssociation',
    );
  }

  @override
  Future<void> checkLaunchArguments() async {
    if (!Platform.isMacOS) return;
    try {
      final path = await _channel.invokeMethod<String?>('getLaunchFilePath');
      if (path != null && path.isNotEmpty) {
        AppLogger.info(
          'FileAssociation (macOS): launch argument file: $path',
          tag: 'FileAssociation',
        );
        onFileRequested?.call(path);
      }
    } catch (e, st) {
      AppLogger.warn(
        'FileAssociation (macOS): checkLaunchArguments failed',
        tag: 'FileAssociation',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == 'openFile') {
      final path = call.arguments as String?;
      if (path != null && path.isNotEmpty) {
        AppLogger.info(
          'FileAssociation (macOS): openFile → $path',
          tag: 'FileAssociation',
        );
        onFileRequested?.call(path);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Linux implementation
// ---------------------------------------------------------------------------

/// Linux delivers file-open events through the single-instance
/// `GtkApplication` command-line path. The native side forwards startup and
/// live requests over a [MethodChannel].
class _LinuxFileAssociationHandler implements FileAssociationHandler {
  static const MethodChannel _channel = MethodChannel('com.musicfse.player/file_association');

  @override
  void Function(String filePath)? onFileRequested;

  @override
  Future<void> initialize() async {
    if (!Platform.isLinux) return;
    _channel.setMethodCallHandler(_onMethodCall);
    AppLogger.info(
      'FileAssociation (Linux): listening on method channel',
      tag: 'FileAssociation',
    );
  }

  @override
  Future<void> checkLaunchArguments() async {
    if (!Platform.isLinux) return;
    try {
      final path = await _channel.invokeMethod<String?>('getLaunchFilePath');
      if (path != null && path.isNotEmpty) {
        AppLogger.info(
          'FileAssociation (Linux): launch argument file: $path',
          tag: 'FileAssociation',
        );
        onFileRequested?.call(path);
      }

      final pendingPaths = await _channel.invokeListMethod<String>('consumePendingFilePaths');
      for (final pendingPath in pendingPaths ?? const <String>[]) {
        if (pendingPath.isEmpty) continue;
        AppLogger.info(
          'FileAssociation (Linux): pending openFile → $pendingPath',
          tag: 'FileAssociation',
        );
        onFileRequested?.call(pendingPath);
      }
    } catch (e, st) {
      AppLogger.warn(
        'FileAssociation (Linux): checkLaunchArguments failed',
        tag: 'FileAssociation',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == 'openFile') {
      final path = call.arguments as String?;
      if (path != null && path.isNotEmpty) {
        AppLogger.info(
          'FileAssociation (Linux): openFile → $path',
          tag: 'FileAssociation',
        );
        onFileRequested?.call(path);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// No-op fallback
// ---------------------------------------------------------------------------

class _NoOpFileAssociationHandler implements FileAssociationHandler {
  @override
  void Function(String filePath)? onFileRequested;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> checkLaunchArguments() async {}

  @override
  Future<void> dispose() async {}
}
