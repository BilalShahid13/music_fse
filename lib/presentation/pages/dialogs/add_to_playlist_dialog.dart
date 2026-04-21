import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/playlist.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/focus_highlight.dart';

/// Dialog presenting a scrollable list of playlists + "Create New" option.
///
/// Spec (REQUIREMENTS §7.17):
/// - Width: 380px, max height 500px, bgSurface, borderRadius 16px
/// - First item: "Create New Playlist" with + icon
/// - Then: all user playlists with their name, song count, art mosaic
/// - Only user playlists (isSmart = false) shown
///
/// Returns the chosen [Playlist], or null if cancelled.
/// Returns a special sentinel `_kCreateNew` to signal "create new".
///
/// Usage:
/// ```dart
/// final result = await showAddToPlaylistDialog(context);
/// if (result == null) return; // cancelled
/// if (result.id == -1) { /* create new */ } else { /* add to playlist */ }
/// ```
Future<Playlist?> showAddToPlaylistDialog(BuildContext context) {
  return showDialog<Playlist>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _AddToPlaylistDialog(),
  );
}

/// Sentinel playlist used to signal "create new playlist".
/// The caller checks `playlist.id == kCreateNewPlaylistSentinelId`.
const int kCreateNewPlaylistSentinelId = -1;

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class _AddToPlaylistDialog extends ConsumerStatefulWidget {
  const _AddToPlaylistDialog();

  @override
  ConsumerState<_AddToPlaylistDialog> createState() =>
      _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends ConsumerState<_AddToPlaylistDialog> {
  late final FocusNode _createNewFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _createNewFocus = FocusNode(debugLabel: 'AddToPlaylist-createNew');
    _keyListenerFocusNode = FocusNode(debugLabel: 'AddToPlaylistDialogState-keyListener')..skipTraversal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createNewFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _createNewFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);

    final playlistsAsync = ref.watch(
      playlistsProvider(sortBy: 'updatedAt', ascending: false),
    );

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.dialogWidth,
            maxHeight: 500,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: ext.bgSurface,
              borderRadius: BorderRadius.circular(sizes.cardRadius),
              border: Border.all(color: ext.borderSubtle),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.dialogPadding,
                    AppConstants.dialogPadding,
                    AppConstants.dialogPadding,
                    0,
                  ),
                  child: Text(
                    'Add to Playlist',
                    style: tt.titleLarge?.copyWith(color: ext.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: ext.borderSubtle, height: 1),

                // "Create New" option
                _PlaylistListItem(
                  focusNode: _createNewFocus,
                  leadingIcon: LucideIcons.plus,
                  title: 'Create New Playlist',
                  subtitle: null,
                  isCreateNew: true,
                  onTap: () => Navigator.of(context).pop(
                    Playlist(
                      id: kCreateNewPlaylistSentinelId,
                      name: '',
                      createdAt: DateTime(0),
                      updatedAt: DateTime(0),
                    ),
                  ),
                ),

                Divider(color: ext.borderSubtle, height: 1),

                // Playlist list
                Flexible(
                  child: playlistsAsync.when(
                    data: (playlists) {
                      final userPlaylists =
                          playlists.where((p) => !p.isSmart).toList();
                      if (userPlaylists.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No playlists yet. Create one above.',
                            style: tt.bodyMedium
                                ?.copyWith(color: ext.textTertiary),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: userPlaylists.length,
                        itemBuilder: (context, index) {
                          final pl = userPlaylists[index];
                          return _PlaylistListItem(
                            title: pl.name,
                            subtitle:
                                '${pl.songCount} song${pl.songCount == 1 ? '' : 's'}',
                            onTap: () => Navigator.of(context).pop(pl),
                          );
                        },
                      );
                    },
                    loading: () => const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox(
                      height: 80,
                      child: Center(child: Icon(LucideIcons.circleAlert)),
                    ),
                  ),
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
// Row item
// ---------------------------------------------------------------------------

class _PlaylistListItem extends StatefulWidget {
  const _PlaylistListItem({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leadingIcon,
    this.isCreateNew = false,
    this.focusNode,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final bool isCreateNew;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  @override
  State<_PlaylistListItem> createState() => _PlaylistListItemState();
}

class _PlaylistListItemState extends State<_PlaylistListItem> {
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
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return FocusHighlight(
      focusNode: _focus,
      borderRadius: 0,
      onPressed: widget.onTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: AppConstants.listTileHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.dialogPadding),
            child: Row(
              children: [
                // Leading icon
                Icon(
                  widget.leadingIcon ?? LucideIcons.listMusic,
                  size: 20,
                  color: widget.isCreateNew ? accent : ext.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: tt.bodyMedium?.copyWith(
                          color: widget.isCreateNew ? accent : ext.textPrimary,
                          fontWeight: widget.isCreateNew
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style:
                              tt.bodySmall?.copyWith(color: ext.textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
