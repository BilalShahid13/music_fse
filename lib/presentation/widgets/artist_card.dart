import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';
import 'art_placeholder.dart';
import 'focus_highlight.dart';
import 'marquee_text.dart';

/// Artist card for grid views and horizontal scroll rows.
///
/// Spec (REQUIREMENTS §6.6 / mockup):
/// - Same base size as album card (165px / 210px)
/// - Art: **circular** (shape: circle)
/// - Placeholder icon: Lucide `user` instead of `music`
/// - Name: 14sp white, centered, 1 line ellipsis
/// - Song count: 12sp secondary, centered
/// - Background: bgCard, border 1px borderCard, borderRadius 16px
///
/// Gamepad: A button → [onTap], X button → [onContextMenu].
class ArtistCard extends StatefulWidget {
  const ArtistCard({
    super.key,
    required this.artistName,
    required this.songCount,
    this.artCachePath,
    this.width = AppConstants.gridCardWidth,
    this.onTap,
    this.onContextMenu,
  });

  final String artistName;
  final int songCount;
  final String? artCachePath;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onContextMenu;

  @override
  State<ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends State<ArtistCard> {
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
    final nameStyle = tt.bodyMedium?.copyWith(color: ext.textPrimary) ?? DefaultTextStyle.of(context).style;

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
            mainAxisSize: MainAxisSize.max,
            children: [
              // Circular art. Use flexible sizing to avoid vertical overflow
              // on dense layouts.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: ClipOval(
                          child: _buildArt(size),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: sizes.isCompact ? 6.0 : 10.0),
              // Artist name
              FocusedMarqueeText(
                focusNode: _focusNode,
                text: widget.artistName,
                style: nameStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              // Song count
              Text(
                '${widget.songCount} songs',
                style: tt.bodySmall?.copyWith(color: ext.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArt(double size) {
    if (widget.artCachePath != null) {
      return Image.file(
        File(widget.artCachePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ArtPlaceholder(
          size: size,
          icon: LucideIcons.user,
          borderRadius: BorderRadius.circular(size / 2),
        ),
      );
    }
    return ArtPlaceholder(
      size: size,
      icon: LucideIcons.user,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}
