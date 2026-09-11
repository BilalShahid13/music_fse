import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/playback_state.dart';
import '../../../domain/entities/song.dart';
import '../../helpers/active_focus_request.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/playback_provider.dart';
import '../../widgets/art_placeholder.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/focus_hint_registry.dart';
import '../../widgets/gamepad_button_hints.dart';
import '../queue/queue_drawer.dart';

/// Full-screen Now Playing page.
///
/// Route: `/now-playing`
///
/// Layout (horizontal split at 1200px+):
/// ```
/// ┌───────────────────────────────────────────────────────┐
/// │  blurred-art background (full bleed)                  │
/// │  ┌──────────────────────────────┐  ┌────────────────┐│
/// │  │  Art (65% vp, 280–500px)     │  │  Info + ctrls  ││
/// │  └──────────────────────────────┘  └────────────────┘│
/// └───────────────────────────────────────────────────────┘
/// ```
class NowPlayingPage extends ConsumerStatefulWidget {
  const NowPlayingPage({super.key});

  @override
  ConsumerState<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends ConsumerState<NowPlayingPage> {
  bool _showQueue = false;
  bool _showLyrics = false;
  bool _showVolumePopup = false;
  late final FocusNode _playPauseFocus;
  late final FocusNode _seekFocus;
  late final FocusNode _queueFocus;
  late final FocusNode _volumeFocus;
  late final FocusNode _keyListenerFocusNode;
  FocusNode? _queueReturnFocus;
  final LayerLink _volumePopupLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _playPauseFocus = FocusNode(debugLabel: 'NP-playPause');
    _seekFocus = FocusNode(debugLabel: 'NP-seekBar');
    _queueFocus = FocusNode(debugLabel: 'NP-queue');
    _volumeFocus = FocusNode(debugLabel: 'NP-volume');
    _keyListenerFocusNode = FocusNode(debugLabel: 'NowPlayingPage-keyListener')
      ..skipTraversal = true;
    scheduleActiveFocusRequest(state: this, focusNode: _playPauseFocus);
  }

  @override
  void dispose() {
    _playPauseFocus.dispose();
    _seekFocus.dispose();
    _queueFocus.dispose();
    _volumeFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _showNowPlayingVolumePopup() {
    if (_showVolumePopup) return;
    if (_showQueue) {
      _queueReturnFocus = null;
      setState(() {
        _showQueue = false;
        _showVolumePopup = true;
      });
      return;
    }
    setState(() => _showVolumePopup = true);
  }

  void _openQueue() {
    if (_showQueue) return;
    _queueReturnFocus = FocusManager.instance.primaryFocus;
    setState(() => _showQueue = true);
  }

  void _closeQueue({bool restoreFocus = true}) {
    if (!_showQueue) return;

    final returnFocus = _queueReturnFocus;
    _queueReturnFocus = null;
    setState(() => _showQueue = false);

    if (!restoreFocus) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (returnFocus != null &&
          returnFocus.context != null &&
          returnFocus.canRequestFocus) {
        returnFocus.requestFocus();
        return;
      }
      if (_queueFocus.context != null && _queueFocus.canRequestFocus) {
        _queueFocus.requestFocus();
      }
    });
  }

  void _dismissNowPlayingVolumePopup({bool restoreFocus = true}) {
    if (!_showVolumePopup) return;
    setState(() => _showVolumePopup = false);
    if (!restoreFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _volumeFocus.requestFocus();
    });
  }

  void _seekByStep(int deltaMs) {
    final playbackState = ref.read(playbackProvider);
    final totalMs = playbackState.duration.inMilliseconds;
    if (totalMs <= 0) return;

    final targetMs =
        (playbackState.position.inMilliseconds + deltaMs).clamp(0, totalMs);
    ref.read(playbackProvider.notifier).seek(Duration(milliseconds: targetMs));
  }

  void _toggleFavoriteCurrentSong() {
    final song = ref.read(playbackProvider).currentSong;
    if (song == null) return;

    final favorites = ref.read(favoritesProvider()).value ?? const <Song>[];
    final isFavorite = favorites.any((favorite) => favorite.id == song.id);

    ref.read(favoritesProvider().notifier).toggleFavorite(
          song.id,
          isFavorite: isFavorite,
        );
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final notifier = ref.read(playbackProvider.notifier);

    if (_showVolumePopup) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.gameButtonB:
        case LogicalKeyboardKey.keyB:
          _dismissNowPlayingVolumePopup();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.gameButtonStart:
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.gameButtonLeft1:
        case LogicalKeyboardKey.gameButtonRight1:
        case LogicalKeyboardKey.gameButtonY:
        case LogicalKeyboardKey.keyY:
          return KeyEventResult.handled;
      }
    }

    switch (event.logicalKey) {
      // B → back
      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.gameButtonB:
      case LogicalKeyboardKey.keyB:
        if (_showVolumePopup) {
          _dismissNowPlayingVolumePopup();
        } else if (_showQueue) {
          _closeQueue();
        } else {
          context.pop();
        }
        return KeyEventResult.handled;

      // Start → play/pause
      case LogicalKeyboardKey.gameButtonStart:
      case LogicalKeyboardKey.space:
        notifier.togglePlayPause();
        return KeyEventResult.handled;

      // LB → prev
      case LogicalKeyboardKey.gameButtonLeft1:
        notifier.skipPrevious();
        return KeyEventResult.handled;

      // RB → next
      case LogicalKeyboardKey.gameButtonRight1:
        notifier.skipNext();
        return KeyEventResult.handled;

      // Y → favorite current song
      case LogicalKeyboardKey.gameButtonY:
      case LogicalKeyboardKey.keyY:
        if (_showQueue || _showVolumePopup) {
          return KeyEventResult.ignored;
        }
        _toggleFavoriteCurrentSong();
        return KeyEventResult.handled;

      // LT → close now playing
      case LogicalKeyboardKey.gameButtonLeft2:
        if (_showVolumePopup) {
          _dismissNowPlayingVolumePopup(restoreFocus: false);
        }
        context.pop();
        return KeyEventResult.handled;

      // RT → toggle queue
      case LogicalKeyboardKey.gameButtonRight2:
        if (_showVolumePopup) {
          _dismissNowPlayingVolumePopup(restoreFocus: false);
        }
        if (_showQueue) {
          _closeQueue();
        } else {
          _openQueue();
        }
        return KeyEventResult.handled;

      // Right stick horizontal is handled by the seek widget directly.
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);
    final song = playbackState.currentSong;
    final ext = context.appTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final edgeScrim = isDark ? Colors.black : Colors.white;
    final surfaceWash = isDark ? ext.bgSurface : Colors.white;
    final depthWash = isDark ? ext.bgSurface : ext.bgPrimary;

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Stack(
          children: [
            // ── Blurred background ───────────────────────────────────────
            if (song?.artCachePath != null &&
                File(song!.artCachePath!).existsSync())
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Image.file(
                    File(song.artCachePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      edgeScrim.withValues(alpha: isDark ? 0.20 : 0.28),
                      surfaceWash.withValues(alpha: isDark ? 0.48 : 0.54),
                      depthWash.withValues(alpha: isDark ? 0.76 : 0.88),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      surfaceWash.withValues(alpha: isDark ? 0.08 : 0.04),
                      Colors.transparent,
                      surfaceWash.withValues(alpha: isDark ? 0.20 : 0.16),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ExcludeFocus(
                          excluding: _showQueue || _showVolumePopup,
                          child: _NowPlayingContent(
                            playbackState: playbackState,
                            song: song,
                            playPauseFocus: _playPauseFocus,
                            seekFocus: _seekFocus,
                            queueFocus: _queueFocus,
                            volumeFocus: _volumeFocus,
                            volumePopupLink: _volumePopupLink,
                            onToggleQueue: () {
                              if (_showVolumePopup) {
                                _dismissNowPlayingVolumePopup(
                                    restoreFocus: false);
                              }
                              if (_showQueue) {
                                _closeQueue();
                              } else {
                                _openQueue();
                              }
                            },
                            onToggleVolumePopup: _showNowPlayingVolumePopup,
                            showLyrics: _showLyrics,
                            onToggleLyrics: () =>
                                setState(() => _showLyrics = !_showLyrics),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: QueueDrawer(
                          isOpen: _showQueue,
                          onDismiss: _closeQueue,
                        ),
                      ),
                      if (_showVolumePopup)
                        Positioned.fill(
                          child: _NowPlayingVolumePopup(
                            layerLink: _volumePopupLink,
                            onDismiss: _dismissNowPlayingVolumePopup,
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Gamepad button hints ────────────────────────────────
                ValueListenableBuilder<QueuePanelHintState?>(
                  valueListenable: queuePanelHintState,
                  builder: (context, queueHints, _) {
                    if (_showQueue && queueHints != null) {
                      return GamepadButtonHints(
                        aLabel: queueHints.aLabel,
                        bLabel: queueHints.bLabel,
                        xLabel: queueHints.xLabel,
                        yLabel: queueHints.yLabel,
                        upLabel: queueHints.upLabel,
                        downLabel: queueHints.downLabel,
                        onAPressed: queueHints.onAPressed,
                        onBPressed: queueHints.onBPressed,
                        onXPressed: queueHints.onXPressed,
                        onYPressed: queueHints.onYPressed,
                        onUpPressed: queueHints.onUpPressed,
                        onDownPressed: queueHints.onDownPressed,
                        backgroundColor: context.appTheme.bgSurface,
                      );
                    }

                    if (_showVolumePopup) {
                      final notifier = ref.read(playbackProvider.notifier);
                      final current =
                          ref.read(playbackProvider.select((s) => s.volume));
                      final l10n = AppLocalizations.of(context)!;
                      return GamepadButtonHints(
                        bLabel: l10n.hintClose,
                        upLabel: l10n.hintVolumeUp,
                        downLabel: l10n.hintVolumeDown,
                        onBPressed: _dismissNowPlayingVolumePopup,
                        onUpPressed: () => notifier
                            .setVolume((current + 0.05).clamp(0.0, 1.0)),
                        onDownPressed: () => notifier
                            .setVolume((current - 0.05).clamp(0.0, 1.0)),
                        backgroundColor: context.appTheme.bgSurface,
                      );
                    }

                    return ValueListenableBuilder<FocusHintCapabilities?>(
                      valueListenable: focusedHintCapabilities,
                      builder: (context, focusedCaps, _) {
                        final l10n = AppLocalizations.of(context)!;
                        final isSeekFocused =
                            identical(focusedCaps?.node, _seekFocus);
                        final hasPrimaryAction = focusedCaps?.supportsA == true;
                        final isPlayFocused =
                            identical(focusedCaps?.node, _playPauseFocus);
                        return GamepadButtonHints(
                          aLabel: hasPrimaryAction
                              ? (isPlayFocused
                                  ? l10n.hintPlay
                                  : l10n.hintSelect)
                              : null,
                          bLabel: l10n.hintBack,
                          yLabel: song != null ? l10n.hintFavorite : null,
                          leftLabel: isSeekFocused ? 'Rewind' : null,
                          rightLabel: isSeekFocused ? 'Forward' : null,
                          lbLabel: l10n.hintPrevTrack,
                          rbLabel: l10n.hintNextTrack,
                          onAPressed:
                              hasPrimaryAction ? focusedCaps?.onA : null,
                          onBPressed: () => context.pop(),
                          onYPressed:
                              song != null ? _toggleFavoriteCurrentSong : null,
                          onLeftPressed: isSeekFocused
                              ? () => _seekByStep(-AppConstants.seekStepMs)
                              : null,
                          onRightPressed: isSeekFocused
                              ? () => _seekByStep(AppConstants.seekStepMs)
                              : null,
                          onLbPressed: () => ref
                              .read(playbackProvider.notifier)
                              .skipPrevious(),
                          onRbPressed: () =>
                              ref.read(playbackProvider.notifier).skipNext(),
                          backgroundColor: context.appTheme.bgSurface,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main content (split: art | info + controls)
// ---------------------------------------------------------------------------

class _NowPlayingContent extends ConsumerWidget {
  const _NowPlayingContent({
    required this.playbackState,
    required this.song,
    required this.playPauseFocus,
    required this.seekFocus,
    required this.queueFocus,
    required this.volumeFocus,
    required this.volumePopupLink,
    required this.onToggleQueue,
    required this.onToggleVolumePopup,
    required this.showLyrics,
    required this.onToggleLyrics,
  });

  final PlaybackState playbackState;
  final Song? song;
  final FocusNode playPauseFocus;
  final FocusNode seekFocus;
  final FocusNode queueFocus;
  final FocusNode volumeFocus;
  final LayerLink volumePopupLink;
  final VoidCallback onToggleQueue;
  final VoidCallback onToggleVolumePopup;
  final bool showLyrics;
  final VoidCallback onToggleLyrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= AppConstants.layoutBreakpoint;
    final sizes = AppSizes.of(context);
    final wideColumnPadding = sizes.isCompact ? 24.0 : 32.0;
    final wideRightPadding = wideColumnPadding + 36.0;

    if (isWide) {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: wideColumnPadding),
              child: Center(
                child: showLyrics
                    ? _LyricsPlaceholder(onToggle: onToggleLyrics)
                    : _AlbumArt(song: song),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: _Controls(
              playbackState: playbackState,
              song: song,
              playPauseFocus: playPauseFocus,
              seekFocus: seekFocus,
              queueFocus: queueFocus,
              volumeFocus: volumeFocus,
              volumePopupLink: volumePopupLink,
              onToggleQueue: onToggleQueue,
              onToggleVolumePopup: onToggleVolumePopup,
              onToggleLyrics: onToggleLyrics,
              showLyrics: showLyrics,
              contentPadding: EdgeInsets.fromLTRB(
                wideColumnPadding,
                wideColumnPadding,
                wideRightPadding,
                wideColumnPadding,
              ),
            ),
          ),
        ],
      );
    }

    // Compact width: keep horizontal composition and move album art inline
    // with the metadata block so controls retain their sizing.
    return Row(
      children: [
        Expanded(
          flex: showLyrics ? 6 : 1,
          child: _Controls(
            playbackState: playbackState,
            song: song,
            playPauseFocus: playPauseFocus,
            seekFocus: seekFocus,
            queueFocus: queueFocus,
            volumeFocus: volumeFocus,
            volumePopupLink: volumePopupLink,
            onToggleQueue: onToggleQueue,
            onToggleVolumePopup: onToggleVolumePopup,
            onToggleLyrics: onToggleLyrics,
            showLyrics: showLyrics,
            compactInlineArtwork: !showLyrics,
          ),
        ),
        if (showLyrics)
          Expanded(
            flex: 4,
            child: Center(
              child: _LyricsPlaceholder(onToggle: onToggleLyrics),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Album art
// ---------------------------------------------------------------------------

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.song, this.sizeOverride});
  final Song? song;
  final double? sizeOverride;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.of(context).size.width;
    final sizes = AppSizes.of(context);
    final artSize = sizeOverride ??
        (viewportWidth * sizes.nowPlayingArtViewportFraction).clamp(
          sizes.nowPlayingArtMinSize,
          sizes.nowPlayingArtMaxSize,
        );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: AppConstants.artCrossfadeMs),
      child: ClipRRect(
        key: ValueKey(song?.artCachePath),
        borderRadius: BorderRadius.circular(sizes.cardRadius),
        child: SizedBox(
          width: artSize,
          height: artSize,
          child: song?.artCachePath != null &&
                  File(song!.artCachePath!).existsSync()
              ? Image.file(File(song!.artCachePath!), fit: BoxFit.cover)
              : ArtPlaceholder(
                  size: artSize,
                  iconSize: (artSize * 0.3).clamp(72.0, 180.0),
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lyrics placeholder
// ---------------------------------------------------------------------------

class _LyricsPlaceholder extends StatelessWidget {
  const _LyricsPlaceholder({required this.onToggle});
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ext = context.appTheme;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.mic, size: 48, color: ext.textTertiary),
          const SizedBox(height: 16),
          Text(
            l10n.lyricsComingSoon,
            style: tt.bodyLarge?.copyWith(color: ext.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.lyricsComingSoonDesc,
            style: tt.bodySmall?.copyWith(color: ext.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Controls panel
// ---------------------------------------------------------------------------

class _Controls extends ConsumerWidget {
  const _Controls({
    required this.playbackState,
    required this.song,
    required this.playPauseFocus,
    required this.seekFocus,
    required this.queueFocus,
    required this.volumeFocus,
    required this.volumePopupLink,
    required this.onToggleQueue,
    required this.onToggleVolumePopup,
    required this.onToggleLyrics,
    required this.showLyrics,
    this.compactInlineArtwork = false,
    this.contentPadding,
  });

  final PlaybackState playbackState;
  final Song? song;
  final FocusNode playPauseFocus;
  final FocusNode seekFocus;
  final FocusNode queueFocus;
  final FocusNode volumeFocus;
  final LayerLink volumePopupLink;
  final VoidCallback onToggleQueue;
  final VoidCallback onToggleVolumePopup;
  final VoidCallback onToggleLyrics;
  final bool showLyrics;
  final bool compactInlineArtwork;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final notifier = ref.read(playbackProvider.notifier);
    final favorites = ref.watch(favoritesProvider());
    final isFav = favorites.value?.any((s) => s.id == song?.id) ?? false;

    final compact = AppSizes.of(context).isCompact;
    final panelPad = compact ? 24.0 : 32.0;
    final titleCtrlGap = compact ? 24.0 : 32.0;
    final ctrlSecGap = compact ? 16.0 : 24.0;
    final outerGap = compact ? 16.0 : 20.0;
    final innerGap = compact ? 12.0 : 16.0;

    return Padding(
      padding: contentPadding ?? EdgeInsets.all(panelPad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compactInlineArtwork)
            LayoutBuilder(
              builder: (context, constraints) {
                final compactArtSize =
                    (constraints.maxWidth * 0.22).clamp(96.0, 150.0);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AlbumArt(
                      song: song,
                      sizeOverride: compactArtSize,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _NowPlayingMeta(
                        song: song,
                        titleStyle: tt.headlineSmall,
                        subtitleStyle: tt.bodyMedium,
                        albumStyle: tt.bodySmall,
                      ),
                    ),
                  ],
                );
              },
            )
          else
            _NowPlayingMeta(
              song: song,
              titleStyle: tt.headlineMedium,
              subtitleStyle: tt.bodyLarge,
              albumStyle: tt.bodySmall,
            ),
          SizedBox(height: titleCtrlGap),

          // Progress bar
          _SeekBar(
            focusNode: seekFocus,
            position: playbackState.position,
            duration: playbackState.duration,
            onSeek: notifier.seek,
          ),
          SizedBox(height: ctrlSecGap),

          // Primary controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shuffle
              _ControlBtn(
                icon: LucideIcons.shuffle,
                size: 20,
                isActive: playbackState.isShuffle,
                onTap: notifier.toggleShuffle,
              ),
              SizedBox(width: outerGap),
              // Skip previous
              _ControlBtn(
                icon: LucideIcons.skipBack,
                size: 28,
                onTap: notifier.skipPrevious,
              ),
              SizedBox(width: innerGap),
              // Play / Pause (primary)
              _PlayPauseBtn(
                focusNode: playPauseFocus,
                isPlaying: playbackState.isPlaying,
                onTap: notifier.togglePlayPause,
              ),
              SizedBox(width: innerGap),
              // Skip next
              _ControlBtn(
                icon: LucideIcons.skipForward,
                size: 28,
                onTap: notifier.skipNext,
              ),
              SizedBox(width: outerGap),
              // Repeat
              _RepeatBtn(
                mode: playbackState.repeatMode,
                onTap: notifier.cycleRepeatMode,
              ),
            ],
          ),
          SizedBox(height: ctrlSecGap),

          // Secondary controls row
          Row(
            children: [
              // Favorite
              _ControlBtn(
                icon: LucideIcons.heart,
                fill: isFav ? 1 : 0,
                isActive: isFav,
                size: 20,
                onTap: song == null
                    ? () {}
                    : () => ref
                        .read(favoritesProvider().notifier)
                        .toggleFavorite(song!.id, isFavorite: isFav),
              ),
              const SizedBox(width: 12),
              // Queue toggle
              _ControlBtn(
                focusNode: queueFocus,
                icon: LucideIcons.listMusic,
                size: 20,
                onTap: onToggleQueue,
              ),
              const SizedBox(width: 12),
              // EQ
              _ControlBtn(
                icon: LucideIcons.chartBar,
                size: 20,
                onTap: () => context.push('/equalizer'),
              ),
              const SizedBox(width: 12),
              // Lyrics toggle
              _ControlBtn(
                icon: LucideIcons.fileText,
                size: 20,
                isActive: showLyrics,
                onTap: onToggleLyrics,
              ),
              const Spacer(),
              // Volume
              _VolumePopupTrigger(
                volume: playbackState.volume,
                isMuted: playbackState.isMuted,
                focusNode: volumeFocus,
                layerLink: volumePopupLink,
                onTap: onToggleVolumePopup,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NowPlayingMeta extends StatelessWidget {
  const _NowPlayingMeta({
    required this.song,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.albumStyle,
  });

  final Song? song;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? albumStyle;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song?.title ?? 'Not Playing',
          style: titleStyle?.copyWith(
            color: ext.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          song?.artist ?? '',
          style: subtitleStyle?.copyWith(color: ext.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (song?.album.isNotEmpty ?? false) ...[
          const SizedBox(height: 2),
          Text(
            song!.album,
            style: albumStyle?.copyWith(color: ext.textTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Seek bar
// ---------------------------------------------------------------------------

class _SeekBar extends StatefulWidget {
  const _SeekBar({
    required this.focusNode,
    required this.position,
    required this.duration,
    required this.onSeek,
  });
  final FocusNode focusNode;
  final Duration position;
  final Duration duration;
  final void Function(Duration) onSeek;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;
  // Prevents Slider's internal focus from consuming arrow keys.
  final _sliderFocus = FocusNode(canRequestFocus: false, skipTraversal: true);
  DateTime? _lastSeekAt;
  int _seekStreak = 0;
  int _lastDirection = 0;

  @override
  void dispose() {
    _sliderFocus.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  void _seekByDirection(int direction) {
    final now = DateTime.now();
    final last = _lastSeekAt;
    final isContinuous = last != null &&
        now.difference(last).inMilliseconds <= 220 &&
        direction == _lastDirection;

    if (isContinuous) {
      _seekStreak += 1;
    } else {
      _seekStreak = 0;
    }

    _lastSeekAt = now;
    _lastDirection = direction;

    final totalMs = widget.duration.inMilliseconds;
    if (totalMs <= 0) return;

    final stepMs = _acceleratedStepMs(_seekStreak);
    final currentMs =
        (_dragValue ?? widget.position.inMilliseconds.toDouble()).round();
    final targetMs = (currentMs + (direction * stepMs)).clamp(0, totalMs);
    widget.onSeek(Duration(milliseconds: targetMs));
  }

  int _acceleratedStepMs(int streak) {
    if (streak >= 16) return 30000;
    if (streak >= 10) return 20000;
    if (streak >= 5) return 10000;
    return AppConstants.seekStepMs;
  }

  KeyEventResult _onKeyEvent(FocusNode _, KeyEvent event) {
    final key = event.logicalKey;

    if (event is KeyUpEvent) {
      if (key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowRight) {
        _seekStreak = 0;
        _lastDirection = 0;
      }
      return KeyEventResult.ignored;
    }

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      _seekByDirection(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _seekByDirection(1);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final cs = Theme.of(context).colorScheme;
    final total = widget.duration.inMilliseconds.toDouble();
    final current = (_dragValue ?? widget.position.inMilliseconds.toDouble())
        .clamp(0.0, total > 0 ? total : 1.0);

    return FocusHighlight(
      focusNode: widget.focusNode,
      borderRadius: 8,
      onKeyEvent: _onKeyEvent,
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              thumbColor: cs.primary,
              activeTrackColor: cs.primary,
              inactiveTrackColor: ext.textTertiary.withValues(alpha: 0.24),
              overlayColor: cs.primary.withValues(alpha: 0.16),
            ),
            child: Slider(
              min: 0,
              max: total > 0 ? total : 1.0,
              value: current,
              onChanged: (v) => setState(() => _dragValue = v),
              onChangeEnd: (v) {
                setState(() => _dragValue = null);
                widget.onSeek(Duration(milliseconds: v.round()));
              },
              focusNode: _sliderFocus,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(widget.position),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: ext.textSecondary),
                ),
                Text(
                  _formatDuration(widget.duration),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: ext.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Control buttons
// ---------------------------------------------------------------------------

class _ControlBtn extends StatefulWidget {
  const _ControlBtn({
    required this.icon,
    required this.onTap,
    this.size = 22,
    this.isActive = false,
    this.focusNode,
    this.fill = 0,
  });
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool isActive;
  final FocusNode? focusNode;
  final double fill;

  @override
  State<_ControlBtn> createState() => _ControlBtnState();
}

class _ControlBtnState extends State<_ControlBtn> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = context.appTheme;
    return FocusHighlight(
      focusNode: _focus,
      borderRadius: 24,
      onPressed: widget.onTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: AppConstants.minFocusableSize,
          height: AppConstants.minFocusableSize,
          child: Icon(
            widget.icon,
            size: widget.size,
            fill: widget.fill,
            color: widget.isActive ? cs.primary : ext.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PlayPauseBtn extends StatefulWidget {
  const _PlayPauseBtn({
    required this.focusNode,
    required this.isPlaying,
    required this.onTap,
  });
  final FocusNode focusNode;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  State<_PlayPauseBtn> createState() => _PlayPauseBtnState();
}

class _PlayPauseBtnState extends State<_PlayPauseBtn> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentForegroundColor = Theme.of(context)
            .filledButtonTheme
            .style
            ?.foregroundColor
            ?.resolve({WidgetState.focused}) ??
        cs.onPrimary;
    return FocusHighlight(
      focusNode: widget.focusNode,
      borderRadius: 36,
      onPressed: widget.onTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: AppConstants.nowPlayingPlayBtnSize,
          height: AppConstants.nowPlayingPlayBtnSize,
          decoration: BoxDecoration(
            color: cs.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.isPlaying ? LucideIcons.pause : LucideIcons.play,
            size: 26,
            color: accentForegroundColor,
          ),
        ),
      ),
    );
  }
}

class _RepeatBtn extends StatelessWidget {
  const _RepeatBtn({required this.mode, required this.onTap});
  final RepeatMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = context.appTheme;
    final isActive = mode != RepeatMode.off;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppConstants.minFocusableSize,
        height: AppConstants.minFocusableSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              mode == RepeatMode.one ? LucideIcons.repeat1 : LucideIcons.repeat,
              size: 20,
              color: isActive ? cs.primary : ext.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Volume control
// ---------------------------------------------------------------------------

class _VolumePopupTrigger extends StatelessWidget {
  const _VolumePopupTrigger({
    required this.volume,
    required this.isMuted,
    required this.focusNode,
    required this.layerLink,
    required this.onTap,
  });
  final double volume;
  final bool isMuted;
  final FocusNode focusNode;
  final LayerLink layerLink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConstants.minFocusableSize,
      child: CompositedTransformTarget(
        link: layerLink,
        child: _ControlBtn(
          focusNode: focusNode,
          icon: isMuted || volume <= 0
              ? LucideIcons.volumeX
              : LucideIcons.volume2,
          size: 18,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _NowPlayingVolumePopup extends ConsumerStatefulWidget {
  const _NowPlayingVolumePopup({
    required this.layerLink,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final VoidCallback onDismiss;

  @override
  ConsumerState<_NowPlayingVolumePopup> createState() =>
      _NowPlayingVolumePopupState();
}

class _NowPlayingVolumePopupState
    extends ConsumerState<_NowPlayingVolumePopup> {
  final FocusNode _popupFocus = FocusNode(debugLabel: 'NP-volumePopup');
  final FocusNode _sliderFocus =
      FocusNode(canRequestFocus: false, skipTraversal: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _popupFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _popupFocus.dispose();
    _sliderFocus.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.gameButtonB ||
        key == LogicalKeyboardKey.keyB) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }

    final notifier = ref.read(playbackProvider.notifier);
    final current = ref.read(playbackProvider.select((s) => s.volume));
    const step = 0.05;

    if (key == LogicalKeyboardKey.arrowUp) {
      notifier.setVolume((current + step).clamp(0.0, 1.0));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      notifier.setVolume((current - step).clamp(0.0, 1.0));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.tab) {
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final volume = ref.watch(playbackProvider.select((s) => s.volume));
    final isMuted = ref.watch(playbackProvider.select((s) => s.isMuted));
    final notifier = ref.read(playbackProvider.notifier);
    final ext = context.appTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);
    final displayVolume = isMuted ? 0.0 : volume;
    final pct = (displayVolume * 100).round();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        CompositedTransformFollower(
          link: widget.layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -8),
          child: Focus(
            focusNode: _popupFocus,
            onKeyEvent: _handleKey,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 48,
                height: 180,
                decoration: BoxDecoration(
                  color: ext.bgSurface,
                  borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                  border: Border.all(color: ext.borderSubtle),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$pct',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ext.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: SliderComponentShape.noOverlay,
                            activeTrackColor: accent,
                            inactiveTrackColor: ext.bgInput,
                            thumbColor: accent,
                          ),
                          child: Slider(
                            value: displayVolume,
                            onChanged: notifier.setVolume,
                            focusNode: _sliderFocus,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: notifier.toggleMute,
                      child: Icon(
                        isMuted ? LucideIcons.volumeX : LucideIcons.volume2,
                        size: 16,
                        color: isMuted ? accent : ext.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
