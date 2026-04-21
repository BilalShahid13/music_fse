import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/sort_preference_provider.dart';
import '../../../widgets/artist_card.dart';
import '../../../widgets/context_menu.dart';
import '../../../widgets/empty_state.dart';

/// Artists tab — grid of artist cards.
class ArtistsTab extends ConsumerWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = AppSizes.of(context);
    final sortPrefAsync = ref.watch(
      sortPreferenceProvider('artists', defaultSortBy: 'name'),
    );
    final sortBy = sortPrefAsync.value?.sortBy ?? 'name';
    final ascending = sortPrefAsync.value?.ascending ?? true;

    final artistsAsync = ref.watch(
      artistsProvider(sortBy: sortBy, ascending: ascending),
    );

    return artistsAsync.when(
      data: (artists) {
        if (artists.isEmpty) {
          return const EmptyState(
            icon: LucideIcons.users,
            title: 'No Artists',
            subtitle: 'Scan a music folder to populate your library.',
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cols = (constraints.maxWidth / 180).floor().clamp(3, 8);
            return GridView.builder(
              padding: EdgeInsets.all(sizes.screenEdgePadding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: sizes.gridCardWidth / sizes.gridCardHeight,
              ),
              itemCount: artists.length,
              itemBuilder: (ctx, i) {
                final artist = artists[i];
                return ArtistCard(
                  key: ValueKey('artist-${artist.name}'),
                  artistName: artist.name,
                  songCount: artist.songCount,
                  artCachePath: artist.artCachePath,
                  onTap: () => context.go(
                    '/library/artist/${Uri.encodeComponent(artist.name)}',
                  ),
                  onContextMenu: () async {
                    final box = ctx.findRenderObject() as RenderBox?;
                    final pos = box?.localToGlobal(Offset.zero) ?? Offset.zero;
                    await showAppContextMenu(
                      context: ctx,
                      position: pos,
                      entries: [
                        ContextMenuItem(
                          label: 'Go to Artist',
                          icon: LucideIcons.user,
                          onTap: () => context.go(
                            '/library/artist/${Uri.encodeComponent(artist.name)}',
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
        title: 'Failed to load artists',
      ),
    );
  }
}
