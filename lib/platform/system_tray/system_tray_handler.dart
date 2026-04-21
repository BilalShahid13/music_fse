import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';

import '../../core/utils/logger.dart';

// ---------------------------------------------------------------------------
// SystemTrayHandler
// ---------------------------------------------------------------------------

/// Manages the system tray icon and its context menu.
///
/// **Architecture**: Belongs to the platform layer. Zero Riverpod dependency.
/// Callers wire up action callbacks before calling [initialize]:
///
/// ```dart
/// trayHandler.onTogglePlayPause = () => notifier.togglePlayPause();
/// trayHandler.onNext            = () => notifier.skipNext();
/// trayHandler.onPrevious        = () => notifier.skipPrevious();
/// trayHandler.onShowWindow      = () => windowManager.show();
/// trayHandler.onQuit            = () => windowManager.close();
/// await trayHandler.initialize();
/// ```
///
/// Call [updateTooltip] whenever the current track changes to display
/// "Artist — Title" in the tray tooltip.
///
/// On Linux the icon path must be a PNG; on Windows use `.ico`.
final class SystemTrayHandler {
  SystemTrayHandler();

  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  bool _initialized = false;

  // -------------------------------------------------------------------------
  // Callbacks (wired up by the provider layer)
  // -------------------------------------------------------------------------

  VoidCallback? onTogglePlayPause;
  VoidCallback? onNext;
  VoidCallback? onPrevious;
  VoidCallback? onShowWindow;
  VoidCallback? onQuit;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) return;

    final iconPath = _platformIconPath();

    try {
      await _systemTray.initSystemTray(
        title: 'Music FSE',
        iconPath: iconPath,
        toolTip: 'Music FSE',
      );

      await _buildContextMenu();

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          // Single-click → show / focus window.
          _handleShowWindow();
        } else if (eventName == kSystemTrayEventRightClick) {
          // Right-click → show context menu (handled automatically on Windows;
          // on macOS we need to call popUpContextMenu explicitly).
          _systemTray.popUpContextMenu();
        }
      });

      _initialized = true;
      AppLogger.info('SystemTray initialised', tag: 'SystemTrayHandler');
    } catch (e, st) {
      AppLogger.error(
        'SystemTrayHandler: failed to initialise',
        tag: 'SystemTrayHandler',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _buildContextMenu() async {
    final menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Play / Pause',
        onClicked: (_) => onTogglePlayPause?.call(),
      ),
      MenuItemLabel(
        label: 'Next Track',
        onClicked: (_) => onNext?.call(),
      ),
      MenuItemLabel(
        label: 'Previous Track',
        onClicked: (_) => onPrevious?.call(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Show Music FSE',
        onClicked: (_) => _handleShowWindow(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit',
        onClicked: (_) => onQuit?.call(),
      ),
    ]);
    await _systemTray.setContextMenu(menu);
  }

  // -------------------------------------------------------------------------
  // Updates
  // -------------------------------------------------------------------------

  /// Updates the tray tooltip to show the currently playing track.
  ///
  /// Pass `null` to reset to the default app name tooltip.
  void updateTooltip(String? trackDescription) {
    if (!_initialized) return;
    try {
      _systemTray.setToolTip(trackDescription ?? 'Music FSE');
    } catch (e) {
      AppLogger.warn(
        'SystemTrayHandler: setToolTip failed',
        tag: 'SystemTrayHandler',
        error: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Cleanup
  // -------------------------------------------------------------------------

  void dispose() {
    if (!_initialized) return;
    try {
      _systemTray.destroy();
    } catch (e) {
      AppLogger.warn(
        'SystemTrayHandler: destroy failed',
        tag: 'SystemTrayHandler',
        error: e,
      );
    }
    _initialized = false;
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  void _handleShowWindow() {
    _appWindow.show();
    onShowWindow?.call();
  }

  /// Returns the platform-appropriate icon asset path.
  String _platformIconPath() {
    if (Platform.isWindows) {
      return 'assets/branding/icon/app_icon.ico';
    }
    // macOS and Linux use PNG.
    return 'assets/branding/icon/app_icon.png';
  }
}
