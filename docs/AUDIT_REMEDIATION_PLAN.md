# Audit Remediation Plan — Music FSE

> Generated: 19 April 2026
> Source: Cross-referencing `REQUIREMENTS.md`, `IMPLEMENTATION_PLAN.md`, and the full codebase.
> Scope: All gaps, issues, and concerns — critical through minor.

---

## Table of Contents

1. [Overview & Priority Matrix](#1-overview--priority-matrix)
2. [R-01: Sort Preference Persistence (FL-BROWSE-007)](#r-01-sort-preference-persistence)
3. [R-02: Search Ranking (FL-SEARCH-003)](#r-02-search-ranking)
4. [R-03: File-Not-Found Handling (FL-PLAY-009)](#r-03-file-not-found-handling)
5. [R-04: QueueSourceType Enum Fix](#r-04-queuesourcetype-enum-fix)
6. [R-05: Input Auto-Detect (FL-INPUT-004)](#r-05-input-auto-detect)
7. [R-06: Recommendations Home Provider](#r-06-recommendations-home-provider)
8. [R-07: Multi-Select / Batch Operations (FL-BROWSE-009)](#r-07-multi-select--batch-operations)
9. [R-08: Drag & Drop (FL-LIB-006)](#r-08-drag--drop)
10. [R-09: Incremental Scan](#r-09-incremental-scan)
11. [R-10: Lyrics Placeholder](#r-10-lyrics-placeholder)
12. [R-11: Configurable Keyboard Shortcuts (FL-KB-002)](#r-11-configurable-keyboard-shortcuts)
13. [R-12: Native Linux MPRIS](#r-12-native-linux-mpris)
14. [R-13: Database Indexes](#r-13-database-indexes)
15. [R-14: Focus Border Width Discrepancy](#r-14-focus-border-width-discrepancy)
16. [R-15: Close-to-Tray First-Time Dialog](#r-15-close-to-tray-first-time-dialog)
17. [R-16: Queue Save-as-Playlist Default Name](#r-16-queue-save-as-playlist-default-name)
18. [R-17: ARB Localization Gaps](#r-17-arb-localization-gaps)
19. [R-18: Tests](#r-18-tests)

---

## 1. Overview & Priority Matrix

| ID | Issue | Severity | Effort | Priority |
|----|-------|----------|--------|----------|
| R-01 | Sort preference persistence | Critical | Small | **P0** |
| R-02 | Search ranking | Critical | Small | **P0** |
| R-03 | File-not-found handling | Critical | Medium | **P0** |
| R-04 | QueueSourceType enum fix | Critical | Tiny | **P0** |
| R-05 | Input auto-detect | Critical | Medium | **P1** |
| R-06 | Recommendations home provider | Significant | Small | **P1** |
| R-07 | Multi-select / batch ops | Critical | Large | **P1** |
| R-08 | Drag & drop | Critical | Medium | **P1** |
| R-09 | Incremental scan | Significant | Medium | **P2** |
| R-10 | Lyrics placeholder | Significant | Small | **P2** |
| R-11 | Configurable keyboard shortcuts | Critical | Large | **P2** |
| R-12 | Native Linux MPRIS | Significant | Large | **P3** |
| R-13 | Database indexes | Minor | Small | **P3** |
| R-14 | Focus border width discrepancy | Minor | Tiny | **P3** |
| R-15 | Close-to-tray first-time dialog | Minor | Small | **P3** |
| R-16 | Queue save-as-playlist name | Minor | Tiny | **P3** |
| R-17 | ARB localization gaps | Minor | Small | **P3** |
| R-18 | Tests | Critical | Ongoing | **Parallel** |

**Priority key**: P0 = do first (quick wins + correctness), P1 = do next (core UX), P2 = do after (features), P3 = do last (polish). Tests run in parallel throughout.

---

## R-01: Sort Preference Persistence

**Requirement**: FL-BROWSE-007 — Library remembers last sort per view.
**Current state**: `songs_tab.dart` (and other tabs) use local `setState` for `_sortBy`/`_ascending`. These reset on navigation.
**Root cause**: No persistence layer for sort preferences.

### Files to Modify

| File | Action |
|------|--------|
| `lib/domain/repositories/settings_repository.dart` | Add `getSortPreference(viewKey)` / `setSortPreference(viewKey, sortBy, ascending)` |
| `lib/domain/usecases/settings/get_sort_preference.dart` | **New** — use case |
| `lib/domain/usecases/settings/set_sort_preference.dart` | **New** — use case |
| `lib/data/repositories/settings_repository_impl.dart` | Implement using the Settings KV table |
| `lib/presentation/providers/sort_preference_provider.dart` | **New** — Riverpod family provider keyed by view name |
| `lib/presentation/pages/library/widgets/songs_tab.dart` | Replace `setState` sort with the provider |
| `lib/presentation/pages/library/widgets/albums_tab.dart` | Same |
| `lib/presentation/pages/library/widgets/artists_tab.dart` | Same |
| `lib/presentation/pages/library/widgets/genres_tab.dart` | Same |
| `lib/presentation/pages/library/widgets/folders_tab.dart` | Same |

### Implementation Steps

1. **Settings KV storage format** — Store sort preferences as JSON in the `Settings` table:
   - Key: `sort_pref_<viewKey>` (e.g., `sort_pref_songs`, `sort_pref_albums`)
   - Value: `{"sortBy": "title", "ascending": true}`

2. **Domain layer** — Add to `SettingsRepository` interface:
   ```dart
   Future<Result<({String sortBy, bool ascending})>> getSortPreference(String viewKey);
   Future<Result<void>> setSortPreference(String viewKey, String sortBy, bool ascending);
   ```

3. **Data layer** — Implement in `SettingsRepositoryImpl` using existing `SettingsDao.getValue` / `SettingsDao.setValue`. JSON encode/decode the value. Default to `('title', true)` when no preference exists.

4. **Use cases** — Two simple use cases:
   - `GetSortPreference` — `call(String viewKey)` → returns the sort tuple.
   - `SetSortPreference` — `call(String viewKey, String sortBy, bool ascending)` → persists.

5. **Provider** — Create `sortPreferenceProvider` as a family `AsyncNotifier` keyed by `String viewKey`:
   ```dart
   @riverpod
   class SortPreferenceNotifier extends _$SortPreferenceNotifier {
     @override
     Future<({String sortBy, bool ascending})> build(String viewKey) async {
       final useCase = ref.read(getSortPreferenceProvider);
       final result = await useCase.call(viewKey);
       return result.when(
         success: (pref) => pref,
         failure: (_) => (sortBy: 'title', ascending: true),
       );
     }

     Future<void> update(String sortBy, bool ascending) async {
       final useCase = ref.read(setSortPreferenceProvider);
       await useCase.call(viewKey, sortBy, ascending);
       state = AsyncData((sortBy: sortBy, ascending: ascending));
     }
   }
   ```

6. **Tab widgets** — Replace local `_sortBy`/`_ascending` state with:
   ```dart
   final sortPref = ref.watch(sortPreferenceNotifierProvider('songs'));
   final sortBy = sortPref.valueOrNull?.sortBy ?? 'title';
   final ascending = sortPref.valueOrNull?.ascending ?? true;
   ```
   The `_SortDropdown.onChanged` calls `ref.read(sortPreferenceNotifierProvider('songs').notifier).update(key, asc)`.

7. **Run `build_runner`** to generate the `.g.dart` file.

### Verification
- Change sort on Songs tab to "Date Added descending"
- Navigate to Albums tab and back to Songs tab — sort must persist
- Restart the app — sort must persist
- Each tab maintains its own independent sort preference

---

## R-02: Search Ranking

**Requirement**: FL-SEARCH-003 — Exact match > starts-with > contains, with weighted ranking.
**Current state**: `SongDao.searchSongs` uses `LIKE '%query%'` with no ordering. Returns in arbitrary SQLite order.

### Files to Modify

| File | Action |
|------|--------|
| `lib/data/datasources/local/daos/song_dao.dart` | Rewrite `searchSongs`, `searchAlbums`, `searchArtists` with ranked ordering |

### Implementation Steps

1. **Replace the `searchSongs` method** in `song_dao.dart` (currently at ~L169) with a custom query that uses `CASE WHEN` scoring:

   ```dart
   Future<List<SongData>> searchSongs(String query, {int limit = 50}) async {
     final escaped = _escapeLike(query);
     final exactQ = escaped;
     final startsQ = '$escaped%';
     final containsQ = '%$escaped%';

     final results = await customSelect(
       '''
       SELECT s.*,
         CASE
           WHEN LOWER(s.title) = LOWER(?) THEN 3
           WHEN LOWER(s.artist) = LOWER(?) THEN 3
           WHEN LOWER(s.album) = LOWER(?) THEN 3
           WHEN LOWER(s.title) LIKE LOWER(?) THEN 2
           WHEN LOWER(s.artist) LIKE LOWER(?) THEN 2
           WHEN LOWER(s.album) LIKE LOWER(?) THEN 2
           ELSE 1
         END AS relevance
       FROM songs s
       WHERE s.title LIKE ? OR s.artist LIKE ? OR s.album LIKE ?
       ORDER BY relevance DESC, s.title ASC
       LIMIT ?
       ''',
       variables: [
         Variable.withString(exactQ),   // exact title
         Variable.withString(exactQ),   // exact artist
         Variable.withString(exactQ),   // exact album
         Variable.withString(startsQ),  // starts-with title
         Variable.withString(startsQ),  // starts-with artist
         Variable.withString(startsQ),  // starts-with album
         Variable.withString(containsQ), // WHERE title LIKE
         Variable.withString(containsQ), // WHERE artist LIKE
         Variable.withString(containsQ), // WHERE album LIKE
         Variable.withInt(limit),
       ],
       readsFrom: {songs},
     ).get();

     return results.map((row) => songs.map(row.data)).toList();
   }
   ```

2. **Apply the same pattern** to `searchAlbums` and `searchArtists`. For albums/artists, the scoring is simpler (fewer columns to match). Same `CASE WHEN` approach with `relevance DESC`.

3. **Increase default limit** from 5 to a reasonable number (e.g., 50 for songs, 20 for albums/artists) so the ranked results are meaningful.

4. **The search use case and provider require no changes** — ranking is entirely a data-layer concern.

### Verification
- Search for "hello" with library containing "Hello" (exact), "Hello World" (starts-with), "Say Hello" (contains)
- Results should appear in that exact order
- Verify via widget test that ordering holds

---

## R-03: File-Not-Found Handling

**Requirement**: FL-PLAY-009 — When a file can't be played: mark `isMissing = true`, show toast, auto-skip to next, track consecutive misses, prompt rescan after N consecutive misses.
**Current state**: `_loadAndPlay` in `playback_provider.dart` catches errors generically, logs them, and sets `isPlaying: false`. Does not skip, does not mark missing, does not toast, does not track consecutive failures.

### Files to Modify

| File | Action |
|------|--------|
| `lib/presentation/providers/playback_provider.dart` | Add file-not-found handling in `_loadAndPlay` error path |
| `lib/domain/usecases/songs/mark_song_missing.dart` | **New** — use case to set `isMissing = true` on a song |
| `lib/domain/repositories/song_repository.dart` | Add `markMissing(int songId, bool isMissing)` if not present |
| `lib/data/repositories/song_repository_impl.dart` | Implement `markMissing` |
| `lib/data/datasources/local/daos/song_dao.dart` | Add `setMissing(int songId, bool isMissing)` |
| `lib/core/constants/app_constants.dart` | Add `consecutiveMissingThreshold` constant (e.g., 3) |
| `lib/core/localization/arb/app_en.arb` | Verify `fileMissing`, `consecutiveMissingPrompt` strings exist (they do) |

### Implementation Steps

1. **Add `_consecutiveMissCount` field** to `PlaybackNotifier` (int, default 0). Reset to 0 on any successful `play()`.

2. **Rewrite the catch block** in `_loadAndPlay` (~L570):

   ```dart
   } on PlayerException catch (e) {
     AppLogger.warning('Playback failed for ${song.filePath}: $e');
     _consecutiveMissCount++;

     // Mark song as missing in the database
     final markMissing = ref.read(markSongMissingProvider);
     await markMissing.call(song.id, true);

     // Show toast
     ref.read(toastNotifierProvider.notifier).show(
       ToastData(
         message: ref.read(l10nProvider).fileMissing,
         type: ToastType.warning,
       ),
     );

     // Check consecutive miss threshold
     if (_consecutiveMissCount >= AppConstants.consecutiveMissingThreshold) {
       ref.read(toastNotifierProvider.notifier).show(
         ToastData(
           message: ref.read(l10nProvider).consecutiveMissingPrompt,
           type: ToastType.error,
           actionLabel: ref.read(l10nProvider).rescanLibrary,
           onAction: () => ref.read(scanNotifierProvider.notifier).startScan(),
         ),
       );
       _consecutiveMissCount = 0;
       return; // Stop playback — don't keep skipping
     }

     // Auto-skip to next
     await skipNext();
   } on Exception catch (e) {
     // Non-file errors (e.g., audio format unsupported)
     AppLogger.error('Unexpected playback error: $e');
     state = state.copyWith(isPlaying: false);
   }
   ```

3. **Also catch `FileSystemException` specifically** (or check `e.toString().contains('404')` / `!File(song.filePath).existsSync()` before attempting playback) to distinguish file-missing from codec/format errors.

4. **Add the use case + repository chain**:
   - `MarkSongMissing` use case: `call(int songId, bool isMissing)` → `songRepository.markMissing(songId, isMissing)`
   - `SongRepository.markMissing` → `SongDao.setMissing`:
     ```dart
     Future<void> setMissing(int songId, bool isMissing) {
       return (update(songs)..where((s) => s.id.equals(songId)))
           .write(SongsCompanion(isMissing: Value(isMissing)));
     }
     ```

5. **Reset `_consecutiveMissCount = 0`** inside the success path of `_loadAndPlay` (after `_playerA.play()` succeeds) and at the start of manual `play()` from a new source.

6. **Add `consecutiveMissingThreshold`** to `app_constants.dart`:
   ```dart
   static const int consecutiveMissingThreshold = 3;
   ```

### Verification
- Delete/rename an audio file, try to play it — toast appears, auto-skips to next
- Delete 3 consecutive files — rescan prompt toast appears
- Song appears with a visual "missing" indicator in the library list
- Playing a valid file after a miss resets the counter

---

## R-04: QueueSourceType Enum Fix

**Requirement**: Queue should track when songs were manually queued or played from "All Songs" view.
**Current state**: `QueueSourceType` enum (in `playback_state.dart` L20-28) has: `library, album, artist, genre, playlist, search, folder`. Missing: `manual`, `allSongs`.

### Files to Modify

| File | Action |
|------|--------|
| `lib/domain/entities/playback_state.dart` | Add `manual` and `allSongs` to `QueueSourceType` |
| `lib/data/models/playback_state_mapper.dart` | Ensure mapper handles new enum values |

### Implementation Steps

1. **Add to the enum**:
   ```dart
   enum QueueSourceType {
     library,
     album,
     artist,
     genre,
     playlist,
     search,
     folder,
     allSongs,
     manual,
   }
   ```

2. **Verify the mapper** in `playback_state_mapper.dart` — since the DB stores this as a text column and the mapper likely uses `.name` / `QueueSourceType.values.byName()`, the new values should map automatically. If there's a manual switch-case, add the new cases.

3. **Update usage sites** — When the user plays from the "All Songs" list, pass `QueueSourceType.allSongs` instead of `QueueSourceType.library`. When the user manually adds a song to the queue via "Add to Queue" context menu, tag it as `QueueSourceType.manual`.

4. **Run `build_runner`** if `PlaybackState` is `@freezed` (it is — regenerate `.freezed.dart`).

### Verification
- Play from "All Songs" — check persisted `queueSourceType` is `allSongs`
- "Add to Queue" from context menu — check source is `manual`
- Restore app — source type survives restart

---

## R-05: Input Auto-Detect

**Requirement**: FL-INPUT-004 — Show focus indicators when gamepad/keyboard input detected, hide when mouse moves. Auto-detect input method.
**Current state**: Not implemented. Focus rings are always visible via `FocusHighlight`.

### Files to Create / Modify

| File | Action |
|------|--------|
| `lib/presentation/providers/input_mode_provider.dart` | **New** — provider tracking current input mode |
| `lib/presentation/widgets/focus_highlight.dart` | Conditionally show focus ring based on input mode |
| `lib/presentation/app.dart` | Add root-level `Listener` for mouse/keyboard/gamepad events |
| `lib/core/localization/arb/app_en.arb` | No new strings needed |

### Implementation Steps

1. **Define the input mode enum and provider**:

   ```dart
   enum InputMode { gamepad, keyboard, mouse }

   @Riverpod(keepAlive: true)
   class InputModeNotifier extends _$InputModeNotifier {
     @override
     InputMode build() => InputMode.keyboard; // Default

     void onMouseMove() {
       if (state != InputMode.mouse) {
         state = InputMode.mouse;
       }
     }

     void onKeyboardInput() {
       if (state != InputMode.keyboard) {
         state = InputMode.keyboard;
       }
     }

     void onGamepadInput() {
       if (state != InputMode.gamepad) {
         state = InputMode.gamepad;
       }
     }

     bool get showFocusIndicators => state != InputMode.mouse;
   }
   ```

2. **Wire into `app.dart`** — Wrap the root `MaterialApp.router` in a `Listener` widget:

   ```dart
   Listener(
     onPointerHover: (_) => ref.read(inputModeNotifierProvider.notifier).onMouseMove(),
     onPointerDown: (_) => ref.read(inputModeNotifierProvider.notifier).onMouseMove(),
     child: // ... existing MaterialApp.router
   )
   ```

   For keyboard events, use a `KeyboardListener` / `RawKeyboardListener` at root level. Arrow keys / Enter / Tab → `onKeyboardInput()`.

3. **Wire XInput** — In the XInput polling handler (wherever gamepad button/stick events are processed), call `onGamepadInput()` when any input is detected.

4. **Modify `FocusHighlight`** — Read the input mode provider:

   ```dart
   final showFocus = ref.watch(
     inputModeNotifierProvider.select((mode) => mode != InputMode.mouse),
   );
   ```

   When `showFocus` is `false`, render the child without the accent border, scale, and glow — but still keep the `Focus` widget for keyboard traversal. Only the **visual** indicator is hidden.

5. **Edge case**: When the user presses a keyboard key while in mouse mode, immediately switch to keyboard mode and show focus on the currently focused element.

### Verification
- Move mouse → focus rings disappear
- Press any arrow key → focus rings reappear on the focused element
- Press gamepad button → focus rings reappear
- Focus traversal still works in all modes (only visual is hidden)

---

## R-06: Recommendations Home Provider

**Requirement**: Home screen should show recommendation sections (recently liked, hidden gems, top played).
**Current state**: `RecommendationsRepositoryImpl` with 3 algorithms exists and works. `home_provider.dart` has no notifier to expose this data.

### Files to Modify

| File | Action |
|------|--------|
| `lib/presentation/providers/home_provider.dart` | Add `RecommendationsNotifier` |
| `lib/presentation/pages/home/home_page.dart` | Add recommendations sections to the home page UI |

### Implementation Steps

1. **Add notifier** to `home_provider.dart`, following the existing pattern (e.g., `RecentlyPlayedNotifier`):

   ```dart
   @riverpod
   class RecommendationsNotifier extends _$RecommendationsNotifier {
     @override
     Future<Map<String, List<Song>>> build() async {
       final useCase = ref.read(getRecommendationsProvider);
       final result = await useCase.call();
       return result.when(
         success: (data) => data,
         failure: (_) => {},
       );
     }
   }
   ```

2. **Verify use case wiring** — Ensure `GetRecommendations` use case exists and is wired to a provider. If not, create:
   - `lib/domain/usecases/recommendations/get_recommendations.dart`
   - Provider in `lib/presentation/providers/` or co-located.

3. **Add to home page UI** — In `home_page.dart`, after the existing sections (RecentlyPlayed, MostPlayed, RecentlyAdded), add:
   - "Recommended for You" section with horizontal scrollable `SongCard` list for each non-empty recommendation category.
   - Only show categories that have data. Empty categories are hidden (not empty state — recommendations are optional content).

4. **Trigger generation** — Call `generateRecommendations()` as part of the post-scan flow or on home page first build. Add a periodic regeneration (e.g., every app launch, after scan completes). This logic goes in the `home_page` init or a startup provider.

5. **Run `build_runner`**.

### Verification
- Library with varied play counts and favorites → home shows recommendation sections
- Empty library → no recommendation sections shown (not an empty state)
- After a scan completes → recommendations refresh

---

## R-07: Multi-Select / Batch Operations

**Requirement**: FL-BROWSE-009 — Long-press A (gamepad) or Shift+click (mouse) to enter selection mode. Batch actions: add to playlist, add to queue, favorite, remove.
**Current state**: Not implemented. Zero code exists.

### Files to Create

| File | Action |
|------|--------|
| `lib/presentation/providers/multi_select_provider.dart` | **New** — selection state provider |
| `lib/presentation/widgets/multi_select_actions_bar.dart` | **New** — batch action bar widget |
| `lib/presentation/widgets/selectable_song_tile.dart` | **New** — song tile with selection checkbox |
| `lib/core/localization/arb/app_en.arb` | Add multi-select strings |

### Files to Modify

| File | Action |
|------|--------|
| `lib/presentation/pages/library/widgets/songs_tab.dart` | Integrate selection mode |
| `lib/presentation/pages/library/widgets/albums_tab.dart` | Same |
| `lib/presentation/pages/favorites/favorites_page.dart` | Same |
| `lib/presentation/pages/playlist/playlist_detail_page.dart` | Same |
| `lib/presentation/widgets/gamepad_button_hints.dart` | Update hints for selection mode |

### Implementation Steps

1. **Create `MultiSelectNotifier`** provider:

   ```dart
   @riverpod
   class MultiSelectNotifier extends _$MultiSelectNotifier {
     @override
     ({bool isActive, Set<int> selectedIds}) build() =>
         (isActive: false, selectedIds: {});

     void activate() {
       state = (isActive: true, selectedIds: state.selectedIds);
     }

     void deactivate() {
       state = (isActive: false, selectedIds: {});
     }

     void toggleSelection(int songId) {
       final ids = Set<int>.from(state.selectedIds);
       if (ids.contains(songId)) {
         ids.remove(songId);
       } else {
         ids.add(songId);
       }
       // Auto-deactivate when nothing selected
       if (ids.isEmpty) {
         state = (isActive: false, selectedIds: {});
       } else {
         state = (isActive: true, selectedIds: ids);
       }
     }

     void selectAll(List<int> allIds) {
       state = (isActive: true, selectedIds: Set<int>.from(allIds));
     }

     void deselectAll() {
       state = (isActive: false, selectedIds: {});
     }

     int get count => state.selectedIds.length;
   }
   ```

2. **Create `MultiSelectActionsBar`** widget — Appears at the bottom when selection is active:
   - Shows: "{count} selected" label
   - Buttons: "Add to Queue", "Add to Playlist" (opens submenu), "Favorite", "Remove" (for playlist context)
   - "Select All" / "Deselect All" actions
   - B button → deactivate selection mode
   - All buttons focusable

3. **Create `SelectableSongTile`** — Wraps existing `SongListTile`:
   - When selection mode active: leading checkbox icon, A button toggles selection (not play)
   - When inactive: normal `SongListTile` behavior
   - Long-press A (hold 500ms) → activate selection mode and select this tile
   - Shift+click (mouse) → activate and select

4. **Integrate into tabs** — In `songs_tab.dart` and similar:
   - Replace `SongListTile` in the `ListView.builder` with `SelectableSongTile`
   - When selection is active, replace the normal bottom bar (button hints) with `MultiSelectActionsBar`
   - On B button: if selection active → deactivate; else → normal back behavior

5. **Batch operations** — When an action button is pressed:
   - "Add to Queue" → `playbackNotifier.addMultipleToQueue(selectedIds)`
   - "Add to Playlist" → open playlist picker dialog, then `addSongsToPlaylist(playlistId, selectedIds)`
   - "Favorite" → `toggleFavoriteMultiple(selectedIds, true)`
   - Show toast: "Added 5 songs to queue" / "Added 5 songs to [Playlist Name]"
   - Deactivate selection after action completes

6. **Gamepad input** — Long-press detection: Track A button down timestamp. If held > 500ms without release, enter selection mode. Alternatively, use Y button (if not already assigned) or a combo.

7. **ARB strings** (add to `app_en.arb`):
   ```json
   "selectedCount": "{count} selected",
   "@selectedCount": { "placeholders": { "count": { "type": "int" } } },
   "selectAll": "Select All",
   "deselectAll": "Deselect All",
   "batchAddToQueue": "Add {count} to Queue",
   "@batchAddToQueue": { "placeholders": { "count": { "type": "int" } } },
   "batchAddToPlaylist": "Add {count} to Playlist",
   "@batchAddToPlaylist": { "placeholders": { "count": { "type": "int" } } },
   "batchFavorite": "Favorite {count} Songs",
   "@batchFavorite": { "placeholders": { "count": { "type": "int" } } },
   "batchRemove": "Remove {count} Songs",
   "@batchRemove": { "placeholders": { "count": { "type": "int" } } }
   ```

8. **Run `build_runner`** for the new provider + localization.

### Verification
- Long-press A on a song → enters selection mode, that song is selected
- D-pad to other songs + A → toggles selection
- "Select All" → all songs in current view selected
- "Add to Queue" → all selected songs added, toast confirms, selection deactivates
- B button → exits selection mode without performing action
- Works on Songs tab, Favorites page, Playlist detail page

---

## R-08: Drag & Drop

**Requirement**: FL-LIB-006 — Drag audio files/folders from OS file explorer into the app window to add them to the library.
**Current state**: `desktop_drop: ^0.4.4` is in `pubspec.yaml` but no Dart code uses `DropTarget`. No drop overlay, no handler.

### Files to Create

| File | Action |
|------|--------|
| `lib/presentation/widgets/drop_overlay.dart` | **New** — visual overlay shown during drag |

### Files to Modify

| File | Action |
|------|--------|
| `lib/presentation/app.dart` or `lib/presentation/pages/shell/app_shell.dart` | Wrap in `DropTarget` |
| `lib/presentation/providers/scan_provider.dart` | Add `addDroppedPaths(List<String> paths)` method |
| `lib/core/localization/arb/app_en.arb` | Add drag/drop strings |

### Implementation Steps

1. **Create `DropOverlay` widget** — Full-screen overlay shown during drag-over:
   ```dart
   class DropOverlay extends StatelessWidget {
     const DropOverlay({super.key});

     @override
     Widget build(BuildContext context) {
       final ext = Theme.of(context).extension<AppThemeExtension>()!;
       return Container(
         color: ext.accent.withAlpha(30),
         child: Center(
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Icon(LucideIcons.folderInput, size: 64, color: ext.accent),
               const SizedBox(height: 16),
               Text(
                 context.l10n.dropToAddToLibrary,
                 style: Theme.of(context).textTheme.headlineSmall,
               ),
             ],
           ),
         ),
       );
     }
   }
   ```

2. **Wrap the app shell in `DropTarget`** (from `desktop_drop` package):

   ```dart
   DropTarget(
     onDragEntered: (_) => setState(() => _isDragging = true),
     onDragExited: (_) => setState(() => _isDragging = false),
     onDragDone: (details) {
       setState(() => _isDragging = false);
       _handleDroppedFiles(details.files);
     },
     child: Stack(
       children: [
         // existing shell content
         if (_isDragging) const DropOverlay(),
       ],
     ),
   )
   ```

3. **`_handleDroppedFiles` logic**:
   - Extract file paths from `details.files` (list of `XFile`)
   - Filter by `AppConstants.supportedAudioExtensions`
   - For directories: recursively discover audio files
   - Pass valid paths to `scanNotifier.addDroppedPaths(paths)` which:
     a. Scans metadata for each file
     b. Inserts new songs into the database (skip duplicates by `filePath` unique constraint)
     c. Reports results via toast: "Added Y of X songs (Z already in library)"

4. **Add to `ScanNotifier`** — New method `addDroppedPaths(List<String> paths)`:
   - Does NOT trigger a full scan
   - Processes only the dropped files
   - Uses the metadata extractor on each
   - Inserts into DB, catching unique constraint violations as "already exists"
   - Returns `({int added, int total, int duplicates})`

5. **ARB strings**:
   ```json
   "dropToAddToLibrary": "Drop files here to add to library",
   "droppedFilesResult": "Added {added} of {total} songs ({duplicates} already in library)",
   "@droppedFilesResult": { "placeholders": { "added": {"type": "int"}, "total": {"type": "int"}, "duplicates": {"type": "int"} } }
   ```

6. **Run `build_runner`** for localization.

### Verification
- Drag a folder of MP3s from Finder → overlay appears with drop icon
- Release → files are processed, toast shows "Added 8 of 10 songs (2 already in library)"
- Drag a non-audio file → nothing happens (filtered out)
- Drag while on any screen → overlay works globally

---

## R-09: Incremental Scan

**Requirement**: Rescan should detect only changes since last scan (new, modified, deleted files) instead of re-processing the entire library.
**Current state**: Only full `startScan()` exists. No delta logic.

### Files to Modify

| File | Action |
|------|--------|
| `lib/domain/usecases/library/scan_library.dart` | Add `incremental` parameter |
| `lib/domain/repositories/song_repository.dart` | Add method to get known file paths with timestamps |
| `lib/data/repositories/song_repository_impl.dart` | Implement |
| `lib/data/datasources/local/daos/song_dao.dart` | Add `getAllFilePathsWithModified()` query |
| `lib/data/file_system/file_scanner.dart` | Add incremental mode |
| `lib/presentation/providers/scan_provider.dart` | Add `startIncrementalScan()` |
| `lib/data/datasources/local/daos/settings_dao.dart` | Store `lastScanTimestamp` |

### Implementation Steps

1. **Store last scan timestamp** — After a full scan completes, save `lastScanTimestamp` to the Settings KV table.

2. **Add `getAllFilePathsWithModified()` to `SongDao`**:
   ```dart
   Future<Map<String, DateTime>> getAllFilePathsWithModified() async {
     final rows = await (selectOnly(songs)
           ..addColumns([songs.filePath, songs.fileModifiedAt]))
         .get();
     return {for (final row in rows) row.read(songs.filePath)!: row.read(songs.fileModifiedAt)!};
   }
   ```

3. **Incremental scan logic** in `FileScanner`:
   - Get known files map: `{filePath: lastModified}`
   - Walk scan folders, for each discovered file:
     - If not in known files → **new** → extract metadata, insert
     - If in known files but `file.lastModified > known[path]` → **modified** → re-extract metadata, update
     - Remove discovered paths from known files map
   - Remaining entries in known files map → **deleted** → mark as missing or remove from DB
   - Emit progress events with category (new/modified/deleted)

4. **Wire to provider** — Add `startIncrementalScan()` to `ScanNotifier` that calls the scan use case with `incremental: true`.

5. **Auto-select mode** — The "Rescan Library" button in settings and the scan-on-startup feature should use incremental by default. Full scan only available via explicit "Full Rescan" option.

### Verification
- Full scan 1000 songs → add 5 new files to folder → incremental scan finds only 5
- Modify 1 file → incremental scan re-extracts only that 1
- Delete 3 files → incremental scan marks them missing
- Incremental scan is significantly faster than full scan

---

## R-10: Lyrics Placeholder

**Requirement**: Now Playing screen should have a lyrics section/tab as a placeholder for future lyrics integration.
**Current state**: `now_playing_page.dart` has no lyrics section.

### Files to Modify

| File | Action |
|------|--------|
| `lib/presentation/pages/now_playing/now_playing_page.dart` | Add lyrics tab/toggle |
| `lib/core/localization/arb/app_en.arb` | Add lyrics strings |

### Implementation Steps

1. **Add a toggle** between "Album Art" and "Lyrics" views in the Now Playing page. This can be a simple icon button or tab toggle in the header area:
   ```dart
   bool _showLyrics = false;
   ```

2. **Create the lyrics placeholder** — When `_showLyrics` is true, replace the album art area with:
   ```dart
   Column(
     mainAxisAlignment: MainAxisAlignment.center,
     children: [
       Icon(LucideIcons.musicNote, size: 48, color: ext.textMuted),
       const SizedBox(height: 16),
       Text(l10n.lyricsComingSoon, style: textTheme.bodyLarge),
       Text(l10n.lyricsComingSoonSubtitle, style: textTheme.bodySmall),
     ],
   )
   ```

3. **Gamepad mapping** — Assign a button to toggle lyrics view. Since Y is "favorite", use a different approach: add a small toggle in the control area, navigable via D-pad.

4. **ARB strings**:
   ```json
   "lyrics": "Lyrics",
   "lyricsComingSoon": "Lyrics coming soon",
   "lyricsComingSoonSubtitle": "This feature is planned for a future update"
   ```

5. **Run `build_runner`** for localization.

### Verification
- Toggle from album art to lyrics → placeholder shown
- Toggle back → album art returns
- Placeholder is properly themed in both dark/light mode

---

## R-11: Configurable Keyboard Shortcuts

**Requirement**: FL-KB-002 — User can customize keyboard shortcuts. Stored as JSON in Settings KV. Shortcut editor UI with conflict detection.
**Current state**: Hardcoded shortcuts in `KeyboardShortcutHandler`. No editor UI, no config persistence.

### Files to Create

| File | Action |
|------|--------|
| `lib/domain/entities/keyboard_shortcut.dart` | **New** — shortcut config entity |
| `lib/domain/usecases/settings/get_keyboard_shortcuts.dart` | **New** — use case |
| `lib/domain/usecases/settings/set_keyboard_shortcut.dart` | **New** — use case |
| `lib/presentation/providers/keyboard_shortcuts_provider.dart` | **New** — provider |
| `lib/presentation/pages/settings/keyboard_shortcut_editor_page.dart` | **New** — editor screen |
| `lib/presentation/widgets/shortcut_capture_dialog.dart` | **New** — key capture dialog |

### Files to Modify

| File | Action |
|------|--------|
| `lib/platform/keyboard/keyboard_shortcut_handler.dart` | Read from provider instead of hardcoded mappings |
| `lib/presentation/pages/settings/settings_page.dart` | Add "Keyboard Shortcuts" row linking to editor |
| `lib/core/router/app_router.dart` | Add route for shortcut editor |
| `lib/core/localization/arb/app_en.arb` | Add shortcut editor strings |

### Implementation Steps

1. **Define shortcut config entity**:
   ```dart
   @freezed
   class KeyboardShortcutConfig with _$KeyboardShortcutConfig {
     const factory KeyboardShortcutConfig({
       required String actionId,        // e.g., 'playPause', 'nextTrack'
       required String label,           // Human-readable name
       required LogicalKeySet keySet,   // The bound key combination
       required LogicalKeySet defaultKeySet, // Factory default
     }) = _KeyboardShortcutConfig;
   }
   ```

2. **Define all configurable actions** as constants:
   ```dart
   static const allActions = [
     'playPause', 'nextTrack', 'previousTrack', 'volumeUp', 'volumeDown',
     'toggleMute', 'toggleShuffle', 'cycleRepeat', 'openSearch', 'toggleFavorite',
     'goBack', 'toggleFullscreen',
   ];
   ```

3. **Storage format** — JSON in Settings KV table:
   - Key: `keyboard_shortcuts`
   - Value: `{"playPause": "Space", "nextTrack": "Ctrl+Right", ...}`
   - Only overridden shortcuts are stored. Missing keys use defaults.

4. **Provider** — `KeyboardShortcutsNotifier`:
   - On build: load from settings, merge with defaults
   - `updateShortcut(actionId, newKeySet)` → check for conflicts → persist
   - `resetToDefaults()` → clear all overrides
   - `resetSingle(actionId)` → remove one override

5. **Modify `KeyboardShortcutHandler`** — Instead of hardcoded `LogicalKeyboardKey` mappings, read the active shortcuts from the provider:
   ```dart
   final shortcuts = ref.read(keyboardShortcutsNotifierProvider).valueOrNull;
   // Build the intent map from shortcuts config
   ```

6. **Editor UI** — `KeyboardShortcutEditorPage`:
   - `ListView.builder` of all configurable actions
   - Each row: action label + current key binding + "Edit" / "Reset" buttons
   - "Edit" → opens `ShortcutCaptureDialog`
   - "Reset All to Defaults" button at bottom
   - Conflict detection: if captured key matches another action, show warning with the conflicting action name and ask to confirm (which unbinds the conflicting action)

7. **`ShortcutCaptureDialog`** — Modal dialog:
   - "Press the key combination you want to use for [Action]"
   - Listens to `RawKeyDownEvent`, captures the key set
   - Shows the captured combo
   - "Save" / "Cancel" buttons

8. **Settings page integration** — Add under the "Controls" section:
   ```dart
   _ActionRow(
     icon: LucideIcons.keyboard,
     label: l10n.keyboardShortcuts,
     onTap: () => context.push('/settings/shortcuts'),
   ),
   ```

9. **Router** — Add route:
   ```dart
   GoRoute(
     path: '/settings/shortcuts',
     builder: (context, state) => const KeyboardShortcutEditorPage(),
   ),
   ```

10. **ARB strings**:
    ```json
    "keyboardShortcuts": "Keyboard Shortcuts",
    "editShortcut": "Edit Shortcut",
    "pressKeyCombo": "Press the key combination for \"{action}\"",
    "@pressKeyCombo": { "placeholders": { "action": { "type": "String" } } },
    "shortcutConflict": "This key is already used for \"{action}\". Reassign?",
    "@shortcutConflict": { "placeholders": { "action": { "type": "String" } } },
    "resetShortcut": "Reset to Default",
    "resetAllShortcuts": "Reset All to Defaults",
    "shortcutSaved": "Shortcut updated"
    ```

11. **Run `build_runner`**.

### Verification
- Open Settings → Keyboard Shortcuts → see all actions with current bindings
- Edit "Play/Pause" → press `P` → saves as `P`, works globally
- Assign same key to another action → conflict warning shown
- "Reset All" → all shortcuts return to defaults
- Restart app → custom shortcuts persist

---

## R-12: Native Linux MPRIS

**Requirement**: Linux media integration via D-Bus MPRIS protocol.
**Current state**: Dart-side `_LinuxMediaKeyHandler` sends/receives via `MethodChannel('com.musicfse.player/mpris')`. No native C++ implementation in `linux/runner/`.

### Files to Create

| File | Action |
|------|--------|
| `linux/runner/mpris_handler.h` | **New** — C++ MPRIS D-Bus handler header |
| `linux/runner/mpris_handler.cc` | **New** — D-Bus MPRIS implementation |

### Files to Modify

| File | Action |
|------|--------|
| `linux/runner/my_application.cc` | Register the MPRIS method channel |
| `linux/CMakeLists.txt` or `linux/runner/CMakeLists.txt` | Add D-Bus dependency + new source files |
| `lib/platform/media_keys/media_key_handler.dart` | Add `updateMetadata()` and `updatePlaybackStatus()` calls |
| `lib/presentation/providers/playback_provider.dart` | Call `updateMetadata` on track change, `updatePlaybackStatus` on play/pause |

### Implementation Steps

1. **C++ MPRIS handler** — Implement the `org.mpris.MediaPlayer2` and `org.mpris.MediaPlayer2.Player` D-Bus interfaces:

   - **Required D-Bus interfaces**:
     - `org.mpris.MediaPlayer2` — Identity, `Quit`, `CanQuit`
     - `org.mpris.MediaPlayer2.Player` — `Play`, `Pause`, `Next`, `Previous`, `Stop`, `PlaybackStatus`, `Metadata`, `Position`

   - **D-Bus object path**: `/org/mpris/MediaPlayer2`
   - **Service name**: `org.mpris.MediaPlayer2.MusicFSE`

   - Use GDBus (part of GLib, already available in the Flutter Linux runner):
     ```cpp
     // Register on session bus
     g_bus_own_name(G_BUS_TYPE_SESSION,
                    "org.mpris.MediaPlayer2.MusicFSE",
                    G_BUS_NAME_OWNER_FLAGS_NONE,
                    on_bus_acquired, on_name_acquired, on_name_lost,
                    user_data, nullptr);
     ```

   - **Method channel integration**: On `registerMpris` → register the D-Bus service. On `updateMetadata(title, artist, album, artUri, duration)` → emit `PropertiesChanged` on D-Bus with the new metadata dict. On `updatePlaybackStatus(isPlaying)` → emit `PlaybackStatus` change.

2. **CMakeLists.txt changes**:
   ```cmake
   pkg_check_modules(DBUS REQUIRED gio-2.0)
   target_link_libraries(${BINARY_NAME} PRIVATE ${DBUS_LIBRARIES})
   target_include_directories(${BINARY_NAME} PRIVATE ${DBUS_INCLUDE_DIRS})
   ```
   Add `mpris_handler.cc` to the sources list.

3. **Dart-side additions** to `_LinuxMediaKeyHandler`:

   ```dart
   Future<void> updateMetadata({
     required String title,
     required String artist,
     required String album,
     String? artUri,
     required int durationMs,
   }) async {
     await _channel.invokeMethod('updateMetadata', {
       'title': title, 'artist': artist, 'album': album,
       'artUri': artUri, 'durationMs': durationMs,
     });
   }

   Future<void> updatePlaybackStatus(bool isPlaying) async {
     await _channel.invokeMethod('updatePlaybackStatus', {
       'isPlaying': isPlaying,
     });
   }
   ```

4. **Wire into playback provider** — On track change, call `updateMetadata`. On play/pause/stop, call `updatePlaybackStatus`. Same pattern already used for SMTC on Windows and `MPNowPlayingInfoCenter` on macOS.

### Verification
- Run on Linux → `org.mpris.MediaPlayer2.MusicFSE` appears on D-Bus
- Play a song → GNOME/KDE media widget shows track info
- Media keys (play/pause/next/prev) work from the desktop environment
- Pause → status updates in media widget

---

## R-13: Database Indexes

**Requirement**: Performance for a 10K+ song library requires indexes on frequently queried/sorted columns.
**Current state**: Only `filePath` has an implicit unique index. No explicit indexes.

### Files to Modify

| File | Action |
|------|--------|
| `lib/data/datasources/local/database.dart` | Add `@TableIndex` annotations or migration SQL |

### Implementation Steps

1. **Increment schema version** from 1 to 2.

2. **Add indexes** via Drift's `@TableIndex` annotation on the `Songs` table:

   ```dart
   @TableIndex(name: 'idx_songs_artist', columns: {#artist})
   @TableIndex(name: 'idx_songs_album', columns: {#album})
   @TableIndex(name: 'idx_songs_genre', columns: {#genre})
   @TableIndex(name: 'idx_songs_date_added', columns: {#dateAdded})
   @TableIndex(name: 'idx_songs_play_count', columns: {#playCount})
   @TableIndex(name: 'idx_songs_last_played_at', columns: {#lastPlayedAt})
   @TableIndex(name: 'idx_songs_is_favorite', columns: {#isFavorite})
   @TableIndex(name: 'idx_songs_title_artist_album', columns: {#title, #artist, #album})
   ```

   Also add to other tables:
   ```dart
   // PlayHistory
   @TableIndex(name: 'idx_play_history_played_at', columns: {#playedAt})
   @TableIndex(name: 'idx_play_history_song_id', columns: {#songId})

   // PlaylistSongs
   @TableIndex(name: 'idx_playlist_songs_playlist_id', columns: {#playlistId})

   // QueueItems
   @TableIndex(name: 'idx_queue_items_sort_order', columns: {#sortOrder})
   ```

3. **Migration** — In the `MigrationStrategy.onUpgrade`:
   ```dart
   onUpgrade: (m, from, to) async {
     if (from < 2) {
       // Create indexes
       await m.createIndex(Index('idx_songs_artist',
           'CREATE INDEX idx_songs_artist ON songs (artist)'));
       await m.createIndex(Index('idx_songs_album',
           'CREATE INDEX idx_songs_album ON songs (album)'));
       // ... etc for each index
     }
   },
   ```

4. **Run `build_runner`** to regenerate the database code.

### Verification
- Existing databases upgrade without data loss
- `EXPLAIN QUERY PLAN` on sort queries shows index usage
- Sorting 10K songs by artist/album/date is near-instant

---

## R-14: Focus Border Width Discrepancy

**Requirement**: CLAUDE.md specifies 2px accent border for focus indicator.
**Current state**: `AppConstants.focusBorderWidth` is `3.0`.

### Files to Modify

| File | Action |
|------|--------|
| `lib/core/constants/app_constants.dart` | Change `focusBorderWidth` from `3.0` to `2.0` |

### Implementation Steps

1. **Single-line change** in `app_constants.dart`:
   ```dart
   static const double focusBorderWidth = 2.0; // was 3.0
   ```

2. **Alternatively**, if 3px was a deliberate design decision that looks better on 7-8" screens, update CLAUDE.md to match. This is a product decision — but the spec says 2px.

### Verification
- Focus indicator border is visibly 2px
- Still clearly visible on dark and light themes at 1080p

---

## R-15: Close-to-Tray First-Time Dialog

**Requirement**: First time the user clicks the X button, show a dialog explaining the app will minimize to the system tray, with a "Remember my choice" checkbox.
**Current state**: Settings for `closeToTray` exist. ARB has `minimizeToTray`, `keepRunning`, `keepRunningDesc`, `rememberChoice`. But no distinct first-time dialog flow.

### Files to Modify

| File | Action |
|------|--------|
| `lib/presentation/pages/shell/app_shell.dart` or wherever `WindowListener.onWindowClose` is handled | Add first-time check |
| `lib/core/localization/arb/app_en.arb` | Add first-time dialog strings |

### Implementation Steps

1. **Track first-close state** — Add a `closeToTrayPrompted` boolean to the Settings KV table (default `false`).

2. **On window close**:
   ```dart
   @override
   void onWindowClose() async {
     final closeToTray = ref.read(settingsNotifierProvider).closeToTray;
     final prompted = ref.read(closeToTrayPromptedProvider);

     if (!prompted) {
       // First time — show dialog
       final result = await showDialog<({bool minimize, bool remember})>(
         context: context,
         builder: (_) => const CloseToTrayDialog(),
       );
       if (result != null) {
         if (result.remember) {
           ref.read(settingsNotifierProvider.notifier).setCloseToTray(result.minimize);
           ref.read(settingsNotifierProvider.notifier).setCloseToTrayPrompted(true);
         }
         if (result.minimize) {
           await windowManager.hide();
         } else {
           await windowManager.destroy();
         }
       }
     } else if (closeToTray) {
       await windowManager.hide();
     } else {
       await windowManager.destroy();
     }
   }
   ```

3. **`CloseToTrayDialog`** — A simple `AlertDialog`:
   - Title: "Keep Music FSE running?"
   - Body: "Music FSE will continue playing in the background. You can find it in the system tray."
   - Checkbox: "Remember my choice"
   - Two buttons: "Minimize to Tray" (primary), "Quit" (secondary)
   - Focusable for gamepad

4. **ARB strings**:
   ```json
   "closeToTrayDialogTitle": "Keep Music FSE running?",
   "closeToTrayDialogBody": "Music FSE will continue playing in the background. You can find it in the system tray.",
   "closeToTrayMinimize": "Minimize to Tray",
   "closeToTrayQuit": "Quit"
   ```

5. **Run `build_runner`** for localization.

### Verification
- First X click → dialog appears with choices
- "Minimize to Tray" + "Remember" → app hides, next X directly hides
- "Quit" + "Remember" → app closes, next X directly closes
- Without "Remember" → dialog appears again next time

---

## R-16: Queue Save-as-Playlist Default Name

**Requirement**: "Save as Playlist" from the queue should suggest a default name format (e.g., "Queue — Apr 19, 2026").
**Current state**: `SaveQueueAsPlaylist` use case exists but no default name format string in ARB.

### Files to Modify

| File | Action |
|------|--------|
| `lib/core/localization/arb/app_en.arb` | Add default name format string |
| `lib/presentation/pages/queue/` or wherever the save dialog is | Use the format string as placeholder |

### Implementation Steps

1. **Add ARB string**:
   ```json
   "queueSaveDefaultName": "Queue — {date}",
   "@queueSaveDefaultName": { "description": "Default playlist name when saving queue", "placeholders": { "date": { "type": "String" } } }
   ```

2. **Use in the save dialog** — When the "Save as Playlist" action is triggered, pre-fill the name field:
   ```dart
   final defaultName = l10n.queueSaveDefaultName(
     DateFormat.yMMMd().format(DateTime.now()),
   );
   ```

3. **Run `build_runner`** for localization.

### Verification
- Open queue → "Save as Playlist" → text field shows "Queue — Apr 19, 2026"
- User can edit the name before saving
- Playlist created with the chosen name

---

## R-17: ARB Localization Gaps

**Requirement**: All user-visible text must go through the ARB localization system.
**Current state**: Several features lack ARB strings because the features themselves are unimplemented. This item tracks the **localization-only** gaps that should be addressed alongside each feature.

### Gaps Mapped to Remediation Items

| Missing Strings | Addressed By |
|----------------|-------------|
| Drag/drop: "Drop to add to library", result message | R-08 (Drag & Drop) |
| Multi-select: "X selected", "Select All", "Deselect All", batch messages | R-07 (Multi-Select) |
| Keyboard shortcut editor: all editor strings | R-11 (Configurable Shortcuts) |
| Close-to-tray first-time dialog | R-15 |
| Queue save default name | R-16 |
| Lyrics placeholder | R-10 |

**No standalone work needed** — each feature's implementation section above includes its ARB additions. This item is a tracking checklist to ensure none are forgotten.

### Verification
- After all features are implemented, `grep -rn "TODO\|FIXME\|hardcoded" lib/ | grep -i string` returns nothing
- `flutter gen-l10n` completes without errors
- All new UI text uses `context.l10n.*` or `l10n.*`, never raw strings

---

## R-18: Tests

**Requirement**: CLAUDE.md mandates ≥80% domain+data coverage, ≥60% presentation coverage. Use `mocktail` for mocking.
**Current state**: Zero real tests. Single placeholder `expect(1 + 1, 2)`.

### Test Strategy

Tests should be written **in parallel** with each remediation item above, plus retroactive tests for existing code. Organize by layer following the existing mirrored directory structure.

### Phase A: Domain Layer Unit Tests (Target: ≥80%)

**Priority files** — one test file per use case:

```
test/domain/usecases/
  songs/
    get_all_songs_test.dart
    get_song_by_id_test.dart
    toggle_favorite_test.dart
    mark_song_missing_test.dart
    ...
  playback/
    save_playback_state_test.dart
    restore_playback_state_test.dart
    record_play_test.dart
    ...
  playlists/
    create_playlist_test.dart
    add_song_to_playlist_test.dart
    remove_song_from_playlist_test.dart
    reorder_playlist_test.dart
    ...
  library/
    scan_library_test.dart
    ...
  settings/
    get_sort_preference_test.dart
    set_sort_preference_test.dart
    get_keyboard_shortcuts_test.dart
    ...
  recommendations/
    generate_recommendations_test.dart
    get_recommendations_test.dart
    ...
```

**Pattern for each use case test**:
```dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSongRepository extends Mock implements SongRepository {}

void main() {
  late MockSongRepository mockRepo;
  late GetAllSongs useCase;

  setUp(() {
    mockRepo = MockSongRepository();
    useCase = GetAllSongs(mockRepo);
  });

  test('returns songs sorted by title ascending', () async {
    when(() => mockRepo.getAllSongs(sortBy: 'title', ascending: true))
        .thenAnswer((_) async => Result.success([/* test songs */]));

    final result = await useCase.call(sortBy: 'title', ascending: true);

    expect(result.isSuccess, true);
    verify(() => mockRepo.getAllSongs(sortBy: 'title', ascending: true)).called(1);
  });

  test('returns failure on repository error', () async { ... });
}
```

### Phase B: Data Layer Unit Tests (Target: ≥80%)

**Priority files**:
```
test/data/
  datasources/local/daos/
    song_dao_test.dart        — search ranking, CRUD, pagination
    playlist_dao_test.dart    — add/remove/reorder
    settings_dao_test.dart    — KV store operations
    play_history_dao_test.dart
    queue_dao_test.dart
    recommendations_dao_test.dart
  repositories/
    song_repository_impl_test.dart
    playback_repository_impl_test.dart
    playlist_repository_impl_test.dart
    settings_repository_impl_test.dart
    recommendations_repository_impl_test.dart
  file_system/
    file_scanner_test.dart    — incremental scan logic
  metadata/
    metadata_extractor_test.dart
```

**DAO tests** — Use Drift's `NativeDatabase.memory()` for in-memory SQLite:
```dart
late AppDatabase db;
late SongDao dao;

setUp(() {
  db = AppDatabase(NativeDatabase.memory());
  dao = SongDao(db);
});

tearDown(() => db.close());
```

### Phase C: Presentation Layer Tests (Target: ≥60%)

**Provider tests** (unit tests, no widgets):
```
test/presentation/providers/
  playback_provider_test.dart    — crossfade, skip, state restore, file-not-found
  library_provider_test.dart
  search_provider_test.dart      — debounce, ranking
  scan_provider_test.dart        — progress, incremental
  home_provider_test.dart
  multi_select_provider_test.dart
  sort_preference_provider_test.dart
  input_mode_provider_test.dart
```

**Widget tests** (with `ProviderScope` overrides):
```
test/presentation/widgets/
  focus_highlight_test.dart      — focus traversal, A/X button handling
  song_list_tile_test.dart       — tap, focus, context menu
  mini_player_test.dart          — state display, controls
  context_menu_test.dart         — submenu navigation
  toast_notification_test.dart   — auto-dismiss, undo
  empty_state_test.dart
  multi_select_actions_bar_test.dart
```

**Page tests** (integration-level):
```
test/presentation/pages/
  home/home_page_test.dart
  library/songs_tab_test.dart    — sort, selection, focus
  now_playing/now_playing_page_test.dart
  settings/settings_page_test.dart
  search/search_page_test.dart
```

### Phase D: Gamepad Focus Traversal Tests

Every widget test should include a focus traversal sub-group:
```dart
group('gamepad focus', () {
  testWidgets('receives focus on D-pad down', (tester) async { ... });
  testWidgets('shows focus indicator when focused', (tester) async { ... });
  testWidgets('A button triggers primary action', (tester) async { ... });
  testWidgets('B button dismisses / goes back', (tester) async { ... });
  testWidgets('X button opens context menu', (tester) async { ... });
});
```

### Test Infrastructure Setup

1. **Replace placeholder test**:
   ```dart
   // test/widget_test.dart — delete the 1+1 test, replace with a real app smoke test
   ```

2. **Create test helpers**:
   ```
   test/helpers/
     test_app.dart          — ProviderScope + MaterialApp wrapper with test overrides
     mock_providers.dart    — Common mock providers (database, audio player, etc.)
     test_songs.dart        — Factory for test Song entities
     pump_helpers.dart      — pumpWidget helpers with all required ancestors
   ```

3. **CI integration** — Run `flutter test --coverage` and verify thresholds.

### Verification
- `flutter test` passes with zero failures
- `flutter test --coverage` reports ≥80% domain+data, ≥60% presentation
- No test uses `mockito` (must use `mocktail` per CLAUDE.md)

---

## Execution Order Summary

```
P0 (Quick wins + correctness):
  R-04  QueueSourceType enum fix           ~30 min
  R-14  Focus border width                 ~10 min
  R-01  Sort preference persistence        ~2-3 hrs
  R-02  Search ranking                     ~1-2 hrs
  R-03  File-not-found handling            ~2-3 hrs

P1 (Core UX):
  R-06  Recommendations home provider      ~1-2 hrs
  R-05  Input auto-detect                  ~3-4 hrs
  R-08  Drag & drop                        ~3-4 hrs
  R-07  Multi-select / batch operations    ~6-8 hrs

P2 (Features):
  R-10  Lyrics placeholder                 ~1 hr
  R-09  Incremental scan                   ~4-5 hrs
  R-16  Queue save-as-playlist name        ~30 min
  R-15  Close-to-tray first-time dialog    ~2-3 hrs
  R-11  Configurable keyboard shortcuts    ~8-10 hrs

P3 (Polish + Platform):
  R-13  Database indexes                   ~1-2 hrs
  R-17  ARB localization gaps              (covered by feature items)
  R-12  Native Linux MPRIS                 ~8-12 hrs

Parallel (ongoing):
  R-18  Tests                              ~20-30 hrs total
```

---

## Post-Implementation Checklist

After all items are complete:

- [ ] `flutter analyze` — zero warnings, zero errors
- [ ] `flutter test --coverage` — meets thresholds
- [ ] `dart run build_runner build` — all generated code up to date
- [ ] `flutter gen-l10n` — all ARB strings generate correctly
- [ ] Manual test: full flow on Windows with gamepad
- [ ] Manual test: keyboard-only navigation on all screens
- [ ] Manual test: mouse-only usage (no focus rings visible)
- [ ] Manual test: library with 10K+ songs — sort/search/scroll performance acceptable
- [ ] Manual test: dark mode and light mode on all new UI
- [ ] Manual test: 800px width and 1200px+ width layout breakpoints
- [ ] `flutter build windows --release` / `flutter build macos --release` — builds succeed
