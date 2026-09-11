import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../platform/xinput/gamepad_scroll_target_mixin.dart';
import '../../helpers/active_focus_request.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/header_sort_dropdown.dart';
import '../dialogs/confirm_dialog.dart';
import '../dialogs/text_input_dialog.dart';
import '../../widgets/playlist_card.dart';

/// Playlist list page — shows all playlists in a grid.
///
/// Route: `/playlists`
class PlaylistListPage extends ConsumerStatefulWidget {
  const PlaylistListPage({super.key});

  @override
  ConsumerState<PlaylistListPage> createState() => _PlaylistListPageState();
}

class _PlaylistListPageState extends ConsumerState<PlaylistListPage>
    with GamepadScrollTargetMixin {
  static const List<HeaderSortOption> _sortOptions = [
    HeaderSortOption(key: 'name', label: 'Name'),
    HeaderSortOption(
      key: 'updatedAt',
      label: 'Last Modified',
      defaultAscending: false,
    ),
    HeaderSortOption(
      key: 'songCount',
      label: 'Most Songs',
      defaultAscending: false,
    ),
  ];

  String _sortBy = 'name';
  bool _ascending = true;
  late final FocusNode _defaultFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _defaultFocus = FocusNode(debugLabel: 'PlaylistList-default');
    _keyListenerFocusNode =
        FocusNode(debugLabel: 'PlaylistListPage-keyListener')
          ..skipTraversal = true;
    scheduleActiveFocusRequest(state: this, focusNode: _defaultFocus);
  }

  @override
  void dispose() {
    _defaultFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    return KeyEventResult.ignored;
  }

  Future<void> _createPlaylist() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showTextInputDialog(
      context,
      title: l10n.newPlaylist,
      hint: l10n.playlistNameHint,
      confirmLabel: l10n.create,
      cancelLabel: l10n.cancel,
    );
    if (name == null || name.trim().isEmpty) return;
    await ref
        .read(
            playlistsProvider(sortBy: _sortBy, ascending: _ascending).notifier)
        .createPlaylist(name.trim());
  }

  Future<void> _showPlaylistContextMenu(
      BuildContext ctx, dynamic playlist) async {
    final l10n = AppLocalizations.of(ctx)!;
    final box = ctx.findRenderObject() as RenderBox?;
    final pos = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    await showAppContextMenu(
      context: ctx,
      position: pos,
      entries: [
        ContextMenuItem(
          label: l10n.ctxRename,
          icon: LucideIcons.pencil,
          onTap: () async {
            final name = await showTextInputDialog(
              ctx,
              title: l10n.renamePlaylistTitle,
              hint: l10n.playlistNameHint,
              initialValue: playlist.name as String,
              confirmLabel: l10n.save,
              cancelLabel: l10n.cancel,
            );
            if (name != null && name.trim().isNotEmpty && ctx.mounted) {
              await ref
                  .read(
                      playlistsProvider(sortBy: _sortBy, ascending: _ascending)
                          .notifier)
                  .renamePlaylist(playlist.id as int, name.trim());
              ref.read(toastProvider.notifier).show(l10n.playlistRenamed);
            }
          },
        ),
        ContextMenuItem(
          label: l10n.ctxDuplicate,
          icon: LucideIcons.copy,
          onTap: () async {
            await ref
                .read(playlistsProvider(sortBy: _sortBy, ascending: _ascending)
                    .notifier)
                .duplicatePlaylist(playlist.id as int);
          },
        ),
        const ContextMenuSeparator(),
        ContextMenuItem(
          label: l10n.ctxDeletePlaylist,
          icon: LucideIcons.trash2,
          isDangerous: true,
          onTap: () async {
            final confirmed = await showConfirmDialog(
              ctx,
              title: l10n.deletePlaylistConfirm(playlist.name as String),
              message: l10n.deletePlaylistBody,
              confirmLabel: l10n.delete,
              cancelLabel: l10n.cancel,
              isDangerous: true,
            );
            if (confirmed == true) {
              await ref
                  .read(
                      playlistsProvider(sortBy: _sortBy, ascending: _ascending)
                          .notifier)
                  .deletePlaylist(playlist.id as int);
              if (ctx.mounted) {
                ref.read(toastProvider.notifier).show(l10n.playlistDeleted);
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final sizes = AppSizes.of(context);
    final playlistsAsync = ref.watch(
      playlistsProvider(sortBy: _sortBy, ascending: _ascending),
    );
    final currentRoute = ref.watch(navigationProvider);

    syncGamepadScrollTarget(currentRoute == '/playlists');

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                0,
              ),
              child: Row(
                children: [
                  Text(
                    l10n.navPlaylists,
                    style: tt.headlineLarge?.copyWith(
                      color: ext.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // Sort dropdown
                  _SortBtn(
                    sortBy: _sortBy,
                    ascending: _ascending,
                    onChange: (s, a) => setState(() {
                      _sortBy = s;
                      _ascending = a;
                    }),
                  ),
                  const SizedBox(width: 12),
                  // Create playlist
                  _HeaderBtn(
                    icon: LucideIcons.plus,
                    label: l10n.newLabel,
                    focusNode: _defaultFocus,
                    onTap: _createPlaylist,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Grid ──────────────────────────────────────────────────────
            Expanded(
              child: playlistsAsync.when(
                data: (playlists) {
                  if (playlists.isEmpty) {
                    return EmptyState(
                      icon: LucideIcons.listMusic,
                      title: l10n.noPlaylistsYet,
                      subtitle: l10n.noPlaylistsMessage,
                      actionLabel: l10n.newPlaylist,
                      onAction: _createPlaylist,
                    );
                  }

                  final smart = playlists.where((p) => p.isSmart).toList();
                  final user = playlists.where((p) => !p.isSmart).toList();

                  return ListView(
                    controller: gamepadScrollController,
                    children: [
                      // Smart playlists section (if any)
                      if (smart.isNotEmpty) ...[
                        _SectionHeader(title: l10n.smartPlaylists),
                        _PlaylistGrid(
                          playlists: smart,
                          onTap: (p) => context.go('/playlists/${p.id}'),
                          onContextMenu: (p) =>
                              _showPlaylistContextMenu(context, p),
                        ),
                      ],

                      // User playlists section
                      if (user.isNotEmpty) ...[
                        if (smart.isNotEmpty)
                          _SectionHeader(title: l10n.myPlaylists),
                        _PlaylistGrid(
                          playlists: user,
                          onTap: (p) => context.go('/playlists/${p.id}'),
                          onContextMenu: (p) =>
                              _showPlaylistContextMenu(context, p),
                        ),
                      ],

                      SizedBox(height: sizes.screenEdgePadding),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => EmptyState(
                  icon: LucideIcons.circleAlert,
                  title: l10n.failedToLoadPlaylists,
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
// Playlist grid (LayoutBuilder)
// ---------------------------------------------------------------------------

class _PlaylistGrid extends StatelessWidget {
  const _PlaylistGrid({
    required this.playlists,
    required this.onTap,
    required this.onContextMenu,
  });

  final List<dynamic> playlists; // List<Playlist>
  final void Function(dynamic) onTap;
  final void Function(dynamic) onContextMenu;

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cols =
            (constraints.maxWidth / sizes.gridCardWidth).floor().clamp(3, 10);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: sizes.screenEdgePadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: sizes.gridCardWidth / sizes.gridCardHeight,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: playlists.length,
          itemBuilder: (ctx2, i) {
            final playlist = playlists[i];
            return PlaylistCard(
              playlistName: playlist.name,
              songCount: playlist.songCount,
              artCachePaths: playlist.coverArtPath != null
                  ? [playlist.coverArtPath!]
                  : const [],
              onTap: () => onTap(playlist),
              onContextMenu: () => onContextMenu(playlist),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.screenEdgePadding,
        16,
        sizes.screenEdgePadding,
        8,
      ),
      child: Text(
        title,
        style: tt.titleMedium?.copyWith(
          color: ext.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sort button
// ---------------------------------------------------------------------------

class _SortBtn extends StatelessWidget {
  const _SortBtn({
    required this.sortBy,
    required this.ascending,
    required this.onChange,
  });
  final String sortBy;
  final bool ascending;
  final void Function(String, bool) onChange;

  @override
  Widget build(BuildContext context) {
    return HeaderSortDropdown(
      value: sortBy,
      ascending: ascending,
      focusDebugLabel: 'PlaylistListPage-sortDropdown',
      options: _PlaylistListPageState._sortOptions,
      onChanged: onChange,
    );
  }
}

// ---------------------------------------------------------------------------
// Header button
// ---------------------------------------------------------------------------

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.focusNode,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      focusNode: focusNode,
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
