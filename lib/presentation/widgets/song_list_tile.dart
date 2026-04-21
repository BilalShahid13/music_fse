import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/song.dart';
import 'art_placeholder.dart';
import 'focus_highlight.dart';
import 'marquee_text.dart';

/// A single song row used in all song list contexts (library, playlist,
/// album detail, queue, favorites, etc.).
///
/// Spec (REQUIREMENTS §6.4 / mockup):
/// - Height: 56px
/// - Horizontal padding: 16px
/// - Album art: 44×44, borderRadius 6px; [ArtPlaceholder] when missing
/// - Title: 14sp textPrimary, 1 line ellipsis
/// - Artist: 12sp textSecondary, 1 line ellipsis
/// - Favorite indicator: Lucide heart (filled accent / outline tertiary)
///   with 200ms scale bounce (1.0→1.3→1.0) on toggle
/// - Duration: 12sp textTertiary, right-aligned
/// - Currently playing: 3px accent left bar, title in accent, animated bars
/// - Track number column (optional): 28px wide, 13sp secondary
/// - Hover: bgCardHover background
///
/// Gamepad:
/// - A button → [onTap]
/// - X button → [onContextMenu]
/// - Y button → [onToggleFavorite]
class SongListTile extends StatefulWidget {
  const SongListTile({
    super.key,
    required this.song,
    this.index,
    this.focusNode,
    this.leading,
    this.isCurrentlyPlaying = false,
    this.isFavorite = false,
    this.onTap,
    this.onContextMenu,
    this.onToggleFavorite,
    this.showArt = true,
    this.showDuration = true,
    this.trailing,
    this.horizontalPadding = AppConstants.songTilePadding,
  });

  final Song song;

  /// When non-null, a track number column is shown to the left.
  final int? index;

  /// Optional external focus node. When omitted, an internal node is created.
  final FocusNode? focusNode;

  /// Optional widget inserted before the track number / artwork region.
  final Widget? leading;

  final bool isCurrentlyPlaying;
  final bool isFavorite;

  final VoidCallback? onTap;
  final VoidCallback? onContextMenu;
  final VoidCallback? onToggleFavorite;

  final bool showArt;
  final bool showDuration;

  /// Horizontal content inset for this row.
  final double horizontalPadding;

  /// Optional widget appended to the right side (e.g. drag handle).
  final Widget? trailing;

  @override
  State<SongListTile> createState() => _SongListTileState();
}

class _SongListTileState extends State<SongListTile> with SingleTickerProviderStateMixin {
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  bool _isHovered = false;

  // Favorite heart bounce animation
  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.favBounceMs),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _handleToggleFavorite() {
    if (widget.onToggleFavorite != null) {
      _heartController.forward(from: 0);
      widget.onToggleFavorite!();
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);

    final bgColor = _isHovered ? ext.bgCardHover : Colors.transparent;

    return FocusHighlight(
      focusNode: _focusNode,
      borderRadius: sizes.cardRadiusSm,
      onPressed: widget.onTap,
      onSecondary: widget.onContextMenu,
      onTertiary: widget.onToggleFavorite,
      showYHint: widget.onToggleFavorite != null,
      child: Focus(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: _handleKey,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            onSecondaryTap: widget.onContextMenu,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              height: AppConstants.listTileHeight,
              padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
              color: bgColor,
              child: Row(
                children: [
                  // Optional left border for currently playing (rounded stroke matching art height)
                  if (widget.isCurrentlyPlaying)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 3,
                        height: AppConstants.songTileArtSize,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),

                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 8),
                  ],

                  // Optional track number
                  if (widget.index != null)
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${widget.index! + 1}',
                        style: tt.bodySmall?.copyWith(color: ext.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Album art
                  if (widget.showArt) ...[
                    ListenableBuilder(
                      listenable: _focusNode,
                      builder: (context, _) {
                        return _ArtThumbnail(
                          artCachePath: widget.song.artCachePath,
                          isPlaying: widget.isCurrentlyPlaying,
                          showFocusedPlayCue: _focusNode.hasFocus && !widget.isCurrentlyPlaying,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Title + artist
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListenableBuilder(
                          listenable: _focusNode,
                          builder: (context, _) {
                            final titleStyle = tt.bodyMedium?.copyWith(
                              color: widget.isCurrentlyPlaying ? accent : ext.textPrimary,
                            );
                            if (titleStyle == null) {
                              return const SizedBox.shrink();
                            }
                            return MarqueeText(
                              text: widget.song.title,
                              style: titleStyle,
                              enabled: _focusNode.hasFocus,
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.song.artist,
                          style: tt.bodySmall?.copyWith(color: ext.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Favorite heart
                  GestureDetector(
                    onTap: _handleToggleFavorite,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ScaleTransition(
                        scale: _heartScale,
                        child: Icon(
                          LucideIcons.heart,
                          size: 16,
                          fill: widget.isFavorite ? 1 : 0,
                          color: widget.isFavorite ? accent : ext.textTertiary,
                        ),
                      ),
                    ),
                  ),

                  // Duration (fixed width to keep heart icon vertically aligned)
                  if (widget.showDuration)
                    SizedBox(
                      width: 48,
                      child: Text(
                        _formatDuration(widget.song.durationMs),
                        style: tt.bodySmall?.copyWith(
                          color: ext.textTertiary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),

                  // Trailing widget (drag handle, etc.)
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 8),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Art thumbnail (44×44 with optional animated equalizer overlay)
// ---------------------------------------------------------------------------

class _ArtThumbnail extends StatelessWidget {
  const _ArtThumbnail({
    required this.artCachePath,
    required this.isPlaying,
    required this.showFocusedPlayCue,
  });

  final String? artCachePath;
  final bool isPlaying;
  final bool showFocusedPlayCue;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    const artSize = AppConstants.songTileArtSize;
    const cueIconSize = artSize * 0.42;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scrimColor = isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.2);

    Widget artWidget;
    if (artCachePath != null) {
      artWidget = Image.file(
        File(artCachePath!),
        width: artSize,
        height: artSize,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ArtPlaceholder(
          size: artSize,
          borderRadius: BorderRadius.circular(6),
          showIcon: !showFocusedPlayCue,
        ),
      );
    } else {
      artWidget = ArtPlaceholder(
        size: artSize,
        borderRadius: BorderRadius.circular(6),
        showIcon: !showFocusedPlayCue,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: artSize,
        height: artSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            artWidget,
            if (isPlaying)
              Container(
                color: scrimColor,
                child: Center(
                  child: _AnimatedEqualizer(color: accent),
                ),
              ),
            if (showFocusedPlayCue)
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: Icon(
                    LucideIcons.play,
                    size: cueIconSize,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3-bar animated equalizer icon for currently playing indicator
// ---------------------------------------------------------------------------

class _AnimatedEqualizer extends StatefulWidget {
  const _AnimatedEqualizer({required this.color});
  final Color color;

  @override
  State<_AnimatedEqualizer> createState() => _AnimatedEqualizerState();
}

class _AnimatedEqualizerState extends State<_AnimatedEqualizer> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  static const _bars = 3;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_bars, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 120),
      )..repeat(reverse: true);
      return ctrl;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_bars, (i) {
          return AnimatedBuilder(
            animation: _controllers[i],
            builder: (_, __) {
              final heightFrac = 0.3 + _controllers[i].value * 0.7;
              return Container(
                width: 3,
                height: 14 * heightFrac,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Duration formatter
// ---------------------------------------------------------------------------

String _formatDuration(int ms) {
  final d = Duration(milliseconds: ms);
  final minutes = d.inMinutes;
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
