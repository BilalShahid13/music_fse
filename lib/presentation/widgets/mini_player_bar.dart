import 'dart:io';

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/playback_state.dart';
import '../providers/playback_provider.dart';
import 'art_placeholder.dart';
import 'focus_highlight.dart';
import 'marquee_text.dart';
import 'mini_player_popup_registry.dart';

/// Persistent mini player bar shown at the bottom of the shell when a song is
/// loaded.
///
/// Spec (REQUIREMENTS §6.3 / mockup):
/// - Height: 84px
/// - Background: bgSurface with top border 1px borderSubtle
/// - 3-column layout: left (240px fixed) | center (flex) | right (140px fixed)
/// - Left: album art (48×48 r12) + title (13sp semibold) + artist (11sp)
/// - Center: shuffle | prev | play/pause circle (34px accent) | next | repeat
///   + progress bar with remaining time indicator (negative format)
/// - Right: volume icon + mini slider (optional)
///
/// Gamepad: Play/Pause button receives default focus. A toggles play/pause.
/// D-pad left/right moves focus between controls. LB = prev, RB = next (global
/// — handled in the shell via XInput, not here).
///
/// Tapping album art or song title → navigates to Now Playing (caller must
/// wire [onOpenNowPlaying]).
class MiniPlayerBar extends ConsumerStatefulWidget {
  const MiniPlayerBar({super.key, this.onOpenNowPlaying});

  /// Called when the user taps the album art or song title.
  final VoidCallback? onOpenNowPlaying;

  @override
  ConsumerState<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends ConsumerState<MiniPlayerBar> {
  final FocusNode _shuffleFocus = FocusNode();
  final FocusNode _prevFocus = FocusNode();
  final FocusNode _playFocus = FocusNode();
  final FocusNode _nextFocus = FocusNode();
  final FocusNode _repeatFocus = FocusNode();
  final FocusNode _seekFocus = FocusNode(debugLabel: 'MiniPlayer-seekBar');
  final FocusNode _volumeFocus = FocusNode();
  final FocusNode _openNowPlayingFocus = FocusNode();

  @override
  void dispose() {
    _shuffleFocus.dispose();
    _prevFocus.dispose();
    _playFocus.dispose();
    _nextFocus.dispose();
    _repeatFocus.dispose();
    _seekFocus.dispose();
    _volumeFocus.dispose();
    _openNowPlayingFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(playbackProvider.select((s) => s.currentSong));

    if (currentSong == null) return const SizedBox.shrink();

    final ext = context.appTheme;
    final sizes = AppSizes.of(context);
    final compact = sizes.isCompact;

    return Container(
      height: sizes.miniPlayerHeight,
      decoration: BoxDecoration(
        color: ext.bgSurface,
        border: Border(top: BorderSide(color: ext.borderSubtle)),
      ),
      child: Row(
        children: [
          // ── Left column ──────────────────────────────────────────────────
          SizedBox(
            width: compact ? 220.0 : 240.0,
            child: _LeftColumn(
              song: currentSong,
              onTap: widget.onOpenNowPlaying,
            ),
          ),
          // ── Center column ─────────────────────────────────────────────
          Expanded(
            child: _CenterColumn(
              shuffleFocus: _shuffleFocus,
              prevFocus: _prevFocus,
              playFocus: _playFocus,
              nextFocus: _nextFocus,
              repeatFocus: _repeatFocus,
              seekFocus: _seekFocus,
              onShuffleKeyEvent: _horizontalKeyHandler(right: _prevFocus),
              onPrevKeyEvent: _horizontalKeyHandler(left: _shuffleFocus, right: _playFocus),
              onPlayKeyEvent: _horizontalKeyHandler(left: _prevFocus, right: _nextFocus),
              onNextKeyEvent: _horizontalKeyHandler(left: _playFocus, right: _repeatFocus),
              onRepeatKeyEvent: _horizontalKeyHandler(left: _nextFocus, right: _volumeFocus),
            ),
          ),
          // ── Right column (same width as left for centering) ───────────
          SizedBox(
            width: compact ? 220.0 : 240.0,
            child: _RightActions(
              volumeFocus: _volumeFocus,
              openNowPlayingFocus: _openNowPlayingFocus,
              onOpenNowPlaying: widget.onOpenNowPlaying,
              onVolumeKeyEvent: _horizontalKeyHandler(left: _repeatFocus, right: _openNowPlayingFocus),
              onOpenNowPlayingKeyEvent: _horizontalKeyHandler(left: _volumeFocus),
            ),
          ),
        ],
      ),
    );
  }

  FocusOnKeyEventCallback _horizontalKeyHandler({
    FocusNode? left,
    FocusNode? right,
  }) {
    return (_, event) {
      if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
        return KeyEventResult.ignored;
      }

      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowLeft) {
        if (left != null) {
          left.requestFocus();
        }
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        if (right != null) {
          right.requestFocus();
        }
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    };
  }
}

// =============================================================================
// Left column — art + title + artist
// =============================================================================

class _LeftColumn extends StatelessWidget {
  const _LeftColumn({required this.song, this.onTap});

  final dynamic song; // Song entity
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    final compact = sizes.isCompact;
    final artSize = sizes.miniPlayerArtSize;

    Widget artWidget;
    final artPath = song.artCachePath as String?;
    if (artPath != null) {
      artWidget = Image.file(
        File(artPath),
        width: artSize,
        height: artSize,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ArtPlaceholder(size: artSize),
      );
    } else {
      artWidget = ArtPlaceholder(size: artSize);
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 12.0 : 16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
              child: artWidget,
            ),
            SizedBox(width: compact ? 10.0 : 14.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarqueeText(
                    text: song.title as String,
                    style: tt.labelMedium!.copyWith(
                      color: ext.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 12.0 : 13.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist as String,
                    style: tt.labelSmall?.copyWith(
                      color: ext.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Center column — controls + progress bar
// =============================================================================

class _CenterColumn extends ConsumerWidget {
  const _CenterColumn({
    required this.shuffleFocus,
    required this.prevFocus,
    required this.playFocus,
    required this.nextFocus,
    required this.repeatFocus,
    required this.seekFocus,
    required this.onShuffleKeyEvent,
    required this.onPrevKeyEvent,
    required this.onPlayKeyEvent,
    required this.onNextKeyEvent,
    required this.onRepeatKeyEvent,
  });

  final FocusNode shuffleFocus;
  final FocusNode prevFocus;
  final FocusNode playFocus;
  final FocusNode nextFocus;
  final FocusNode repeatFocus;
  final FocusNode seekFocus;
  final FocusOnKeyEventCallback onShuffleKeyEvent;
  final FocusOnKeyEventCallback onPrevKeyEvent;
  final FocusOnKeyEventCallback onPlayKeyEvent;
  final FocusOnKeyEventCallback onNextKeyEvent;
  final FocusOnKeyEventCallback onRepeatKeyEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));
    final isShuffle = ref.watch(playbackProvider.select((s) => s.isShuffle));
    final repeatMode = ref.watch(playbackProvider.select((s) => s.repeatMode));
    final position = ref.watch(playbackProvider.select((s) => s.position));
    final duration = ref.watch(playbackProvider.select((s) => s.duration));

    final notifier = ref.read(playbackProvider.notifier);
    final compact = AppSizes.of(context).isCompact;
    final controlSize = compact ? 18.0 : 20.0;
    final outerGap = compact ? 12.0 : 16.0;
    final innerGap = compact ? 8.0 : 12.0;
    final controlsProgressGap = compact ? 0.0 : 2.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shuffle
              _ControlButton(
                focusNode: shuffleFocus,
                icon: LucideIcons.shuffle,
                isActive: isShuffle,
                size: controlSize,
                onPressed: notifier.toggleShuffle,
                onKeyEvent: onShuffleKeyEvent,
              ),
              SizedBox(width: outerGap),
              // Previous
              _ControlButton(
                focusNode: prevFocus,
                icon: LucideIcons.skipBack,
                size: controlSize,
                onPressed: notifier.skipPrevious,
                onKeyEvent: onPrevKeyEvent,
              ),
              SizedBox(width: innerGap),
              // Play / Pause (primary button — larger, accent circle)
              _PlayPauseButton(
                focusNode: playFocus,
                isPlaying: isPlaying,
                onPressed: notifier.togglePlayPause,
                onKeyEvent: onPlayKeyEvent,
              ),
              SizedBox(width: innerGap),
              // Next
              _ControlButton(
                focusNode: nextFocus,
                icon: LucideIcons.skipForward,
                size: controlSize,
                onPressed: notifier.skipNext,
                onKeyEvent: onNextKeyEvent,
              ),
              SizedBox(width: outerGap),
              // Repeat
              _RepeatButton(
                focusNode: repeatFocus,
                repeatMode: repeatMode,
                onPressed: notifier.cycleRepeatMode,
                onKeyEvent: onRepeatKeyEvent,
              ),
            ],
          ),
          SizedBox(height: controlsProgressGap),
          // Progress bar + time labels
          _ProgressSection(
            seekFocus: seekFocus,
            position: position,
            duration: duration,
            onSeek: notifier.seek,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Right column — volume icon (with popup) + open Now Playing
// =============================================================================

class _RightActions extends ConsumerWidget {
  const _RightActions({
    required this.volumeFocus,
    required this.openNowPlayingFocus,
    this.onOpenNowPlaying,
    required this.onVolumeKeyEvent,
    required this.onOpenNowPlayingKeyEvent,
  });

  final FocusNode volumeFocus;
  final FocusNode openNowPlayingFocus;
  final VoidCallback? onOpenNowPlaying;
  final FocusOnKeyEventCallback onVolumeKeyEvent;
  final FocusOnKeyEventCallback onOpenNowPlayingKeyEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(playbackProvider.select((s) => s.volume));
    final isMuted = ref.watch(playbackProvider.select((s) => s.isMuted));

    final ext = context.appTheme;
    final compact = AppSizes.of(context).isCompact;

    final displayVolume = isMuted ? 0.0 : volume;
    final volIcon = displayVolume == 0
        ? LucideIcons.volumeX
        : displayVolume < 0.4
            ? LucideIcons.volume1
            : LucideIcons.volume2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10.0 : 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Volume icon — tap or A button opens volume popup
          _VolumeIconButton(
            focusNode: volumeFocus,
            icon: volIcon,
            onTap: () => _showVolumePopup(context, ref),
            onKeyEvent: onVolumeKeyEvent,
          ),
          SizedBox(width: compact ? 4.0 : 8.0),
          // Open Now Playing
          FocusHighlight(
            focusNode: openNowPlayingFocus,
            borderRadius: 8,
            onPressed: onOpenNowPlaying,
            onKeyEvent: onOpenNowPlayingKeyEvent,
            child: GestureDetector(
              onTap: onOpenNowPlaying,
              child: SizedBox(
                width: AppConstants.minFocusableSize,
                height: AppConstants.minFocusableSize,
                child: Center(
                  child: Icon(
                    LucideIcons.chevronUp,
                    size: compact ? 18.0 : 20.0,
                    color: ext.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVolumePopup(BuildContext context, WidgetRef ref) {
    // Use the volume icon's render box for accurate positioning
    final renderBox = volumeFocus.context?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final position = renderBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _VolumePopup(
        anchorPosition: position,
        anchorSize: renderBox.size,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

// =============================================================================
// Progress section — bar + time labels
// =============================================================================

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.seekFocus,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final FocusNode seekFocus;
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    final total = duration.inMilliseconds > 0 ? duration.inMilliseconds : 1;
    final progress = (position.inMilliseconds / total).clamp(0.0, 1.0);

    final remaining = duration - position;
    final remainingStr = '-${_fmtDuration(remaining)}';
    final posStr = _fmtDuration(position);

    final timeStyle = tt.labelSmall?.copyWith(
      color: ext.textSecondary,
      fontSize: 11,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final compact = AppSizes.of(context).isCompact;
    final hPad = compact ? 14.0 : 18.0;
    final timeGap = compact ? 8.0 : 10.0;
    final barHeight = compact ? 3.0 : 4.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Row(
        children: [
          Text(posStr, style: timeStyle),
          SizedBox(width: timeGap),
          // Seek bar
          Expanded(
            child: _MiniSeekBar(
              focusNode: seekFocus,
              position: position,
              duration: duration,
              progress: progress,
              barHeight: barHeight,
              bgColor: ext.bgInput,
              accent: accent,
              onSeek: onSeek,
            ),
          ),
          SizedBox(width: timeGap),
          Text(remainingStr, style: timeStyle),
        ],
      ),
    );
  }

  static String _fmtDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _MiniSeekBar extends StatefulWidget {
  const _MiniSeekBar({
    required this.focusNode,
    required this.position,
    required this.duration,
    required this.progress,
    required this.barHeight,
    required this.bgColor,
    required this.accent,
    required this.onSeek,
  });

  final FocusNode focusNode;
  final Duration position;
  final Duration duration;
  final double progress;
  final double barHeight;
  final Color bgColor;
  final Color accent;
  final ValueChanged<Duration> onSeek;

  @override
  State<_MiniSeekBar> createState() => _MiniSeekBarState();
}

class _MiniSeekBarState extends State<_MiniSeekBar> {
  DateTime? _lastSeekAt;
  int _seekStreak = 0;
  int _lastDirection = 0;

  void _seekByDirection(int direction) {
    final now = DateTime.now();
    final last = _lastSeekAt;
    final isContinuous = last != null && now.difference(last).inMilliseconds <= 220 && direction == _lastDirection;

    if (isContinuous) {
      _seekStreak += 1;
    } else {
      _seekStreak = 0;
    }

    _lastSeekAt = now;
    _lastDirection = direction;

    final stepMs = _acceleratedStepMs(_seekStreak);
    final totalMs = widget.duration.inMilliseconds;
    if (totalMs <= 0) return;

    final targetMs = (widget.position.inMilliseconds + (direction * stepMs)).clamp(0, totalMs);
    widget.onSeek(Duration(milliseconds: targetMs));
  }

  int _acceleratedStepMs(int streak) {
    if (streak >= 16) return 30000;
    if (streak >= 10) return 20000;
    if (streak >= 5) return 10000;
    return 5000;
  }

  KeyEventResult _onKeyEvent(FocusNode _, KeyEvent event) {
    final key = event.logicalKey;

    if (event is KeyUpEvent) {
      if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.arrowRight) {
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
    final compact = AppSizes.of(context).isCompact;
    final seekHitHeight = compact ? 14.0 : 16.0;

    return LayoutBuilder(
      builder: (_, constraints) {
        return FocusHighlight(
          focusNode: widget.focusNode,
          borderRadius: 8,
          onKeyEvent: _onKeyEvent,
          child: GestureDetector(
            onTapDown: (d) {
              final frac = (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
              widget.onSeek(Duration(milliseconds: (frac * widget.duration.inMilliseconds).round()));
            },
            child: SizedBox(
              width: double.infinity,
              height: seekHitHeight,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    backgroundColor: widget.bgColor,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.accent),
                    minHeight: widget.barHeight,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// Control button (shuffle, prev, next, repeat)
// =============================================================================

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.focusNode,
    required this.icon,
    required this.onPressed,
    this.onKeyEvent,
    this.size = 20,
    this.isActive = false,
  });

  final FocusNode focusNode;
  final IconData icon;
  final VoidCallback onPressed;
  final FocusOnKeyEventCallback? onKeyEvent;
  final double size;
  final bool isActive;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final color = widget.isActive ? accent : ext.textSecondary;

    return FocusHighlight(
      focusNode: widget.focusNode,
      borderRadius: 8,
      onPressed: widget.onPressed,
      onKeyEvent: widget.onKeyEvent,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: SizedBox(
          width: AppConstants.minFocusableSize,
          height: AppConstants.minFocusableSize,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(widget.icon, size: widget.size, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Play/Pause button — accent-filled circle
// =============================================================================

class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({
    required this.focusNode,
    required this.isPlaying,
    required this.onPressed,
    this.onKeyEvent,
  });

  final FocusNode focusNode;
  final bool isPlaying;
  final VoidCallback onPressed;
  final FocusOnKeyEventCallback? onKeyEvent;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);
    final btnSize = sizes.miniPlayerPlayBtnSize;
    final iconSize = sizes.isCompact ? 14.0 : 16.0;

    return FocusHighlight(
      focusNode: widget.focusNode,
      isCircular: true,
      onPressed: widget.onPressed,
      onKeyEvent: widget.onKeyEvent,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              widget.isPlaying ? LucideIcons.pause : LucideIcons.play,
              size: iconSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Repeat button
// =============================================================================

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({
    required this.focusNode,
    required this.repeatMode,
    required this.onPressed,
    this.onKeyEvent,
  });

  final FocusNode focusNode;
  final RepeatMode repeatMode;
  final VoidCallback onPressed;
  final FocusOnKeyEventCallback? onKeyEvent;

  @override
  Widget build(BuildContext context) {
    final isActive = repeatMode != RepeatMode.off;
    final icon = repeatMode == RepeatMode.one ? LucideIcons.repeat1 : LucideIcons.repeat;

    return _ControlButton(
      focusNode: focusNode,
      icon: icon,
      isActive: isActive,
      onPressed: onPressed,
      onKeyEvent: onKeyEvent,
    );
  }
}

// =============================================================================
// Volume icon button — tap to mute, A button opens volume popup
// =============================================================================

class _VolumeIconButton extends StatelessWidget {
  const _VolumeIconButton({
    required this.focusNode,
    required this.icon,
    required this.onTap,
    this.onKeyEvent,
  });

  final FocusNode focusNode;
  final IconData icon;
  final VoidCallback onTap;
  final FocusOnKeyEventCallback? onKeyEvent;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final compact = AppSizes.of(context).isCompact;

    return FocusHighlight(
      focusNode: focusNode,
      borderRadius: 8,
      onPressed: onTap,
      onKeyEvent: onKeyEvent,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: AppConstants.minFocusableSize,
          height: AppConstants.minFocusableSize,
          child: Center(
            child: Icon(
              icon,
              size: compact ? 16.0 : 18.0,
              color: ext.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Volume popup — vertical slider floating above the volume icon
// =============================================================================

class _VolumePopup extends ConsumerStatefulWidget {
  const _VolumePopup({
    required this.anchorPosition,
    required this.anchorSize,
    required this.onDismiss,
  });

  final Offset anchorPosition;
  final Size anchorSize;
  final VoidCallback onDismiss;

  @override
  ConsumerState<_VolumePopup> createState() => _VolumePopupState();
}

class _VolumePopupState extends ConsumerState<_VolumePopup> {
  final FocusNode _popupFocus = FocusNode();
  // Prevents Slider's internal focus from consuming arrow keys.
  final FocusNode _sliderFocus = FocusNode(canRequestFocus: false, skipTraversal: true);

  @override
  void initState() {
    super.initState();
    miniPlayerVolumePopupDismiss.value = widget.onDismiss;
    miniPlayerVolumePopupVisible.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popupFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    miniPlayerVolumePopupVisible.value = false;
    if (identical(miniPlayerVolumePopupDismiss.value, widget.onDismiss)) {
      miniPlayerVolumePopupDismiss.value = null;
    }
    _popupFocus.dispose();
    _sliderFocus.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // B button / Escape dismisses
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.gameButtonB || key == LogicalKeyboardKey.keyB) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }

    // D-pad up/down adjusts volume
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

    // Lock focus inside popup while open.
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.tab) {
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

    // Position above the anchor (right-aligned area)
    const popupWidth = 48.0;
    const popupHeight = 180.0;
    final left = widget.anchorPosition.dx + (widget.anchorSize.width / 2) - (popupWidth / 2);
    final top = widget.anchorPosition.dy - popupHeight - 8;

    return Stack(
      children: [
        // Dismiss barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        // Popup card
        Positioned(
          left: left.clamp(8.0, MediaQuery.sizeOf(context).width - popupWidth - 8),
          top: top.clamp(8.0, double.infinity),
          child: Focus(
            focusNode: _popupFocus,
            onKeyEvent: _handleKey,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: popupWidth,
                height: popupHeight,
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
                    // Percentage label
                    Text(
                      '$pct',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ext.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Vertical slider
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
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
                    // Mute toggle icon
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
