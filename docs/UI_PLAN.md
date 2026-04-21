# UI Design Plan

> Phase 2 of Music FSE development — visual design selection before implementation.

## Approach

1. **Style Sampler** — One representative screen (Home) rendered in 5 design languages, tab-switchable in a single HTML file. Enough to pick a direction.
2. **Full Mockup Set** — After style selection, all screens mocked up interactively in the chosen style with both breakpoints, focus states, dark/light themes.

## Design Languages

### 1. Music FSE Original (Agent Recommendation)
- **Philosophy**: Warm, refined, content-first. Its own identity — not copying any platform.
- **Key Traits**: Warm orange glow on focus, subtle frosted glass on mini player, 12px card radius, comfortable (not dense) spacing, deep dark background (#0D1117).

### 2. Spotify-Inspired
- **Philosophy**: Dense and functional — maximum content visible, bold typography hierarchy.
- **Key Traits**: Ultra-compact cards, 8px radius, no glow/blur effects, strongest size contrast between headings and body, minimal chrome.

### 3. Sony / PlayStation-Inspired
- **Philosophy**: Premium and spacious — gallery-like presentation with dramatic focus effects.
- **Key Traits**: Largest cards, biggest focus scale-up (1.05×), deep blue-black background, 16px radius, generous whitespace, floating shadow cards.

### 4. Xbox / Microsoft Fluent-Inspired
- **Philosophy**: Structured and layered — acrylic materials with organized grid alignment.
- **Key Traits**: Frosted glass (acrylic) surfaces, 4px radius (sharp), reveal-style focus highlight, compact grid layout, information-dense but orderly.

### 5. Valve / Steam-Inspired
- **Philosophy**: Bold and high-contrast — game-launcher confidence with gradient accents.
- **Key Traits**: Blue-tinted dark background (#1B2838), thickest focus borders (3px), gradient overlays on cards, large targets, strongest visual weight.

## Screens for Full Mockup (after style selection)

| # | Screen | Key Elements |
|---|--------|-------------|
| 1 | Home | Quick resume, recently played, recommendations, quick access, stats |
| 2 | Library — Songs tab | Song list, sort/filter controls, tab bar |
| 3 | Library — Albums tab | Album grid, sort controls |
| 4 | Library — Artists tab | Artist card grid |
| 5 | Library — Genres tab | Genre card grid |
| 6 | Library — Folders tab | Folder tree, file list |
| 7 | Album Detail | Album header, track list |
| 8 | Artist Detail | Artist header, albums, top songs |
| 9 | Now Playing | Full-screen album art, controls, lyrics placeholder |
| 10 | Queue Panel | Current track, up next, queue list |
| 11 | Search — Empty | Search bar, recent searches |
| 12 | Search — Results | Categorized results (songs, albums, artists) |
| 13 | Playlists List | Playlist cards/tiles, create button |
| 14 | Playlist Detail | Header, track list, drag-reorder indicators |
| 15 | Favorites | Favorites list with unfavorite action |
| 16 | Settings | All settings sections |
| 17 | EQ Overlay | 10-band EQ, presets |
| 18 | Context Menu | Song context menu with submenu |
| 19 | Dialogs | Create playlist, delete confirmation, close-to-tray |
| 20 | Empty States | Library empty, playlist empty, search no results |
| 21 | Onboarding | 4-step first-run flow |

## File Structure

```
mockups/
├── style_sampler.html          ← 5-variant comparison (Home screen)
└── full/                       ← Complete screen set (after selection)
    ├── index.html              ← Navigation hub
    ├── home.html
    ├── library.html
    ├── now_playing.html
    ├── search.html
    ├── playlists.html
    ├── settings.html
    └── ...
```
