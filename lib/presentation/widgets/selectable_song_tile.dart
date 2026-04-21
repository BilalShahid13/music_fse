import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/entities/song.dart';
import '../providers/multi_select_provider.dart';
import 'song_list_tile.dart';

/// Wraps [SongListTile] with multi-select support.
///
/// When selection mode is active, A button toggles selection instead of playing.
class SelectableSongTile extends ConsumerWidget {
  const SelectableSongTile({
    super.key,
    required this.song,
    this.index,
    this.focusNode,
    this.isCurrentlyPlaying = false,
    this.isFavorite = false,
    this.onTap,
    this.onContextMenu,
    this.onToggleFavorite,
    this.showArt = true,
    this.showDuration = true,
    this.horizontalPadding,
  });

  final Song song;
  final int? index;
  final FocusNode? focusNode;
  final bool isCurrentlyPlaying;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onContextMenu;
  final VoidCallback? onToggleFavorite;
  final bool showArt;
  final bool showDuration;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final multiSelect = ref.watch(multiSelectProvider);
    final isSelected = multiSelect.selectedIds.contains(song.id);
    final isActive = multiSelect.isActive;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return SongListTile(
      song: song,
      index: index,
      focusNode: focusNode,
      leading: isActive
          ? Icon(
              isSelected ? LucideIcons.squareCheck : LucideIcons.square,
              color: isSelected ? accent : theme.colorScheme.onSurfaceVariant,
              size: 20,
            )
          : null,
      isCurrentlyPlaying: isCurrentlyPlaying,
      isFavorite: isFavorite,
      onTap: isActive ? () => ref.read(multiSelectProvider.notifier).toggleSelection(song.id) : onTap,
      onContextMenu: isActive ? null : onContextMenu,
      onToggleFavorite: isActive ? null : onToggleFavorite,
      showArt: showArt,
      showDuration: showDuration,
      horizontalPadding: horizontalPadding ?? 14,
    );
  }
}
