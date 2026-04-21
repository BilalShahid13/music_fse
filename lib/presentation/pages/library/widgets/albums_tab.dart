import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/sort_preference_provider.dart';
import '../../../widgets/album_card.dart';
import '../../../widgets/context_menu.dart';
import '../../../widgets/empty_state.dart';

/// Albums tab — grid of album cards.
///
/// Column count: `(width / 180).floor().clamp(3, 8)`.
class AlbumsTab extends ConsumerWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortPrefAsync = ref.watch(
      sortPreferenceProvider('albums', defaultSortBy: 'name'),
    );
    final sortBy = sortPrefAsync.value?.sortBy ?? 'name';
    final ascending = sortPrefAsync.value?.ascending ?? true;

    final albumsAsync = ref.watch(
      albumsProvider(sortBy: sortBy, ascending: ascending),
    );

    return albumsAsync.when(
      data: (albums) {
        if (albums.isEmpty) {
          return const EmptyState(
            icon: LucideIcons.disc,
            title: 'No Albums',
            subtitle: 'Scan a music folder to populate your library.',
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cols = (constraints.maxWidth / 180).floor().clamp(3, 8);
            return GridView.builder(
              padding: const EdgeInsets.all(AppConstants.screenEdgePadding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: AppConstants.gridCardWidth / AppConstants.gridCardHeight,
              ),
              itemCount: albums.length,
              itemBuilder: (ctx, i) {
                final album = albums[i];
                return AlbumCard(
                  key: ValueKey('album-${album.name}-${album.artist}'),
                  albumName: album.name,
                  artistName: album.artist,
                  artCachePath: album.artCachePath,
                  onTap: () => context.go(
                    '/library/album/${Uri.encodeComponent(album.name)}/${Uri.encodeComponent(album.artist)}',
                  ),
                  onContextMenu: () async {
                    final box = ctx.findRenderObject() as RenderBox?;
                    final pos = box?.localToGlobal(Offset.zero) ?? Offset.zero;
                    await showAppContextMenu(
                      context: ctx,
                      position: pos,
                      entries: [
                        ContextMenuItem(
                          label: 'Go to Album',
                          icon: LucideIcons.disc,
                          onTap: () => context.go(
                            '/library/album/${Uri.encodeComponent(album.name)}/${Uri.encodeComponent(album.artist)}',
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyState(
        icon: LucideIcons.circleAlert,
        title: 'Failed to load albums',
      ),
    );
  }
}
