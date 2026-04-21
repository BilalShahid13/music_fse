# Music FSE — Full Screen Experience Music Player for Handhelds

## Requirements & Goals Document

> A local-only music player built with Flutter, designed for the ASUS ROG Ally and similar Windows handhelds. "FSE" stands for **Full Screen Experience**, inspired by the Windows FSE mode on ROG Ally X. Supports XInput gamepad controls natively alongside keyboard/mouse. Targets Windows as the primary platform with macOS and Linux as secondary targets.

---

## 1. Project Overview

### 1.1 Vision

A lightweight, modern, local-only music player that feels native on handheld gaming PCs. The UI strikes a balance between desktop and TV apps — not zoomed-in like Spotify TV, but designed for thumb-friendly navigation with large enough touch targets and clear focus indicators for gamepad use.

### 1.2 Target Platforms

| Platform | Priority | Status |
|----------|----------|--------|
| Windows (x64) | Primary | Must have |
| macOS (arm64 / x64) | Secondary | Must have (development platform) |
| Linux (x64) | Secondary | Should have |

### 1.3 Target Devices

- **Primary**: ASUS ROG Ally, Lenovo Legion Go, Steam Deck (Windows), MSI Claw — devices with 7-8" screens and XInput gamepads
- **Secondary**: Standard Windows/macOS/Linux desktops with keyboard/mouse

### 1.4 Non-Goals

- No internet/streaming functionality — strictly local files
- No Android/iOS support (may come later but out of scope)
- No Game Bar widget (UWP mini-app) — SMTC integration covers the overlay use case
- No cloud sync or accounts
- No lyrics fetching or online metadata lookup

---

## 2. Supported Audio Formats

| Format | Extension(s) | Priority | Notes |
|--------|-------------|----------|-------|
| MP3 | `.mp3` | Must have | ID3v1, ID3v2.3, ID3v2.4 tags |
| FLAC | `.flac` | Must have | Vorbis comments, embedded art |
| WAV | `.wav` | Must have | Limited metadata support |
| AAC | `.aac`, `.m4a` | Should have | Common in ripped CDs |
| OGG Vorbis | `.ogg` | Should have | Common in game soundtracks |
| WMA | `.wma` | Won't have | Legacy format, low demand |

---

## 3. Feature Requirements

### 3.1 Library Management

#### 3.1.1 Music Library Scanning

- **FL-LIB-001**: User can configure one or more folders to scan for music files
- **FL-LIB-002**: App scans configured folders recursively on startup (configurable: auto-scan on/off)
- **FL-LIB-003**: Manual rescan button available in settings
- **FL-LIB-004**: Incremental scan — only process new/modified/deleted files since last scan
- **FL-LIB-005**: Background scanning with progress indicator — UI remains responsive. If the scanner encounters access-denied directories, log a WARN with the path, skip the directory, and continue. After scan completes, if any folders were inaccessible, show toast: "Scan complete. X folders were inaccessible."
- **FL-LIB-006**: Drag & drop files or folders onto the app window to add music. Uses Flutter's `DropTarget` widget (or `desktop_drop` package as fallback). Dropped files/folders are scanned **in-place** (not copied). Songs are added directly to the DB — the folder is NOT auto-added to `scan_folders` (that's a persistent config the user sets in Settings). **Duplicate handling**: files whose `file_path` already exists in the library are silently skipped (no metadata re-read — that's what Rescan is for). Visual feedback: semi-transparent accent overlay covering main content area with `+` icon and "Drop to add to library" text on drag-enter. After drop: toast "Scanning X files..." then "Added Y songs to library" (or "Added Y of X songs (Z already in library)" if duplicates were skipped)
- **FL-LIB-007**: Display total library stats (total songs, total duration, total size)

#### 3.1.2 Metadata Extraction

- **FL-META-001**: Extract from ID3v2 tags (MP3): title, artist, album, album artist, genre, year, track number, disc number, duration, embedded album art
- **FL-META-002**: Extract from Vorbis comments (FLAC/OGG): same fields
- **FL-META-003**: Extract from WAV: limited tags (INFO chunks) + fallback to filename parsing
- **FL-META-004**: Fallback strategy for missing metadata:
  - Title → filename without extension
  - Artist → "Unknown Artist"
  - Album → parent folder name
  - Album Art → look for `cover.jpg`, `cover.png`, `folder.jpg`, `folder.png`, `album.jpg`, `album.png` in the same directory
- **FL-META-005**: Cache all metadata in local SQLite database for fast access
- **FL-META-006**: Cache extracted album art as thumbnails (300x300 max) on disk to avoid re-reading tags. Images larger than 300×300 are downscaled to 300×300 for the cache. Images already ≤300×300 are stored at their original size without upscaling — the UI widget uses `BoxFit.cover` to handle display scaling gracefully

#### 3.1.3 Library Browsing

- **FL-BROWSE-001**: Browse all songs (flat list)
- **FL-BROWSE-002**: Browse by artist (list of artists → songs/albums by that artist)
- **FL-BROWSE-003**: Browse by album (grid of albums with cover art → track listing)
- **FL-BROWSE-004**: Browse by genre
- **FL-BROWSE-005**: Browse by folder structure (mirrors file system hierarchy)
- **FL-BROWSE-006**: Sort any list by: name (A-Z, Z-A), artist, album, date added, duration, year
- **FL-BROWSE-007**: Remember last used sort preference per view
- **FL-BROWSE-008**: "Scroll to Now Playing" button — in any song list that contains the currently playing track, a floating pill-shaped button appears at the bottom-right of the list area (above the mini player bar). Shows the Lucide `disc` icon + "Now Playing" label. The button is **only visible** when: (1) a song is currently playing, (2) the current list/view contains that song, AND (3) the song is scrolled out of the visible viewport. Pressing A (gamepad) or clicking the button scrolls the list to the playing track and briefly highlights it (accent background flash, 500ms fade). The button is focusable and participates in the focus order (placed after the last list item). After scrolling, the button auto-hides. On screens where the playing track is NOT in the current list (e.g., browsing Artists while a playlist plays), the button is hidden entirely. Keyboard shortcut: `Ctrl+G` ("Go to now playing in list")
- **FL-BROWSE-009**: Multi-select / batch operations — hold Shift+click (mouse) or long-press A (hold >500ms, gamepad) to enter multi-select mode. Batch actions: add to playlist, add to queue, remove, toggle favorite
  - **Enter multi-select**: long-press A (gamepad) or Shift+click (mouse) on any list item
  - **Visual indicator**: Checkbox slides in (150ms) on the left of every list item. Selected items get accent-tinted background. Header shows "X selected" badge with "Cancel" button
  - **Navigation in multi-select**: D-pad moves focus normally. Short-press A toggles selection on focused item. X opens batch action menu (Add to Queue, Add to Playlist, Toggle Favorite, Remove). Y = Select All / Deselect All toggle
  - **Exit multi-select**: B cancels and deselects all. Performing a batch action auto-exits multi-select after completion
  - **Button hints during multi-select**: `Ⓐ Toggle  Ⓑ Cancel  Ⓧ Batch Actions  Ⓨ Select All`
- **FL-BROWSE-010**: Virtualized/lazy lists — all list and grid views use virtualized scrolling with lazy image loading and placeholder album art for smooth 60fps at 50K+ songs

### 3.2 Playback

#### 3.2.1 Core Playback

- **FL-PLAY-001**: Play, pause, stop
- **FL-PLAY-002**: Next track, previous track
- **FL-PLAY-003**: Seek via progress bar (drag or tap/click to position)
- **FL-PLAY-004**: Volume control (0-100%) with mute toggle
- **FL-PLAY-005**: Display current track info: title, artist, album, album art, duration, elapsed time
- **FL-PLAY-006**: Gapless playback between consecutive tracks
- **FL-PLAY-007**: Remember playback state on app close (current track, position, volume, queue) and restore on next launch. On launch: silently restore the queue, current track, seek position, volume, shuffle/repeat state — but do **NOT** auto-play. The Home Screen's "Quick Resume" card (Section 6.3.1) serves as the resume prompt — the user presses A/"Resume" to start playback. If the user has enabled `resume_on_launch` in Settings > Playback (default: off), auto-play on launch instead
- **FL-PLAY-008**: Play count increment threshold — `play_count` increments after **30 seconds of listening OR 50% of the track's duration, whichever is less**. A skip before the threshold does NOT increment `play_count` but DOES create a `play_history` entry with `duration_listened_ms` recording actual listen time. This keeps recommendations accurate — skipped tracks don't inflate play counts
- **FL-PLAY-009**: File-not-found handling during playback:
  1. Show error toast: "Can't play [title] — file not found. Skipping..."
  2. Auto-skip to next track after 1 second
  3. Mark the song in the DB with `is_missing = true` — show a subtle warning icon in library views
  4. If **3+ consecutive** tracks fail, show persistent notification: "Multiple files missing. Rescan your library?" with a "Rescan" CTA button
  5. Do NOT auto-delete from library — the file might be on a disconnected external drive
  6. On next library scan, songs whose files reappear get `is_missing` cleared. Songs still missing after scan remain flagged

#### 3.2.2 Shuffle & Repeat

- **FL-SHUF-001**: Shuffle mode toggle (randomize queue order)
- **FL-SHUF-002**: Repeat modes: Off → Repeat All → Repeat One (cycle)
- **FL-SHUF-003**: Shuffle should not repeat a song until all songs in the queue have been played (Fisher-Yates based)

#### 3.2.3 Queue Management

- **FL-QUEUE-001**: View the current play queue ("Up Next")
- **FL-QUEUE-002**: Reorder tracks in the queue via drag & drop or gamepad controls (move up/down)
- **FL-QUEUE-003**: Remove individual tracks from the queue
- **FL-QUEUE-004**: Clear entire queue
- **FL-QUEUE-005**: "Play Next" — insert a track after the currently playing track
- **FL-QUEUE-006**: "Add to Queue" — append a track to the end of the queue
- **FL-QUEUE-007**: Queue persists across app sessions

#### 3.2.4 Crossfade

- **FL-CROSS-001**: Optional crossfade between tracks (0-12 seconds, configurable)
- **FL-CROSS-002**: Crossfade disabled by default
- **FL-CROSS-003**: Crossfade does not apply when Repeat One is active

#### 3.2.5 Equalizer

> Scope: Implement what `just_audio` (or `just_audio` + platform audio APIs) can reliably support. If full parametric EQ is not feasible on Windows/Linux via `just_audio`, fall back to a simpler approach (e.g., bass/treble only, or defer EQ entirely to V1.1). Do not use unreliable or hacky workarounds.

- **FL-EQ-001**: Equalizer bands — use whatever `just_audio`'s `AndroidEqualizer`/platform equivalent supports. If native EQ is not available on Windows, provide bass boost + treble adjustment as a minimum
- **FL-EQ-002**: Preset profiles (if full EQ is available): Flat, Rock, Pop, Jazz, Classical, Bass Boost, Vocal
- **FL-EQ-003**: Custom user profiles (save/load/delete) — only if full EQ is available
- **FL-EQ-004**: Equalizer can be toggled on/off

### 3.3 Playlists

- **FL-PL-001**: Create, rename, delete playlists
- **FL-PL-001a**: Create / Rename Playlist dialog:
  - **Layout**: Modal dialog with a title ("New Playlist" or "Rename Playlist"), a single text input field, and two buttons: "Create"/"Save" (primary, accent-colored) and "Cancel" (secondary)
  - **Default name (create)**: "My Playlist". If that name exists, append a number: "My Playlist (2)", "My Playlist (3)", etc.
  - **Default name (rename)**: Pre-filled with current playlist name, text fully selected
  - **Validation**: Name cannot be empty. Name cannot exceed 100 characters. Whitespace-only names are rejected. Duplicate names are **allowed** (playlists are identified by ID, not name)
  - **Gamepad**: Default focus on text input (activates system keyboard). D-pad down to buttons. A on "Create"/"Save" confirms. B or A on "Cancel" dismisses. All other buttons disabled (Modal/Dialog row in matrix)
  - **After creation**: Navigate to the new (empty) playlist detail screen (6.3.6)
  - **After rename**: Stay on current screen, name updates in-place. Toast: "Playlist renamed"
  - **Used by**: "Create Playlist" button (6.3.9), "New Playlist..." in Add to Playlist submenu (FL-INPUT-008a), Ctrl+N shortcut, "Rename" in playlist context menu
- **FL-PL-001b**: Destructive action confirmation dialogs:
  - **Delete playlist**: Modal dialog — "Delete \"[playlist name]\"? This cannot be undone." Buttons: "Cancel" (default focus, safe choice) and "Delete" (destructive, tinted with error color from theme). Gamepad: A on focused button confirms, B always cancels. After deletion: navigate back to Playlists List screen, toast: "Playlist deleted"
  - **Clear queue**: Modal dialog — "Remove all N tracks from the queue?" Buttons: "Cancel" (default focus) and "Clear" (destructive). After clearing: queue panel stays open showing empty state, toast: "Queue cleared"
  - **No confirmation needed for**: remove single song from playlist (has undo toast), remove from queue via Y (has undo toast), unfavorite (has undo toast). These are lightweight, reversible actions
- **FL-PL-002**: Add songs to playlist from any browse view or now playing
- **FL-PL-003**: Remove songs from playlist
- **FL-PL-004**: Reorder songs within a playlist (drag & drop / gamepad)
- **FL-PL-005**: Duplicate playlist
- **FL-PL-006**: Playlist cover art: auto-generated mosaic from first 4 unique album arts, or user can set custom image. Mosaic is generated on playlist creation and cached as `playlist_covers/{playlist_id}.jpg`. Regenerated lazily on next display after songs are added/removed (by comparing a hash of the first 4 song IDs against the cached version). If the user sets a custom cover via `cover_art_path`, auto-generation is permanently disabled for that playlist.
  - **Mosaic edge cases**: 0 songs (empty playlist) → Lucide `music` icon centered on a themed background color card. 1 unique album art → use that single art full-size. 2 unique arts → 2×1 vertical split. 3 unique arts → 2×2 grid with the first art repeated in the 4th slot. 4+ unique arts → standard 2×2 mosaic of first 4
- **FL-PL-007**: Import/export playlists as M3U files
  - **Export**: Available via context menu on any playlist (FL-INPUT-008). Saves a `.m3u8` file (UTF-8 M3U) with relative or absolute paths (user choice in dialog)
  - **Import**: "Import M3U" button in the Playlists list screen header (next to "Create Playlist"). Opens system file picker filtered to `.m3u`/`.m3u8`. Parses the file, resolves paths against the library DB by `file_path`. Creates a new playlist named after the M3U filename. Toast: "Imported [name] (X of Y tracks found in library)" — tracks not in the library are silently skipped (they may be on a different machine). Gamepad: button is focusable in the header, A to activate
- **FL-PL-008**: Smart playlists (auto-generated, non-editable):
  - "Recently Added" (last 30 days)
  - "Most Played" (top 50 by play count)
  - "Recently Played" (last 5 sessions worth of songs)
  - **Session definition**: A session starts when the app launches. Each launch generates a new `session_id` in `play_history` (max existing + 1). "Last 5 sessions" = songs with the 5 highest distinct `session_id` values. Deterministic — no ambiguous time-gap logic

### 3.4 Search

- **FL-SEARCH-001**: Global search across songs, artists, albums, genres, playlists
- **FL-SEARCH-002**: Real-time search-as-you-type with debouncing (300ms)
- **FL-SEARCH-003**: Search results grouped by category (Songs, Artists, Albums, Playlists). Each category shows a **maximum of 5 results** initially. If more results exist, a focusable "Show all (N)" button appears at the end of the category group. Pressing A expands the category in-line to show all results (virtualized list). Categories with 0 results are hidden entirely. Results are ranked by relevance: exact title match > starts-with match > contains match
- **FL-SEARCH-004**: Search history (last 10 queries, clearable)
- **FL-SEARCH-005**: Gamepad: rely on the system on-screen keyboard for V1. Every target handheld (ROG Ally, Legion Go, Steam Deck with Windows) has an OS-level on-screen keyboard accessible via a dedicated button or touch. Building a custom gamepad-navigable virtual keyboard is deferred to V1.1 only if user testing shows the system keyboard is inadequate

### 3.5 Favorites

- **FL-FAV-001**: Toggle favorite on any song (heart icon)
- **FL-FAV-002**: "Favorites" accessible as a special auto-playlist
- **FL-FAV-003**: Favorite toggle accessible from: library views, now playing, queue, mini player context menu

### 3.6 Recently Played

- **FL-RECENT-001**: Track last played timestamp per song
- **FL-RECENT-002**: "Recently Played" section on home screen showing last 10 unique songs
- **FL-RECENT-003**: Full recently played history accessible from home (last 100)

### 3.7 Recommendations ("For You")

- **FL-REC-001**: Fully offline, heuristic-based recommendations
- **FL-REC-002**: Algorithm inputs:
  - Play count per song/artist/album/genre
  - Recent listening patterns (last 7 days vs. overall)
  - Time-of-day patterns (if available)
  - Songs favorited
- **FL-REC-003**: Recommendation categories:
  - "More from artists you love" — top songs from your most-played artists that you haven't played recently
  - "Rediscover" — songs you used to play a lot but haven't touched in 30+ days
  - "Deep cuts" — least-played songs from your most-played artists/genres
  - "Genre mix" — shuffle from your top 3 genres
- **FL-REC-004**: Recommendations refresh on each app launch and can be manually refreshed
- **FL-REC-005**: Minimum library size of 20 songs before recommendations are shown

#### 3.7a Recommendation Algorithm Specification

> Scoring runs on a **background isolate** — never blocks the UI thread. Results are cached in memory and persisted to a lightweight `recommendations` table (category, song_id, generated_at). Regenerated on launch or manual refresh.

**Category: "More from artists you love"**
- Query: Top 5 artists ranked by total play_count across all their songs
- From each artist, select songs sorted by: `(artist_total_plays × 0.7) + (song_play_count × 0.3)` descending
- Exclude songs played in the last 3 days (to keep it fresh)
- Pick top 2 per artist → **10 songs total**
- If an artist has fewer than 2 eligible songs, fill from the next-ranked artist

**Category: "Rediscover"**
- Query: Songs where `play_count ≥ 5` AND `last_played_at < (now - 30 days)`
- Sort by `play_count` descending (most-loved forgotten songs first)
- Pick top **10 songs**
- If fewer than 10 qualify, lower the threshold to `play_count ≥ 3` and retry

**Category: "Deep cuts"**
- Query: Identify user's top 5 genres by total play_count. From songs in those genres, select songs where `play_count ≤ 2`
- Shuffle randomly (the point is discovery, not ranking)
- Pick **10 songs**
- Exclude songs already appearing in other recommendation categories

**Category: "Genre mix"**
- Query: Top 3 genres by total play_count across all songs
- From each genre, select a random sample of 5 songs
- **15 songs total** (5 per genre)
- If a genre has fewer than 5 songs, take all and fill remainder from the 4th genre

**Edge Cases:**

| Condition | Behavior |
|-----------|----------|
| Library < 20 songs | Show empty state: "Play more music to get personalized recommendations." No recommendation rows |
| Total plays < 50 | Only show "Genre mix" using genre distribution by song count (not play count). Hide other categories |
| Total plays 50–200 | Show "Genre mix" + "More from artists you love". Hide "Rediscover" and "Deep cuts" (not enough history) |
| Total plays > 200 | Show all 4 categories |
| Single-artist library | "More from artists you love" becomes "Your top tracks" (play_count desc). Other categories still work |
| Single-genre library | "Genre mix" becomes "Random picks" (random 15 songs). Label changes accordingly |
| All songs played recently (< 3 days) | "More from artists you love" drops the recency exclusion, picks lowest-recent-play songs instead |
| "Rediscover" has 0 results | Hide the row entirely. Don't show an empty row |
| Favorited songs boost | Songs where `is_favorite = true` get a 1.2× multiplier on their score in "More from artists you love" |

---

## 4. Input & Controls

### 4.1 XInput Gamepad Controls

- **FL-INPUT-001**: Full app navigation via XInput gamepad (D-pad, analog sticks, face buttons)
- **FL-INPUT-002**: Control mapping:

| Input | Action |
|-------|--------|
| D-pad Up/Down | Navigate list items / menu items |
| D-pad Left/Right | Navigate tabs / horizontal lists / seek ±5s in now playing |
| A button | Select / Confirm / Play |
| B button | Back / Cancel / Close overlay |
| X button | Context menu (add to playlist, play next, etc.) |
| Y button | Toggle favorite |
| Left Bumper (LB) | Previous track |
| Right Bumper (RB) | Next track |
| Left Trigger (LT) | Volume down (analog) |
| Right Trigger (RT) | Volume up (analog) |
| Start | Toggle play/pause |
| Back/Select | Open search |
| Left Stick press | Shuffle toggle |
| Right Stick press | Repeat mode cycle |
| Left Stick | Scroll navigation (analog scroll speed) |
| Right Stick | Seek through current track (horizontal) |

- **FL-INPUT-003**: Visible focus indicator on all interactive elements when gamepad is active
- **FL-INPUT-004**: Auto-detect input method: show focus indicators when gamepad input detected, hide when mouse moves
- **FL-INPUT-005**: UI navigation sounds: subtle, satisfying audio feedback on button press / focus change (similar to Steam Big Picture mode). Configurable: on/off and volume level as a 3-position toggle — **Off** (0%), **Quiet** (50%), **Normal** (100%). Default: Normal. Stored in settings KV as `nav_sound_level`: `"off"` | `"quiet"` | `"normal"`. Independent from music volume
- **FL-INPUT-006**: Small library of built-in UI sounds: navigate, select, back, error. Short samples (~50-100ms), low-latency playback via a separate lightweight audio channel (must not interrupt music)
  - **Format**: WAV, 22kHz, 16-bit mono. WAV for zero-decode-latency
  - **Sounds**: 4 files — `navigate.wav` (soft tick), `select.wav` (confirmation chirp), `back.wav` (descending tone), `error.wav` (low buzz). Total <100KB bundled as assets
  - **Playback**: On Windows, use Win32 `PlaySound` API via `dart:ffi` (fire-and-forget, separate from music audio stream). On macOS/Linux, use a second lightweight `AudioPlayer` instance dedicated to UI sounds with independently controlled volume
  - **Source**: Generate programmatically (sine wave tones) or source from a CC0 sound pack. Actual sound design deferred to implementation phase
- **FL-INPUT-007**: Contextual button hints bar at the bottom of the screen (console-style). **Right-aligned** (hugging the right edge, matching PS5/console UI convention). Shows available actions for the current context (e.g., `Ⓐ Select  Ⓑ Back  Ⓧ Options  Ⓨ Favorite`). Hints update dynamically based on focused element and screen. Only visible when gamepad/keyboard input is active; hides on mouse movement
- **FL-INPUT-008**: Context menu items vary by context:
  - **Song in library**: Play, Play Next, Add to Queue, Add to Playlist ▸, Toggle Favorite, Go to Artist, Go to Album
  - **Song in playlist**: Play, Play Next, Add to Queue, Remove from Playlist, Toggle Favorite, Go to Artist, Go to Album
  - **Song in queue**: Play Now, Move Up, Move Down, Remove from Queue, Toggle Favorite
  - **Album**: Play All, Shuffle, Add to Queue, Add to Playlist ▸, Go to Artist
  - **Artist**: Play All, Shuffle, Add to Queue
  - **Playlist**: Play All, Shuffle, Rename, Duplicate, Delete, Export as M3U

- **FL-INPUT-008a**: "Add to Playlist ▸" submenu behavior:
  - Opens a scrollable sub-menu anchored to the parent context menu item
  - **First item**: "New Playlist..." (Lucide `plus` icon) — selecting this opens the Create Playlist dialog (see FL-PL-001a), then adds the song/album to the newly created playlist
  - **Remaining items**: All user playlists sorted by `updated_at` desc. Each row shows: playlist name + song count. Max **8 visible items** without scrolling; list scrolls with D-pad if more exist
  - **On select (A)**: Adds the song (or all songs from album) to the chosen playlist, closes both menus, toast: "Added to [playlist name]"
  - **On back (B)**: Closes submenu, returns focus to the parent context menu item
  - **If no user playlists exist**: Only "New Playlist..." is shown
  - **Gamepad**: D-pad up/down navigates the submenu. A selects. B goes back to parent menu

- **FL-INPUT-009**: Volume trigger (LT/RT) mapping: dead zone 15% (trigger value 0–0.15 → no change). Linear mapping from 15–100% → volume change rate 0–50%/second. Full trigger pull goes 0→100% in ~2 seconds. On-screen volume overlay appears briefly (1s auto-dismiss) when trigger input is detected, similar to the system volume OSD. Volume slider animates to follow with a 100ms implicit animation

#### 4.1a Per-Screen Button Override Matrix

> Every screen has access to the global button mapping defined in FL-INPUT-002. This table documents **where buttons deviate from global behavior** on specific screens. The button hints bar reads this matrix to display the correct context. Inputs not listed for a screen use their global mapping. "*(disabled)*" means the button does nothing on that screen.

| Screen | LB | RB | Y | X | L3 (Left Stick Press) | R3 (Right Stick Press) | Special Notes |
|--------|----|----|---|---|----|----|---------|
| **Onboarding** | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | A=Next, B=Back, Start=Skip. No playback controls during onboarding |
| **Home** | Prev track | Next track | Fav focused song | Context menu on focused card | Shuffle toggle | Repeat cycle | All global defaults apply |
| **Library (tabbed)** | **Switch tab left** | **Switch tab right** | Fav focused song | Context on focused item | Shuffle toggle | Repeat cycle | LB/RB override: tab switching takes priority over prev/next track |
| **Artist Detail** | Prev track | Next track | Fav focused song | Context on focused item | Shuffle toggle | Repeat cycle | — |
| **Album Detail** | Prev track | Next track | Fav focused song | Context on focused item | Shuffle toggle | Repeat cycle | — |
| **Genre Detail** | Prev track | Next track | Fav focused song | Context on focused item | Shuffle toggle | Repeat cycle | — |
| **Folder Browser** | Prev track | Next track | **Fav focused song** (disabled on folders) | Context on focused item/folder | Shuffle toggle | Repeat cycle | B = go up one folder level. Y toggles favorite on songs; does nothing when a folder is focused. Button hints update to show/hide Y based on focused item type |
| **Favorites** | Prev track | Next track | **Unfavorite focused song** (with undo toast) | Context on focused song | Shuffle toggle | Repeat cycle | Y = unfavorite (immediate remove from list + undo toast). Same context menu as "Song in library". B does nothing (root screen) |
| **Now Playing** | Prev track | Next track | Fav current song | *(disabled)* | Shuffle toggle (visual feedback) | Repeat cycle (visual feedback) | Right stick = seek. D-pad L/R = ±5s seek. No context menu (X disabled) |
| **Queue Panel** | Prev track | Next track | **Remove from queue** | **Enter reorder mode** | Shuffle toggle | Repeat cycle | Y repurposed: remove is more useful than fav in queue context. X enters reorder (D-pad up/down to move, A to confirm, B to cancel) |
| **Search** | Prev track | Next track | Fav focused song | Context on focused result | Shuffle toggle | Repeat cycle | Back/Select button already on search screen |
| **Playlists List** | Prev track | Next track | *(disabled)* | Context on focused playlist | Shuffle toggle | Repeat cycle | Y disabled (no fav on playlists themselves) |
| **Playlist Detail** | Prev track | Next track | Fav focused song | Context on focused song | Shuffle toggle | Repeat cycle | — |
| **Settings** | **Jump to prev section** | **Jump to next section** | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | LB/RB override: section jumping. Pure navigation screen, no playback/fav actions |
| **EQ Overlay** | **Prev preset** | **Next preset** | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | D-pad L/R = switch bands, D-pad U/D = adjust gain. LB/RB for quick preset A/B testing |
| **Context Menu** | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | Focus trapped. D-pad + A to select, B to close. All other buttons disabled |
| **Modal/Dialog** | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | *(disabled)* | Focus trapped. A on confirm, B to dismiss. All other buttons disabled |
| **Multi-select (any screen)** | Prev track | Next track | **Select All / Deselect All** | **Open batch action menu** | Shuffle toggle | Repeat cycle | Y/X repurposed during multi-select mode. A toggles selection on focused item. B exits multi-select |

**Design principles for this matrix:**
1. **LT/RT (volume) and Start (play/pause) are NEVER overridden** — they work identically in every context, even in modals. Muscle memory must be reliable
2. **Back/Select (open search) is NEVER overridden** — search is always one button press away
3. **LB/RB are the only contextual buttons** — they switch tabs (Library), jump sections (Settings), cycle presets (EQ), or fall back to prev/next track. The button hints bar must clearly communicate the current LB/RB behavior
4. **Y and X can be repurposed per-screen** — but only when the default action is irrelevant (e.g., no favorites on folders) or a screen-specific action is significantly more useful (e.g., Remove in Queue)
5. **All buttons disabled in overlays** (context menu, modal, dialog) — prevents accidental actions. Only D-pad, A, and B work inside overlays
6. **L3/R3 (stick presses) are global everywhere except overlays** — shuffle and repeat are always accessible, but disabled in trapped-focus contexts to prevent accidental toggling

- **FL-KB-001**: Standard keyboard shortcuts:

| Key | Action |
|-----|--------|
| Space | Play/Pause |
| Left/Right Arrow | Seek ±5s |
| Up/Down Arrow | Volume ±5% |
| Ctrl+Left/Right | Previous/Next track |
| Ctrl+F | Open search |
| Ctrl+L | Open library |
| Escape | Close overlay / Go back |
| Ctrl+N | New playlist |
| Ctrl+Q | Toggle queue panel |
| F11 | Toggle fullscreen |
| Ctrl+, | Open settings |
| Enter | Select / Confirm |
| Delete | Remove from playlist/queue (when focused) |
| Ctrl+G | Scroll to now playing track in current list |

- **FL-KB-002**: All keyboard shortcuts configurable in settings. Stored in `settings` KV table under key `keyboard_shortcuts` as a JSON object: `{"play_pause": "Space", "seek_forward": "ArrowRight", ...}`. Conflict detection: if two actions are mapped to the same key, highlight the conflict in the UI and prevent saving until resolved. "Reset to Defaults" button available. Shortcut editor: focus a row, press A (gamepad) or Enter to "listen" for a new key, press the desired key, confirm or B/Escape to cancel
- **FL-KB-003**: Keyboard shortcut overlay — press `?` or `F1` to show a modal with all available shortcuts grouped by category. Dismissable with Escape

### 4.3 Mouse/Touch

- **FL-MOUSE-001**: Full mouse support — click, hover states, scroll wheel
- **FL-MOUSE-002**: Touch-friendly hit targets (minimum 44x44 logical pixels)
- **FL-MOUSE-003**: Right-click context menus
- **FL-MOUSE-004**: Mouse scroll wheel for volume on the volume slider

---

## 5. Platform Integration

### 5.1 Windows SMTC (System Media Transport Controls)

- **FL-SMTC-001**: Register as a media source with Windows SMTC
- **FL-SMTC-002**: Display now playing info (title, artist, album art) in:
  - Windows volume flyout
  - Game Bar media overlay
  - Any app that reads SMTC (e.g., Xbox Game Bar, OBS)
- **FL-SMTC-003**: Respond to SMTC commands: play, pause, next, previous, seek
- **FL-SMTC-004**: Update playback status (playing, paused, stopped) and position in real-time

### 5.2 Media Key Support

- **FL-MEDIA-001**: Respond to hardware media keys (Play/Pause, Next, Previous, Stop)
- **FL-MEDIA-002**: Works even when app is not focused (global hotkeys)

### 5.3 System Tray (Windows)

- **FL-TRAY-001**: Minimize to system tray option
- **FL-TRAY-002**: Tray icon with right-click menu: Play/Pause, Next, Previous, Open, Quit
- **FL-TRAY-003**: Tray tooltip shows current track info
- **FL-TRAY-004**: Close button behavior configurable: close to tray vs. quit app. Default: **close to tray** (standard music player behavior). On the very first close, show a one-time dialog: "Keep Music FSE running in the background?" with two options — "Minimize to Tray" (default focus, A button) and "Quit" (B button). Checkbox: "Remember my choice." The dialog is gamepad-navigable. Changeable later in Settings > System

### 5.4 Window Management

- **FL-WIN-001**: Remember window position and size across sessions
- **FL-WIN-002**: Minimum window size: 800x500
- **FL-WIN-003**: Custom title bar (no default Windows title bar) integrated with app design
- **FL-WIN-004**: Fullscreen mode (F11)
- **FL-WIN-005**: Start minimized / start with Windows options

### 5.5 Linux Integration

- **FL-LINUX-001**: MPRIS D-Bus integration (Linux equivalent of SMTC)
- **FL-LINUX-002**: Media key support via D-Bus
- **FL-LINUX-003**: System tray via StatusNotifierItem / AppIndicator

### 5.6 macOS Integration

- **FL-MAC-001**: Now Playing integration via `MPNowPlayingInfoCenter` (macOS equivalent of SMTC)
- **FL-MAC-002**: Media key support (play/pause/next/prev via keyboard media keys)
- **FL-MAC-003**: Menu bar tray icon with playback controls (similar to Windows system tray)
- **FL-MAC-004**: Native macOS title bar style (traffic light buttons) or custom title bar matching app design

### 5.7 Single Instance Enforcement

- **FL-SINGLE-001**: Only one instance of the app can run at a time
- **FL-SINGLE-002**: If a second instance is launched, it should focus/activate the existing window and pass any file arguments to it
- **FL-SINGLE-003**: Implementation per platform:
  - **Windows**: Named mutex for instance detection + named pipe `\\.\pipe\MusicFSE` for IPC
  - **macOS**: Unix domain socket at `~/Library/Application Support/MusicFSE/.ipc.sock`
  - **Linux**: Unix domain socket at `~/.local/share/music-fse/.ipc.sock`
  - **Protocol**: Line-delimited JSON messages: `{"action": "open", "files": ["/path/to/song.mp3"]}` or `{"action": "focus"}` (bring window to front). First instance listens on the socket/pipe. Second instance connects, sends message, exits. `window_manager` handles bringing the window to front

### 5.8 File Association

- **FL-ASSOC-001**: Register as a handler for supported audio file types (`.mp3`, `.flac`, `.wav`, `.m4a`, `.ogg`)
- **FL-ASSOC-002**: Double-clicking an audio file in the OS file manager opens it in Music FSE. If the app is **not running**, launch and play the file immediately. If the app **is already running** (single-instance IPC), insert the file as "Play Next" after the currently playing track and begin playing it. If nothing is playing, just play it. Multiple files selected in the OS: all are inserted into the queue in order, first one starts playing
- **FL-ASSOC-003**: File association is optional and configurable in settings (don't force it on install)

### 5.9 In-App Notifications (Toast/Snackbar)

- **FL-TOAST-001**: Non-intrusive toast notifications for user actions: "Added to queue", "Added to playlist", "Removed from favorites", etc.
- **FL-TOAST-002**: Toasts appear at the bottom-center, above the mini player bar, auto-dismiss after 3 seconds
- **FL-TOAST-003**: Some toasts include an undo action (e.g., "Removed from playlist" → [Undo])
- **FL-TOAST-004**: Error toasts (e.g., "File not found", "Unsupported format") use a distinct error color

---

## 6. UI / UX Requirements

### 6.1 Design Philosophy

- **Clean, modern, content-focused** — album art is prominent, text is readable at arm's length (~14-18" from screen)
- **Handheld-first** — all interactive elements reachable with gamepad, generous spacing
- **Not a "TV app"** — no oversized cards or 3-item grids. Dense enough to show meaningful content on a 7" 1080p screen
- **Fluid animations** — purposeful, polished transitions that guide the eye and confirm actions. Not decorative or excessive — this app runs alongside games and must stay lightweight
- **Contextual actions** — long-press / X-button context menus instead of cluttered permanent buttons

### 6.1a Handheld & Gamepad Design System

> **This section is mandatory for every screen, widget, and interaction in the app.** The primary target device is a 7-8" 1080p handheld held ~14-18 inches from the eyes, operated via an XInput gamepad with no keyboard, mouse, or touchscreen. Every design decision must be validated against this scenario first, then adapted for desktop second.

#### Physical Context
- **Screen**: 7-8" diagonal, 1920×1080, ~315 PPI, held in landscape
- **Viewing distance**: 14-18 inches (arm's length while gripping the device)
- **Input**: Two thumbsticks, D-pad, ABXY, bumpers, triggers — no precision pointer
- **Hands**: Both hands grip the device at all times; no free hand to tap the screen

#### Sizing Rules (Mandatory Minimums)

| Element | Minimum Size | Notes |
|---------|-------------|-------|
| Focusable item (button, card, list tile) | 48×48 logical px | Must be easily selectable with D-pad/stick |
| List tile height | 56 lp | Song rows, menu items, settings rows |
| Touch/click target (icon buttons) | 44×44 lp | Per Material 3 spec, but we round up to 48 |
| Grid card (album, artist, playlist) | 140×180 lp min | Art (140×140) + 2 lines of text below |
| Horizontal scroll card | 130×170 lp min | For "Recently Played" / recommendation rows |
| Nav rail icon | 48×48 lp | With 8 lp vertical gap between items |
| Mini player bar height | 84 lp | 3-column grid: left (art+info), center (controls + progress bar), right (volume) |
| Button hints bar height | 40 lp | Icons + labels at small caption size |
| Spacing between focusable items | ≥8 lp | Prevents mis-navigation with D-pad |
| Screen edge padding | 16-24 lp | Content must not touch window edges |

#### Focus & Navigation Rules

1. **Every interactive element must be focusable** — no element should exist that can only be reached by mouse/touch
2. **Focus order must be logical** — left-to-right, top-to-bottom, matching visual layout. Never jump focus across the screen unexpectedly
3. **Focus wrapping**: at the end of a list, focus wraps to the beginning (configurable). In grids, D-pad left at column 0 goes to the nav rail
4. **Focus memory**: when navigating away from a screen and back, restore focus to the last focused item on that screen
5. **Focus indicator**: 3px focus-border-color (defaults to accent) border/ring + subtle scale-up (1.02x for tiles, 1.05x for cards) + glow shadow. Uses a dedicated focus color token so the focus border color can be changed independently of the accent color. Must be visible against both dark and light themes
6. **Focus groups**: screens are divided into focus groups (nav rail, main content, mini player, button hints). Bumpers (LB/RB) or a designated button switch between groups; D-pad/stick moves within a group
7. **No dead ends**: from any focusable element, every D-pad direction must either move focus to another element or do nothing (no focus loss)
8. **Scroll-into-view**: when focus moves to an off-screen item (via D-pad), the list must auto-scroll to reveal it with at least 1 item of padding above/below

#### Per-Widget Gamepad Behavior

| Widget | Gamepad Behavior |
|--------|-----------------|
| Song list tile | D-pad up/down to move, A to play, X for context menu, Y to toggle favorite |
| Album/Artist/Playlist card | D-pad navigate grid, A to open detail, X for context menu |
| Horizontal scroll row | D-pad left/right to scroll one card at a time, LB/RB to page-scroll |
| Tab bar (Library tabs) | LB/RB to switch tabs, not D-pad left/right (D-pad reserved for content) |
| Progress/seek bar | D-pad left/right ±5s small seek, hold for continuous seek, right stick for fine seek |
| Volume slider | LT/RT analog control, D-pad up/down when focused |
| Toggle/switch | A to toggle |
| Dropdown/select | A to open, D-pad to choose, A to confirm, B to cancel |
| Text input (search) | A to activate on-screen keyboard or system keyboard, B to dismiss |
| Context menu | D-pad to navigate items, A to select, B to close |
| Modal/dialog | Focus trapped inside, B to dismiss, A on confirm button |
| Onboarding steps | A for "Next", B for "Back", Start to skip |
| Drag-reorder (queue/playlist) | X to enter reorder mode, D-pad up/down to move, A to confirm position, B to cancel |

#### Screen-Specific Gamepad Requirements

Every screen spec (6.3.x) must define:
1. **Default focus**: which element receives focus when the screen opens
2. **Focus groups**: how the screen is divided into navigable groups
3. **Button mapping context**: what each face button does on this screen (feeds into the button hints bar)
4. **Scroll behavior**: how content scrolls (D-pad step, stick analog, bumper page)

#### Testing Criteria for Handheld

Before any screen is considered complete, it must pass:
- [ ] **All actions reachable with gamepad only** — no mouse/keyboard required
- [ ] **No focus traps** — user can always navigate away from any element
- [ ] **Text readable at 18 inches** — minimum 14sp for body text on 7" 1080p
- [ ] **Focus indicator visible** — on every focusable element, in both themes
- [ ] **Context menu accessible** — via X button on every item that has actions
- [ ] **Button hints correct** — bar at bottom shows accurate actions for focused element
- [ ] **Smooth scrolling** — 60fps with virtualized lists at 1000+ items
- [ ] **No layout overflow** — content fits within 1920×1080 at all times

### 6.2 Layout Structure

```
┌──────────────────────────────────────────────┐
│  Custom Title Bar (drag area, min/max/close) │
├────────┬─────────────────────────────────────┤
│        │                                     │
│  Side  │        Main Content Area            │
│  Nav   │                                     │
│  Rail  │                                     │
│        │                                     │
│        │                                     │
│        │                                     │
├────────┴─────────────────────────────────────┤
│  Mini Player Bar (persistent, shows current)         │
│  [art] Title - Artist    advancement advancement ► ► ►   │
│  3-col grid: [art+info] [shuffle ◄◄ ▶ ►► repeat]  [🔊] │
│                          ━━━━━━━━━━━━━━━━━                │
│                         3:45 ━━━━━━━━ -2:37              │
├──────────────────────────────────────────────┤
│         Ⓐ Select  Ⓑ Back  Ⓧ Options  Ⓨ Fav │  ← Button hints (right-aligned)
└──────────────────────────────────────────────┘
```

- **Side Navigation Rail** (always visible, collapsed icons + labels):
  - Home
  - Library
  - Search
  - Playlists
  - Favorites
  - Settings
- **Main Content Area**: changes based on active nav item
- **Mini Player Bar**: persistent at bottom, click/A-button to expand to full Now Playing view. **Spotify-style 3-column grid layout**: left column (album art 48×48 + song title/artist), center column (transport controls row: shuffle, prev, play/pause, next, repeat — with progress bar + elapsed/remaining time below), right column (volume control). Play/pause button: accent-filled circle with 3px accent border, white play icon. Remaining time shown in negative format (e.g., `-2:37`). Total height: 84 lp
- **Now Playing**: expands from mini player as a full-screen overlay with album art, controls, queue access

### 6.3 Screens

#### 6.3.0 First-Run Onboarding
- **Step 1 — Welcome**: App logo, name, tagline ("Your music. Your controls. Full screen experience.")
- **Step 2 — Choose Music Folders**: Prominent "Add Folder" button, shows selected folders as chips. Can skip (will prompt later)
- **Step 3 — Theme Selection**: Toggle Dark/Light, pick accent color
- **Step 4 — Scanning**: Progress bar scanning selected folders, shows count of songs found in real-time. "Done" button when complete
- **Navigation**: Back/Next with gamepad (B/A), can skip entire onboarding
- **Onboarding only shows once** (flag in settings DB). Can be re-triggered from Settings > About > "Re-run setup"
- **Gamepad**: Default focus on "Next" / primary action button. D-pad navigates between interactive elements within each step. LB/RB disabled during onboarding

#### 6.3.1 Home Screen

The Home screen is the app's landing page. It combines quick-resume, recent history, and personalized recommendations in a vertically scrollable layout.

**Layout (top to bottom):**

1. **Quick Resume Section** (always visible if there's playback history)
   - Shows the last played context (album, playlist, or queue) as a large hero card
   - Card displays: album art (or playlist icon), title, subtitle ("Album · Artist" or "Playlist · 24 songs"), and a prominent "Resume" button
   - If last context was a single song (not from album/playlist), show the song with album art
   - A button resumes playback from where the user left off (same position in queue)
   - If no playback history exists (fresh install), this section is hidden

2. **Recently Played Row**
   - Row header: "Recently Played" on the left, **"See All"** focusable text button on the right (navigates to a full-screen list of the last 100 recently played songs, sorted by `played_at` descending, same layout/sort options as Library Songs tab; B returns to Home)
   - Horizontal scrollable row of the last 10 distinct songs/albums played
   - Each card: album art thumbnail (130×170 lp), song title, artist name
   - Tapping a song plays it; tapping an album opens the album detail
   - Shows time since last played as subtle caption ("2h ago", "Yesterday")
   - If fewer than 3 items, row is hidden (not enough to be useful)

3. **Recommendation Rows** (conditional on play history — see Section 3.7a)
   - Each recommendation category is a separate horizontal scrollable row
   - Row header: category name on the left, "Refresh" icon button on the right
   - Each card: album art, song title, artist name (130×170 lp)
   - Number of visible rows depends on play history thresholds (see 3.7a edge cases)
   - If library < 20 songs or no play history: show empty state placeholder instead

4. **Quick Access Row** (always visible if user has playlists)
   - Horizontal scrollable row of the user's most recently updated playlists (sorted by `updated_at` descending, max 10)
   - Each card: playlist cover art (or auto-generated mosaic from first 4 song arts), playlist name, song count
   - If no playlists exist, show a "Create your first playlist" CTA card

5. **Library Stats Footer**
   - Compact single line: "1,234 songs · 89 artists · 45 albums · 4d 12h total"
   - Subtle text, non-focusable (informational only)

**Gamepad behavior:**
- Default focus on Quick Resume "Resume" button (or first Recently Played card if no resume context)
- D-pad down moves between sections (Quick Resume → Recently Played → Recommendation rows → Quick Access)
- D-pad left/right scrolls within a horizontal row
- A plays/opens the focused item
- X opens context menu on focused song/album card
- Y toggles favorite on focused song
- Left stick analog scrolls vertically through all sections
- B does nothing on Home (it's the root screen)

#### 6.3.2 Library Screen
- **Tabs**: All Songs | Artists | Albums | Genres | Folders
- **Each tab**: Sortable list/grid with appropriate layout
  - Songs: song list tiles (same `SongListTile` widget used elsewhere: title, artist, album, duration). Sort controlled by a **dropdown/selector at the top of the tab** (not clickable column headers). Sort options: name A-Z, name Z-A, artist, album, date added, duration, year
  - Artists: grid of artist cards (artist name, song count, optional placeholder icon — Lucide `user` — when no artist image is available)
  - Albums: grid with cover art, album name, artist, year
  - Genres: list with song count
  - Folders: tree/list mirroring file system
- **"Now playing" indicator**: highlight on the currently playing track
- **Gamepad**: Default focus on first item in active tab. LB/RB switch tabs. D-pad navigates list/grid. A plays song / opens detail. X context menu. Y favorite. Left stick for analog scrolling

#### 6.3.2a Artist Detail Screen
- **Artist header**: artist name, total songs count, total albums count, total duration
- **Albums by artist**: horizontal scrollable row of album cards
- **All songs by artist**: sortable list below albums
- **Actions**: Play All, Shuffle All
- **Gamepad**: Default focus on "Play All" button. D-pad down to albums row, then to song list. B to go back to Library

#### 6.3.2b Album Detail Screen
- **Album header**: large album art, album name, artist, year, song count, total duration
- **Track listing**: ordered by disc number → track number
- **Actions**: Play All, Shuffle, Add to Queue, Add to Playlist
- **Gamepad**: Default focus on "Play All" button. D-pad down to track list. X on a track opens context menu. B to go back

#### 6.3.2c Genre Detail Screen
- **Genre header**: genre name, total songs count, total albums count, total duration
- **Albums in genre**: horizontal scrollable row of album cards (unique albums that contain at least one song in this genre)
- **All songs in genre**: sortable list below albums (same sort options as Library: name, artist, album, date added, duration, year)
- **Actions**: Play All, Shuffle All
- **Gamepad**: Default focus on "Play All" button. D-pad down to albums row, then to song list. X on a song opens context menu. B to go back to Library Genres tab

#### 6.3.2d Folder Navigation Screen
- **Breadcrumb bar** at top: shows current path relative to the scan folder root (e.g., `Music / Rock / Pink Floyd / The Wall`). Non-focusable, informational only
- **Content list**: Subfolders first (folder icon + name + contained file count), then audio files below (standard song list tiles with title, artist, duration)
- **Subfolders**: shown with a folder icon (Lucide `folder` icon) and the count of audio files within (recursive)
- **Navigation**: A opens a subfolder (pushes new breadcrumb level) or plays a file. B goes up one folder level (pops breadcrumb). At the root scan folder level, B returns to Library Folders tab
- **Context menu (X)**: On a subfolder → "Play All in Folder", "Shuffle Folder", "Add Folder to Queue". On a file → standard song context menu
- **Sort**: Files can be sorted by name, date modified, duration. Folders always sorted alphabetically
- **Gamepad**: Default focus on first item in the list. D-pad up/down navigates the combined folder+file list. Y toggles favorite on focused song (disabled on folders). Left stick for analog scrolling

#### 6.3.3 Now Playing Screen
- **Large album art** (centered, 60-70% of viewport width)
- **Track info**: title, artist, album
- **Progress bar** with elapsed/remaining time
- **Controls**: shuffle, previous, play/pause, next, repeat
- **Secondary controls**: favorite, add to playlist, queue, volume slider (with mute toggle), equalizer
- **Mute toggle**: Lucide `volume-2` icon button next to the volume slider. A button or click toggles mute. When muted: icon changes to Lucide `volume-x`, slider track grays out (reduced opacity), audio output is silent but playback position continues advancing. Unmuting restores the previous volume level. No dedicated gamepad button — mute is only reachable when the volume/secondary controls row is focused via D-pad. Mute state is **not** persisted across app restarts (always starts unmuted)
- **Background**: subtle blurred album art tint. Pre-computed on track change using a background isolate: extract album art, apply Gaussian blur (sigma 25), overlay at 15–20% opacity on the dark background color. Cached per song as a `Uint8List` in memory (not re-blurred every frame). Use `dart:ui` `ImageFilter.blur` or the `image` package on an isolate. Do NOT use `BackdropFilter` widget (recomputes every frame on GPU). When no album art is available, use a plain dark gradient background
- **Gamepad**: Default focus on play/pause button. D-pad left/right → seek ±5s. D-pad up → album art area (no action, visual only). D-pad down → secondary controls row. Right stick horizontal → fine seek. LT/RT → volume. Y → favorite. B → minimize back to mini player

#### 6.3.4 Queue / Up Next
- **Slide-in panel** from the right side (or full screen on small viewports)
- **Currently playing** at the top (highlighted)
- **Up next list**: reorderable, removable
- **"Clear queue"** and **"Save as playlist"** actions
  - **Save as Playlist flow**: A on "Save as Playlist" opens a dialog with a text input field. Default name: "Queue – [localized date]" (e.g., "Queue – Apr 19, 2026"). A confirms and creates the playlist, B cancels. Songs are **copied** as new `playlist_songs` entries (not a live reference to the queue — queue is ephemeral). After saving, toast: "Playlist created: [name]" with an "Open" action button on the toast
- **Gamepad**: Default focus on currently playing track. D-pad to navigate queue items. X to enter reorder mode (then D-pad up/down to move, A to drop). A on a track to play it immediately. Y to remove from queue. B to close panel

#### 6.3.5 Search Screen
- **Large search input** at top
- **Search history** shown when input is empty:
  - Vertical list of up to 10 recent queries, each shown as: Lucide `clock` icon + query text + trailing Lucide `x` icon button to remove that individual entry
  - **"Clear History"** text button at the bottom of the list (only visible when ≥1 history item exists)
  - Selecting a history item (A button / click) fills the search input with that query and immediately triggers the search
  - Gamepad in history: D-pad up/down navigates items, A selects (runs search), D-pad right focuses the "X" remove button on the current row, A on "X" removes the entry. B from history goes back to previous screen
- **Results grouped**: Songs, Artists, Albums, Playlists sections (see FL-SEARCH-003 for per-category limits)
- **Keyboard auto-opens** when navigating to search via gamepad
- **Gamepad**: Default focus on search input (activates system keyboard). D-pad down moves to results (or history if input is empty). B from results goes back to input. B from input goes back to previous screen. Results navigate as a vertical list with group headers as non-focusable separators

#### 6.3.6 Playlist View
- **Playlist header**: cover art mosaic, name, song count, total duration
- **Actions**: Play All, Shuffle, Edit, Delete
- **Track list**: reorderable, removable per-track
- **Gamepad**: Default focus on "Play All" button. D-pad down to track list. X on track for context menu (includes "Remove from Playlist" and "Reorder" — selecting "Reorder" enters reorder mode: D-pad up/down moves the track, A confirms new position, B cancels. Visual drag handle appears on the focused item). X on header area for playlist-level actions (Rename, Delete, Export). B to go back to playlists list

#### 6.3.7 Settings Screen
- **Sections**:
  - **Appearance**: Theme (Dark/Light/System), Accent color
  - **Library**: Managed folders, Auto-scan toggle, Rescan button
  - **Playback**: Crossfade duration, Gapless toggle, Resume on launch
  - **Equalizer**: Enable/disable, presets, custom profiles
  - **Controls**: Gamepad enable/disable, navigation sounds on/off, custom key bindings
  - **System**: Minimize to tray, close behavior, start with Windows, language
  - **About**: Version, licenses
- **Gamepad**: Default focus on first settings section. D-pad navigates settings rows. A toggles switches, opens dropdowns, activates buttons. Sections are separated by non-focusable headers. B exits settings. LB/RB can jump between sections

#### 6.3.7a Equalizer Overlay
- **Access points**: (1) Settings > Equalizer > "Open Equalizer" button, (2) EQ icon button in Now Playing secondary controls row
- **Layout**: Full-screen overlay (not inline in settings)
  - **Top row**: On/off toggle (left), preset dropdown selector (right)
  - **Main area (full EQ available)**: Vertical sliders for each frequency band, labeled with frequency (e.g., 60Hz, 250Hz, 1kHz, 4kHz, 16kHz). Each slider shows its current gain in dB. Visual frequency response curve drawn above the sliders
  - **Main area (bass/treble fallback)**: Two large vertical sliders labeled "Bass" and "Treble" with a flat visual frequency curve
  - **Bottom row**: "Save as Custom" button (opens name input dialog), "Reset" button (returns all bands to 0dB)
- **Gamepad**: D-pad left/right moves between bands/sliders. D-pad up/down adjusts the focused band's gain (±1dB per press, hold for continuous). A on preset dropdown opens it (D-pad to select, A to confirm, B to cancel). LB/RB cycle through presets for quick A/B comparison. B closes the EQ overlay. The overlay is designed to gracefully handle both full EQ and bass/treble fallback — use a conditional layout that checks what `just_audio` supports at runtime

#### 6.3.8 Favorites Screen
- **Purpose**: Dedicated screen for the "Favorites" nav rail item. Displays all songs where `is_favorite = true`
- **Layout**: Same as Library Songs tab — song list tiles with sort dropdown at top. Sort options: name A-Z, name Z-A, artist, album, date added, duration, year
- **Header**: "Favorites" title on the left, song count ("N songs") on the right
- **Empty state**: Already defined in 6.3a — "No favorites yet. Tap the heart on any song." → "Browse Library" button
- **Gamepad**: Default focus on first song in the list (or "Browse Library" CTA if empty). D-pad up/down navigates songs. A plays the song. X opens context menu (same as "Song in library" from FL-INPUT-008). Y unfavorites the song (removes it from this list — immediate, with undo toast: "Removed from Favorites" + [Undo]). B does nothing (root-level screen, same as Home). Left stick for analog scrolling. LB/RB = prev/next track (global default)

#### 6.3.9 Playlists List Screen
- **Purpose**: Dedicated screen for the "Playlists" nav rail item. Lists all smart playlists and user playlists
- **Layout (top to bottom)**:
  1. **Header row**: "Playlists" title on the left. Two buttons on the right: **"Import M3U"** (Lucide `file-down` icon) and **"Create Playlist"** (Lucide `plus` icon + "New" label). Both focusable
  2. **Smart Playlists section**: Non-collapsible section with a subtle "Auto" or Lucide `sparkles` icon badge. Contains: "Recently Added", "Most Played", "Recently Played" (as defined in FL-PL-008). Each shown as a list tile with a Lucide `sparkles` icon, playlist name, and song count. Smart playlists are NOT editable (no rename, delete, or reorder in context menu). Context menu (X): Play All, Shuffle, Add to Queue
  3. **User Playlists section**: Grid of playlist cards (cover art mosaic, name, song count). If empty, show the Playlists empty state from 6.3a. Sort: by name A-Z (default), by date created, by date updated. Sort selector dropdown at top of section
- **Gamepad**: Default focus on "Create Playlist" button (or first smart playlist if no user playlists exist). D-pad navigates between header buttons → smart playlists → user playlist grid. A opens a playlist (navigates to Playlist Detail 6.3.6). X on a user playlist opens context menu (Play All, Shuffle, Rename, Duplicate, Delete, Export as M3U). X on a smart playlist opens context menu (Play All, Shuffle, Add to Queue). B does nothing (root-level screen). Y disabled (no favorites on playlists). LB/RB = prev/next track (global default)

### 6.3a Empty States

Every screen must define an empty state with an illustration/icon, a message, and a call-to-action:

| Screen | Empty State Message | CTA |
|--------|-------------------|-----|
| Home (no library) | "No music yet. Add a folder to get started." | "Add Music Folder" button |
| Home (no recently played) | "Start listening to see your recent tracks here." | "Go to Library" button |
| Home (no recommendations) | "Play more music to get personalized recommendations." | (none, auto-populates) |
| Library (no songs) | "Your library is empty. Scan a folder to find music." | "Add Music Folder" button |
| Search (no results) | "No results for '[query]'. Try a different search." | (none) |
| Search (no history) | "Search for songs, artists, albums, or playlists." | (none, show search input) |
| Playlists (none created) | "No playlists yet. Create one to organize your music." | "Create Playlist" button |
| Favorites (none) | "No favorites yet. Tap the heart on any song." | "Browse Library" button |
| Queue (empty) | "Queue is empty. Add songs from your library." | "Browse Library" button |

### 6.4 Theme

- **Dark Mode**: Primary background `#0D1117`, surface `#161B22`, card `#1C2128`, text `#E6EDF3`, accent configurable (default: `#C76E00` Dark Orange)
- **Light Mode**: Primary background `#FFFFFF`, surface `#F6F8FA`, card `#EAEEF2`, text `#1F2328`, accent configurable (default: `#C76E00` Dark Orange)
- **Accent Colors**: User selectable from a palette in Settings. Accent color is stored in settings and applied globally via ThemeData. All colors chosen for sufficient contrast on both dark (`#0D1117`) and light (`#FFFFFF`) backgrounds:

| Name | Hex | Notes |
|------|-----|-------|
| Dark Orange (default) | `#C76E00` | Warm, unique app identity |
| Blue | `#2F81F7` | GitHub blue, universally readable |
| Purple | `#8957E5` | Rich, high contrast on dark |
| Green | `#3FB950` | Avoids neon, readable |
| Red | `#F85149` | Distinct from error red by context |
| Pink | `#DB61A2` | Softer than magenta |
| Teal | `#39D2C0` | Cool complement to orange |
| Amber | `#D29922` | Gold-adjacent, warm |
- **Typography**: **Inter** font family (bundled via `google_fonts` package, cached locally — no network calls at runtime). Variable font with optical sizing for optimal rendering at all sizes. Weights used: Regular (400) for body, Medium (500) for emphasis, SemiBold (600) for headings, Bold (700) for display. Font sizes: headings 20-28sp, body 14-16sp, caption 12sp. Fallback stack: Segoe UI (Windows), SF Pro (macOS), system sans (Linux)
- **Icon Library**: **Lucide Icons** (`lucide_icons` package). All UI icons use the Lucide set for visual consistency — same 24px grid, 2px stroke, round joins throughout the app. Do not mix with Material Icons
- **Focus Indicator**: 3px border/ring using a dedicated focus border color token (`--focus-border-color`, defaults to accent color but independently overridable for theming). Subtle scale-up (1.02x cards, 1.05x grid cards) + glow shadow. Must be visible against both dark and light themes
- **Transitions**: 200-300ms ease-in-out for page transitions, 150ms for hover/focus states

### 6.4a Animation System

> **Philosophy**: Animations exist to guide the user's attention and provide feedback — never for decoration. This app runs on gaming handhelds where every CPU/GPU cycle matters. Use the minimum animation needed to feel polished, then stop.

#### What Gets Animated (DO animate)

| Animation | Duration | Easing | Implementation |
|-----------|----------|--------|----------------|
| Page transitions (push/pop) | 250ms | `easeInOut` | `go_router` custom `CustomTransitionPage` with shared `SlideTransition` + `FadeTransition` |
| Focus indicator appear/change | 150ms | `easeOut` | `AnimatedContainer` border + `AnimatedScale` (1.0 → 1.02) |
| Mini player expand → Now Playing | 300ms | `easeInOutCubic` | Hero-like transition on album art + slide-up for controls |
| Now Playing collapse → Mini player | 250ms | `easeInOut` | Reverse of above |
| Context menu open | 150ms | `easeOut` | `ScaleTransition` from 0.95 + `FadeTransition` |
| Context menu close | 100ms | `easeIn` | `FadeTransition` out |
| Toast slide in | 200ms | `easeOut` | `SlideTransition` from bottom |
| Toast slide out | 150ms | `easeIn` | `FadeTransition` + slide |
| Queue panel slide | 250ms | `easeInOut` | `SlideTransition` from right |
| List item appear (staggered on first load) | 50ms stagger, 200ms per item | `easeOut` | `FadeTransition` + slight `SlideTransition` up. Max 8-10 items staggered, rest appear instantly |
| Album art crossfade (track change) | 300ms | `linear` | `AnimatedSwitcher` with `FadeTransition` |
| Progress bar | Continuous | `linear` | `AnimatedContainer` or `CustomPaint` — driven by stream, no explicit tween |
| Shuffle/repeat icon state change | 150ms | `easeInOut` | `AnimatedSwitcher` |
| Favorite heart toggle | 200ms | `easeOut` | Scale bounce 1.0 → 1.3 → 1.0 via `TweenSequence` |
| Onboarding step transitions | 300ms | `easeInOut` | Horizontal `SlideTransition` between steps |

#### What Does NOT Get Animated (DO NOT animate)

- Background blur updates (static per track, not animated)
- Theme changes (instant swap, no transition)
- Sort order changes in lists (instant re-render)
- Search results appearing (instant, no stagger — speed matters here)
- Settings toggles beyond the switch widget itself
- Scroll position (native physics only, no custom scroll animations)
- Window resize / layout breakpoint changes
- Nav rail expand/collapse (instant at breakpoint, not animated)
- Any looping/continuous decorative animation (no pulsing, no breathing, no rotating elements)
- Album art loading placeholder (static placeholder → fade in real image, but placeholder itself is not animated)

#### Animation Rules

1. **Max 250-300ms for any transition.** Nothing should take longer. Users on gamepad are navigating quickly
2. **No animation should block input.** All transitions must be interruptible — if the user presses B during a page transition, cancel the animation and go back immediately
3. **Stagger only on initial load.** List items stagger only the first time a screen appears. Subsequent visits or scroll-into-view items appear instantly
4. **One animation at a time per region.** Never have the page transitioning while the mini player is also animating. Overlap creates visual noise and wastes GPU
5. **Use implicit animations (`Animated*` widgets) over explicit (`AnimationController`) wherever possible.** Implicit animations are simpler, less error-prone, and auto-dispose
6. **No `Ticker` running when not visible.** All animation controllers must be paused/disposed when their widget is off-screen. Use `TickerProviderStateMixin` correctly
7. **Test at 30fps.** Animations should still look acceptable if the device is under load and frame rate drops. Avoid animations that look broken at low frame rates (e.g., physics-based bounces)

### 6.5 Responsive Behavior

- **≥1200px width**: Full side nav with labels + main content
- **800-1199px width**: Collapsed side nav (icons only) + main content  
- **The app will NOT be responsive below 800px** — minimum supported window size

---

## 7. Data & Storage

### 7.1 SQLite Database Schema (Conceptual)

```
songs
  - id (PK, auto-increment)
  - file_path (unique, indexed)
  - title
  - artist
  - album
  - album_artist
  - genre
  - year
  - track_number
  - disc_number
  - duration_ms
  - file_size
  - file_modified_at
  - art_cache_path (nullable)
  - date_added
  - play_count (default 0)
  - last_played_at (nullable)
  - is_favorite (default false)
  - is_missing (boolean, default false — set when file not found during playback/scan, cleared when file reappears)

playlists
  - id (PK)
  - name
  - cover_art_path (nullable)
  - created_at
  - updated_at
  - is_smart (boolean, default false)
  - smart_rule (nullable, JSON for smart playlist criteria)

playlist_songs
  - playlist_id (FK)
  - song_id (FK)
  - sort_order
  - added_at

play_history
  - id (PK)
  - song_id (FK)
  - played_at
  - duration_listened_ms
  - session_id (int — incremented on each app launch, used for "Recently Played last 5 sessions" smart playlist)

queue_state
  - song_id (FK)
  - sort_order
  - is_current (boolean)
  - position_ms (for current track)

playback_state (singleton row)
  - id (PK, always 1)
  - shuffle_enabled (boolean, default false)
  - repeat_mode (enum: off, all, one — default off)
  - volume (float 0.0-1.0, default 0.7)
  - crossfade_seconds (int, default 0)
  - eq_enabled (boolean, default false)
  - eq_preset_id (FK nullable)
  - queue_source_type (text, nullable: 'album', 'playlist', 'artist', 'genre', 'folder', 'all_songs', 'manual')
  - queue_source_id (int, nullable — references the album/playlist/artist/genre ID for Quick Resume display)

eq_presets
  - id (PK)
  - name
  - is_builtin (boolean) — true for factory presets (Flat, Rock, etc.)
  - bands_json (JSON array of {frequency_hz, gain_db} objects)
  - created_at

settings
  - key (PK)
  - value (JSON)
  NOTE: search_history is stored here as key='search_history', value=JSON array of last 10 query strings

recommendations
  - id (PK)
  - category (text: 'artists_you_love', 'rediscover', 'deep_cuts', 'genre_mix')
  - song_id (FK)
  - score (real — sort order within category)
  - generated_at (timestamp)
  NOTE: Entire table is cleared and regenerated on each refresh. No historical data.

scan_folders
  - id (PK)
  - path
  - enabled (boolean)
  - last_scanned_at (timestamp, nullable — used for incremental scan; compare against file system modified timestamps)

INDEXES:
  - songs.title (for search + sort)
  - songs.artist (for search + sort + group by)
  - songs.album (for search + sort + group by)
  - songs.genre (for group by)
  - songs.album_artist (for group by)
  - songs.year (for sort)
  - songs.date_added (for sort)
  - songs.play_count (for recommendations + smart playlists)
  - songs.last_played_at (for recently played)
  - songs.is_favorite (for favorites filter)
  - play_history.played_at (for recent history queries)
  - play_history.session_id (for session-based smart playlists)
  - recommendations(category, generated_at) (composite, for fetching current recommendations)
  - playlist_songs(playlist_id, sort_order) (composite, for ordered listing)
```

### 7.2 File Storage

```
%APPDATA%/MusicFSE/           (Windows)
~/Library/Application Support/MusicFSE/  (macOS)
~/.local/share/music-fse/     (Linux)
├── music_fse.db               # SQLite database
├── art_cache/                 # Thumbnail cache (300x300)
│   ├── {hash}.jpg
│   └── ...
├── playlist_covers/           # Custom playlist covers
├── logs/                      # Application logs
│   ├── music_fse.log          # Current log file
│   └── music_fse.log.1        # Rotated previous log
└── settings.json              # Backup/export of settings
```

### 7.3 Data Policies

- **No telemetry, no analytics, no network calls**
- All data stays on the local machine
- Database should handle libraries of up to 50,000 songs without lag
- Art cache can be cleared and regenerated

### 7.4 Logging

- **FL-LOG-001**: Local log files for debugging (no remote logging). Uses Dart's built-in `logging` package — zero external dependencies, lightweight
- **FL-LOG-002**: Log levels: debug, info, warning, error
- **FL-LOG-003**: Log rotation: max 5MB per file, keep last 2 files (current + 1 rotated). Rotation checked on app startup (if current log >5MB, rotate)
- **FL-LOG-004**: Logs include: app lifecycle, library scan events, playback errors, platform integration errors, unhandled exceptions
- **FL-LOG-005**: Logs accessible from Settings > About > "Export Logs" (copies to clipboard or saves to file)
- **FL-LOG-006**: Log format: `[2026-04-19 14:30:05.123] [INFO] [LibraryScanner] Found 1234 songs`. Timestamps in ISO 8601 local time. Each log entry includes level, source class/tag, and message

---

## 8. Performance Requirements

> **Critical context**: This app runs on gaming handhelds where the user is likely alt-tabbing between a game and the music player. Every megabyte of RAM and every percentage of CPU this app consumes is a megabyte/cycle stolen from the game. Resource efficiency is not optional — it is a core feature.

### 8.1 Targets

- **App startup**: < 2 seconds to interactive (excluding library scan)
- **Library scan**: Process ~1000 songs/minute on average hardware
- **Search**: Results within 100ms for libraries up to 50K songs
- **Scrolling**: 60fps smooth scrolling in all list/grid views (virtualized lists with lazy image loading required)
- **Memory**: < 300MB RAM for a 10K song library. < 150MB idle (no active playback, app in background)
- **Image loading**: Album art placeholders shown immediately, actual thumbnails loaded asynchronously with fade-in
- **Audio latency**: < 50ms from play command to audio output
- **Gamepad input latency**: < 16ms (single frame at 60fps)
- **CPU idle**: < 1% CPU when playing audio with the app minimized/in background. No unnecessary timers, polling, or repaints
- **CPU active**: < 5% CPU during normal browsing and navigation
- **GPU**: Near-zero GPU usage when idle. During transitions/animations, keep GPU work minimal — no shader-heavy effects, no real-time blur recalculation

### 8.2 Resource Efficiency Rules

1. **No unnecessary rebuilds.** Use `const` constructors wherever possible. Use `select()` on Riverpod providers to listen only to the specific fields a widget needs. Never pass an entire state object when a widget only needs one field
2. **Dispose everything.** `FocusNode`, `ScrollController`, `AnimationController`, `StreamSubscription` — all must be disposed in `dispose()`. Memory leaks are unacceptable on a device with 16-24GB shared between GPU and system
3. **Throttle XInput polling.** 60Hz polling is the max. When the app is in the background or minimized, reduce to 0Hz (stop polling entirely). Resume on window focus
4. **Image cache limits.** Flutter's default `ImageCache` holds 1000 images / 100MB. Override to: max 200 images / 50MB. Purge aggressively when the app goes to background
5. **Database connection pooling.** Single database connection. No concurrent writes. Use write-ahead logging (WAL) mode for read concurrency
6. **Background mode.** When minimized: stop all UI rendering, stop XInput polling, stop all animations/tickers, keep only the audio player + SMTC/MPRIS integration alive
7. **Lazy initialization.** Recommendations engine, equalizer, scan worker — none of these should initialize until first use. Don't pre-load what the user hasn't asked for
8. **No wake-up timers.** The app must not wake itself up when in the background. No periodic timers for refresh, no polling for file changes. Rescan is manual or on-launch only
9. **Prefer `Uint8List` over `List<int>`** for any binary data (audio buffers, image bytes). Typed lists use less memory
10. **Release mode profiling.** Always profile in `--release` mode. Debug mode numbers are meaningless. Use Flutter DevTools memory and CPU tabs to verify targets

---

## 9. Localization

### 9.1 Supported Languages (Initial)

| Language | Code | Priority |
|----------|------|----------|
| English (US) | `en` | Must have (default) |
| Spanish | `es` | Should have |
| French | `fr` | Should have |
| German | `de` | Should have |
| Japanese | `ja` | Should have |
| Chinese (Simplified) | `zh` | Should have |
| Arabic | `ar` | Should have (RTL support) |

### 9.2 Localization Requirements

- **FL-L10N-001**: All user-visible strings externalized via Flutter `intl` / ARB files
- **FL-L10N-002**: Language selectable in settings (overrides system locale). Change applies **immediately** without app restart — Riverpod `localeProvider` updates, `MaterialApp` rebuilds with the new locale
- **FL-L10N-003**: RTL layout support for Arabic:
  - Nav rail stays on the **left** (consistent with YouTube, Spotify — nav position is a UX convention, not text-direction)
  - Body text alignment flips (right-aligned text, left-aligned numbers)
  - Horizontal scroll rows reverse (newest items appear on the right, scroll direction reverses)
  - Queue panel slides from the **left** instead of right
  - Progress bar fills right-to-left
  - Button hints bar reverses order
  - Flutter's `Directionality` widget handles most of this automatically. Manual work: queue panel slide direction, any hardcoded `left`/`right` padding or alignment
- **FL-L10N-004**: Date/time formatting follows locale
- **FL-L10N-005**: Number formatting (e.g., "1,234 songs" vs "1.234 songs") follows locale

---

## 10. Technical Architecture

### 10.1 Architecture Pattern

**Clean Architecture** with three layers:

```
Presentation (UI + Providers)
       ↓ depends on
Domain (Entities + Use Cases + Repository Interfaces)
       ↓ depends on
Data (Repository Implementations + Data Sources + Models)
```

Dependency rule: inner layers never depend on outer layers. Domain has zero Flutter/package imports.

### 10.2 State Management

**Riverpod** (with code generation via `riverpod_annotation`):

- `@riverpod` annotated providers for all state
- `AsyncNotifier` for async operations (library scan, search)
- `Notifier` for synchronous state (playback controls, theme)
- `StreamProvider` for real-time updates (playback position, scan progress)

### 10.3 Dependency Injection

Riverpod itself serves as the DI container. No `get_it` or `injectable`.

- Data sources provided as `@riverpod` singletons
- Repositories provided as `@riverpod` that depend on data source providers
- Use cases provided as `@riverpod` that depend on repository providers
- Presentation providers depend on use case providers

### 10.4 Project Structure

```
lib/
├── main.dart
├── app.dart                          # MaterialApp with router, theme, localization
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart        # Sizes, durations, limits
│   │   └── db_constants.dart         # Table names, column names
│   ├── errors/
│   │   ├── failures.dart             # Failure sealed class
│   │   └── exceptions.dart           # Custom exceptions
│   ├── extensions/
│   │   ├── duration_ext.dart         # Duration formatting helpers
│   │   ├── string_ext.dart
│   │   └── context_ext.dart          # Theme/l10n shortcuts
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData definitions
│   │   ├── color_schemes.dart        # Dark/light color schemes
│   │   └── text_styles.dart
│   ├── localization/
│   │   ├── l10n.dart                 # Generated localizations
│   │   └── arb/
│   │       ├── app_en.arb
│   │       ├── app_es.arb
│   │       └── ...
│   ├── utils/
│   │   ├── file_utils.dart           # Path helpers, extension checks
│   │   ├── metadata_utils.dart       # Filename parsing fallback
│   │   └── image_utils.dart          # Art extraction, caching
│   └── router/
│       └── app_router.dart           # GoRouter configuration
│
├── domain/
│   ├── entities/
│   │   ├── song.dart
│   │   ├── album.dart
│   │   ├── artist.dart
│   │   ├── genre.dart
│   │   ├── playlist.dart
│   │   ├── play_history_entry.dart
│   │   ├── queue_state.dart
│   │   └── eq_preset.dart
│   ├── repositories/
│   │   ├── song_repository.dart       # Abstract
│   │   ├── playlist_repository.dart
│   │   ├── playback_repository.dart
│   │   ├── settings_repository.dart
│   │   └── scan_repository.dart
│   └── usecases/
│       ├── library/
│       │   ├── scan_library.dart
│       │   ├── get_all_songs.dart
│       │   ├── get_songs_by_artist.dart
│       │   ├── get_songs_by_album.dart
│       │   ├── get_songs_by_genre.dart
│       │   ├── search_library.dart
│       │   └── get_folder_contents.dart
│       ├── playback/
│       │   ├── play_song.dart
│       │   ├── pause_resume.dart
│       │   ├── seek.dart
│       │   ├── next_track.dart
│       │   ├── previous_track.dart
│       │   └── set_volume.dart
│       ├── playlist/
│       │   ├── create_playlist.dart
│       │   ├── add_to_playlist.dart
│       │   ├── remove_from_playlist.dart
│       │   ├── reorder_playlist.dart
│       │   └── get_playlists.dart
│       ├── queue/
│       │   ├── get_queue.dart
│       │   ├── add_to_queue.dart
│       │   ├── remove_from_queue.dart
│       │   ├── reorder_queue.dart
│       │   └── clear_queue.dart
│       ├── favorites/
│       │   ├── toggle_favorite.dart
│       │   └── get_favorites.dart
│       └── recommendations/
│           └── get_recommendations.dart
│
├── data/
│   ├── models/
│   │   ├── song_model.dart            # DB ↔ Entity mapping
│   │   ├── playlist_model.dart
│   │   └── settings_model.dart
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── database.dart          # Drift database definition
│   │   │   ├── song_dao.dart
│   │   │   ├── playlist_dao.dart
│   │   │   ├── history_dao.dart
│   │   │   ├── queue_dao.dart
│   │   │   ├── settings_dao.dart
│   │   │   ├── recommendations_dao.dart
│   │   │   ├── eq_preset_dao.dart
│   │   │   └── scan_folders_dao.dart
│   │   ├── file_system_datasource.dart  # File scanning, art discovery
│   │   └── metadata_datasource.dart     # Tag reading (audiotags/FFI)
│   └── repositories/
│       ├── song_repository_impl.dart
│       ├── playlist_repository_impl.dart
│       ├── playback_repository_impl.dart
│       ├── settings_repository_impl.dart
│       └── scan_repository_impl.dart
│
├── presentation/
│   ├── providers/
│   │   ├── theme_provider.dart
│   │   ├── locale_provider.dart
│   │   ├── library_provider.dart
│   │   ├── playback_provider.dart
│   │   ├── queue_provider.dart
│   │   ├── playlist_provider.dart
│   │   ├── search_provider.dart
│   │   ├── favorites_provider.dart
│   │   ├── recommendations_provider.dart
│   │   ├── settings_provider.dart
│   │   ├── equalizer_provider.dart
│   │   └── input_mode_provider.dart     # Gamepad vs mouse vs keyboard
│   ├── pages/
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── widgets/
│   │   │       ├── recently_played_row.dart
│   │   │       ├── recommendations_section.dart
│   │   │       └── quick_access_row.dart
│   │   ├── onboarding/
│   │   │   ├── onboarding_page.dart
│   │   │   └── widgets/
│   │   │       ├── welcome_step.dart
│   │   │       ├── folder_picker_step.dart
│   │   │       ├── theme_picker_step.dart
│   │   │       └── scan_progress_step.dart
│   │   ├── library/
│   │   │   ├── library_page.dart
│   │   │   └── widgets/
│   │   │       ├── songs_tab.dart
│   │   │       ├── artists_tab.dart
│   │   │       ├── albums_tab.dart
│   │   │       ├── genres_tab.dart
│   │   │       ├── folders_tab.dart
│   │   │       ├── artist_detail_page.dart
│   │   │       ├── album_detail_page.dart
│   │   │       ├── genre_detail_page.dart
│   │   │       └── folder_navigation_page.dart
│   │   ├── now_playing/
│   │   │   ├── now_playing_page.dart
│   │   │   └── widgets/
│   │   │       ├── album_art_display.dart
│   │   │       ├── playback_controls.dart
│   │   │       ├── progress_bar.dart
│   │   │       └── volume_control.dart
│   │   ├── equalizer/
│   │   │   └── equalizer_overlay.dart
│   │   ├── search/
│   │   │   ├── search_page.dart
│   │   │   └── widgets/
│   │   │       ├── search_results_group.dart
│   │   │       └── search_history_list.dart
│   │   ├── favorites/
│   │   │   └── favorites_page.dart
│   │   ├── recently_played/
│   │   │   └── recently_played_page.dart
│   │   ├── playlist/
│   │   │   ├── playlists_page.dart
│   │   │   └── playlist_detail_page.dart
│   │   ├── queue/
│   │   │   └── queue_panel.dart
│   │   └── settings/
│   │       ├── settings_page.dart
│   │       └── widgets/
│   │           ├── appearance_section.dart
│   │           ├── library_section.dart
│   │           ├── playback_section.dart
│   │           ├── controls_section.dart
│   │           └── system_section.dart
│   └── widgets/                         # Shared/reusable widgets
│       ├── mini_player_bar.dart
│       ├── side_nav_rail.dart
│       ├── song_list_tile.dart
│       ├── scroll_to_now_playing_button.dart  # Floating pill button (FL-BROWSE-008)
│       ├── album_card.dart
│       ├── artist_card.dart
│       ├── playlist_card.dart
│       ├── context_menu.dart
│       ├── focus_highlight.dart          # Gamepad focus wrapper
│       ├── gamepad_button_hints.dart     # Console-style contextual hints bar
│       ├── toast_notification.dart       # In-app snackbar/toast system
│       ├── volume_osd.dart               # On-screen volume overlay for trigger input
│       ├── empty_state.dart              # Reusable empty state with icon + CTA
│       ├── keyboard_shortcuts_overlay.dart  # F1/? shortcut help modal
│       ├── custom_title_bar.dart
│       └── loading_indicator.dart
│
└── platform/
    ├── xinput/
    │   ├── xinput_binding.dart            # dart:ffi bindings to xinput1_4.dll
    │   ├── xinput_controller.dart         # High-level gamepad state manager
    │   └── xinput_mappings.dart           # Button → Action mapping
    ├── smtc/
    │   ├── smtc_binding.dart             # Platform channel to Win32 SMTC
    │   └── smtc_controller.dart
    ├── media_keys/
    │   ├── media_key_handler.dart        # Global media key listener
    │   ├── media_key_handler_linux.dart
    │   └── media_key_handler_macos.dart
    ├── macos/
    │   └── now_playing_info_center.dart  # MPNowPlayingInfoCenter integration
    ├── system_tray/
    │   └── tray_manager.dart             # System tray integration
    └── window/
        └── window_manager_helper.dart    # Window state persistence
```

### 10.5 Key Packages

| Package | Version (approx) | Purpose |
|---------|------------------|---------|
| `flutter_riverpod` | ^2.5 | State management |
| `riverpod_annotation` | ^2.3 | Code gen for providers |
| `riverpod_generator` | ^2.4 | Build runner for riverpod |
| `just_audio` | ^0.9 | Audio playback engine |
| `just_audio_windows` | ^0.2 | Windows audio backend |
| `drift` | ^2.16 | SQLite ORM |
| `sqlite3_flutter_libs` | ^0.5 | SQLite native libs |
| `go_router` | ^14.0 | Declarative routing |
| `ffi` | (dart:ffi) | XInput, native bindings |
| `win32` | ^5.5 | Win32 API access (SMTC, etc.) |
| `window_manager` | ^0.3 | Window control |
| `system_tray` | ^2.0 | System tray integration |
| `path_provider` | ^2.1 | App data directories |
| `path` | ^1.9 | Path manipulation |
| `flutter_localizations` | (SDK) | i18n framework |
| `intl` | ^0.19 | i18n utilities |
| `audiotags` | ^1.4 | Audio metadata extraction |
| `image` | ^4.1 | Image processing (thumbnails) |
| `reorderables` | ^0.6 | Drag-to-reorder lists |
| `freezed_annotation` | ^2.4 | Immutable data classes |
| `freezed` | ^2.5 | Code gen for freezed |
| `json_annotation` | ^4.8 | JSON serialization |
| `json_serializable` | ^6.7 | Code gen for JSON |
| `build_runner` | ^2.4 | Code generation runner |
| `google_fonts` | ^6.2 | Inter font family (cached locally, no runtime network) |
| `lucide_icons` | ^0.2 | Lucide icon set for all UI icons |
| `desktop_drop` | ^0.4 | Drag & drop files/folders onto window (fallback if Flutter built-in DropTarget insufficient) |
| `flutter_lints` | ^4.0 | Lint rules |
| `mocktail` | ^1.0 | Testing mocks |

### 10.6 Audio Playback Architecture

```
PlaybackProvider (Riverpod)
    ↓ controls
just_audio AudioPlayer (playerA — primary)
just_audio AudioPlayer (playerB — crossfade only, lazy)
    ↓ events (stream)
PlaybackProvider (updates state)
    ↓ notifies
UI (Now Playing, Mini Player, etc.)
    ↓ parallel
SMTC Controller (updates Windows overlay)
```

- `AudioPlayer` from `just_audio` is the single source of truth for playback state
- `PlaybackProvider` wraps it, manages queue logic, crossfade, shuffle, repeat
- SMTC controller listens to playback state changes and mirrors them to Windows
- XInput controller polls gamepad state at 60Hz and dispatches actions to the provider

#### 10.6a Crossfade Dual-Player Architecture

> Crossfade requires managing **two `AudioPlayer` instances** because `just_audio` does not have built-in crossfade support.

- **Normal playback (crossfade = 0)**: Only `playerA` is instantiated. `playerB` is never created. Zero overhead
- **Crossfade enabled (crossfade > 0)**: When a track transition approaches (crossfade duration before track end):
  1. Pre-load the next track into `playerB` (lazy-instantiated on first crossfade)
  2. Start `playerB` playback, begin fading: `playerA` volume ramps down, `playerB` volume ramps up, over the configured crossfade duration
  3. When crossfade completes: dispose `playerA`, swap references (`playerB` becomes the new `playerA`), set `playerB = null`
  4. SMTC updates fire when the "active" player reference changes (i.e., at the midpoint of the crossfade or when the swap occurs)
- **Crossfade does NOT apply** when: Repeat One is active (FL-CROSS-003), user manually skips (next/prev — instant transition), or seeking near the end of a track
- **Background blur during crossfade**: The blurred background image for the next track is pre-computed when `playerB` starts loading (before the visual crossfade begins), so the background transitions smoothly alongside the album art `AnimatedSwitcher` crossfade
- **Volume during crossfade**: Both players' individual volumes are scaled relative to the user's master volume setting. If master volume is 70%, crossfade fades between 0–70%, not 0–100%

---

## 11. Build & Distribution

### 11.1 Build Targets

- **Windows**: MSIX package for clean install, or plain exe + dlls folder
- **macOS**: DMG or direct .app bundle
- **Linux**: AppImage or Flatpak (future)

### 11.2 Build Commands

```bash
# Windows release
flutter build windows --release

# macOS release
flutter build macos --release

# Linux release
flutter build linux --release
```

### 11.3 App Metadata

- **App Name**: Music FSE
- **Package Name**: `com.musicfse.player`
- **Version**: 1.0.0
- **Min Windows Version**: Windows 10 (1903+)
- **Min macOS Version**: macOS 12 (Monterey)
- **Min Linux**: Ubuntu 20.04 equivalent

---

## 12. Testing Strategy

### 12.1 Unit Tests

- All use cases
- All repository implementations
- All providers (using `ProviderContainer`)
- Recommendation algorithm
- Metadata parsing / fallback logic

### 12.2 Widget Tests

- All custom widgets in isolation
- Page layouts with mocked providers
- Gamepad focus traversal

### 12.3 Integration Tests

- Full playback flow: scan → browse → play → pause → seek → next → stop
- Playlist CRUD
- Search flow
- Queue management

### 12.4 Coverage Target

- **≥80%** line coverage for domain and data layers
- **≥60%** for presentation layer

---

## 12a. Branding & Assets

### 12a.1 App Icon

- **Design**: Geometric/angular music note (♪) — a single beamed eighth note with a slightly angular note head, giving it a modern, gaming-adjacent feel
- **Color**: `#C76E00` (Dark Orange) — the app's default accent color
- **Background**: Transparent
- **Style**: Solid filled glyph, no outlines, no gradients, no shadows, no text. Must be recognizable at 16×16px
- **Variations**: 
  - Full color on transparent (primary)
  - White on transparent (for dark tray backgrounds where orange may not contrast)
  - Monochrome (for OS contexts that require it)

### 12a.2 Required Asset Sizes

| Asset | Dimensions | Format | Usage |
|-------|-----------|--------|-------|
| App Icon (multi-res) | 16, 32, 48, 64, 128, 256, 512px | ICO (Windows), ICNS (macOS), PNG (Linux) | Taskbar, tray, dock, file association |
| App Icon source | 1024×1024 | SVG + PNG | Master source for all icon derivations |
| Windows Store tile | 150×150, 310×310 | PNG | MSIX package tile |
| macOS icon | 512×512 @2x (1024×1024) | ICNS | macOS Dock & Finder |

### 12a.3 Launcher & Store Assets (Playnite / Steam)

| Asset | Dimensions | Format | Usage |
|-------|-----------|--------|-------|
| Grid / Cover (portrait) | 600×900 | PNG | Playnite grid, Steam vertical capsule |
| Hero Banner (landscape) | 1920×620 | PNG | Steam hero, Playnite background header |
| Logo (transparent) | 960×540 | PNG | Steam overlay logo on hero image |
| Playnite Background | 1920×1080 | PNG/JPG | Playnite detail view background |
| Playnite Icon | 256×256 | PNG | Playnite list view |
| Square Capsule | 600×600 | PNG | Steam square capsule |

### 12a.4 Design Guidelines for Launcher Assets

- **Grid/Cover**: Dark background (`#0D1117`), large centered app icon, app name "Music FSE" below in white, tagline "Full Screen Experience" in smaller text
- **Hero Banner**: Abstract dark gradient background with subtle geometric pattern (angular lines echoing the icon's style), app name left-aligned, icon at left
- **Logo**: Just the icon + "Music FSE" wordmark in white, transparent background — for overlaying on the hero
- **All assets use the same visual language**: dark backgrounds, `#C76E00` accent, geometric/angular aesthetic, Inter font family

---

## 13. Future Considerations (Out of Scope for V1)

These are intentionally excluded from V1 but documented for future reference:

- Audio visualizer / waveform display
- Scrobbling to Last.fm / ListenBrainz
- Online metadata/art lookup (MusicBrainz)
- Podcast support
- CD ripping
- Android/iOS ports
- Plugin/extension system
- Sleep timer
- Playback speed control
- A/B repeat (loop a section)
- Tag editor (edit metadata from within the app)
- Multiple audio output device selection
- **Playnite integration** — C#/.NET Playnite extension communicating with Music FSE via named pipes. Features: now-playing widget in Playnite fullscreen mode, auto volume duck on game launch/exit, quick-launch from Playnite sidebar, game-aware playlist associations. Requires separate C# codebase and a local IPC protocol endpoint in Music FSE
- **Steam Big Picture integration** — Add Music FSE as a non-Steam game with proper artwork (grid, hero, logo) for seamless launching from Steam's controller-friendly UI
- **Custom gamepad virtual keyboard** — In-app QWERTY keyboard navigable by D-pad/stick for search input on devices without a convenient system on-screen keyboard. Console-style grid layout with autocomplete

---

## 14. Resolved Decisions

| # | Question | Decision |
|---|----------|----------|
| 1 | App name | **Music FSE** (Full Screen Experience) |
| 2 | Default accent color | **Dark Orange `#C76E00`**, with user-selectable palette in Settings |
| 3 | Equalizer | Implement whatever `just_audio` can reliably support on Windows/Linux/macOS. If full EQ isn't feasible, provide bass/treble or defer to V1.1 |
| 4 | M3U import/export | **V1** — included in initial release |
| 5 | Gamepad vibration | **No** — replaced with UI navigation sounds (Steam Big Picture style) |
| 6 | macOS support | **V1** — added as secondary platform (development machine is Mac) |
| 7 | V1.2 additions | First-run onboarding, empty states, button hints bar, toast system, artist/album detail, context menus, single instance, scroll-to-now-playing, virtualized lists, logging, file association, shortcut overlay, multi-select — all included in V1 |
| 8 | Handheld design system | Added comprehensive Section 6.1a with sizing minimums, focus rules, per-widget gamepad behavior, per-screen gamepad requirements, and testing criteria. Added gamepad defaults to every screen spec |
| 9 | Animation system | Section 6.4a \u2014 explicit animation budget: what gets animated (page transitions, focus, expand/collapse, toast, heart) and what does NOT (theme change, sort, search results, scroll, looping effects). Max 300ms per transition, all interruptible, stagger only on first load |
| 10 | Gaming device resource efficiency | Section 8 rewritten with resource budgets: <150MB idle RAM, <1% background CPU, near-zero idle GPU. 10 mandatory efficiency rules: background mode, lazy init, no wake-up timers, XInput throttling, image cache limits, const constructors, provider select(), Uint8List |
| 11 | Play count threshold | Increment after **30 seconds or 50% of track duration** (whichever is less). Skips still create `play_history` entries but don't inflate `play_count`. See FL-PLAY-008 |
| 12 | Virtual keyboard (gamepad) | **Rely on system on-screen keyboard for V1.** Custom gamepad-navigable virtual keyboard deferred to V1.1 pending user testing. See FL-SEARCH-005 |
| 13 | Crossfade architecture | **Dual `AudioPlayer` instances** (`playerA` + `playerB`). `playerB` lazy-instantiated only when crossfade > 0. Volume fading, swap, dispose cycle. See Section 10.6a |
| 14 | Close-to-tray default | Default: **close to tray**. First-time dialog asks user preference with "Remember my choice" checkbox. See FL-TRAY-004 |
| 15 | Single-instance IPC | Windows: named pipe. macOS/Linux: Unix domain socket. JSON protocol. See FL-SINGLE-003 |
| 16 | File-not-found during playback | Error toast + auto-skip + `is_missing` flag in DB. 3+ consecutive failures trigger rescan prompt. Never auto-delete. See FL-PLAY-009 |
| 17 | Session definition | Session = app launch. Tracked via `session_id` column in `play_history`. See FL-PL-008 |
| 18 | Accent color hex values | All 8 colors defined with hex codes. Chosen for contrast on both dark and light backgrounds. See Section 6.4 |
| 19 | Per-screen button override matrix | Section 4.1a — full matrix of all 16+ controller inputs across every screen. LT/RT/Start never overridden. LB/RB contextual. Y/X repurposed where relevant |
| 20 | Genre Detail screen | Added Section 6.3.2c — same structure as Artist Detail. Header, album row, song list, gamepad spec |
| 21 | Folder Navigation screen | Added Section 6.3.2d — breadcrumb-style navigation. Subfolders first, then files. B goes up one level |
| 22 | Equalizer UI | Added Section 6.3.7a — full-screen overlay accessible from Settings and Now Playing. Graceful fallback between full EQ and bass/treble |
| 23 | Drag & drop | In-place scan, no auto-add to `scan_folders`. Accent overlay visual feedback. Duplicates silently skipped. See FL-LIB-006 |
| 24 | D-pad L/R on Now Playing | **±5s seek** (not ±10s, not prev/next). Consistent across global mapping, button matrix, and screen spec. LB/RB handle prev/next |
| 25 | M3U import entry point | **"Import M3U" button on Playlists list screen header**, next to "Create Playlist". Opens system file picker, resolves paths against library. See FL-PL-007 |
| 26 | File association (app already running) | **Play Next + start playing.** Inserts after current track and auto-advances to it. Multiple files inserted in order. See FL-ASSOC-002 |
| 27 | Drag & drop duplicate handling | **Silently skip**, toast reports "Added Y of X songs (Z already in library)". No metadata re-read. See FL-LIB-006 |
| 28 | Playlist reorder via gamepad | Via **context menu "Reorder" item** (X button). Same reorder-mode UX as Queue: D-pad moves, A confirms, B cancels. See Section 6.3.6 |
| 29 | Language change restart | **Immediate, no restart required.** Riverpod `localeProvider` update triggers `MaterialApp` rebuild. See FL-L10N-002 |
| 30 | Scan permission errors | **Log WARN + skip + toast** "Scan complete. X folders were inaccessible." See FL-LIB-005 |
| 31 | Background blur during crossfade | **Pre-compute when `playerB` starts loading**, before visual crossfade begins. See Section 10.6a |
| 32 | Navigation sound volume | **3-position toggle: Off / Quiet / Normal.** Stored in settings KV as `nav_sound_level`. Independent from music volume. See FL-INPUT-005 |
| 33 | Now Playing section header | Fixed missing `#### 6.3.3 Now Playing Screen` header that was lost during v1.5 batch edits |
| 34 | Favorites screen spec | Added Section 6.3.8 — dedicated screen for Favorites nav item. Song list with sort dropdown, unfavorite via Y with undo toast. See 6.3.8 |
| 35 | Playlists List screen spec | Added Section 6.3.9 — dedicated screen for Playlists nav item. Smart playlists section (top, non-editable, `sparkles` badge) + user playlists grid. Header has "Import M3U" + "Create Playlist". See 6.3.9 |
| 36 | Search results per-category limits | **Max 5 results per category**, with "Show all (N)" expandable button. Categories with 0 results hidden. See FL-SEARCH-003 |
| 37 | Scroll to Now Playing button UI | Floating pill button, bottom-right above mini player. Visible only when playing track is in current list and scrolled off-screen. Focusable, A scrolls to track. `Ctrl+G` shortcut. See FL-BROWSE-008 |
| 38 | Recently Played full history | **"See All" button** on Recently Played row header. Opens full-screen list of last 100 songs. See Section 6.3.1 #2 |
| 39 | Folder Browser Y button | **Fav focused song, disabled on folders.** Y works on song files but does nothing on folder items. Button hints update dynamically. See Section 4.1a matrix |
| 40 | Quick Access Row source | Changed from "pinned/favorited playlists" to **most recently updated playlists** (`updated_at` desc, max 10). No new schema needed. See Section 6.3.1 #4 |
| 41 | Playlist cover mosaic edge cases | 0 songs → Lucide `music` icon on themed bg. 1 art → full-size. 2 arts → 2×1 split. 3 arts → 2×2 with first repeated. 4+ → standard 2×2. See FL-PL-006 |
| 42 | Playback resume on launch | **No dialog. Restore queue/position silently, do NOT auto-play.** Home Quick Resume card is the prompt. Optional `resume_on_launch` setting for auto-play. See FL-PLAY-007 |
| 43 | Library Songs tab layout | **Song list tiles** (not table columns). Sort via dropdown selector at top of tab. Consistent with all other song lists in the app. See Section 6.3.2 |
| 44 | Smart playlists UI placement | **Separate section at top** of Playlists List Screen with `sparkles` badge. Non-editable. See Section 6.3.9 |
| 45 | Search history UI | Vertical list with `clock` icons, per-item `x` remove, "Clear History" button. A selects/runs, D-pad right focuses remove. See Section 6.3.5 |
| 46 | "Add to Playlist" submenu | Scrollable sub-menu: "New Playlist..." at top, then user playlists by `updated_at` desc. Max 8 visible, scrollable. A adds song, B returns to parent menu. See FL-INPUT-008a |
| 47 | Create/Rename Playlist dialog | Modal with text input + Create/Save & Cancel buttons. Default name "My Playlist" (auto-numbered). Max 100 chars. After create → navigate to detail. After rename → stay, toast. See FL-PL-001a |
| 48 | Destructive confirmation dialogs | Delete playlist and Clear queue get confirmation modals. Cancel is default focus (safe). No confirmation for single-item removals that have undo toasts. See FL-PL-001b |
| 49 | Favorites button matrix row | Added Favorites row to 4.1a matrix: Y = **Unfavorite** (with undo toast), X = song context menu, B = nothing (root screen). Distinct from global Y = toggle favorite |
| 50 | Mute toggle | Lucide `volume-2` / `volume-x` icon button next to volume slider in Now Playing. Grays out slider. Playback continues. Not persisted across restarts. See Section 6.3.3 |
| 51 | Artists tab layout | **Grid of artist cards** (not ambiguous "grid/list"). Shows artist name, song count, Lucide `user` placeholder icon. Consistent with Albums grid. See Section 6.3.2 |

---

*Document version: 1.8*
*Last updated: 2026-04-19*
