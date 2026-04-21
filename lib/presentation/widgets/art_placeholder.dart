import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';

/// Standardised placeholder shown whenever album/artist/playlist art is
/// missing.
///
/// Spec (REQUIREMENTS §6.2a):
/// - Background: [bgCard] with a radial gradient to [bgCardHover]
/// - Icon: accent-colored [LucideIcons.music] by default
/// - Border radius follows the parent's context (pass via [borderRadius])
/// - Does NOT animate — this is intentionally static
///
/// Size breakdown by usage context:
/// | Context                    | size  | iconSize |
/// |----------------------------|-------|----------|
/// | Song list tile             | 44    | 20       |
/// | Mini player                | 48    | 20       |
/// | Queue item                 | 36    | 16       |
/// | Album/playlist card        | 140+  | 32       |
/// | Detail header              | 200   | 48       |
/// | Now Playing                | 300+  | 64       |
///
/// [iconSize] is auto-computed as `size * 0.45` when omitted.
class ArtPlaceholder extends StatelessWidget {
  const ArtPlaceholder({
    super.key,
    required this.size,
    this.iconSize,
    this.icon,
    this.borderRadius,
    this.showIcon = true,
    this.iconOffset,
  });

  final double size;

  /// Explicit icon size. If null, defaults to `size * 0.45`.
  final double? iconSize;

  /// Defaults to [LucideIcons.music].
  /// Use [LucideIcons.user] for artist cards.
  /// Use [LucideIcons.listMusic] for empty playlist cards.
  final IconData? icon;

  /// Explicit border radius. If null, a sensible default based on [size] is
  /// used (6px for small tiles, 12px for medium cards, up to 50% for artists).
  final BorderRadius? borderRadius;

  /// Whether to render the placeholder icon glyph.
  final bool showIcon;

  /// Optional optical centering offset for the icon glyph.
  ///
  /// When omitted, the icon stays mathematically centered.
  final Offset? iconOffset;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final resolvedGlyph = icon ?? LucideIcons.music;
    final resolvedIconSize = iconSize ?? (size * 0.45).clamp(16.0, 64.0);
    final resolvedRadius = borderRadius ?? _defaultRadius(size);
    final resolvedIconOffset = iconOffset ?? Offset.zero;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: resolvedRadius,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.6,
          colors: [ext.bgCardHover, ext.bgCard],
        ),
      ),
      child: Center(
        child: showIcon
            ? Transform.translate(
                offset: resolvedIconOffset,
                child: Icon(
                  resolvedGlyph,
                  size: resolvedIconSize,
                  color: accent,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  static BorderRadius _defaultRadius(double size) {
    if (size <= 44) return BorderRadius.circular(6);
    if (size <= 60) return BorderRadius.circular(8);
    return BorderRadius.circular(12);
  }
}
