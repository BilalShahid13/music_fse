import 'dart:ffi';
import 'dart:io' show Platform, exit;

import 'package:ffi/ffi.dart';

import '../../core/utils/logger.dart';

// ---------------------------------------------------------------------------
// Win32 kernel32 typedefs
// ---------------------------------------------------------------------------

typedef _CreateMutexWNative = Pointer<Void> Function(
  Pointer<Void> lpMutexAttributes,
  Int32 bInitialOwner,
  Pointer<Utf16> lpName,
);
typedef _CreateMutexWDart = Pointer<Void> Function(
  Pointer<Void> lpMutexAttributes,
  int bInitialOwner,
  Pointer<Utf16> lpName,
);

typedef _GetLastErrorNative = Uint32 Function();
typedef _GetLastErrorDart = int Function();

const int _errorAlreadyExists = 183;

// ---------------------------------------------------------------------------
// SingleInstance — named mutex for Windows single-instance enforcement
// ---------------------------------------------------------------------------

/// Enforces that only one instance of Music FSE is running at any time
/// on Windows.
///
/// Uses a named Win32 mutex (`Global\MusicFSE_SingleInstance`) via
/// `dart:ffi` to `kernel32.dll`. If [acquire] returns `false`, a second
/// instance is already running and the caller should exit immediately:
///
/// ```dart
/// if (Platform.isWindows && !SingleInstance.acquire()) {
///   exit(0); // Bring existing window to front first, then exit.
/// }
/// ```
///
/// The mutex is automatically released by Windows when the process exits,
/// so there is no explicit [release] method needed in normal flow.
///
/// On non-Windows platforms [acquire] always returns `true`.
abstract final class SingleInstance {
  /// Mutex name — must be unique system-wide. `Global\` prefix makes it
  /// visible across terminal-server sessions.
  static const String _mutexName = 'Global\\MusicFSE_SingleInstance';

  // The mutex handle is retained so Windows doesn't release the mutex
  // when the value goes out of scope. Never read directly — its existence is
  // what matters.
  // ignore: unused_field
  static Pointer<Void>? _mutexHandle;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Attempts to acquire the single-instance mutex.
  ///
  /// Returns `true` if this is the first instance (mutex acquired).
  /// Returns `false` if another instance already holds the mutex.
  ///
  /// Always returns `true` on non-Windows platforms.
  static bool acquire() {
    if (!Platform.isWindows) return true;

    try {
      final kernel32 = DynamicLibrary.open('kernel32.dll');
      final createMutexW = kernel32.lookupFunction<_CreateMutexWNative, _CreateMutexWDart>('CreateMutexW');
      final getLastError = kernel32.lookupFunction<_GetLastErrorNative, _GetLastErrorDart>('GetLastError');

      final namePtr = _mutexName.toNativeUtf16();
      try {
        final handle = createMutexW(nullptr, 1 /* bInitialOwner = TRUE */, namePtr);
        final lastError = getLastError();

        if (handle == nullptr) {
          // CreateMutexW failed entirely — treat as first instance to avoid
          // incorrectly blocking the app.
          AppLogger.warn(
            'SingleInstance: CreateMutexW returned null handle',
            tag: 'SingleInstance',
          );
          return true;
        }

        _mutexHandle = handle;

        if (lastError == _errorAlreadyExists) {
          AppLogger.info(
            'SingleInstance: another instance is already running',
            tag: 'SingleInstance',
          );
          return false;
        }

        AppLogger.info(
          'SingleInstance: mutex acquired — this is the primary instance',
          tag: 'SingleInstance',
        );
        return true;
      } finally {
        calloc.free(namePtr);
      }
    } catch (e, st) {
      // FFI failures (e.g. running under Wine with incomplete kernel32) are
      // treated as first-instance to avoid blocking the app.
      AppLogger.warn(
        'SingleInstance: mutex check failed — assuming first instance',
        tag: 'SingleInstance',
        error: e,
        stackTrace: st,
      );
      return true;
    }
  }

  // -------------------------------------------------------------------------
  // IPC — bring existing window to front (best-effort)
  // -------------------------------------------------------------------------

  /// On Windows, when a second instance is detected, the convention is to
  /// bring the first instance's window to the foreground before exiting.
  ///
  /// This is a best-effort implementation using `PostMessage`/`FindWindow`.
  /// A more robust solution uses a named pipe (see [FileAssociationHandler]).
  static void focusExistingInstanceAndExit() {
    if (!Platform.isWindows) return;

    // best-effort: the primary instance registers a window class named
    // "FLUTTER_RUNNER_WIN32_WINDOW" (Flutter default). Use FindWindowW and
    // SetForegroundWindow to bring it up.
    try {
      final _ = DynamicLibrary.open('kernel32.dll'); // keep handle alive
      final user32 = DynamicLibrary.open('user32.dll');

      final findWindowW =
          user32.lookupFunction<Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>), Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>)>(
              'FindWindowW');
      final setForegroundWindow = user32.lookupFunction<Int32 Function(Pointer<Void>), int Function(Pointer<Void>)>('SetForegroundWindow');

      final classNamePtr = 'FLUTTER_RUNNER_WIN32_WINDOW'.toNativeUtf16();
      try {
        final hwnd = findWindowW(classNamePtr, nullptr);
        if (hwnd != nullptr) {
          setForegroundWindow(hwnd);
        }
      } finally {
        calloc.free(classNamePtr);
      }
    } catch (e) {
      AppLogger.warn(
        'SingleInstance: focusExistingInstanceAndExit — could not focus window',
        tag: 'SingleInstance',
        error: e,
      );
    }

    exit(0);
  }
}
