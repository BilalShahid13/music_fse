import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/genre.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/sort_preference_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/focus_highlight.dart';

/// Genres tab — virtualized list of genre rows with a colored icon.
class GenresTab extends ConsumerWidget {
  const GenresTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortPrefAsync = ref.watch(
      sortPreferenceProvider('genres', defaultSortBy: 'name'),
    );
    final sortBy = sortPrefAsync.value?.sortBy ?? 'name';
    final ascending = sortPrefAsync.value?.ascending ?? true;

    final genresAsync = ref.watch(
      genresProvider(sortBy: sortBy, ascending: ascending),
    );

    return genresAsync.when(
      data: (genres) {
        if (genres.isEmpty) {
          return const EmptyState(
            icon: LucideIcons.tag,
            title: 'No Genres',
            subtitle: 'Scan a music folder to detect genres from file tags.',
          );
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: genres.length,
          itemBuilder: (ctx, i) => _GenreTile(
            genre: genres[i],
            colorIndex: i,
            onTap: () => ctx.go(
              '/library/genre/${Uri.encodeComponent(genres[i].name)}',
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyState(
        icon: LucideIcons.circleAlert,
        title: 'Failed to load genres',
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Genre tile
// ---------------------------------------------------------------------------

/// Color cycle for genre icons — 12 accent-ish colors.
const List<Color> _kGenreColors = [
  Color(0xFFC76E00),
  Color(0xFF2196F3),
  Color(0xFF4CAF50),
  Color(0xFFE53935),
  Color(0xFF9C27B0),
  Color(0xFFE91E63),
  Color(0xFF009688),
  Color(0xFFFFC107),
  Color(0xFF3F51B5),
  Color(0xFF00BCD4),
  Color(0xFF8BC34A),
  Color(0xFFFF8F00),
];

class _GenreTile extends StatefulWidget {
  const _GenreTile({
    required this.genre,
    required this.colorIndex,
    required this.onTap,
  });
  final Genre genre;
  final int colorIndex;
  final VoidCallback onTap;

  @override
  State<_GenreTile> createState() => _GenreTileState();
}

class _GenreTileState extends State<_GenreTile> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    final color = _kGenreColors[widget.colorIndex % _kGenreColors.length];

    return FocusHighlight(
      focusNode: _focus,
      borderRadius: 0,
      onPressed: widget.onTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: AppConstants.listTileHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.screenEdgePadding,
            ),
            child: Row(
              children: [
                // Colored icon chip
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.tag, size: 18, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.genre.name,
                    style: tt.bodyMedium?.copyWith(color: ext.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${widget.genre.songCount} song${widget.genre.songCount == 1 ? '' : 's'}',
                  style: tt.bodySmall?.copyWith(color: ext.textTertiary),
                ),
                const SizedBox(width: 8),
                Icon(LucideIcons.chevronRight, size: 16, color: ext.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
