import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';
import 'art_placeholder.dart';
import 'focus_highlight.dart';
import 'marquee_text.dart';

/// Album card for grid views and horizontal scroll rows.
///
/// Spec (REQUIREMENTS §6.5 / mockup):
/// - Width: 165px (default in grids), 210px in horizontal scroll rows
/// - Art: square, borderRadius 12px
/// - Title: 14sp white, 1 line ellipsis, margin-top 10px
/// - Artist: 12sp secondary, 1 line ellipsis, margin-top 2px
/// - Background: bgCard, border 1px borderCard, borderRadius 16px (cardRadius)
/// - Padding: 12px
///
/// Gamepad: A button → [onTap], X button → [onContextMenu].
class AlbumCard extends StatefulWidget {
  const AlbumCard({
    super.key,
    required this.albumName,
    required this.artistName,
    this.artCachePath,
    this.width = AppConstants.gridCardWidth,
    this.focusNode,
    this.onTap,
    this.onContextMenu,
    this.showFocusedPlayCue = false,
    this.isCurrentlyPlaying = false,
    this.artPlaceholderIconOffset,
  });

  final String albumName;
  final String artistName;
  final String? artCachePath;
  final double width;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final VoidCallback? onContextMenu;
  final bool showFocusedPlayCue;
  final bool isCurrentlyPlaying;
  final Offset? artPlaceholderIconOffset;

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  FocusNode? _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    final titleStyle = tt.bodyMedium?.copyWith(color: ext.textPrimary) ?? DefaultTextStyle.of(context).style;

    final artSize = widget.width - sizes.cardPadding * 2;

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
            mainAxisSize: MainAxisSize.max,
            children: [
              // Album art — Expanded so it takes remaining height after text
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                  child: ListenableBuilder(
                    listenable: _focusNode,
                    builder: (context, _) {
                      return _buildArt(
                        artSize,
                        sizes.cardRadiusSm,
                        showFocusedPlayCue: widget.showFocusedPlayCue && _focusNode.hasFocus && !widget.isCurrentlyPlaying,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: sizes.isCompact ? 6.0 : 10.0),
              // Title
              FocusedMarqueeText(
                focusNode: _focusNode,
                text: widget.albumName,
                style: titleStyle,
              ),
              const SizedBox(height: 2),
              // Artist
              Text(
                widget.artistName,
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

  Widget _buildArt(
    double size,
    double borderRadiusValue, {
    required bool showFocusedPlayCue,
  }) {
    final sizes = AppSizes.of(context);
    final cueIconSize = size * 0.32;
    final placeholderIconOffset = widget.artPlaceholderIconOffset ??
        (sizes.isCompact ? Offset.zero : Offset(size * 0.024, size * 0.012));

    Widget art;
    if (widget.artCachePath != null) {
      art = Image.file(
        File(widget.artCachePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ArtPlaceholder(
          size: size,
          borderRadius: BorderRadius.circular(borderRadiusValue),
          showIcon: !showFocusedPlayCue,
          iconOffset: placeholderIconOffset,
        ),
      );
    } else {
      art = ArtPlaceholder(
        size: size,
        borderRadius: BorderRadius.circular(borderRadiusValue),
        showIcon: !showFocusedPlayCue,
        iconOffset: placeholderIconOffset,
      );
    }

    if (!showFocusedPlayCue) return art;

    return Stack(
      fit: StackFit.expand,
      children: [
        art,
        Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: Center(
            child: Icon(
              LucideIcons.play,
              size: cueIconSize,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
