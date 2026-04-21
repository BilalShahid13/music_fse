import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';
import 'art_placeholder.dart';
import 'focus_highlight.dart';
import 'marquee_text.dart';

/// Playlist card for grid views.
///
/// Spec (REQUIREMENTS §6.7 / mockup):
/// - Same base size as album card (165px / 210px)
/// - Art: borderRadius 12px. If [artCachePaths] has entries, renders a 2×2
///   mosaic of the first 4 paths (each quadrant is [ArtPlaceholder] if the
///   path is null or loading fails). If empty: [ArtPlaceholder] with
///   [LucideIcons.listMusic].
/// - Name: 14sp white, 1 line ellipsis
/// - Song count: 12sp secondary ("N songs")
/// - Background: bgCard, border 1px borderCard, borderRadius 16px
///
/// Gamepad: A button → [onTap], X button → [onContextMenu].
class PlaylistCard extends StatefulWidget {
  const PlaylistCard({
    super.key,
    required this.playlistName,
    required this.songCount,
    this.artCachePaths = const [],
    this.width = AppConstants.gridCardWidth,
    this.onTap,
    this.onContextMenu,
  });

  final String playlistName;
  final int songCount;

  /// Up to 4 art paths for the mosaic. Pass empty list for the placeholder.
  final List<String?> artCachePaths;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onContextMenu;

  @override
  State<PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<PlaylistCard> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    final titleStyle = tt.bodyMedium?.copyWith(color: ext.textPrimary) ?? DefaultTextStyle.of(context).style;

    final artSize = widget.width - sizes.cardPadding * 2;
    final songLabel = '${widget.songCount} ${widget.songCount == 1 ? "song" : "songs"}';

    return FocusHighlight(
      focusNode: _focusNode,
      isCard: true,
      borderRadius: sizes.cardRadius,
      onPressed: widget.onTap,
      onSecondary: widget.onContextMenu,
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: widget.onContextMenu,
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: ext.bgCard,
            borderRadius: BorderRadius.circular(sizes.cardRadius),
            border: Border.all(color: ext.borderCard),
          ),
          padding: EdgeInsets.all(sizes.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Art area
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                  child: _buildArt(artSize),
                ),
              ),
              const SizedBox(height: 10),
              FocusedMarqueeText(
                focusNode: _focusNode,
                text: widget.playlistName,
                style: titleStyle,
              ),
              const SizedBox(height: 2),
              Text(
                songLabel,
                style: tt.bodySmall?.copyWith(color: ext.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArt(double size) {
    final sizes = AppSizes.of(context);
    final paths = widget.artCachePaths;

    // No art at all → single placeholder
    if (paths.isEmpty || paths.every((p) => p == null)) {
      return ArtPlaceholder(
        size: size,
        icon: LucideIcons.listMusic,
        borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
      );
    }

    // Only one art → fill full square
    if (paths.length == 1) {
      return _ArtImage(path: paths[0], size: size);
    }

    // 2–4 arts → 2×2 mosaic
    final quadrant = size / 2;
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        children: [
          Row(
            children: [
              _ArtImage(path: _safeGet(paths, 0), size: quadrant),
              _ArtImage(path: _safeGet(paths, 1), size: quadrant),
            ],
          ),
          Row(
            children: [
              _ArtImage(path: _safeGet(paths, 2), size: quadrant),
              _ArtImage(path: _safeGet(paths, 3), size: quadrant),
            ],
          ),
        ],
      ),
    );
  }

  static String? _safeGet(List<String?> list, int index) => index < list.length ? list[index] : null;
}

// ---------------------------------------------------------------------------
// Internal — single quadrant image
// ---------------------------------------------------------------------------

class _ArtImage extends StatelessWidget {
  const _ArtImage({required this.path, required this.size});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (path != null) {
      return Image.file(
        File(path!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Placeholder(size: size),
      );
    }
    return _Placeholder(size: size);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    return Container(
      width: size,
      height: size,
      color: ext.bgCardHover,
    );
  }
}
