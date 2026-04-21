# Audit Iteration 3 — Remediation Plan

> **Status:** 0 errors, 0 warnings, 134/134 tests passing.
> **Goal:** Eliminate every remaining stub, hardcoded string, resource leak, and empty callback.

---

## Table of Contents

1. [F-01] Wire "Add to Playlist" across 9 pages
2. [F-02] Wire playlist list context menus (rename/delete)
3. [F-03] Wire empty state action buttons
4. [F-04] Wire album detail "Add to Favorites" stub
5. [F-05] Fix now_playing favorite button no-op when song is null
6. [L-01] Replace all hardcoded context menu labels with l10n keys
7. [L-02] Replace hardcoded dialog button labels with l10n keys
8. [L-03] Replace hardcoded system tray labels
9. [L-04] Add missing l10n keys to ARB file
10. [R-01] Fix TextEditingController leaks in dialogs
11. [C-01] Extract hardcoded overlay color to theme extension
12. [C-02] Equalizer FocusHighlight empty onPressed

---

## [F-01] Wire "Add to Playlist" across 9 pages — CRITICAL

**Problem:** The `showAddToPlaylistDialog()` function exists in
`lib/presentation/pages/dialogs/add_to_playlist_dialog.dart` and is fully
implemented, but every "Add to Playlist" context-menu item calls `onTap: () {}`
instead of invoking it.

**Files to change (9 context menus):**

| # | File | Line | Context Menu Location |
|---|------|------|-----------------------|
| 1 | `lib/presentation/pages/home/home_page.dart` | 446 | `_RecentSongList._showContextMenu` |
| 2 | `lib/presentation/pages/library/widgets/songs_tab.dart` | 173 | `_SongsTabState._showContextMenu` |
| 3 | `lib/presentation/pages/library/widgets/folders_tab.dart` | 180 | `_FolderSongsState._showContextMenu` |
| 4 | `lib/presentation/pages/favorites/favorites_page.dart` | 228 | `_FavoritesPageState._showContextMenu` |
| 5 | `lib/presentation/pages/recently_played/recently_played_page.dart` | 193 | `_RecentlyPlayedPageState._showContextMenu` |
| 6 | `lib/presentation/pages/search/search_page.dart` | 323 | `_SearchResultsList._showContextMenu` |
| 7 | `lib/presentation/pages/artist_detail/artist_detail_page.dart` | 293 | `_ArtistSongList._showContextMenu` |
| 8 | `lib/presentation/pages/genre_detail/genre_detail_page.dart` | 237 | `_GenreDetailPageState._showContextMenu` |
| 9 | `lib/presentation/pages/album_detail/album_detail_page.dart` | 268 | `_AlbumSongList._showContextMenu` (labeled "Add to Favorites" — wrong label, also stub) |

**Implementation for each (identical pattern):**

Each stub currently looks like:
```dart
ContextMenuItem(
  label: 'Add to Playlist',
  icon: LucideIcons.listMusic,
  onTap: () {},
),
```

Replace with:
```dart
ContextMenuItem(
  label: l10n.ctxAddToPlaylist,
  icon: LucideIcons.listMusic,
  onTap: () async {
    final playlist = await showAddToPlaylistDialog(context);
    if (playlist == null) return;
    if (playlist.id == kCreateNewPlaylistSentinelId) {
      final name = await showTextInputDialog(
        context,
        title: l10n.ctxNewPlaylist,
        hint: l10n.playlistNameHint,
        confirmLabel: l10n.create,
      );
      if (name != null && name.trim().isNotEmpty) {
        await ref.read(playlistsProvider().notifier).createPlaylistWithSong(name.trim(), song.id);
        ref.read(toastProvider.notifier).show(l10n.addedToPlaylist);
      }
    } else {
      await ref.read(playlistSongsProvider(playlist.id).notifier).addSong(song.id);
      ref.read(toastProvider.notifier).show(l10n.addedToPlaylist);
    }
  },
),
```

**Import needed in each file:**
```dart
import '../../dialogs/add_to_playlist_dialog.dart';
import '../../dialogs/text_input_dialog.dart';
```
(Relative paths vary by file depth — adjust `../` accordingly.)

**Special case — album_detail_page.dart line 268:**
This item is mislabeled `'Add to Favorites'` with icon `LucideIcons.heart` and
`onTap: () {}`. Fix: change label to `l10n.ctxAddToPlaylist`, icon to
`LucideIcons.listMusic`, and wire the same dialog pattern above. Also add a
proper "Add to Favorites" toggle item below it (see [F-04]).

**Provider dependency:** `playlistSongsProvider` must expose an `addSong(int songId)`
method. Verify it exists; if not, add it to the playlist songs notifier.

**Prerequisite l10n keys (see [L-04]):** `addedToPlaylist`, `playlistNameHint`, `create`.

---

