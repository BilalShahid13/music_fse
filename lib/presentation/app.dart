import 'dart:async' show Future, unawaited;
import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/app_enums.dart';
import '../core/constants/app_sizes.dart';
import '../core/errors/result.dart';
import '../core/localization/generated/app_localizations.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/logger.dart';
import '../domain/entities/song.dart';
import '../platform/file_association/file_association_handler.dart';
import '../platform/keyboard/keyboard_gamepad_emulator.dart';
import 'providers/input_mode_provider.dart';
import 'providers/home_provider.dart';
import 'providers/library_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/nav_sound_provider.dart';
import 'providers/platform_providers.dart';
import 'providers/playback_provider.dart';
import 'providers/repository_providers.dart';
import 'providers/theme_provider.dart';
import 'providers/use_case_providers.dart';
import 'widgets/focus_highlight.dart';
import 'widgets/toast_notification.dart';
import 'widgets/volume_osd.dart';

/// Root widget for Music FSE.
///
/// Responsibilities:
///   - Builds the [MaterialApp.router] with user-chosen theme, locale,
///     and the [GoRouter] from [appRouterProvider].
///   - Observes the app lifecycle to pause/resume XInput polling when the
///     app is backgrounded (battery / CPU saving on handheld gaming PCs).
///   - Lazily initialises platform services (SMTC, system tray, XInput)
///     by simply reading their keepAlive providers once on startup.
///   - Injects global non-focusable overlays (toast notifications, volume OSD)
///     above the routed content via [MaterialApp.router]'s `builder`.
class MusicFseApp extends ConsumerStatefulWidget {
  const MusicFseApp({super.key});

  @override
  ConsumerState<MusicFseApp> createState() => _MusicFseAppState();
}

class _MusicFseAppState extends ConsumerState<MusicFseApp>
    with WidgetsBindingObserver, WindowListener {
  FileAssociationHandler? _fileAssociationHandler;
  Future<void> _pendingFileAssociationWork = Future<void>.value();

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_handleRawKeyForInputMode);
    if (Platform.isWindows) {
      windowManager.addListener(this);
    }

    // Trigger lazy init of platform services after the first frame so that
    // BuildContext and Riverpod containers are fully ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPlatformServices());
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleRawKeyForInputMode);
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isWindows) {
      windowManager.removeListener(this);
    }
    final handler = _fileAssociationHandler;
    _fileAssociationHandler = null;
    if (handler != null) {
      unawaited(handler.dispose());
    }
    super.dispose();
  }

  /// Global key handler for input-mode detection.
  /// Uses [HardwareKeyboard] so it fires even when no widget has focus
  /// (e.g. after a mouse click on an empty area).
  /// Returns false so the event continues propagating normally.
  bool _handleRawKeyForInputMode(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowDown ||
          key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.tab ||
          key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.escape ||
          key == LogicalKeyboardKey.gameButtonA ||
          key == LogicalKeyboardKey.gameButtonB ||
          key == LogicalKeyboardKey.gameButtonX ||
          key == LogicalKeyboardKey.gameButtonY ||
          key == LogicalKeyboardKey.gameButtonLeft1 ||
          key == LogicalKeyboardKey.gameButtonRight1 ||
          key == LogicalKeyboardKey.gameButtonLeft2 ||
          key == LogicalKeyboardKey.gameButtonRight2 ||
          key == LogicalKeyboardKey.gameButtonStart ||
          key == LogicalKeyboardKey.keyA ||
          key == LogicalKeyboardKey.keyB ||
          key == LogicalKeyboardKey.keyX ||
          key == LogicalKeyboardKey.keyY ||
          key == LogicalKeyboardKey.keyQ ||
          key == LogicalKeyboardKey.keyE ||
          key == LogicalKeyboardKey.keyP) {
        ref.read(inputModeProvider.notifier).onKeyboardInput();
      }
    }
    return false; // Never consume — let events propagate normally.
  }

  // -------------------------------------------------------------------------
  // App lifecycle → XInput polling
  // -------------------------------------------------------------------------

  void _stopXInputPolling() {
    suppressNextNavigateSound();
    if (Platform.isWindows) {
      ref.read(xInputControllerProvider.notifier).stop();
    }
  }

  void _startXInputPolling() {
    suppressNextNavigateSound();
    if (Platform.isWindows) {
      ref.read(xInputControllerProvider.notifier).start();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _stopXInputPolling();
      case AppLifecycleState.resumed:
        _startXInputPolling();
      case AppLifecycleState.inactive:
        // Transitional state (e.g. app switcher visible) — keep polling.
        suppressNextNavigateSound();
        break;
    }
  }

  @override
  void onWindowBlur() {
    _stopXInputPolling();
  }

  @override
  void onWindowFocus() {
    _startXInputPolling();
  }

  @override
  void onWindowMinimize() {
    _stopXInputPolling();
  }

  @override
  void onWindowRestore() {
    _startXInputPolling();
  }

  // -------------------------------------------------------------------------
  // Platform service init
  // -------------------------------------------------------------------------

  /// Reading a keepAlive provider is enough to construct it.
  /// All three providers self-initialise in their [build] methods.
  void _initPlatformServices() {
    // UI navigation sounds.
    ref.read(navSoundPlayerProvider);

    // SMTC (Windows media transport controls — safe no-op on macOS/Linux).
    ref.read(smtcHandlerProvider);

    // System tray icon (safe no-op if system_tray unsupported).
    ref.read(systemTrayHandlerProvider);

    // XInput gamepad controller (Windows only; does nothing on other platforms).
    if (Platform.isWindows) {
      ref.read(xInputControllerProvider);
    }

    unawaited(_initFileAssociationHandler());
  }

  Future<void> _initFileAssociationHandler() async {
    final handler = FileAssociationHandler.create();
    _fileAssociationHandler = handler;
    handler.onFileRequested = (filePath) {
      _pendingFileAssociationWork = _pendingFileAssociationWork.then(
        (_) => _handleAssociatedFile(filePath),
      );
    };

    await handler.initialize();
    await handler.checkLaunchArguments();
  }

  Future<void> _handleAssociatedFile(String filePath) async {
    final normalizedPath = File(filePath).absolute.path;
    final sourceFile = File(normalizedPath);

    if (!await sourceFile.exists()) {
      AppLogger.warn(
        'FileAssociation: requested file does not exist: $normalizedPath',
        tag: 'FileAssociation',
      );
      return;
    }

    final song = await _resolveAssociatedSong(normalizedPath);
    if (song == null) {
      AppLogger.warn(
        'FileAssociation: unable to resolve song for $normalizedPath',
        tag: 'FileAssociation',
      );
      return;
    }

    await ref.read(playbackProvider.notifier).playSong(song);
  }

  Future<Song?> _resolveAssociatedSong(String filePath) async {
    final repository = ref.read(songRepositoryProvider);

    Song? readSongResult(Result<Song> result) => result.when(
          success: (song) => song,
          failure: (_) => null,
        );

    var song = readSongResult(await repository.getSongByPath(filePath));
    if (song != null) return song;

    final scanUseCase = await ref.read(scanLibraryProvider.future);
    await scanUseCase.scanFiles([filePath]).drain<void>();
    _refreshLibraryAfterAssociatedImport();

    song = readSongResult(await repository.getSongByPath(filePath));
    return song;
  }

  void _refreshLibraryAfterAssociatedImport() {
    ref.invalidate(songsProvider);
    ref.invalidate(albumsProvider);
    ref.invalidate(artistsProvider);
    ref.invalidate(genresProvider);
    ref.invalidate(recentlyPlayedProvider);
    ref.invalidate(mostPlayedProvider);
    ref.invalidate(recentlyAddedProvider);
    ref.invalidate(libraryStatsProvider);
    ref.invalidate(recommendationsProvider);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return Listener(
      onPointerHover: (_) => ref.read(inputModeProvider.notifier).onMouseMove(),
      onPointerDown: (_) => ref.read(inputModeProvider.notifier).onMouseMove(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tier = constraints.maxHeight < AppSizes.compactBreakpoint ? DensityTier.compact : DensityTier.standard;

          return AppSizes(
            tier: tier,
            scale: themeState.uiScale,
            child: MaterialApp.router(
              title: AppConstants.appTitle,
              debugShowCheckedModeBanner: false,

              // ── Theming ───────────────────────────────────────────────────────────
              theme: AppTheme.buildTheme(
                accentColor: themeState.accentColor,
                accentTextColor: themeState.accentTextColor,
                appFont: themeState.appFont,
                brightness: Brightness.light,
                uiScale: themeState.uiScale,
              ),
              darkTheme: AppTheme.buildTheme(
                accentColor: themeState.accentColor,
                accentTextColor: themeState.accentTextColor,
                appFont: themeState.appFont,
                brightness: Brightness.dark,
                uiScale: themeState.uiScale,
              ),
              themeMode: switch (themeState.mode) {
                ThemeModeSetting.dark => ThemeMode.dark,
                ThemeModeSetting.light => ThemeMode.light,
                ThemeModeSetting.system => ThemeMode.system,
              },

              // ── Localisation ──────────────────────────────────────────────────────
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,

              // ── Routing ───────────────────────────────────────────────────────────
              routerConfig: router,

              // ── Global overlays ───────────────────────────────────────────────────
              // Toast notifications and the volume OSD sit above the routed content.
              // Both widgets position themselves via Positioned and must be direct
              // children of a Stack. Neither widget ever captures focus.
              builder: (context, child) {
                Widget content = Stack(
                  children: [
                    child!,
                    const ToastNotificationOverlay(),
                    const VolumeOsd(),
                  ],
                );
                // On non-Windows platforms, enable keyboard→gamepad
                // emulation so the app can be tested without a controller.
                if (!Platform.isWindows) {
                  content = KeyboardGamepadEmulator(child: content);
                }
                return content;
              },
            ),
          );
        },
      ),
    );
  }
}
