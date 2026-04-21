import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';
import 'focus_highlight.dart';

/// Genre list tile for the library genres tab.
///
/// Spec (REQUIREMENTS §6.8 / §6.3.2):
/// - Height: 56px (standard list tile height)
/// - Left: 40×40 rounded square with a deterministic gradient derived from
///   the genre name. Genre initial letter (16sp white) is centered inside.
/// - Center: genre name (14sp textPrimary), song count (12sp textSecondary)
/// - Right: Lucide `chevronRight` (16×16, textTertiary)
///
/// Gamepad: A button → [onTap]. D-pad navigates the list.
class GenreListTile extends StatefulWidget {
  const GenreListTile({
    super.key,
    required this.genreName,
    required this.songCount,
    this.onTap,
  });

  final String genreName;
  final int songCount;
  final VoidCallback? onTap;

  @override
  State<GenreListTile> createState() => _GenreListTileState();
}

class _GenreListTileState extends State<GenreListTile> {
  late final FocusNode _focusNode;
  bool _isHovered = false;

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

    final bgColor = _isHovered ? ext.bgCardHover : Colors.transparent;
    final songLabel =
        '${widget.songCount} ${widget.songCount == 1 ? "song" : "songs"}';

    return FocusHighlight(
      focusNode: _focusNode,
      borderRadius: sizes.cardRadiusSm,
      onPressed: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            height: AppConstants.listTileHeight,
            padding: EdgeInsets.symmetric(
                horizontal: sizes.screenEdgePadding),
            color: bgColor,
            child: Row(
              children: [
                // Colored genre icon
                _GenreIcon(genreName: widget.genreName),
                const SizedBox(width: 14),
                // Name + count
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.genreName,
                        style: tt.bodyMedium
                            ?.copyWith(color: ext.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        songLabel,
                        style: tt.bodySmall
                            ?.copyWith(color: ext.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: ext.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal — 40×40 gradient icon box
// ---------------------------------------------------------------------------

class _GenreIcon extends StatelessWidget {
  const _GenreIcon({required this.genreName});

  final String genreName;

  @override
  Widget build(BuildContext context) {
    final colors = _deriveColors(genreName);
    final initial =
        genreName.isNotEmpty ? genreName[0].toUpperCase() : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }

  /// Derives a deterministic two-color gradient from a genre name.
  /// Uses the hash code to pick hues so the same genre always gets the same
  /// color, but different genres get visually distinct colors.
  static List<Color> _deriveColors(String name) {
    final hash = name.hashCode.abs();
    final hue1 = (hash % 360).toDouble();
    final hue2 = (hue1 + 40) % 360;
    return [
      HSLColor.fromAHSL(1, hue1, 0.55, 0.38).toColor(),
      HSLColor.fromAHSL(1, hue2, 0.65, 0.28).toColor(),
    ];
  }
}
