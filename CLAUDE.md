# CLAUDE.md — Music FSE Project Rules

> This file defines mandatory rules for all AI-assisted development on the Music FSE project.
> Every code generation, review, and refactoring session MUST follow these rules.
> Read `docs/REQUIREMENTS.md` for the full feature spec, architecture, and schema.

---

## 1. Project Identity

- **App Name**: Music FSE (Full Screen Experience)
- **Package**: `com.musicfse.player`
- **Framework**: Flutter (desktop only — Windows, macOS, Linux)
- **Primary Target**: 7-8" handheld gaming PCs (ASUS ROG Ally, Lenovo Legion Go) with XInput gamepads
- **Secondary Target**: Standard desktop with keyboard/mouse
- **Architecture**: Clean Architecture (Presentation → Domain → Data)
- **State Management**: Riverpod with code generation (`@riverpod` annotations)
- **Database**: Drift (SQLite ORM)
- **Audio**: `just_audio` + `just_audio_windows`
- **Routing**: `go_router` v14

---

## 2. GOLDEN RULE: Handheld & Gamepad First

**This is the single most important rule in the entire project.**

The app is designed to be operated with an XInput gamepad on a 7-8 inch 1080p screen held at arm's length. Every widget, screen, layout, and interaction MUST be designed and implemented with this as the primary input method.

### 2.1 What This Means in Practice

- **Every interactive widget MUST be focusable** via `Focus`/`FocusNode`. No element may exist that can only be reached by mouse click or touch.
- **Every screen MUST define a default focus element** — the element that receives focus when the screen opens.
- **Focus traversal MUST be predictable** — left-to-right, top-to-bottom, matching the visual layout. Use `FocusTraversalGroup` and `OrderedTraversalPolicy` where automatic traversal is wrong.
- **Focus indicator MUST be visible** — 2px accent-colored border + subtle scale (1.02x). Must contrast against both dark and light themes.
- **Focus memory MUST be preserved** — when navigating away from a screen and returning, restore focus to the last-focused item.
- **No focus traps** — the user must always be able to navigate away from any focused element using the D-pad or B button.
- **No dead-end focus** — from any focused element, pressing any D-pad direction must either move focus somewhere or do nothing. Focus must never be lost.

### 2.2 Sizing Minimums (NEVER Go Below These)

| Element | Minimum Size |
|---------|-------------|
| Any focusable item | 48×48 lp |
| List tile height | 56 lp |
| Icon button hit area | 48×48 lp |
| Grid card | 140×180 lp |
| Nav rail icon | 48×48 lp |
| Mini player bar | 72 lp height |
| Body text | 14sp minimum |
| Heading text | 20-28sp |
| Caption text | 12sp minimum |
| Spacing between focusable items | ≥8 lp |
| Screen edge padding | 16-24 lp |

### 2.3 Gamepad Button Mapping (Global)

Always respect this mapping. Do not reassign buttons:

| Button | Action |
|--------|--------|
| A | Select / Confirm / Play |
| B | Back / Cancel / Close |
| X | Context menu / Options |
| Y | Toggle favorite |
| LB | Previous track (global) / Switch tab (in tabbed views) |
| RB | Next track (global) / Switch tab (in tabbed views) |
| LT | Volume down (analog) |
| RT | Volume up (analog) |
| D-pad | Navigate within focus group |
| Left Stick | Analog scroll / navigate |
| Right Stick | Seek current track (horizontal) |
| Start | Play/Pause toggle |
| Back/Select | Open search |

### 2.4 Gamepad Checklist for Every Widget

Before any widget is complete, verify:
- [ ] Focusable with `Focus` widget or inherently focusable (e.g., `InkWell`, `ElevatedButton`)
- [ ] Shows accent-colored focus indicator when focused
- [ ] A button triggers the primary action
- [ ] X button opens context menu (if applicable)
- [ ] B button goes back / dismisses (if applicable)
- [ ] D-pad moves focus logically to adjacent items
- [ ] Works without any mouse/touch interaction

### 2.5 Gamepad Checklist for Every Screen

- [ ] Has a defined default focus element
- [ ] All actions are reachable via gamepad
- [ ] Button hints bar shows correct context for focused item
- [ ] LB/RB behavior is defined (tab switch, focus group switch, or prev/next track)
- [ ] B button exits the screen or dismisses the overlay
- [ ] Scroll works with D-pad (step) and left stick (analog)
- [ ] No layout overflow at 1920×1080

---

## 3. Architecture Rules

### 3.1 Clean Architecture — Dependency Rule

```
Presentation (UI + Providers)  →  depends on  →  Domain
Domain (Entities + Use Cases)  →  depends on  →  NOTHING (pure Dart)
Data (Repos + DAOs + Models)   →  depends on  →  Domain (implements interfaces)
```

- **Domain layer has ZERO Flutter imports.** No `package:flutter`, no `BuildContext`, no widgets.
- **Domain defines repository interfaces** (abstract classes). Data layer implements them.
- **Use cases are single-purpose classes** with a `call()` method.
- **Presentation depends on domain only** — never import from `data/` in `presentation/`.
- **Data depends on domain only** — never import from `presentation/` in `data/`.

### 3.2 Riverpod Rules

- Use `@riverpod` annotation (code generation) for all providers. No manual `Provider()`/`StateNotifierProvider()`.
- Use `@Riverpod(keepAlive: true)` for singletons (database, audio player, settings).
- Use `AsyncNotifier` for anything involving async operations.
- Use `Notifier` for synchronous state.
- Use `StreamProvider` for real-time streams (playback position, scan progress).
- Providers live in `presentation/providers/`. They depend on use cases, not on repositories or DAOs directly.
- Run `dart run build_runner build` after adding/modifying any `@riverpod` annotated class.

### 3.3 Drift (Database) Rules

- All tables defined in a single `database.dart` file using Drift's table classes.
- DAOs are separate files: `song_dao.dart`, `playlist_dao.dart`, etc.
- Always use parameterized queries (Drift handles this, but never construct raw SQL with string interpolation).
- Migrations: use `MigrationStrategy` with `onUpgrade` for schema changes. Never drop tables in production.
- All queries that return lists used in the UI should support pagination/limits for performance.

### 3.4 File Organization

Follow the project structure defined in `docs/REQUIREMENTS.md` Section 10.4. Key rules:
- One class per file (with small private helpers allowed in the same file).
- File names in `snake_case.dart`.
- Folder structure mirrors the architecture: `core/`, `domain/`, `data/`, `presentation/`, `platform/`.
- Platform-specific code goes in `platform/` with clear separation: `xinput/`, `smtc/`, `media_keys/`, `macos/`, etc.

---

## 4. UI/UX Rules

### 4.1 Theming

- **Dark mode is the default.** Design dark-first, then verify light mode.
- Use `Theme.of(context)` and `ColorScheme` exclusively. No hardcoded colors.
- Accent color is user-configurable. Always reference it via the theme, never hardcode `#C76E00`.
- **All text styling MUST use `Theme.of(context).textTheme`** (e.g., `textTheme.bodyMedium`, `textTheme.titleLarge`). Never hardcode `fontSize`, `fontFamily`, or `fontWeight` in a `TextStyle`. If a text variant doesn't exist in the theme, add it to the theme definition — don't inline it. The theme is the single source of truth for typography across both dark and light modes.
- Font sizes use the scale: caption 12sp, body 14-16sp, heading 20-28sp.
- **Font**: Inter (bundled via `google_fonts`, cached locally). Weights: Regular 400 (body), Medium 500 (emphasis), SemiBold 600 (headings), Bold 700 (display). Fallback: Segoe UI → SF Pro → system sans.
- **Icons**: Lucide Icons (`lucide_icons` package) for all UI icons. Do not use Material Icons. Lucide provides consistent 24px/2px-stroke icons matching the app icon style.

### 4.2 Layout

- Minimum window size: 800×500.
- Two layout breakpoints only: ≥1200px (full nav rail with labels), 800-1199px (collapsed icon-only nav rail).
- No responsive behavior below 800px — it will never happen.
- Screen edge padding: 16-24 lp.
- Content never touches window edges or overlaps the mini player bar.

### 4.3 Animations & Transitions

> Animations exist to guide the user and confirm actions — never for decoration. This app runs alongside games on handheld gaming PCs. Every CPU/GPU cycle matters.

**DO animate** (purposeful transitions):
- Page transitions: 250ms `easeInOut` slide+fade via `CustomTransitionPage`
- Focus indicator changes: 150ms `easeOut` via `AnimatedContainer` + `AnimatedScale`
- Mini player ↔ Now Playing expand/collapse: 300ms hero-like album art transition
- Context menu open/close: 150ms scale+fade in, 100ms fade out
- Toast notifications: 200ms slide-in, 150ms fade-out
- Queue panel: 250ms slide from right
- Album art crossfade on track change: 300ms `AnimatedSwitcher`
- Favorite heart toggle: 200ms scale bounce (1.0 → 1.3 → 1.0)
- List item stagger on first screen load only: 50ms stagger, max 8-10 items

**DO NOT animate** (instant, zero-cost):
- Theme changes, sort order changes, search results appearing
- Background blur (static per track), settings toggles
- Window resize, nav rail expand/collapse, scroll position
- Any looping/pulsing/breathing/rotating decorative animation

**Rules**:
- Max 300ms for any single transition. Users on gamepad navigate quickly
- All transitions interruptible — if B is pressed mid-animation, cancel and go back immediately
- Stagger only on initial screen load, never on scroll-into-view
- Use implicit animations (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedScale`) over explicit `AnimationController` wherever possible
- No `Ticker` running when widget is off-screen. Dispose/pause properly
- One animation per visual region at a time — no overlapping transitions

### 4.4 Empty States

Every screen/view that can be empty MUST show:
1. An icon or illustration
2. A descriptive message
3. A call-to-action button (where applicable)

Use the reusable `EmptyState` widget. See the empty states table in `REQUIREMENTS.md` Section 6.3a.

### 4.5 Context Menus

Context menus are triggered by:
- X button (gamepad)
- Right-click (mouse)
- Long-press (touch, if ever applicable)

Menu items vary by context (song in library vs. song in playlist vs. album, etc.). See `REQUIREMENTS.md` Section 4.1 FL-INPUT-008 for the full mapping.

### 4.6 Toast Notifications

- Use the `ToastNotification` widget for action confirmations ("Added to queue", "Removed from playlist").
- Position: bottom-center, above mini player bar.
- Auto-dismiss: 3 seconds.
- Destructive actions (remove, delete) include an "Undo" button in the toast.
- Error toasts use the error color from the theme.
- Toasts must not block gamepad focus — they are non-focusable overlays.

---

## 5. Performance Rules

> **This app runs on gaming handhelds.** The user alt-tabs between a game and the music player. Every MB of RAM and every CPU cycle consumed is stolen from the game. Resource efficiency is a core feature, not an optimization.

### 5.1 Resource Budgets

| Metric | Target |
|--------|--------|
| RAM (active, 10K library) | < 300MB |
| RAM (idle/background) | < 150MB |
| CPU (background, playing audio) | < 1% |
| CPU (active browsing) | < 5% |
| GPU (idle) | Near-zero |
| Startup to interactive | < 2 seconds |

### 5.2 Mandatory Practices

- **`const` constructors everywhere possible.** Prevents unnecessary widget rebuilds.
- **`select()` on Riverpod providers.** Listen to specific fields, not entire state objects. A widget showing only a song title must not rebuild when play position changes.
- **Dispose EVERYTHING.** `FocusNode`, `ScrollController`, `AnimationController`, `StreamSubscription` — all disposed in `dispose()`. No exceptions.
- **Virtualized lists ONLY.** `ListView.builder` / `GridView.builder` / `Sliver*`. Never `ListView(children: [...])` for growable lists.
- **Lazy image loading.** `FadeInImage` with placeholders. Never load all album art eagerly.
- **Image cache limit**: Override Flutter default to max 200 images / 50MB. Purge on background.
- **Isolates for heavy work.** Library scanning, metadata extraction, art thumbnail generation — all on background isolates. Never block the UI thread.
- **Background mode.** When minimized: stop UI rendering, stop XInput polling, stop all tickers/animations. Keep only audio player + SMTC/MPRIS alive.
- **Lazy initialization.** Recommendations engine, equalizer, scan worker — don't initialize until first use.
- **No wake-up timers.** No periodic background timers. No polling. Rescan is manual or on-launch only.
- **Throttle XInput.** 60Hz max when active. 0Hz (stopped) when app is in background.
- **Prefer `Uint8List`** over `List<int>` for binary data.
- **Profile in `--release` mode only.** Debug mode numbers are meaningless.

---

## 6. Platform Rules

### 6.1 Windows (Primary)

- XInput polling at 60Hz via `dart:ffi` bindings to `xinput1_4.dll`.
- SMTC integration via platform channels to Win32 APIs.
- System tray via `system_tray` package.
- Custom title bar (no native Windows title bar). Window controls (min/max/close) are part of the app's `CustomTitleBar` widget.
- Named mutex for single-instance enforcement.

### 6.2 macOS (Secondary)

- `MPNowPlayingInfoCenter` for Now Playing integration.
- Media key handling via macOS-specific platform channel.
- Menu bar tray icon.
- Native traffic light buttons OR custom title bar — match the app's design.
- XInput not available on macOS — gamepad controls are Windows-only (keyboard/mouse on Mac is fine).

### 6.3 Linux (Secondary)

- MPRIS D-Bus for media integration.
- Media keys via D-Bus.
- System tray via StatusNotifierItem.
- XInput not available — keyboard/mouse only.

---

## 7. Code Quality Rules

### 7.1 General

- **Widget reusability (DRY rule)**: If a widget pattern, layout, or component appears in 2 or more places, extract it into a reusable widget in `lib/presentation/widgets/`. No copy-pasting widget trees across screens. Shared widgets must be parameterized (via constructor args), not specialized per-screen.
- **No `print()` statements.** Use the app's logging system (`FL-LOG-*`) with appropriate log levels.
- **No `// TODO` without a tracking issue.** If something is deferred, it must be in the Future Considerations section of the requirements.
- **No unused imports.** Run `dart fix --apply` regularly.
- **No magic numbers.** Use `app_constants.dart` for sizes, durations, limits.
- **Error handling**: Use `Result` types (sealed classes) or Dart's `Either` equivalent. Catch errors at system boundaries (file I/O, FFI calls, platform channels). Don't scatter try-catch throughout business logic.
- **Null safety**: Full sound null safety. No `!` operator unless the value is provably non-null with a comment explaining why.

### 7.2 Naming Conventions

- Classes: `PascalCase` (e.g., `SongListTile`, `PlaybackProvider`)
- Files: `snake_case.dart` (e.g., `song_list_tile.dart`, `playback_provider.dart`)
- Variables/functions: `camelCase`
- Constants: `camelCase` for top-level, `SCREAMING_CASE` not used in Dart
- Private members: prefix with `_`
- Providers: suffix with `Provider` (e.g., `playbackProvider`, `themeProvider`)
- Use cases: verb-noun (e.g., `ScanLibrary`, `GetAllSongs`, `ToggleFavorite`)
- Entities: singular nouns (e.g., `Song`, `Playlist`, `Artist`)
- DAOs: suffix with `Dao` (e.g., `SongDao`, `PlaylistDao`)

### 7.3 Testing

- Unit tests for all use cases and repository implementations.
- Widget tests for all custom widgets — include gamepad focus traversal tests.
- Integration tests for critical flows (scan → browse → play → queue).
- Use `mocktail` for mocking. No `mockito`.
- Test file naming: `<source_file>_test.dart` in a mirrored `test/` directory structure.
- Coverage targets: ≥80% for domain + data, ≥60% for presentation.

---

## 8. What NOT to Do

- **Do NOT add network calls.** This is a fully offline app. No HTTP, no WebSocket, no REST, no GraphQL. Any code that imports `dart:io` `HttpClient` or `package:http` is wrong.
- **Do NOT add telemetry or analytics.** No tracking, no crash reporting services, no Firebase.
- **Do NOT use `get_it` or `injectable`.** Riverpod is the DI container.
- **Do NOT use `provider` package.** Only `flutter_riverpod` + `riverpod_annotation`.
- **Do NOT use `bloc` or `cubit`.** Riverpod only.
- **Do NOT use Material Icons.** Use `lucide_icons` package exclusively for all UI icons. This ensures visual consistency with the 24px/2px-stroke Lucide style.
- **Do NOT design mobile-first layouts.** Minimum width is 800px. There is no phone layout.
- **Do NOT use `setState()` in any widget** except trivially local animation state. All app state goes through Riverpod.
- **Do NOT hardcode strings.** All user-visible text goes through the localization system (ARB files).
- **Do NOT use `Image.network()`.** There are no network images. All images are local files or cached assets.
- **Do NOT create widgets that are only usable with a mouse.** If it can't be operated with a gamepad, it doesn't belong in this app.
- **Do NOT ignore the focus system.** If you create a new interactive widget and it doesn't participate in focus traversal, it is broken.

---

## 9. Workflow Rules for AI Sessions

### 9.1 Before Writing Code

1. Read this `CLAUDE.md` file.
2. Read `docs/REQUIREMENTS.md` for the relevant feature/section.
3. Check existing code in the relevant directories to understand patterns already established.
4. If a similar widget/provider/use case exists, follow its patterns exactly.

### 9.2 When Creating a New Widget

1. Make it focusable (wrap with `Focus` or use a focusable base widget).
2. Add a visible focus indicator using the app's `FocusHighlight` wrapper.
3. Handle A/B/X/Y button actions via `KeyboardListener` or the app's input system.
4. Ensure it works in the tab order / D-pad navigation flow.
5. Add to the `gamepad_button_hints` context map if it has unique button actions.
6. Test with both dark and light themes.

### 9.3 When Creating a New Screen

1. Define the default focus element.
2. Set up `FocusTraversalGroup` for each focus region (header, content, actions).
3. Define button hints context for the screen.
4. Handle B button to go back.
5. Handle empty state.
6. Use virtualized lists for any list that can have more than ~20 items.
7. Verify it works at both 1200px+ and 800-1199px layout breakpoints.

### 9.4 When Modifying Existing Code

1. Don't refactor code unrelated to your task.
2. Don't add docstrings, comments, or type annotations to code you didn't change.
3. Don't "improve" code that's working and not part of the task.
4. Run `flutter analyze` after changes — zero warnings policy.
5. Run relevant tests after changes.

---

## 10. Quick Reference — File Locations

| What | Where |
|------|-------|
| Requirements & spec | `docs/REQUIREMENTS.md` |
| App entry point | `lib/main.dart` |
| Theme definitions | `lib/core/theme/` |
| Router config | `lib/core/router/app_router.dart` |
| Domain entities | `lib/domain/entities/` |
| Repository interfaces | `lib/domain/repositories/` |
| Use cases | `lib/domain/usecases/` |
| Database & DAOs | `lib/data/datasources/local/` |
| Riverpod providers | `lib/presentation/providers/` |
| Pages/screens | `lib/presentation/pages/` |
| Shared widgets | `lib/presentation/widgets/` |
| Platform code (XInput, SMTC) | `lib/platform/` |
| Localization ARB files | `lib/core/localization/arb/` |
| Tests | `test/` (mirrored structure) |
