import 'dart:ui' show Offset, Size;

import 'package:flutter/material.dart' show Colors;
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

// ---------------------------------------------------------------------------
// WindowManagerHelper
// ---------------------------------------------------------------------------

/// Utility facade over the `window_manager` package.
///
/// Provides a clean, static API for the rest of the app to manipulate the
/// native window without depending on `window_manager` directly. This makes
/// testing easier and keeps the coupling surface minimal.
///
/// Call [initialize] once at app startup (before [runApp]) and then use
/// the static action methods anywhere in the app.
abstract final class WindowManagerHelper {
  // -------------------------------------------------------------------------
  // Initialisation
  // -------------------------------------------------------------------------

  /// Configures and shows the app window.
  ///
  /// Must be called after [WidgetsFlutterBinding.ensureInitialized] and
  /// before [runApp]. This is a one-time setup — subsequent calls are no-ops
  /// because `window_manager` guards against double-init internally.
  static Future<void> initialize() async {
    await windowManager.ensureInitialized();

    const options = WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(
        AppConstants.minWindowWidth,
        AppConstants.minWindowHeight,
      ),
      center: true,
      backgroundColor: Colors.transparent,

      // Hides the OS-native title bar so [CustomTitleBar] can draw its own.
      titleBarStyle: TitleBarStyle.hidden,

      // Prevent the window from appearing until we explicitly show it below,
      // which avoids a white flash on startup.
      skipTaskbar: false,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    AppLogger.info('Window manager initialised', tag: 'WindowManagerHelper');
  }

  // -------------------------------------------------------------------------
  // Window controls (used by CustomTitleBar and system-tray callbacks)
  // -------------------------------------------------------------------------

  /// Minimises the window to the taskbar.
  static Future<void> minimize() => windowManager.minimize();

  /// Toggles between maximised and restored states.
  static Future<void> toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  /// Closes (or hides to tray, if configured) the window.
  ///
  /// The actual close-to-tray logic is handled by [WindowListener.onWindowClose]
  /// in the `AppShell` widget which intercepts this event.
  static Future<void> close() => windowManager.close();

  /// Begins a window drag operation — call from a mouse-down event on the
  /// [CustomTitleBar] drag region.
  static Future<void> startDragging() => windowManager.startDragging();

  // -------------------------------------------------------------------------
  // Visibility
  // -------------------------------------------------------------------------

  /// Shows and focuses the window (e.g. when the tray icon is clicked).
  static Future<void> show() async {
    await windowManager.show();
    await windowManager.focus();
  }

  /// Hides the window without closing it (used for close-to-tray behaviour).
  static Future<void> hide() => windowManager.hide();

  // -------------------------------------------------------------------------
  // Fullscreen
  // -------------------------------------------------------------------------

  /// Toggles native fullscreen (F11 keyboard shortcut).
  static Future<void> toggleFullscreen() async {
    final isFullscreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullscreen);
  }

  // -------------------------------------------------------------------------
  // Position / size persistence
  // -------------------------------------------------------------------------

  /// Returns the current window size, or `null` if the query fails.
  static Future<Size?> currentSize() async {
    try {
      return await windowManager.getSize();
    } catch (e) {
      AppLogger.warn(
        'WindowManagerHelper: getSize failed',
        tag: 'WindowManagerHelper',
        error: e,
      );
      return null;
    }
  }

  /// Returns the current window position, or `null` if the query fails.
  static Future<Offset?> currentPosition() async {
    try {
      final offset = await windowManager.getPosition();
      return Offset(offset.dx, offset.dy);
    } catch (e) {
      AppLogger.warn(
        'WindowManagerHelper: getPosition failed',
        tag: 'WindowManagerHelper',
        error: e,
      );
      return null;
    }
  }

  /// Restores a previously persisted window [size] and [position].
  ///
  /// Silently ignores errors (e.g. multi-monitor position out of range).
  static Future<void> restoreGeometry({
    required Size size,
    required Offset position,
  }) async {
    try {
      await windowManager.setSize(size);
      await windowManager.setPosition(position);
    } catch (e) {
      AppLogger.warn(
        'WindowManagerHelper: restoreGeometry failed',
        tag: 'WindowManagerHelper',
        error: e,
      );
    }
  }
}
