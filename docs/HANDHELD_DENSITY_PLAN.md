# Handheld Density Optimization Plan — Responsive Approach

> Target device: **ASUS ROG Ally** — 7" 1920×1080 IPS, 16:9, Windows 150% scaling  
> Effective logical resolution: **~1280×720 lp** (at recommended 150% DPI scaling)  
> Viewing distance: **~30 cm (12 inches)** — arm's length, handheld  
> Date: 20 April 2026

---

## 1. Problem Statement

The current layout was designed at **console/10-foot UI scale** — generous spacing, large cards, and thick chrome bars. On the ROG Ally's 7" 1080p display at 150% scaling (1280×720 lp effective), the fixed vertical chrome consumes **23%** of screen height, and content sections are so tall that only **~1.3 sections** are visible above the fold on the Home screen.

**On desktop (1920×1080 at 100%)** the current layout looks great. We must not regress it.

### Solution: Responsive Two-Tier Layout

Instead of flatly changing every constant, we introduce a **height-based density tier** that selects between **standard** (current values, unchanged) and **compact** (handheld-optimized values) based on screen height. This preserves the desktop experience while optimizing the handheld experience.

| Tier | Condition | When |
|------|-----------|------|
| **Standard** | Screen height **≥ 800 lp** | Desktop 1080p/1440p, laptops |
| **Compact** | Screen height **< 800 lp** | ROG Ally (720 lp), Steam Deck (~800 lp at boundary), minimum window (500 lp) |

The 800 lp breakpoint was chosen because:
- ROG Ally at 150% scaling = **720 lp** → compact
- Steam Deck at 1280×800 native = **800 lp** → standard (borderline, but spacing is less critical at 800)
- Typical laptop at 1366×768 = **768 lp** → compact (appropriate — these screens are also small)
- Desktop at 1920×1080 = **1080 lp** → standard (unchanged)
- Minimum window at 800×500 = **500 lp** → compact

### Current Vertical Budget on Handheld (720 lp total)

| Layer | Current Height | % of Screen |
|-------|---------------|-------------|
| Title bar | 36 lp | 5.0% |
| **Content area** | **556 lp** | **77.2%** |
| Mini player | 84 lp | 11.7% |
| Button hints bar | 44 lp | 6.1% |
| **Total chrome** | **164 lp** | **22.8%** |

### What the User Sees on Home (above fold, 556 lp)

| Element | Height | Running Total |
|---------|--------|---------------|
| Top padding | 20 lp | 20 |
| Page title ("Home") | ~30 lp | 50 |
| Section gap | 16 lp | 66 |
| Quick Resume card | 100 lp | 166 |
| Section gap | 20 lp | 186 |
| "Recently Played" header | ~28 lp | 214 |
| Header-to-cards gap | 8 lp | 222 |
| Card row | 210 lp | 432 |
| Section gap | 20 lp | 452 |
| Next section header | ~28 lp | 480 |
| Next section cards (partial) | **76 lp visible** | 556 |

**Result:** The user sees 1 full card row + a sliver of the next. Two thumb-scrolls to reach stats.

---

## 2. Goals

1. **Reclaim ~70 lp of vertical space on handhelds** — enough to show 2 full sections above the fold.
2. **Reduce chrome height** from 164 → ~136 lp on compact tier.
3. **Shrink card rows** from 210 → 170 lp on compact tier without sacrificing readability at arm's length.
4. **Tighten inter-section spacing** on compact tier.
5. **Maintain all CLAUDE.md minimum sizing rules** — no focusable element below 48×48 lp.
6. **Zero visual change on desktop** — standard tier serves the exact same values as today.
7. **Automatic tier switching** — resizing the window live-switches between tiers.

### Post-Optimization Vertical Budget (Compact Tier, 720 lp)

| Layer | New Height | Saved |
|-------|-----------|-------|
| Title bar | 32 lp | 4 lp |
| Mini player | 72 lp | 12 lp |
| Button hints bar | 36 lp | 8 lp |
| **Total chrome** | **140 lp** | **24 lp** |
| **Content area** | **580 lp** | **+24 lp** |

Combined with tighter content spacing, net gain is **~70 lp** of visible content.

Desktop (standard tier) is **completely unchanged**.

---

## 3. Architecture: `AppSizes` InheritedWidget

### 3.0 Design

Instead of scattering `MediaQuery` calls across every widget, we introduce a **single `AppSizes` InheritedWidget** that reads the screen height once and exposes tier-appropriate values to the entire widget tree.

**New file:** `lib/core/constants/app_sizes.dart`

```dart
/// Height-responsive layout sizes.
///
/// Placed once in the widget tree (inside `MusicFseApp.build`, wrapping the
/// `MaterialApp.router`). Every descendant reads values via:
///
///     final sizes = AppSizes.of(context);
///     sizes.miniPlayerHeight  // → 84.0 on desktop, 72.0 on handheld
///
/// Only the ~20 properties that differ between tiers live here.
/// All fixed constants (animation durations, focusable minimums, font sizes,
/// dialog sizes, etc.) remain in `AppConstants` and are NOT duplicated.
enum DensityTier { standard, compact }

class AppSizes extends InheritedWidget {
  const AppSizes({
    super.key,
    required this.tier,
    required super.child,
  });

  final DensityTier tier;

  // ── Tier-switched getters ───────────────────────────────────────────────

  bool get isCompact => tier == DensityTier.compact;

  // Chrome
  double get titleBarHeight       => isCompact ? 32.0 : 36.0;
  double get miniPlayerHeight     => isCompact ? 72.0 : 84.0;
  double get buttonHintsHeight    => isCompact ? 36.0 : 44.0;

  // Layout
  double get screenEdgePadding    => isCompact ? 16.0 : 20.0;
  double get navRailCollapsedWidth => isCompact ? 64.0 : 72.0;
  double get sectionGap           => isCompact ? 14.0 : 20.0;
  double get headerContentGap     => isCompact ? 6.0  : 8.0;

  // Cards
  double get gridCardWidth        => isCompact ? 155.0 : 165.0;
  double get gridCardHeight       => isCompact ? 170.0 : 210.0;
  double get gridCardScrollRowWidth => isCompact ? 170.0 : 210.0;
  double get cardRadius           => isCompact ? 14.0 : 16.0;
  double get cardRadiusSm         => isCompact ? 10.0 : 12.0;
  double get cardPadding          => isCompact ? 10.0 : 12.0;

  // Mini player
  double get miniPlayerArtSize    => isCompact ? 44.0 : 48.0;
  double get miniPlayerPlayBtnSize => isCompact ? 32.0 : 34.0;

  // Now Playing
  double get nowPlayingArtMinSize          => isCompact ? 240.0 : 280.0;
  double get nowPlayingArtMaxSize          => isCompact ? 420.0 : 500.0;
  double get nowPlayingArtViewportFraction => isCompact ? 0.55  : 0.65;

  // ── InheritedWidget boilerplate ─────────────────────────────────────────

  static AppSizes of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppSizes>();
    assert(result != null, 'No AppSizes found in context');
    return result!;
  }

  /// Non-rebuilding access (for callbacks / layout code that shouldn't trigger
  /// a dependency on the InheritedWidget).
  static AppSizes read(BuildContext context) {
    final result = context.getInheritedWidgetOfExactType<AppSizes>();
    assert(result != null, 'No AppSizes found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppSizes oldWidget) => tier != oldWidget.tier;
}
```

### 3.0a Placement in Widget Tree

In `lib/presentation/app.dart`, inside `MusicFseApp.build()`:

```dart
@override
Widget build(BuildContext context) {
  // ... existing themeState, locale, router reads ...

  return Listener(
    // ... existing pointer handlers ...
    child: Focus(
      // ... existing key handler ...
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tier = constraints.maxHeight < 800
              ? DensityTier.compact
              : DensityTier.standard;

          return AppSizes(
            tier: tier,
            child: MaterialApp.router(
              // ... everything else unchanged ...
            ),
          );
        },
      ),
    ),
  );
}
```

**Why `LayoutBuilder` instead of `MediaQuery`?**  
`LayoutBuilder` uses the constraints from the window directly. `MediaQuery.sizeOf(context).height` would also work but requires the `MediaQuery` to already be in the tree (it's injected by `MaterialApp`). Since `AppSizes` wraps `MaterialApp`, `LayoutBuilder` is the right choice — it reads the window size before `MaterialApp` is built.

### 3.0b Migration Pattern for Widgets

Every widget that currently reads a tier-switched value from `AppConstants` changes one import:

```dart
// BEFORE
Container(height: AppConstants.miniPlayerHeight, ...)

// AFTER
Container(height: AppSizes.of(context).miniPlayerHeight, ...)
```

Fixed constants that don't vary by tier (`minFocusableSize`, `focusBorderWidth`, animation durations, etc.) continue to use `AppConstants` directly — no change needed.

### 3.0c What stays in `AppConstants`

`AppConstants` is **NOT modified**. It continues to hold:
- All fixed values (focusable minimums, animation durations, font sizes, dialog sizes, etc.)
- The **standard tier defaults** for reference (the values it has today)
- Non-layout constants (app identity, playback thresholds, image cache, etc.)

The values in `AppConstants` for the tier-switched properties (e.g., `miniPlayerHeight = 84.0`) remain as documentation of the standard tier, but widgets will read from `AppSizes.of(context)` instead.

---

## 4. Changes — Detailed Specification (Compact Tier)

All values in this section describe the **compact tier only**. The standard tier is unchanged from the current implementation.

### 4.1 Button Hints Bar: 44 → 36 lp (compact)

**File:** `lib/presentation/widgets/gamepad_button_hints.dart`  
**Reads from:** `AppSizes.of(context).buttonHintsHeight`

| Property | Current | New | Rationale |
|----------|---------|-----|-----------|
| `buttonHintsHeight` | 44 lp | 36 lp | Bar is reference UI, not interactive. 36 lp is comfortable for text at arm's length. |
| Button circle diameter | 28 lp | 22 lp | PS5-scale circles are overkill on a 7" screen. 22 lp matches the bumper badges, creating visual consistency. |
| Button letter font size | 15 sp | 12 sp | Proportional to circle shrink. Still bold (w900) so highly legible. |
| Hint label font size | 14 sp | 12 sp | Slightly smaller but still meets the 12sp caption minimum from CLAUDE.md §2.2. |
| Hint gap (between groups) | 20 lp | 16 lp | Tighter grouping. |
| Badge-to-label gap | 8 lp | 6 lp | Slight tightening. |
| Bumper badge height | 22 lp | 20 lp | Minor trim for consistency with smaller bar. |
| Bumper badge font size | 10 sp | 10 sp | **No change** — already at minimum. |
| Bar horizontal padding | 24 lp | 20 lp | Align with `screenEdgePadding`. |

**Implementation note:** The widget reads `AppSizes.of(context).buttonHintsHeight` for the bar height. The inner sizing (circle diameter, fonts, gaps) is switched inside the widget using `AppSizes.of(context).isCompact`.

**Visual result:** Thinner, more utilitarian hint bar. Still clearly readable. Saves 8 lp.

---

### 4.2 Mini Player Bar: 84 → 72 lp (compact)

**File:** `lib/presentation/widgets/mini_player_bar.dart`  
**Reads from:** `AppSizes.of(context).miniPlayerHeight`, `.miniPlayerArtSize`, `.miniPlayerPlayBtnSize`

The spec minimum in CLAUDE.md §2.2 is **72 lp**. The current 84 lp exceeds this by 12 lp.

| Property | Current | New | Rationale |
|----------|---------|-----|-----------|
| `miniPlayerHeight` | 84 lp | 72 lp | Matches the CLAUDE.md specified minimum. |
| Left column width | 240 lp | 220 lp | Slightly narrower; title text gets `MarqueeText` anyway. |
| Album art size (`miniPlayerArtSize`) | 48 lp | 44 lp | Slightly smaller, still well above 36 lp queue art. |
| Art-to-text gap | 14 lp | 10 lp | Tighter. |
| Title font size | 13 sp | 12 sp | 12sp is the caption minimum. Still `w600` weight. |
| Title-to-artist gap | 2 lp | 2 lp | **No change.** |
| Artist font size | 11 sp | 11 sp | **No change** — already at minimum. |
| Control icon size (shuffle/prev/next/repeat) | 20 lp | 18 lp | Slightly smaller, still clear with Lucide's 2px stroke. |
| Control button hit area | 48 lp | 48 lp | **No change** — must stay at minimum. |
| Control button spacing (16/12/12/16) | 16, 12, 12, 16 | 12, 8, 8, 12 | Tighter grouping. Buttons still have 48 lp hit areas. |
| Play/pause button size | 34 lp | 32 lp | Minor trim. Container is still 48 lp focusable. |
| Play/pause icon size | 16 lp | 16 lp | **No change.** |
| Controls-to-progress gap | 2 lp | 0 lp | Remove gap; progress bar is directly below controls. |
| Progress bar horizontal padding | 18 lp | 14 lp | Slightly tighter. |
| Progress bar height | 4 lp | 3 lp | Thinner track, still visible. |
| Time label font size | 11 sp | 11 sp | **No change.** |
| Time label gap to bar | 10 lp | 8 lp | Slightly tighter. |
| Right column width | 140 lp | 120 lp | Volume slider is still usable at this width. |
| Volume icon size | 18 lp | 16 lp | Minor trim. |
| Volume icon-to-slider gap | 8 lp | 6 lp | Slightly tighter. |
| Left/right column horizontal padding | 16 / 12 lp | 12 / 10 lp | Slightly tighter. |

**Key constraint:** All focusable hit areas remain **48×48 lp**. Only visual icon sizes and decorative spacing shrink.

**Implementation note:** The widget reads `sizes.miniPlayerHeight`, `sizes.miniPlayerArtSize`, `sizes.miniPlayerPlayBtnSize` from `AppSizes`. Inner spacing (column widths, gaps, icon sizes) is switched using `sizes.isCompact`.

**Visual result:** More compact mini player that still has all the same controls and information. Saves 12 lp on compact tier. Standard tier is unchanged.

---

### 4.3 Title Bar: 36 → 32 lp (compact)

**File:** `lib/presentation/widgets/custom_title_bar.dart`  
**Reads from:** `AppSizes.of(context).titleBarHeight`

| Property | Current | New | Rationale |
|----------|---------|-----|-----------|
| `titleBarHeight` | 36 lp | 32 lp | Title bar is non-interactive (drag handle + window buttons). 32 lp still accommodates traffic lights on macOS and min/max/close buttons on Windows. |
| Window button width | 46 lp | 42 lp | Slightly narrower. Still comfortable click/tap target. |
| Window button height | 36 lp | 32 lp | Matches new bar height. |
| Window button icon size | 14 lp | 12 lp | Proportionally smaller. |

**Implementation note:** Reads `sizes.titleBarHeight`. Inner button sizes switched via `sizes.isCompact`.

**Visual result:** Thinner title bar. Saves 4 lp on compact tier. Standard tier is unchanged.

---

### 4.4 Horizontal Scroll Cards (Home): 210 → 170 lp (compact)

**File:** `lib/presentation/widgets/album_card.dart`  
**File:** `lib/presentation/pages/home/home_page.dart`  
**Reads from:** `AppSizes.of(context).gridCardHeight`, `.gridCardScrollRowWidth`, `.cardPadding`, `.cardRadius`

| Property | Current | New | Rationale |
|----------|---------|-----|-----------|
| `gridCardHeight` | 210 lp | 170 lp | 40 lp shorter. Art shrinks from ~186 → ~146 lp per side — still large and legible. |
| `gridCardScrollRowWidth` | 210 lp | 170 lp | Square aspect ratio maintained (width matches height for scroll rows). |
| Card padding (`cardPadding`) | 12 lp | 10 lp | Slightly tighter to maximize art area within the smaller card. |
| Art-to-title gap | 10 lp | 6 lp | Tighter. |
| Title-to-artist gap | 2 lp | 2 lp | **No change.** |
| Card border radius (`cardRadius`) | 16 lp | 14 lp | Slightly less rounded for a denser feel. |
| Card inter-item spacing | 12 lp | 10 lp | Tighter horizontal rhythm. |
| Grid card width (grid view) | 165 lp | 155 lp | Slightly narrower in grid views to fit more columns. |

**Art size calculation (new):**  
- Card width: 170 lp  
- Padding: 10 lp × 2 = 20 lp  
- Art: 170 − 20 = **150 × 150 lp** (was 186 × 186)  
- Text area: ~30 lp (title + artist + gaps)  
- Total: 10 + 150 + 6 + 14 + 2 + 12 + 10 ≈ 170 lp ✓  

**More cards visible:** At 170 lp width + 10 lp gap, a 1280 lp - 72 lp (nav rail) = 1208 lp content width shows **~6.7 cards** (was ~5.3). User sees one more card per row.

**Visual result:** Noticeably more compact cards. Art is still the dominant element. Saves 40 lp vertically per card row.

---

### 4.5 Section Spacing & Page Padding (compact)

**File:** `lib/presentation/pages/home/home_page.dart`  
**File:** All page files that use section gaps  
**Reads from:** `AppSizes.of(context).screenEdgePadding`, `.sectionGap`, `.headerContentGap`

| Property | Standard (≥800 lp) | Compact (<800 lp) | Notes |
|----------|--------------------|--------------------|-------|
| `screenEdgePadding` | 20.0 | 16.0 | Was in `AppConstants` |
| `sectionGap` | 20.0 | 14.0 | **New** — currently hardcoded as `20` in page files |
| `headerContentGap` | 8.0 | 6.0 | **New** — currently hardcoded as `8` in page files |
| Quick Resume card height | 100 lp | 80 lp | Trim: reduce inner padding 16→12, art 68→56, tighten text. |
| Quick Resume art size | 68 lp | 56 lp | Still larger than list tile art (44). Clearly a featured element. |
| Quick Resume inner padding | 16 lp | 12 lp | Tighter. |
| Stats footer top padding | 28 lp | 20 lp | Generous top padding can shrink. |

---

### 4.6 Now Playing Page Adjustments (compact)

**File:** `lib/presentation/pages/now_playing/now_playing_page.dart`  
**Reads from:** `AppSizes.of(context).nowPlayingArtViewportFraction`, `.nowPlayingArtMaxSize`, `.nowPlayingArtMinSize`

| Property | Current | New | Rationale |
|----------|---------|-----|-----------|
| `nowPlayingArtViewportFraction` | 0.65 | 0.55 | On 720 lp content height, 0.65 = 468 lp art. That's enormous. 0.55 = 396 lp — still dominant, but leaves more room for metadata and controls. |
| `nowPlayingArtMaxSize` | 500 lp | 420 lp | Cap for large monitors. |
| `nowPlayingArtMinSize` | 280 lp | 240 lp | Lower floor for very small windows. |
| Control panel padding | 32 lp | 24 lp | Tighter. |
| Title-to-controls gap | 32 lp | 24 lp | Saves 8 lp. |
| Controls-to-secondary gap | 24 lp | 16 lp | Saves 8 lp. |
| Control button spacing (20/16/16/20) | 20, 16, 16, 20 | 16, 12, 12, 16 | Tighter. Hit areas remain 48 lp. |

---

### 4.7 Nav Rail — Minor Tightening (compact)

**File:** `lib/presentation/widgets/side_nav_rail.dart`  
**Reads from:** `AppSizes.of(context).navRailCollapsedWidth`

| Property | Current | New | Rationale |
|----------|---------|-----|-----------|
| `navRailCollapsedWidth` | 72 lp | 64 lp | On a 1280 lp wide screen, saving 8 lp of horizontal space gives content more room. Icons at 22 lp are still centered and clear. |
| Header height | 64 lp | 56 lp | Shorter header. Icon (28 lp) still fits comfortably. |
| Nav item min height | 48 lp | 48 lp | **No change** — must stay at minimum. |
| Nav item vertical padding | 2 lp | 2 lp | **No change.** |
| Separator vertical padding | 6 lp | 4 lp | Minor trim. |

---

### 4.8 Grid View Cards (Library Albums/Artists/Genres)

**File:** `lib/presentation/widgets/album_card.dart`  
**Reads from:** `AppSizes.of(context).gridCardWidth`, `.gridCardHeight`, `.cardPadding`, `.cardRadiusSm`

| Property | Current | New | Rationale |
|----------|---------|-----|-----------|
| `gridCardWidth` | 165 lp | 155 lp | Slightly narrower. Fits one more column in most layouts. |
| `gridCardHeight` | 210 lp | 170 lp | Consistent with scroll row card changes. |
| `cardPadding` | 12 lp | 10 lp | Consistent with scroll row changes. |
| `cardRadiusSm` | 12 lp | 10 lp | Proportionally smaller with smaller cards. |

---

### 4.9 Tier Values Summary (all properties in `AppSizes`)

These values are served by `AppSizes` getters. `AppConstants` is **not modified**.

| Property | Standard (≥800 lp) | Compact (<800 lp) | Savings |
|----------|--------------------|--------------------|--------|
| `titleBarHeight` | 36.0 | 32.0 | 4 lp |
| `miniPlayerHeight` | 84.0 | 72.0 | 12 lp |
| `buttonHintsHeight` | 44.0 | 36.0 | 8 lp |
| `screenEdgePadding` | 20.0 | 16.0 | 4 lp |
| `navRailCollapsedWidth` | 72.0 | 64.0 | 8 lp horizontal |
| `sectionGap` | 20.0 | 14.0 | 6 lp × N sections |
| `headerContentGap` | 8.0 | 6.0 | 2 lp × N sections |
| `gridCardWidth` | 165.0 | 155.0 | — |
| `gridCardHeight` | 210.0 | 170.0 | 40 lp per row |
| `gridCardScrollRowWidth` | 210.0 | 170.0 | — |
| `cardRadius` | 16.0 | 14.0 | — |
| `cardRadiusSm` | 12.0 | 10.0 | — |
| `cardPadding` | 12.0 | 10.0 | — |
| `miniPlayerArtSize` | 48.0 | 44.0 | — |
| `miniPlayerPlayBtnSize` | 34.0 | 32.0 | — |
| `nowPlayingArtMinSize` | 280.0 | 240.0 | — |
| `nowPlayingArtMaxSize` | 500.0 | 420.0 | — |
| `nowPlayingArtViewportFraction` | 0.65 | 0.55 | — |

---

## 5. What Does NOT Change

These values are already correct for both tiers and must not be reduced or made responsive:

| Property | Value | Reason |
|----------|-------|--------|
| `minFocusableSize` | 48 lp | WCAG / CLAUDE.md hard minimum |
| `listTileHeight` | 56 lp | Already compact for D-pad navigation |
| `songTileArtSize` | 44 lp | Correct for list items |
| `focusableSpacing` | 8 lp | Minimum gap for focus traversal |
| `focusBorderWidth` | 2 lp | Visibility requirement |
| `focusScaleTile` / `focusScaleCard` | 1.02 / 1.05 | Feedback requirement |
| Body text sizes | 14 sp | CLAUDE.md minimum |
| Caption text sizes | 12 sp | CLAUDE.md minimum |
| All animation durations | Various | Already optimal |
| `queuePanelWidth` | 340 lp | Needed for queue item readability |
| `contextMenuWidth` | 240 lp | Needed for menu text |
| `dialogWidth` | 380 lp | Needed for dialog content |
| `navRailExpandedWidth` | 220 lp | Only shown at ≥1200 lp width (desktop) |

All of the above remain as `static const` in `AppConstants`.

---

## 6. Implementation Order

Each phase is independently shippable and testable.

### Phase 1: Create `AppSizes` and Wire It Up (foundation)

**Files created: 1 | Files modified: 1**

1. **Create** `lib/core/constants/app_sizes.dart` — the `AppSizes` InheritedWidget with `DensityTier` enum, all 18 tier-switched getters, `of(context)` and `read(context)` static methods.
2. **Modify** `lib/presentation/app.dart` — wrap `MaterialApp.router` with `LayoutBuilder` → `AppSizes(tier: ..., child: MaterialApp.router(...))`.

**Test:** App launches. `AppSizes.of(context)` resolves in any widget. At full-screen desktop → standard tier. Resize window below 800 lp height → compact tier. No visual change yet (nothing reads from `AppSizes` yet).

### Phase 2: Chrome Widgets — Title Bar, Mini Player, Button Hints (high impact)

**Files modified: 3**

1. **Modify** `lib/presentation/widgets/custom_title_bar.dart` — read `AppSizes.of(context).titleBarHeight`, switch inner sizes via `sizes.isCompact`.
2. **Modify** `lib/presentation/widgets/gamepad_button_hints.dart` — read `sizes.buttonHintsHeight`, switch circle/font/gap sizes.
3. **Modify** `lib/presentation/widgets/mini_player_bar.dart` — read `sizes.miniPlayerHeight`, `sizes.miniPlayerArtSize`, `sizes.miniPlayerPlayBtnSize`, switch inner spacing.

**Migration pattern for each widget:**
```dart
// At top of build():
final sizes = AppSizes.of(context);

// Replace:
//   AppConstants.miniPlayerHeight → sizes.miniPlayerHeight
//   Hardcoded inner sizes → sizes.isCompact ? compact : standard
```

**Test:** 
- At 1920×1080: mini player = 84 lp, hints bar = 44 lp, title bar = 36 lp (unchanged).
- At 1280×720: mini player = 72 lp, hints bar = 36 lp, title bar = 32 lp.
- All controls still focusable on both tiers.
- No layout overflow at either size.

### Phase 3: Cards & Home Page (medium risk)

**Files modified: 2-3**

1. **Modify** `lib/presentation/widgets/album_card.dart` — read `sizes.cardPadding`, `sizes.cardRadius`, `sizes.cardRadiusSm`. Art-to-title gap switched via `sizes.isCompact`.
2. **Modify** `lib/presentation/pages/home/home_page.dart` — read `sizes.screenEdgePadding`, `sizes.sectionGap`, `sizes.headerContentGap`, `sizes.gridCardHeight`, `sizes.gridCardScrollRowWidth`. Quick Resume card sizes switched via `sizes.isCompact`.
3. **Verify** all grid views (albums, artists, genres, playlists) that use `AlbumCard` automatically adapt via the card's new `AppSizes` reads.

**Test:** 
- At desktop: Home looks identical to current.
- At 1280×720: Home shows 2 full card rows above fold. Cards are 170 lp tall. Section spacing is tighter.

### Phase 4: Now Playing & Nav Rail (low risk)

**Files modified: 2**

1. **Modify** `lib/presentation/pages/now_playing/now_playing_page.dart` — read `sizes.nowPlayingArtViewportFraction`, `sizes.nowPlayingArtMaxSize`, `sizes.nowPlayingArtMinSize`. Control spacing switched via `sizes.isCompact`.
2. **Modify** `lib/presentation/widgets/side_nav_rail.dart` — read `sizes.navRailCollapsedWidth`. Header height and separator padding switched via `sizes.isCompact`.

**Test:**
- At desktop: Now Playing and nav rail look identical.
- At 1280×720: Art is smaller, controls have tighter spacing, nav rail is 64 lp wide.

### Phase 5: Ripple Effects & Polish

**Files modified: 5-10 (various pages)**

1. Audit all pages for hardcoded `20.0` padding that should read `sizes.screenEdgePadding`.
2. Audit all pages for inter-section gaps that should read `sizes.sectionGap`.
3. Audit any widget that still reads tier-switched constants from `AppConstants` instead of `AppSizes`.
4. Verify detail pages (album detail, artist detail, playlist detail) at 1280×720.
5. Verify search results page density.
6. Verify settings page density.
7. Run `flutter analyze` — zero warnings.
8. Run full test suite — all passing.

### Phase 6: Visual QA

1. Build release: `flutter build macos` (or Windows if available).
2. Set window to exactly **1280×720** → verify every screen uses compact tier.
3. Set window to exactly **1920×1080** → verify every screen uses standard tier (identical to current app).
4. Resize window **live from 1080 to 720** → verify smooth tier switch, no overflow, no layout jump.
5. Test at **800×500** (minimum window) → verify compact tier, no overflow.
6. Test at **1280×800** (boundary) → verify standard tier.
7. Test at **1280×799** → verify compact tier.
8. Verify focus traversal on all modified screens at both tiers.
9. Screenshot before/after for each screen at both resolutions.

---

## 7. Expected Results (Home Screen)

### Standard Tier — Desktop 1920×1080 (UNCHANGED)

```
┌──────────────────────────────────┐
│ Title Bar (36)                   │
├──────────────────────────────────┤
│ [20] Home                        │
│ [16] Quick Resume [100]          │
│ [20] Recently Played header      │
│ [8]  ┌─210──┐ ┌─210──┐ ┌─210──┐ │
│      │      │ │      │ │      │ │
│      │ art  │ │ art  │ │ art  │ │
│      │      │ │      │ │      │ │
│      │title │ │title │ │title │ │
│      └──────┘ └──────┘ └──────┘ │
│ [20] Most Played header          │
│ [8]  ┌─210──┐ ┌─210──┐ ┌─210──┐ │
│      │      │ │      │ │      │ │
│      │ art  │ │ art  │ │ art  │ │
│      │      │ │      │ │      │ │
│      │title │ │title │ │title │ │
│      └──────┘ └──────┘ └──────┘ │
│      ... (plenty of room)        │
├──────────────────────────────────┤
│ Mini Player (84)                 │
├──────────────────────────────────┤
│ Button Hints (44)                │
└──────────────────────────────────┘
```

Looks exactly like today. No changes.

### Compact Tier — Handheld 1280×720 (BEFORE)

```
┌──────────────────────────────────┐
│ Title Bar (36)                   │
├──────────────────────────────────┤
│ [20] Home                        │
│ [16] Quick Resume [100]          │
│ [20] Recently Played header      │
│ [8]  ┌─210──┐ ┌─210──┐ ┌─210──┐ │
│      │      │ │      │ │      │ │
│      │ art  │ │ art  │ │ art  │ │
│      │      │ │      │ │      │ │
│      │title │ │title │ │title │ │
│      └──────┘ └──────┘ └──────┘ │
│ [20] Most Played header          │
│ [8]  ┌──────┐ ┌──────┐ ← 76 lp  │
│ ─ ─ ─ ─FOLD─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
│      │ art  │ │ art  │           │
├──────────────────────────────────┤
│ Mini Player (84)                 │
├──────────────────────────────────┤
│ Button Hints (44)                │
└──────────────────────────────────┘
```

### Compact Tier — Handheld 1280×720 (AFTER)

```
┌──────────────────────────────────┐
│ Title Bar (32)                   │
├──────────────────────────────────┤
│ [16] Home                        │
│ [14] Quick Resume [80]           │
│ [14] Recently Played header      │
│ [6]  ┌─170──┐ ┌─170──┐ ┌─170──┐ │
│      │ art  │ │ art  │ │ art  │ │
│      │title │ │title │ │title │ │
│      └──────┘ └──────┘ └──────┘ │
│ [14] Most Played header          │
│ [6]  ┌─170──┐ ┌─170──┐ ┌─170──┐ │
│      │ art  │ │ art  │ │ art  │ │
│      │title │ │title │ │title │ │
│      └──────┘ └──────┘ └──────┘ │
│ [14] Reco─ ─ ─FOLD─ ─ ─ ─ ─ ─ ─ │
├──────────────────────────────────┤
│ Mini Player (72)                 │
├──────────────────────────────────┤
│ Button Hints (36)                │
└──────────────────────────────────┘
```

**Result:** 2 full card rows visible above the fold on handheld. Desktop unchanged.

---

## 8. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Focus hit areas shrink below 48 lp | High | Only visual sizes change. All `SizedBox` constraints for focusable areas stay ≥48 lp on both tiers. |
| Text becomes unreadable on compact | Medium | No font goes below 11 sp (artist/time labels). All body text stays ≥12 sp. |
| Layout overflow at 800×500 | Medium | Compact tier kicks in at <800 lp height. Test at minimum window in Phase 6. |
| Desktop appearance changes | **None** | Standard tier serves the exact same values as today. Zero visual change. |
| Tier switch causes visual jank on resize | Low | All size changes are via `AnimatedContainer`-friendly values. If needed, add 150ms implicit animation on tier switch. |
| `AppSizes.of(context)` called before InheritedWidget is in tree | Low | `AppSizes` is placed above `MaterialApp.router` in `app.dart`. All routed widgets are descendants. |
| Card art too small on compact | Low | 150×150 lp art is still larger than Spotify's desktop grid art (~128 lp). |
| Performance overhead of InheritedWidget | None | `updateShouldNotify` only fires when tier changes (rare — only on resize across 800 lp boundary). |

---

## 9. Files Changed Summary

| Phase | File | Action |
|-------|------|--------|
| 1 | `lib/core/constants/app_sizes.dart` | **Create** — `AppSizes` InheritedWidget |
| 1 | `lib/presentation/app.dart` | **Modify** — wrap with `LayoutBuilder` → `AppSizes` |
| 2 | `lib/presentation/widgets/custom_title_bar.dart` | **Modify** — read from `AppSizes` |
| 2 | `lib/presentation/widgets/gamepad_button_hints.dart` | **Modify** — read from `AppSizes` |
| 2 | `lib/presentation/widgets/mini_player_bar.dart` | **Modify** — read from `AppSizes` |
| 3 | `lib/presentation/widgets/album_card.dart` | **Modify** — read from `AppSizes` |
| 3 | `lib/presentation/pages/home/home_page.dart` | **Modify** — read from `AppSizes` |
| 4 | `lib/presentation/pages/now_playing/now_playing_page.dart` | **Modify** — read from `AppSizes` |
| 4 | `lib/presentation/widgets/side_nav_rail.dart` | **Modify** — read from `AppSizes` |
| 5 | Various page files (5-10) | **Modify** — replace hardcoded padding/gaps with `AppSizes` reads |

**Total: 1 new file, ~12-15 modified files. `AppConstants` is not modified.**
