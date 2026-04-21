# Music FSE — File-by-File Implementation Plan

> **Purpose**: This document provides exact, file-by-file implementation instructions for every file in the Music FSE project. Each entry specifies the file path, purpose, imports, classes, methods, exact UI specs (from the HTML mockup), gamepad behavior, and dependencies on other files. An implementer should be able to build each file without asking questions or leaving TODOs.
>
> **Implementation Order**: Files are grouped into phases. Within each phase, files are listed in dependency order. Complete all files in a phase before moving to the next.
>
> **Rules**: Every file MUST follow CLAUDE.md. Key reminders:
> - `const` constructors everywhere possible
> - Lucide Icons only (never Material Icons)
> - `Theme.of(context).textTheme` for all text (never hardcode fontSize/fontWeight)
> - Every interactive widget focusable with visible focus indicator
> - `@riverpod` annotations for all providers (run `dart run build_runner build` after)
> - All user-visible strings via ARB localization
> - `ListView.builder` / `GridView.builder` only (never `ListView(children: [...])`)
> - Dispose all FocusNode, ScrollController, AnimationController, StreamSubscription
> - No `print()`, no `setState()` (except trivial local animation), no Material Icons

---

## Table of Contents

- [Phase 1: Project Scaffold & Configuration](#phase-1-project-scaffold--configuration)
- [Phase 2: Core Layer](#phase-2-core-layer)
- [Phase 3: Domain Layer](#phase-3-domain-layer)
- [Phase 4: Data Layer](#phase-4-data-layer)
- [Phase 5: Presentation — Providers](#phase-5-presentation--providers)
- [Phase 6: Presentation — Shared Widgets](#phase-6-presentation--shared-widgets)
- [Phase 7: Presentation — Pages & Screens](#phase-7-presentation--pages--screens)
- [Phase 8: Platform Layer](#phase-8-platform-layer)
- [Phase 9: App Entry, Routing & Finalization](#phase-9-app-entry-routing--finalization)

---

## Phase 1: Project Scaffold & Configuration

### 1.1 `pubspec.yaml`

**Path**: `pubspec.yaml`
**Purpose**: Project metadata, dependencies, assets, and fonts.

```yaml
name: music_fse
description: Full Screen Experience music player for handheld gaming PCs
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  just_audio: ^0.9.39
  just_audio_windows: ^0.2.1
  drift: ^2.16.0
  sqlite3_flutter_libs: ^0.5.21
  go_router: ^14.2.0
  window_manager: ^0.3.9
  system_tray: ^2.0.3
  path_provider: ^2.1.3
  path: ^1.9.0
  intl: ^0.19.0
  audiotags: ^1.4.1
  image: ^4.1.7
  google_fonts: ^6.2.1
  lucide_icons: ^0.257.0
  desktop_drop: ^0.4.4
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  ffi: ^2.1.2
  win32: ^5.5.1
  smtc_windows: ^0.1.0
  reorderables: ^0.6.0
  collection: ^1.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.7.1
  drift_dev: ^2.16.0
  mocktail: ^1.0.3

flutter:
  uses-material-design: false
  generate: true  # for l10n

  assets:
    - assets/branding/icon/
    - assets/branding/launcher/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

**Post-step**: Run `flutter pub get`.

### 1.2 `l10n.yaml`

**Path**: `l10n.yaml`
**Purpose**: Flutter localization configuration.

```yaml
arb-dir: lib/core/localization/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: false
output-dir: lib/core/localization/generated
```

### 1.3 `analysis_options.yaml`

**Path**: `analysis_options.yaml`
**Purpose**: Strict lint rules.

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
    prefer_single_quotes: true
    sort_constructors_first: true
    unnecessary_lambdas: true
    prefer_relative_imports: true

analyzer:
  errors:
    avoid_print: error
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

### 1.4 `build.yaml`

**Path**: `build.yaml`
**Purpose**: Configure build_runner for Drift and Riverpod code generation.

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          store_date_time_values_as_text: true
          named_parameters: true
          generate_connect_constructor: false
```

### 1.5 Directory Structure Creation

Create these empty directories (the files will be created in subsequent phases):

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── theme/
│   ├── localization/
│   │   ├── arb/
│   │   └── generated/
│   ├── utils/
│   └── router/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/
│   │   └── local/
│   ├── file_system/
│   ├── metadata/
│   └── repositories/
├── presentation/
│   ├── providers/
│   ├── pages/
│   │   ├── home/
│   │   │   └── widgets/
│   │   ├── onboarding/
│   │   │   └── widgets/
│   │   ├── library/
│   │   │   └── widgets/
│   │   ├── now_playing/
│   │   │   └── widgets/
│   │   ├── equalizer/
│   │   ├── search/
│   │   │   └── widgets/
│   │   ├── favorites/
│   │   ├── recently_played/
│   │   ├── playlist/
│   │   ├── queue/
│   │   └── settings/
│   │       └── widgets/
│   └── widgets/
├── platform/
│   ├── xinput/
│   ├── smtc/
│   ├── media_keys/
│   ├── macos/
│   ├── system_tray/
│   └── window/
assets/
└── fonts/
test/
├── domain/
├── data/
└── presentation/
```

<!-- END PHASE 1 -->

## Phase 2: Core Layer

### 2.1 `lib/core/constants/app_constants.dart`

**Purpose**: All magic numbers, sizes, durations, and limits used across the app.

```dart
// Abstract final class — not instantiable
abstract final class AppConstants {
  // Layout
  static const double minWindowWidth = 800.0;
  static const double minWindowHeight = 500.0;
  static const double navRailExpandedWidth = 220.0;
  static const double navRailCollapsedWidth = 72.0;
  static const double layoutBreakpoint = 1200.0;
  static const double screenEdgePadding = 20.0;
  static const double miniPlayerHeight = 84.0;
  static const double buttonHintsHeight = 40.0;
  static const double titleBarHeight = 36.0; // Matches widget spec (36px)
  static const double queuePanelWidth = 340.0;

  // Focusable minimums
  static const double minFocusableSize = 48.0;
  static const double listTileHeight = 56.0;
  static const double gridCardWidth = 165.0;
  static const double gridCardHeight = 210.0;
  static const double gridCardScrollRowWidth = 210.0;
  static const double focusableSpacing = 8.0;

  // Cards
  static const double cardRadius = 16.0;
  static const double cardRadiusSm = 12.0;
  static const double btnRadius = 12.0;
  static const double cardPadding = 12.0;

  // Focus indicator (per REQUIREMENTS §6.4: 3px border, dual scale, glow shadow)
  static const double focusBorderWidth = 3.0;
  static const double focusScaleTile = 1.02;
  static const double focusScaleCard = 1.05;
  static const double focusGlowBlur = 12.0;
  static const double focusGlowOpacity = 0.3;

  // Animations (milliseconds)
  static const int pageTransitionMs = 250;
  static const int focusTransitionMs = 150;
  static const int expandCollapseMs = 300;
  static const int contextMenuOpenMs = 150;
  static const int contextMenuCloseMs = 100;
  static const int toastSlideInMs = 200;
  static const int toastFadeOutMs = 150;
  static const int queueSlideMs = 250;
  static const int artCrossfadeMs = 300;
  static const int favBounceMs = 200;
  static const int listStaggerMs = 50;
  static const int listStaggerMaxItems = 10;

  // Toast
  static const int toastDurationSec = 3;

  // Mini player
  static const double miniPlayerArtSize = 48.0;
  static const double miniPlayerPlayBtnSize = 34.0;

  // Now Playing (responsive: 60-70% of viewport width per REQUIREMENTS §6.3.3)
  static const double nowPlayingArtMinSize = 280.0;
  static const double nowPlayingArtMaxSize = 500.0;
  static const double nowPlayingArtViewportFraction = 0.65; // 65% of viewport width
  static const double nowPlayingPlayBtnSize = 56.0;

  // Song tile
  static const double songTileArtSize = 44.0;
  static const double songTilePadding = 14.0;

  // Queue
  static const double queueItemArtSize = 36.0;

  // Detail header
  static const double detailArtSize = 200.0;

  // Search
  static const int searchHistoryMax = 10; // REQUIREMENTS §6.3.5
  static const int searchResultsPerCategory = 5;

  // Playback
  static const int playCountThresholdMs = 30000; // 30 seconds
  static const double playCountThresholdPercent = 0.5; // 50%
  static const int seekStepMs = 5000; // 5 seconds for D-pad seek
  static const int recentlyPlayedMax = 100;

  // Image cache
  static const int imageCacheMaxImages = 200;
  static const int imageCacheMaxSizeMB = 50;

  // XInput
  static const int xinputPollHz = 60;

  // Context menu
  static const double contextMenuWidth = 240.0;

  // Dialog
  static const double dialogWidth = 380.0;
  static const double dialogPadding = 24.0;

  // Onboarding
  static const double onboardingCardWidth = 500.0;

  // Settings
  static const double colorChipSize = 28.0;

  // EQ
  static const int eqBandCount = 10; // Matches EQ page visual spec (10 bands)
  static const double eqSliderHeight = 180.0;
  static const double eqSliderWidth = 6.0;
  static const double eqThumbSize = 16.0;
  static const List<String> eqBandLabels = [
    '60', '170', '310', '600', '1k', '3k', '6k', '12k', '14k', '16k',
  ];
  static const List<double> eqBandFrequencies = [
    60, 170, 310, 600, 1000, 3000, 6000, 12000, 14000, 16000,
  ];

  // Playlist
  static const int playlistNameMaxLength = 100;
  static const String playlistDefaultName = 'My Playlist';
  static const int addToPlaylistMaxVisible = 8;

  // Scan
  static const List<String> supportedAudioExtensions = [
    '.mp3', '.flac', '.wav', '.aac', '.m4a',
    '.ogg', '.wma', '.opus', '.aiff', '.alac',
  ];

  // Accent colors (hex values from settings mockup)
  static const List<int> accentColorValues = [
    0xFFC76E00, // Dark Orange (default)
    0xFF2F81F7, // Blue
    0xFF8957E5, // Purple
    0xFF3FB950, // Green
    0xFFF85149, // Red
    0xFFDB61A2, // Pink
    0xFF39D2C0, // Teal
    0xFFD29922, // Gold
  ];
}
```

### 2.2 `lib/core/constants/ui_strings.dart`

**Purpose**: Non-localizable string constants only (app package name, etc.). All user-visible strings are in ARB files accessed via `AppLocalizations.of(context)!.keyName`.

```dart
abstract final class UiStrings {
  static const String appName = 'Music FSE';
  static const String packageName = 'com.musicfse.player';
}
```

### 2.3 `lib/core/localization/arb/app_en.arb`

**Purpose**: English localization strings — ALL user-visible text.

This is a large JSON file. Key categories:
- **Navigation**: `navHome`, `navLibrary`, `navSearch`, `navPlaylists`, `navFavorites`, `navSettings`
- **Library tabs**: `libTabSongs`, `libTabAlbums`, `libTabArtists`, `libTabGenres`, `libTabFolders`
- **Home**: `homeGreetingMorning/Afternoon/Evening`, `homeQuickResume`, `homeRecentlyPlayed`, `homeMostPlayed`, `homeRecentlyAdded`, `homeQuickAccess`, `homeRecommended`, `homeSeeAll`
- **Sort options**: `sortNameAZ`, `sortNameZA`, `sortArtist`, `sortAlbum`, `sortDateAdded`, `sortDateUpdated`, `sortYear`, `sortDuration`, `sortTrackNumber`
- **Playback**: `playAll`, `shuffle`, `nowPlaying`, `upNext`, `queue`, `clearQueue`, `clearQueueConfirm` (with `{count}` placeholder)
- **Search**: `searchPlaceholder`, `recentSearches`, `clearAll`, `noResults`, `noResultsFor` (with `{query}`), `showAll` (with `{count}`), `songsResults`/`artistsResults`/`albumsResults` (with `{count}`)
- **Favorites**: `favorites`, `noFavoritesYet`, `noFavoritesMessage`, `browseLibrary`
- **Playlists**: `smartPlaylists`, `yourPlaylists`, `newPlaylist`, `importM3U`, `deletePlaylistConfirm` (with `{name}`), `recentlyAdded`, `mostPlayed`, `recentlyPlayed`
- **Settings**: All `settings*` keys for each section (Appearance, Library, Playback, Controls, System, About) + values (`themeDark/Light/System`, `navSoundOff/Quiet/Normal`)
- **Equalizer**: `equalizer`, `eqSaveCustom`, `eqReset`, preset names
- **Context menu**: `ctxPlay`, `ctxPlayNext`, `ctxAddToQueue`, `ctxAddToPlaylist`, `ctxNewPlaylist`, `ctxToggleFavorite`, `ctxGoToArtist`, `ctxGoToAlbum`, `ctxRemoveFromQueue`, `ctxRemoveFromPlaylist`, `ctxReorder`
- **Dialogs**: `cancel`, `delete`, `save`, `create`, `confirm`, `quit`, `minimizeToTray`, `keepRunning`, `keepRunningDesc`, `rememberChoice`, `undo`
- **Toasts**: `addedToQueue`, `removedFromQueue`, `addedToPlaylist` (with `{name}`), `removedFromPlaylist` (with `{name}`), `removedFromFavorites`, `addedToFavorites`, `playlistCreated`, `playlistDeleted`, `playlistRenamed`
- **Empty states**: `noMusicYet`, `noMusicMessage`, `addMusicFolder`, `queueEmpty`, `queueEmptyMessage`
- **Onboarding**: `onboardingWelcome`, `onboardingDesc`, `onboardingGetStarted/Skip/Next/Back/Done`, `onboardingSelectFolders(Desc)`, `onboardingChooseTheme(Desc)`, `onboardingScanProgress(Desc)`
- **Button hints**: `hintSelect`, `hintBack`, `hintOptions`, `hintFavorite`, `hintPlay`, `hintOpen`, `hintClose`, `hintPrevTrack`, `hintNextTrack`, etc.
- **Scan**: `scanComplete`, `scanFoundSongs` (with `{count}`), `scanFoldersInaccessible` (with `{count}`)
- **Generic**: `artist`, `album`, `genre`, `unknownArtist`, `unknownAlbum`, `variousArtists`, `addedXOfYSongs` (with `{added}`, `{total}`, `{dupes}`)

Each placeholder entry needs a companion `@keyName` entry with `"placeholders"` object per the ARB spec.

### 2.4 `lib/core/errors/app_error.dart`

**Purpose**: Sealed error class hierarchy using Freezed.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'app_error.freezed.dart';

@freezed
sealed class AppError with _$AppError {
  const factory AppError.database({required String message}) = DatabaseError;
  const factory AppError.fileSystem({required String message, String? path}) = FileSystemError;
  const factory AppError.metadata({required String message, String? path}) = MetadataError;
  const factory AppError.playback({required String message}) = PlaybackError;
  const factory AppError.platform({required String message}) = PlatformError;
  const factory AppError.notFound({required String message}) = NotFoundError;
  const factory AppError.validation({required String message}) = ValidationError;
}
```

### 2.5 `lib/core/errors/result.dart`

**Purpose**: Generic `Result<T>` type — `Success<T>` or `Failure<T>` (wrapping `AppError`). No exceptions in business logic.

```dart
import 'app_error.dart';

sealed class Result<T> {
  const Result();
  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppError error) = Failure<T>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };
  AppError? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  }) => switch (this) {
    Success(:final value) => success(value),
    Failure(:final error) => failure(error),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppError error;
}
```

### 2.6 `lib/core/extensions/duration_extensions.dart`

**Purpose**: Formatting extensions on `Duration`.

Methods:
- `toDisplayString()` → `"m:ss"` or `"h:mm:ss"`
- `toRemainingString(Duration total)` → `"-m:ss"`
- `toHoursMinutes()` → `"Xh Ym"` for playlist/album durations

### 2.7 `lib/core/extensions/string_extensions.dart`

**Purpose**: `capitalize()` extension on String. Also a top-level `getTimeGreeting(int hour)` returning `'morning'`/`'afternoon'`/`'evening'` for Home screen greeting.

### 2.8 `lib/core/utils/logger.dart`

**Purpose**: Replaces `print()`. Uses `dart:developer` `log()`. Provides `AppLogger.debug/info/warn/error(message, {tag, error, stackTrace})`.

### 2.9 `lib/core/utils/debouncer.dart`

**Purpose**: Timer-based debouncer for search input. Constructor takes `Duration delay`. `call(VoidCallback)` cancels previous timer. `dispose()` cleans up.

### 2.10 `lib/core/theme/app_theme.dart`

**Purpose**: Complete dark and light theme definitions matching the HTML mockup exactly.

> **PALETTE NOTE**: The color values below come from the HTML mockup (Sony/PS5-inspired deep navy palette). REQUIREMENTS.md Section 5.2 lists slightly different base values (e.g., `#0A0E1A` vs `#050810`). **Use the mockup values as the authoritative palette** since they are the most visually refined and tested — the mockup was iterated on after the REQUIREMENTS palette was drafted, and the deeper navy tones provide better contrast and a more immersive gaming-centric aesthetic. The REQUIREMENTS palette is considered an earlier draft. If there are future discrepancies, the mockup CSS variables take precedence. The accent color is user-configurable and defaults to `#C76E00` (warm amber) per both sources.

**Key implementation details**:

1. **`AppTheme` abstract final class** with:
   - Static color constants for dark mode (from CSS vars: `darkBgDeep=#000000`, `darkBgPrimary=#050810`, `darkBgSurface=#0A0E17`, `darkBgCard=#0F1520`, `darkBgCardHover=#151D2E`, `darkBgInput=#111825`, `darkTextPrimary=#FFFFFF`, `darkTextSecondary=#9EA3B0`, `darkTextTertiary=#464B58`, `darkBorderSubtle=rgba(255,255,255,0.05)`, `darkBorderCard=rgba(255,255,255,0.04)`)
   - Static color constants for light mode (inverted — light backgrounds, dark text)
   - `destructiveColor = #FF4444`
   - Button hint colors: `btnA=#4CAF50`, `btnB=#F44336`, `btnX=#2196F3`, `btnY=#FFC107`
   - `buildTheme({required Color accentColor, required Brightness brightness})` → `ThemeData`

2. **ColorScheme mapping**:
   - `primary/secondary` → accent color
   - `surface` → `bgSurface`
   - `onSurface` → `textPrimary`
   - `surfaceContainerHighest` → `bgCard`
   - `surfaceContainerHigh` → `bgPrimary`
   - `surfaceContainerLow` → `bgInput`
   - `outline` → `borderSubtle`
   - `onSurfaceVariant` → `textSecondary`
   - `outlineVariant` → `textTertiary`
   - `error` → `destructiveColor`

3. **TextTheme** (using `GoogleFonts.interTextTheme()`):
   - `displayLarge`: 28sp Bold (page titles)
   - `headlineLarge`: 24sp SemiBold
   - `titleLarge`: 22sp SemiBold (Now Playing title)
   - `titleMedium`: 18sp SemiBold (section titles, dialog titles)
   - `titleSmall`: 14sp SemiBold (card titles, song titles)
   - `bodyLarge`: 16sp Regular
   - `bodyMedium`: 14sp Regular (default body)
   - `bodySmall`: 13sp Regular, secondary color (settings desc, meta)
   - `labelLarge`: 14sp Medium (buttons, nav items)
   - `labelMedium`: 12sp Medium, secondary color (subtitles, durations)
   - `labelSmall`: 11sp SemiBold, secondary color, letterSpacing 1.0 (section headers, uppercase)

4. **ThemeData settings**: `splashFactory: NoSplash.splashFactory`, `highlightColor: transparent`, `scrollbarTheme` with 4px thumb.

5. **`AppThemeExtension extends ThemeExtension<AppThemeExtension>`**: Holds all custom colors (`bgDeep`, `bgPrimary`, `bgSurface`, `bgCard`, `bgCardHover`, `bgInput`, `textPrimary`, `textSecondary`, `textTertiary`, `borderSubtle`, `borderCard`, `accentGlow`). Implements `copyWith` and `lerp`.

6. **`AppThemeContext` extension on `BuildContext`**: `context.appTheme` → `AppThemeExtension`.

<!-- END PHASE 2 -->

## Phase 3: Domain Layer

> Domain has ZERO Flutter imports. Pure Dart only. No `package:flutter`, no `BuildContext`.

### 3.1 `lib/domain/entities/song.dart`

**Purpose**: Core song entity. Immutable with Freezed.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'song.freezed.dart';

@freezed
class Song with _$Song {
  const factory Song({
    required int id,
    required String filePath,
    required String title,
    required String artist,
    required String album,
    required String albumArtist,
    required String genre,
    int? year,
    int? trackNumber,
    int? discNumber,
    required int durationMs,
    required int fileSize,
    required DateTime fileModifiedAt,
    String? artCachePath,
    required DateTime dateAdded,
    @Default(0) int playCount,
    DateTime? lastPlayedAt,
    @Default(false) bool isFavorite,
    @Default(false) bool isMissing,
  }) = _Song;
}
```

### 3.2 `lib/domain/entities/album.dart`

**Purpose**: Album entity — aggregated from songs.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'album.freezed.dart';

@freezed
class Album with _$Album {
  const factory Album({
    required String name,
    required String artist,
    int? year,
    String? artCachePath,
    required int songCount,
    required int totalDurationMs,
  }) = _Album;
}
```

### 3.3 `lib/domain/entities/artist.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'artist.freezed.dart';

@freezed
class Artist with _$Artist {
  const factory Artist({
    required String name,
    required int songCount,
    required int albumCount,
    String? artCachePath,
  }) = _Artist;
}
```

### 3.4 `lib/domain/entities/genre.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'genre.freezed.dart';

@freezed
class Genre with _$Genre {
  const factory Genre({
    required String name,
    required int songCount,
  }) = _Genre;
}
```

### 3.5 `lib/domain/entities/playlist.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'playlist.freezed.dart';

@freezed
class Playlist with _$Playlist {
  const factory Playlist({
    required int id,
    required String name,
    String? coverArtPath,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isSmart,
    String? smartRule,
    @Default(0) int songCount,
    @Default(0) int totalDurationMs,
  }) = _Playlist;
}
```

### 3.6 `lib/domain/entities/queue_item.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'song.dart';
part 'queue_item.freezed.dart';

@freezed
class QueueItem with _$QueueItem {
  const factory QueueItem({
    required Song song,
    required int sortOrder,
    @Default(false) bool isCurrent,
    @Default(0) int positionMs,
  }) = _QueueItem;
}
```

### 3.7 `lib/domain/entities/play_history_entry.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'play_history_entry.freezed.dart';

@freezed
class PlayHistoryEntry with _$PlayHistoryEntry {
  const factory PlayHistoryEntry({
    required int id,
    required int songId,
    required DateTime playedAt,
    required int durationListenedMs,
    required String sessionId,
  }) = _PlayHistoryEntry;
}
```

### 3.8 `lib/domain/entities/eq_preset.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'eq_preset.freezed.dart';

@freezed
class EqPreset with _$EqPreset {
  const factory EqPreset({
    required int id,
    required String name,
    @Default(false) bool isBuiltin,
    required List<double> bands, // 8 band gains in dB
    required DateTime createdAt,
  }) = _EqPreset;
}
```

### 3.9 `lib/domain/entities/scan_folder.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'scan_folder.freezed.dart';

@freezed
class ScanFolder with _$ScanFolder {
  const factory ScanFolder({
    required int id,
    required String path,
    @Default(true) bool enabled,
    DateTime? lastScannedAt,
  }) = _ScanFolder;
}
```

### 3.10 `lib/domain/entities/playback_state.dart`

**Purpose**: Represents the current playback state (what's playing, shuffle, repeat, volume, etc.).

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'song.dart';
part 'playback_state.freezed.dart';

enum RepeatMode { off, all, one }
enum QueueSourceType { library, album, artist, genre, playlist, search, folder }

@freezed
class PlaybackState with _$PlaybackState {
  const factory PlaybackState({
    Song? currentSong,
    @Default(false) bool isPlaying,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(false) bool shuffle,
    @Default(RepeatMode.off) RepeatMode repeatMode,
    @Default(1.0) double volume,
    @Default(false) bool isMuted,
    @Default(0) int crossfadeSeconds,
    @Default(false) bool eqEnabled,
    QueueSourceType? queueSourceType,
    int? queueSourceId,
  }) = _PlaybackState;
}
```

### 3.11 `lib/domain/entities/recommendation.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'recommendation.freezed.dart';

@freezed
class Recommendation with _$Recommendation {
  const factory Recommendation({
    required int id,
    required String category,
    required int songId,
    required double score,
    required DateTime generatedAt,
  }) = _Recommendation;
}
```

### 3.12 Repository Interfaces

All repository interfaces are abstract classes in `lib/domain/repositories/`. They define the contract; the data layer implements them.

#### `lib/domain/repositories/song_repository.dart`

```dart
import '../entities/song.dart';
import '../entities/album.dart';
import '../entities/artist.dart';
import '../entities/genre.dart';
import '../../core/errors/result.dart';

abstract class SongRepository {
  Future<Result<List<Song>>> getAllSongs({String? sortBy, bool ascending = true});
  Future<Result<Song>> getSongById(int id);
  Future<Result<Song>> getSongByPath(String filePath);
  Future<Result<List<Song>>> getSongsByAlbum(String album, String albumArtist);
  Future<Result<List<Song>>> getSongsByArtist(String artist);
  Future<Result<List<Song>>> getSongsByGenre(String genre);
  Future<Result<List<Song>>> getSongsByFolder(String folderPath);
  Future<Result<List<Song>>> getFavorites({String? sortBy, bool ascending = true});
  Future<Result<List<Song>>> getMostPlayed({int limit = 50});
  Future<Result<List<Song>>> getRecentlyAdded({int limit = 50});
  Future<Result<List<Song>>> getRecentlyPlayed({int limit = 100});
  Future<Result<List<Song>>> searchSongs(String query, {int limit = 5});
  Future<Result<int>> upsertSong(Song song);
  Future<Result<void>> updatePlayCount(int songId, {required int playCount, required DateTime lastPlayedAt});
  Future<Result<void>> toggleFavorite(int songId, {required bool isFavorite});
  Future<Result<void>> markMissing(int songId, {required bool isMissing});
  Future<Result<void>> deleteSong(int songId);
  Future<Result<int>> getSongCount();

  Future<Result<List<Album>>> getAllAlbums({String? sortBy, bool ascending = true});
  Future<Result<List<Album>>> searchAlbums(String query, {int limit = 5});
  Future<Result<List<Artist>>> getAllArtists({String? sortBy, bool ascending = true});
  Future<Result<List<Artist>>> searchArtists(String query, {int limit = 5});
  Future<Result<List<Genre>>> getAllGenres({String? sortBy, bool ascending = true});
  Future<Result<List<String>>> getTopLevelFolders();
  Future<Result<List<String>>> getSubFolders(String parentPath);
}
```

#### `lib/domain/repositories/playlist_repository.dart`

```dart
import '../entities/playlist.dart';
import '../entities/song.dart';
import '../../core/errors/result.dart';

abstract class PlaylistRepository {
  Future<Result<List<Playlist>>> getAllPlaylists({String? sortBy});
  Future<Result<Playlist>> getPlaylistById(int id);
  Future<Result<List<Song>>> getPlaylistSongs(int playlistId);
  Future<Result<int>> createPlaylist(String name);
  Future<Result<void>> renamePlaylist(int id, String name);
  Future<Result<void>> deletePlaylist(int id);
  Future<Result<void>> duplicatePlaylist(int id);
  Future<Result<void>> addSongToPlaylist(int playlistId, int songId);
  Future<Result<void>> removeSongFromPlaylist(int playlistId, int songId);
  Future<Result<void>> reorderPlaylistSong(int playlistId, int oldIndex, int newIndex);
  Future<Result<List<Playlist>>> searchPlaylists(String query, {int limit = 5});
  Future<Result<String>> exportM3U(int playlistId);
  Future<Result<int>> importM3U(String filePath);
}
```

#### `lib/domain/repositories/playback_repository.dart`

```dart
import '../entities/queue_item.dart';
import '../entities/playback_state.dart';
import '../../core/errors/result.dart';

abstract class PlaybackRepository {
  Future<Result<List<QueueItem>>> getQueue();
  Future<Result<void>> saveQueue(List<QueueItem> items);
  Future<Result<void>> clearQueue();
  Future<Result<PlaybackState>> getSavedPlaybackState();
  Future<Result<void>> savePlaybackState(PlaybackState state);
}
```

#### `lib/domain/repositories/play_history_repository.dart`

```dart
import '../entities/play_history_entry.dart';
import '../../core/errors/result.dart';

abstract class PlayHistoryRepository {
  Future<Result<void>> addEntry(PlayHistoryEntry entry);
  Future<Result<List<PlayHistoryEntry>>> getHistory({int limit = 100});
  Future<Result<void>> clearHistory();
}
```

#### `lib/domain/repositories/settings_repository.dart`

```dart
import '../../core/errors/result.dart';

abstract class SettingsRepository {
  Future<Result<String?>> getString(String key);
  Future<Result<bool?>> getBool(String key);
  Future<Result<int?>> getInt(String key);
  Future<Result<double?>> getDouble(String key);
  Future<Result<void>> setString(String key, String value);
  Future<Result<void>> setBool(String key, bool value);
  Future<Result<void>> setInt(String key, int value);
  Future<Result<void>> setDouble(String key, double value);
  Future<Result<void>> remove(String key);
}
```

#### `lib/domain/repositories/scan_folder_repository.dart`

```dart
import '../entities/scan_folder.dart';
import '../../core/errors/result.dart';

abstract class ScanFolderRepository {
  Future<Result<List<ScanFolder>>> getAll();
  Future<Result<int>> addFolder(String path);
  Future<Result<void>> removeFolder(int id);
  Future<Result<void>> toggleEnabled(int id, {required bool enabled});
  Future<Result<void>> updateLastScanned(int id, DateTime time);
}
```

#### `lib/domain/repositories/eq_preset_repository.dart`

```dart
import '../entities/eq_preset.dart';
import '../../core/errors/result.dart';

abstract class EqPresetRepository {
  Future<Result<List<EqPreset>>> getAll();
  Future<Result<EqPreset>> getById(int id);
  Future<Result<int>> createPreset(String name, List<double> bands);
  Future<Result<void>> updatePreset(int id, List<double> bands);
  Future<Result<void>> deletePreset(int id);
}
```

#### `lib/domain/repositories/recommendations_repository.dart`

```dart
import '../entities/recommendation.dart';
import '../entities/song.dart';
import '../../core/errors/result.dart';

abstract class RecommendationsRepository {
  Future<Result<Map<String, List<Song>>>> getRecommendationsByCategory({int limitPerCategory = 20});
  Future<Result<void>> generateRecommendations(); // Runs recommendation algorithm
  Future<Result<void>> clearAll();
}
```

### 3.13 Use Cases

All use cases are single-purpose classes with a `call()` method. They live in `lib/domain/usecases/`.

**Naming convention**: verb-noun (e.g., `GetAllSongs`, `ToggleFavorite`).

#### Song Use Cases (`lib/domain/usecases/`)

**`get_all_songs.dart`**: Takes optional sort and direction. Calls `songRepository.getAllSongs()`. Returns `Result<List<Song>>`.

**`get_song_by_id.dart`**: Takes `int id`. Returns `Result<Song>`.

**`get_songs_by_album.dart`**: Takes `String album, String albumArtist`. Returns `Result<List<Song>>`.

**`get_songs_by_artist.dart`**: Takes `String artist`. Returns `Result<List<Song>>`.

**`get_songs_by_genre.dart`**: Takes `String genre`. Returns `Result<List<Song>>`.

**`get_songs_by_folder.dart`**: Takes `String folderPath`. Returns `Result<List<Song>>`.

**`get_favorites.dart`**: Optional sort. Returns `Result<List<Song>>`.

**`get_most_played.dart`**: Takes `int limit`. Returns `Result<List<Song>>`.

**`get_recently_added.dart`**: Takes `int limit`. Returns `Result<List<Song>>`.

**`get_recently_played.dart`**: Takes `int limit`. Returns `Result<List<Song>>`.

**`search_library.dart`**: Takes `String query`. Calls `searchSongs`, `searchAlbums`, `searchArtists`, `searchPlaylists` on their respective repos (all in parallel). Returns a `SearchResults` record/class with `songs`, `albums`, `artists`, `playlists` and counts.

**`toggle_favorite.dart`**: Takes `int songId, bool isFavorite`. Calls `songRepository.toggleFavorite()`. Returns `Result<void>`.

**`update_play_count.dart`**: Takes `int songId, int playCount, DateTime lastPlayedAt`. Calls `songRepository.updatePlayCount()`.

#### Album/Artist/Genre Use Cases

**`get_all_albums.dart`**: Optional sort. Returns `Result<List<Album>>`.

**`get_all_artists.dart`**: Optional sort. Returns `Result<List<Artist>>`.

**`get_all_genres.dart`**: Optional sort. Returns `Result<List<Genre>>`.

**`get_folder_contents.dart`**: Takes `String? parentPath` (null = top level). Returns `Result<({List<String> subFolders, List<Song> songs})>` by calling `getSubFolders` and `getSongsByFolder`.

#### Playlist Use Cases

**`get_all_playlists.dart`**: Optional sort. Returns `Result<List<Playlist>>`.

**`get_playlist_songs.dart`**: Takes `int playlistId`. Returns `Result<List<Song>>`.

**`create_playlist.dart`**: Takes `String name`. Returns `Result<int>` (new playlist ID).

**`rename_playlist.dart`**: Takes `int id, String name`. Returns `Result<void>`.

**`delete_playlist.dart`**: Takes `int id`. Returns `Result<void>`.

**`duplicate_playlist.dart`**: Takes `int id`. Returns `Result<void>`.

**`add_song_to_playlist.dart`**: Takes `int playlistId, int songId`. Returns `Result<void>`.

**`remove_song_from_playlist.dart`**: Takes `int playlistId, int songId`. Returns `Result<void>`.

**`reorder_playlist_song.dart`**: Takes `int playlistId, int oldIndex, int newIndex`. Returns `Result<void>`.

**`save_queue_as_playlist.dart`**: Takes `String name, List<QueueItem> queueItems`. Creates a new playlist with the given name, then adds all queue songs as `playlist_songs` entries preserving queue order. Returns `Result<int>` (new playlist ID). Used by the Queue panel's "Save as Playlist" button.

**`import_m3u.dart`**: Takes `String filePath`. Returns `Result<int>` (imported playlist ID).

**`export_m3u.dart`**: Takes `int playlistId`. Returns `Result<String>` (export file path).

#### Playback Use Cases

**`get_saved_queue.dart`**: Returns `Result<List<QueueItem>>`.

**`save_queue.dart`**: Takes `List<QueueItem>`. Returns `Result<void>`.

**`get_saved_playback_state.dart`**: Returns `Result<PlaybackState>`.

**`save_playback_state.dart`**: Takes `PlaybackState`. Returns `Result<void>`.

**`get_resume_context.dart`**: Returns `Result<({Song? lastSong, Duration? lastPosition, List<QueueItem> savedQueue})>`. Used by the Home screen's "Quick Resume" hero card. Combines `getSavedPlaybackState`, `getSavedQueue`, and `getSongById` into a single convenient call.

#### Library Stats Use Cases

**`get_library_stats.dart`**: Returns `Result<({int totalSongs, Duration totalDuration, int totalAlbums, int totalArtists})>`. Used by the Home screen's Stats Footer. Queries aggregate counts/sums from the database.

#### History Use Cases

**`add_play_history.dart`**: Takes `PlayHistoryEntry`. Returns `Result<void>`.

**`get_play_history.dart`**: Takes `int limit`. Returns `Result<List<PlayHistoryEntry>>`.

#### Settings Use Cases

**`get_setting.dart`**: Generic — `getSetting<T>(String key)`. Returns `Result<T?>`.

**`set_setting.dart`**: Generic — `setSetting<T>(String key, T value)`. Returns `Result<void>`.

#### Scan Use Cases

**`scan_library.dart`**: The most complex use case. Takes list of `ScanFolder` paths. Scans file system for audio files, extracts metadata, upserts songs. Returns a `Stream<ScanProgress>` where `ScanProgress` has `{int found, int processed, int total, String? currentFile}`. This use case depends on `SongRepository` and `FileScanner` and `MetadataExtractor` (both defined as abstract classes in domain).

**`get_scan_folders.dart`**: Returns `Result<List<ScanFolder>>`.

**`add_scan_folder.dart`**: Takes `String path`. Returns `Result<int>`.

**`remove_scan_folder.dart`**: Takes `int id`. Returns `Result<void>`.

#### EQ Use Cases

**`get_eq_presets.dart`**: Returns `Result<List<EqPreset>>`.

**`save_eq_preset.dart`**: Takes `String name, List<double> bands`. Returns `Result<int>`.

**`delete_eq_preset.dart`**: Takes `int id`. Returns `Result<void>`.

### 3.14 Domain Service Interfaces

These abstract classes define contracts for services that the data layer implements.

#### `lib/domain/services/file_scanner.dart`

```dart
abstract class FileScanner {
  /// Recursively scans directories for audio files.
  /// Returns a stream of discovered file paths.
  Stream<String> scanDirectories(List<String> directories);
}
```

#### `lib/domain/services/metadata_extractor.dart`

```dart
import '../entities/song.dart';

abstract class MetadataExtractor {
  /// Extracts metadata from an audio file, returns a partial Song entity.
  Future<Song> extractMetadata(String filePath);

  /// Extracts and caches album art thumbnail. Returns cache path or null.
  Future<String?> extractArt(String filePath, String cacheDir);
}
```

<!-- END PHASE 3 -->

## Phase 4: Data Layer

### 4.1 `lib/data/datasources/local/database.dart`

**Purpose**: Drift database definition with all tables. Single file defines all table classes and the `@DriftDatabase` annotated class.

```dart
import 'package:drift/drift.dart';
// Import DAOs (defined in subsequent files)
part 'database.g.dart';

// --- Table Definitions ---

class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text().unique()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant('Unknown Artist'))();
  TextColumn get album => text().withDefault(const Constant('Unknown Album'))();
  TextColumn get albumArtist => text().withDefault(const Constant(''))();
  TextColumn get genre => text().withDefault(const Constant(''))();
  IntColumn get year => integer().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get discNumber => integer().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  DateTimeColumn get fileModifiedAt => dateTime()();
  TextColumn get artCachePath => text().nullable()();
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isMissing => boolean().withDefault(const Constant(false))();
}

class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get coverArtPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSmart => boolean().withDefault(const Constant(false))();
  TextColumn get smartRule => text().nullable()();
}

class PlaylistSongs extends Table {
  IntColumn get playlistId => integer().references(Playlists, #id)();
  IntColumn get songId => integer().references(Songs, #id)();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

class PlayHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get songId => integer().references(Songs, #id)();
  DateTimeColumn get playedAt => dateTime()();
  IntColumn get durationListenedMs => integer()();
  IntColumn get sessionId => integer()(); // REQUIREMENTS §7.1: int, not text
}

class QueueItems extends Table {
  IntColumn get id => integer().autoIncrement()(); // Auto-increment PK allows duplicate songs
  IntColumn get songId => integer().references(Songs, #id)();
  IntColumn get sortOrder => integer()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
}

class PlaybackStates extends Table {
  // Singleton row — always id=1
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get shuffle => boolean().withDefault(const Constant(false))();
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();
  RealColumn get volume => real().withDefault(const Constant(0.7))(); // REQUIREMENTS §7.1: default 0.7
  IntColumn get crossfadeSeconds => integer().withDefault(const Constant(0))();
  BoolColumn get eqEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get eqPresetId => integer().nullable().references(EqPresets, #id)(); // REQUIREMENTS §7.1
  TextColumn get queueSourceType => text().nullable()();
  IntColumn get queueSourceId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class EqPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
  TextColumn get bandsJson => text()(); // JSON-encoded List<double>
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Recommendations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  IntColumn get songId => integer().references(Songs, #id)();
  RealColumn get score => real()();
  DateTimeColumn get generatedAt => dateTime()();
}

class ScanFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastScannedAt => dateTime().nullable()();
}

// --- Database Class ---

@DriftDatabase(
  tables: [
    Songs, Playlists, PlaylistSongs, PlayHistory,
    QueueItems, PlaybackStates, EqPresets, Settings,
    Recommendations, ScanFolders,
  ],
  daos: [SongDao, PlaylistDao, PlaybackDao, PlayHistoryDao, SettingsDao, ScanFolderDao, EqPresetDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Future migrations go here
    },
  );
}
```

**Connecting the database** (platform-specific): Create a helper in `lib/data/datasources/local/database_connection.dart`:

```dart
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'database.dart';

AppDatabase constructDatabase() {
  final dbFolder = getApplicationSupportDirectory();
  return AppDatabase(LazyDatabase(() async {
    final folder = await dbFolder;
    final file = File(p.join(folder.path, 'music_fse.sqlite'));
    return NativeDatabase.createInBackground(file);
  }));
}
```

### 4.2 DAOs

Each DAO is a separate file in `lib/data/datasources/local/`. Each extends `DatabaseAccessor<AppDatabase>` and uses `@DriftAccessor(tables: [...])`.

#### `lib/data/datasources/local/song_dao.dart`

**Annotated with**: `@DriftAccessor(tables: [Songs])`

**Methods** (all return Drift `Future` or `Stream`):
- `getAllSongs({String? sortBy, bool ascending})` — builds `select(songs)` with dynamic `orderBy` based on `sortBy` string (`'title'`, `'artist'`, `'album'`, `'dateAdded'`, `'year'`, `'duration'`). Default sort: title ascending.
- `getSongById(int id)` — `(select(songs)..where((s) => s.id.equals(id))).getSingle()`
- `getSongByPath(String filePath)` — filter by `filePath.equals()`
- `getSongsByAlbum(String album, String albumArtist)` — filter by both
- `getSongsByArtist(String artist)` — filter by `artist.equals()`
- `getSongsByGenre(String genre)` — filter by `genre.equals()`
- `getSongsByFolder(String folderPath)` — filter `filePath` with `like('$folderPath%')` and then filter to only direct children (no deeper subfolder)
- `getFavorites({String? sortBy, bool ascending})` — filter `isFavorite.equals(true)`
- `getMostPlayed({int limit})` — order by `playCount` desc, limit
- `getRecentlyAdded({int limit})` — order by `dateAdded` desc, limit
- `getRecentlyPlayed({int limit})` — order by `lastPlayedAt` desc, where `lastPlayedAt` is not null, limit
- `searchSongs(String query, {int limit})` — `title.like('%$query%') | artist.like('%$query%') | album.like('%$query%')`, limit
- `upsertSong(SongsCompanion)` — `into(songs).insertOnConflictUpdate()`
- `updatePlayCount(int id, int count, DateTime lastPlayed)` — update specific columns
- `toggleFavorite(int id, bool value)` — update `isFavorite`
- `markMissing(int id, bool value)` — update `isMissing`
- `deleteSong(int id)` — `(delete(songs)..where((s) => s.id.equals(id))).go()`
- `getSongCount()` — `countAll().getSingle()`
- `getAllAlbums({String? sortBy, bool ascending})` — Custom query: `SELECT album, album_artist, year, art_cache_path, COUNT(*) as song_count, SUM(duration_ms) as total_duration FROM songs GROUP BY album, album_artist ORDER BY ...`. Returns list of album data.
- `searchAlbums(String query, {int limit})` — Similar grouped query with `album LIKE '%query%'`
- `getAllArtists({String? sortBy, bool ascending})` — `SELECT artist, COUNT(*) as song_count, COUNT(DISTINCT album) as album_count FROM songs GROUP BY artist`
- `searchArtists(String query, {int limit})` — filter artist name
- `getAllGenres({String? sortBy, bool ascending})` — `SELECT genre, COUNT(*) FROM songs WHERE genre != '' GROUP BY genre`
- `getTopLevelFolders()` — Custom query extracting unique parent directories from `filePath`
- `getSubFolders(String parentPath)` — Extract sub-directories one level deep

#### `lib/data/datasources/local/playlist_dao.dart`

**Annotated with**: `@DriftAccessor(tables: [Playlists, PlaylistSongs, Songs])`

**Methods**:
- `getAllPlaylists({String? sortBy})` — select with optional ordering. Also joins to count songs and sum duration.
- `getPlaylistById(int id)` — with song count and duration
- `getPlaylistSongs(int playlistId)` — join `PlaylistSongs` with `Songs`, order by `sortOrder`
- `createPlaylist(String name)` → returns new `id`
- `renamePlaylist(int id, String name)` — also updates `updatedAt`
- `deletePlaylist(int id)` — deletes playlist AND its `PlaylistSongs` entries (cascade)
- `duplicatePlaylist(int id)` — creates new playlist with " (Copy)" suffix, copies all `PlaylistSongs`
- `addSongToPlaylist(int playlistId, int songId)` — insert with `sortOrder` = max+1, update playlist `updatedAt`
- `removeSongFromPlaylist(int playlistId, int songId)` — delete, re-order remaining, update `updatedAt`
- `reorderPlaylistSong(int playlistId, int oldIndex, int newIndex)` — update `sortOrder` for affected range
- `searchPlaylists(String query, {int limit})` — `name.like('%$query%')`

#### `lib/data/datasources/local/playback_dao.dart`

**Annotated with**: `@DriftAccessor(tables: [PlaybackStates])`

**Methods**:
- `getPlaybackState()` — get singleton row (id=1) or return default
- `savePlaybackState(PlaybackStatesCompanion)` — upsert singleton

#### `lib/data/datasources/local/queue_dao.dart`

**Annotated with**: `@DriftAccessor(tables: [QueueItems, Songs])`

**Methods**:
- `getQueue()` — join `QueueItems` with `Songs`, order by `sortOrder`
- `saveQueue(List<QueueItemsCompanion> items)` — delete all, batch insert
- `clearQueue()` — delete all from `QueueItems`

#### `lib/data/datasources/local/play_history_dao.dart`

**Annotated with**: `@DriftAccessor(tables: [PlayHistory])`

**Methods**:
- `addEntry(PlayHistoryCompanion)` — insert
- `getHistory({int limit})` — order by `playedAt` desc, limit
- `clearHistory()` — delete all

#### `lib/data/datasources/local/settings_dao.dart`

**Annotated with**: `@DriftAccessor(tables: [Settings])`

**Methods**:
- `getValue(String key)` → `String?`
- `setValue(String key, String value)` — upsert
- `remove(String key)` — delete

#### `lib/data/datasources/local/scan_folder_dao.dart`

**Annotated with**: `@DriftAccessor(tables: [ScanFolders])`

**Methods**:
- `getAll()` — select all, order by path
- `addFolder(String path)` → returns new `id`
- `removeFolder(int id)` — delete
- `toggleEnabled(int id, bool enabled)` — update
- `updateLastScanned(int id, DateTime time)` — update

#### `lib/data/datasources/local/eq_preset_dao.dart`

**Annotated with**: `@DriftAccessor(tables: [EqPresets])`

**Methods**:
- `getAll()` — select all, builtins first then by name
- `getById(int id)` — single
- `createPreset(String name, String bandsJson)` → new `id`
- `updatePreset(int id, String bandsJson)` — update
- `deletePreset(int id)` — only if not builtin

#### `lib/data/datasources/local/recommendations_dao.dart`

**Annotated with**: `@DriftAccessor(tables: [Recommendations, Songs])`

**Methods**:
- `getByCategory(String category, {int limit = 20})` — join with `Songs`, order by `score` desc, limit
- `getAllCategories()` — select distinct `category` values
- `replaceCategory(String category, List<RecommendationsCompanion> items)` — delete all for category, batch insert
- `clearAll()` — delete all from `Recommendations`

### 4.3 Model Mappers

**`lib/data/models/song_mapper.dart`**: Extension methods to convert between Drift's `Song` row type and domain `Song` entity, and vice versa (`toEntity()` on Drift row, `toCompanion()` on domain entity).

**`lib/data/models/playlist_mapper.dart`**: Same pattern for playlists.

**`lib/data/models/queue_mapper.dart`**: Maps `QueueItem` rows to domain `QueueItem`.

**`lib/data/models/playback_state_mapper.dart`**: Maps singleton `PlaybackState` row to domain entity. Handles `repeatMode` string↔enum conversion.

**`lib/data/models/eq_preset_mapper.dart`**: Maps `EqPreset` row to domain entity. Parses `bandsJson` (JSON string) ↔ `List<double>`.

**`lib/data/models/scan_folder_mapper.dart`**: Maps `ScanFolder` rows.

**`lib/data/models/play_history_mapper.dart`**: Maps `PlayHistory` rows.

### 4.4 Repository Implementations

Each file in `lib/data/repositories/` implements a domain repository interface. They depend on DAOs and mappers.

#### `lib/data/repositories/song_repository_impl.dart`

```dart
class SongRepositoryImpl implements SongRepository {
  SongRepositoryImpl(this._songDao);
  final SongDao _songDao;

  // Each method wraps DAO call in try-catch, returns Result.success or Result.failure
  // Uses mapper extensions to convert Drift rows to domain entities
}
```

Pattern for every method:
```dart
@override
Future<Result<List<Song>>> getAllSongs({String? sortBy, bool ascending = true}) async {
  try {
    final rows = await _songDao.getAllSongs(sortBy: sortBy, ascending: ascending);
    return Result.success(rows.map((r) => r.toEntity()).toList());
  } catch (e, st) {
    AppLogger.error('Failed to get songs', error: e, stackTrace: st);
    return Result.failure(AppError.database(message: e.toString()));
  }
}
```

#### `lib/data/repositories/playlist_repository_impl.dart`

Same pattern. Depends on `PlaylistDao`.

#### `lib/data/repositories/playback_repository_impl.dart`

Same pattern. Depends on `PlaybackDao`.

#### `lib/data/repositories/play_history_repository_impl.dart`

Same pattern. Depends on `PlayHistoryDao`.

#### `lib/data/repositories/settings_repository_impl.dart`

Depends on `SettingsDao`. Converts `String?` values to typed results using JSON decode for complex types.

#### `lib/data/repositories/scan_folder_repository_impl.dart`

Same pattern. Depends on `ScanFolderDao`.

#### `lib/data/repositories/eq_preset_repository_impl.dart`

Same pattern. Depends on `EqPresetDao`.

### 4.5 File System & Metadata Services

#### `lib/data/file_system/file_scanner_impl.dart`

Implements `FileScanner`. Uses `dart:io` `Directory` to recursively list files. Filters by `AppConstants.supportedAudioExtensions`. Yields file paths as a `Stream<String>`. Catches permission errors, logs `WARN`, and continues scanning.

```dart
class FileScannerImpl implements FileScanner {
  @override
  Stream<String> scanDirectories(List<String> directories) async* {
    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (!await dir.exists()) continue;
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (AppConstants.supportedAudioExtensions.contains(ext)) {
              yield entity.path;
            }
          }
        }
      } catch (e) {
        AppLogger.warn('Cannot access directory: $dirPath', error: e);
      }
    }
  }
}
```

#### `lib/data/metadata/metadata_extractor_impl.dart`

Implements `MetadataExtractor`. Uses `audiotags` package to read ID3/Vorbis/etc. tags. Extracts title, artist, album, albumArtist, genre, year, trackNumber, discNumber, duration. Falls back to filename for title if tag is empty. Falls back to "Unknown Artist"/"Unknown Album" for missing fields.

For `extractArt`: Reads embedded artwork bytes from tags, writes to cache dir as `<hash>.jpg` using the `image` package for resizing to 300x300 thumbnail. Returns the cache path. If no art, returns null.

**Important**: Both methods are designed to run on a background isolate (called from `ScanLibrary` use case via `Isolate.run` or `compute`).

<!-- END PHASE 4 -->

## Phase 5: Presentation — Providers

All providers use `@riverpod` annotations. After creating/modifying any provider file, run `dart run build_runner build`.

### 5.1 `lib/presentation/providers/database_provider.dart`

**Purpose**: Singleton provider for the Drift database instance.

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/database.dart';
import '../../data/datasources/local/database_connection.dart';
part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) {
  final db = constructDatabase();
  ref.onDispose(() => db.close());
  return db;
}
```

### 5.2 `lib/presentation/providers/repository_providers.dart`

**Purpose**: Provides all repository implementations as Riverpod providers. Depends on database provider.

```dart
// One @riverpod function per repository:
// songRepository, playlistRepository, playbackRepository,
// playHistoryRepository, settingsRepository, scanFolderRepository, eqPresetRepository,
// recommendationsRepository
//
// Each creates the DAO from ref.watch(databaseProvider) and passes to the impl constructor.
// All are @Riverpod(keepAlive: true) since repos are singletons.
```

### 5.3 `lib/presentation/providers/use_case_providers.dart`

**Purpose**: Provides all use case instances. Each watches its required repository provider(s).

```dart
// One @riverpod function per use case, e.g.:
// getAllSongs, toggleFavorite, searchLibrary, getAllPlaylists, etc.
// Each creates the use case class with the required repository from ref.watch().
// These are keepAlive: false (default) — created on demand.
```

### 5.4 `lib/presentation/providers/theme_provider.dart`

**Purpose**: Manages theme state (brightness, accent color). Persists to settings repository.

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'theme_provider.g.dart';

// NOTE: ThemeModeSetting is a domain-level enum used by both the data layer (settings repo)
// and presentation (theme provider). Define it in `lib/core/constants/app_enums.dart` or
// `lib/domain/entities/theme_mode_setting.dart`, NOT here in the provider file.
// It is shown inline here for readability only.
enum ThemeModeSetting { dark, light, system }

@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState({
    @Default(ThemeModeSetting.dark) ThemeModeSetting mode,
    @Default(Color(0xFFC76E00)) Color accentColor,
  }) = _ThemeState;
}

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeState build() {
    // Load persisted values from settings repository on init
    _loadFromSettings();
    return const ThemeState();
  }

  Future<void> _loadFromSettings() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    // Read 'theme_mode' and 'accent_color' keys
    // Update state accordingly
  }

  Future<void> setThemeMode(ThemeModeSetting mode) async {
    state = state.copyWith(mode: mode);
    // Persist to settings
  }

  Future<void> setAccentColor(Color color) async {
    state = state.copyWith(accentColor: color);
    // Persist to settings
  }

  Brightness get brightness => switch (state.mode) {
    ThemeModeSetting.dark => Brightness.dark,
    ThemeModeSetting.light => Brightness.light,
    ThemeModeSetting.system => /* use platform brightness */ Brightness.dark,
  };
}
```

### 5.5 `lib/presentation/providers/locale_provider.dart`

**Purpose**: Manages app locale. Changing this triggers full `MaterialApp` rebuild for immediate language switch (no restart). Persists to settings.

```dart
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    _loadFromSettings();
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    // Persist 'language' key to settings
  }
}
```

### 5.6 `lib/presentation/providers/playback_provider.dart`

**Purpose**: The central playback state manager. Wraps `just_audio` AudioPlayer. Manages queue, shuffle, repeat, crossfade, play count tracking.

This is the most complex provider. Key details:

```dart
@Riverpod(keepAlive: true)
class PlaybackNotifier extends _$PlaybackNotifier {
  AudioPlayer? _playerA;
  AudioPlayer? _playerB; // Lazy — only for crossfade
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _completionSub;
  String _sessionId = ''; // Set on app launch

  List<Song> _queue = [];
  List<Song> _originalQueue = []; // Pre-shuffle order
  int _currentIndex = -1;
  DateTime? _trackStartTime; // For play count tracking
  int _listenedMs = 0;

  @override
  PlaybackState build() {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _initPlayer();
    _restoreState();
    ref.onDispose(_dispose);
    return const PlaybackState();
  }
```

**Key methods**:

- `_initPlayer()` — Creates `_playerA = AudioPlayer()`. Subscribes to position, duration, playerState, and sequence completion streams. Updates `state` on each event.

- `_restoreState()` — Loads saved queue and playback state from repositories. Restores position but does NOT auto-play (per Decision #42). Pre-loads the current song.

- `play()` — If current song loaded, `_playerA!.play()`. Updates `state.isPlaying = true`.

- `pause()` — `_playerA!.pause()`. Updates state.

- `togglePlayPause()` — If playing → pause, else → play.

- `playFromQueue(int index)` — Seeks to the song at `index` in `_queue`. Loads it into `_playerA`. Updates `_currentIndex` and `state.currentSong`.

- `playSong(Song song, {List<Song>? queueContext, QueueSourceType? sourceType, int? sourceId})` — Sets up a new queue from `queueContext` (or just the single song), sets `_currentIndex`, loads and plays. Updates queue source info.

- `skipNext()` — Move to next in queue. Handles repeat modes. If `RepeatMode.one`, replay current. If at end and `RepeatMode.all`, wrap to 0. If at end and `RepeatMode.off`, stop. Does NOT crossfade (instant transition per spec).

- `skipPrevious()` — If position > 3 seconds, restart current track. Otherwise go to previous in queue.

- `seek(Duration position)` — `_playerA!.seek(position)`.

- `seekRelative(int deltaMs)` — Add delta to current position. Used for D-pad ±5s seek.

- `setVolume(double volume)` — Clamp 0.0–1.0. `_playerA!.setVolume(volume)`. Update state.

- `toggleMute()` — Toggle `state.isMuted`. If muting, set player volume to 0 but keep `state.volume` unchanged. If unmuting, restore.

- `toggleShuffle()` — If enabling: save `_originalQueue`, shuffle `_queue` (keep current song at position 0). If disabling: restore `_originalQueue`, update `_currentIndex` to match current song's position.

- `cycleRepeatMode()` — `off → all → one → off`.

- `addToQueue(Song song)` — Append to `_queue`.

- `addToQueueNext(Song song)` — Insert after `_currentIndex` in `_queue`.

- `removeFromQueue(int index)` — Remove from `_queue`. Adjust `_currentIndex` if needed.

- `reorderQueue(int oldIndex, int newIndex)` — Reorder `_queue`. Adjust `_currentIndex`.

- `clearQueue()` — Clear `_queue`, stop playback.

- `_onTrackComplete()` — Called when current track finishes naturally. Handles crossfade logic or instant next. Updates play count if threshold met (30s or 50% duration). Records play history entry.

- `_handleCrossfade()` — If `crossfadeSeconds > 0` and next track exists: lazy-init `_playerB`, pre-load next track, start volume fade. After crossfade completes, swap player references.

- `_updatePlayCount(Song song, int listenedMs)` — If `listenedMs >= 30000 || listenedMs >= song.durationMs * 0.5`, increment song's play count and update `lastPlayedAt` via use case.

- `_saveState()` — Debounced. Saves current queue and playback state to repository for resume on next launch.

- `_dispose()` — Cancel all subscriptions. Dispose both players. Save state.

**Derived providers** (separate `@riverpod` functions in same file or nearby):

- `currentSongProvider` — `ref.watch(playbackNotifierProvider.select((s) => s.currentSong))`
- `isPlayingProvider` — `ref.watch(playbackNotifierProvider.select((s) => s.isPlaying))`
- `positionProvider` — `ref.watch(playbackNotifierProvider.select((s) => s.position))`
- `durationProvider` — `ref.watch(playbackNotifierProvider.select((s) => s.duration))`
- `volumeProvider` — `ref.watch(playbackNotifierProvider.select((s) => s.volume))`
- `shuffleProvider` — `ref.watch(playbackNotifierProvider.select((s) => s.shuffle))`
- `repeatModeProvider` — `ref.watch(playbackNotifierProvider.select((s) => s.repeatMode))`
- `queueProvider` — exposes `_queue` as immutable list

### 5.7 `lib/presentation/providers/library_provider.dart`

**Purpose**: Manages library data (song list, album list, artist list, genre list) with sorting. Each tab has its own async state.

```dart
@riverpod
class SongsNotifier extends _$SongsNotifier {
  @override
  Future<List<Song>> build({String sortBy = 'title', bool ascending = true}) async {
    final useCase = ref.watch(getAllSongsProvider);
    final result = await useCase.call(sortBy: sortBy, ascending: ascending);
    return result.when(success: (songs) => songs, failure: (_) => []);
  }
}

// Similar for AlbumsNotifier, ArtistsNotifier, GenresNotifier
// FolderContentsNotifier takes a path parameter
```

### 5.8 `lib/presentation/providers/search_provider.dart`

**Purpose**: Manages search state — query text, results, search history.

```dart
@riverpod
class SearchNotifier extends _$SearchNotifier {
  // State holds: query, SearchResults (songs, albums, artists, playlists),
  // isSearching flag, search history list

  // Methods:
  // search(String query) — debounced, calls SearchLibrary use case
  // clearSearch()
  // addToHistory(String query) — max 20 entries, persisted in settings
  // removeFromHistory(String query)
  // clearHistory()
  // loadHistory() — called on build
}
```

### 5.9 `lib/presentation/providers/playlist_provider.dart`

**Purpose**: Manages playlist list state and CRUD operations.

```dart
@riverpod
class PlaylistsNotifier extends _$PlaylistsNotifier {
  @override
  Future<List<Playlist>> build({String? sortBy}) async {
    // Fetch all playlists via use case
  }

  Future<int> createPlaylist(String name) async { /* ... */ }
  Future<void> renamePlaylist(int id, String name) async { /* ... */ }
  Future<void> deletePlaylist(int id) async { /* ... */ }
  Future<void> duplicatePlaylist(int id) async { /* ... */ }
}

// Separate provider for a single playlist's songs:
@riverpod
Future<List<Song>> playlistSongs(PlaylistSongsRef ref, int playlistId) async {
  // ...
}
```

### 5.10 `lib/presentation/providers/favorites_provider.dart`

```dart
@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  @override
  Future<List<Song>> build({String sortBy = 'title', bool ascending = true}) async {
    // Fetch via GetFavorites use case
  }

  Future<void> toggleFavorite(int songId, bool currentValue) async {
    // Call ToggleFavorite use case, then invalidate self
  }
}
```

### 5.11 `lib/presentation/providers/scan_provider.dart`

**Purpose**: Manages library scan state — progress, current file, found/processed counts.

```dart
@freezed
class ScanState with _$ScanState {
  const factory ScanState({
    @Default(false) bool isScanning,
    @Default(0) int found,
    @Default(0) int processed,
    @Default(0) int total,
    String? currentFile,
    @Default(0) int inaccessibleFolders,
  }) = _ScanState;
}

@Riverpod(keepAlive: true)
class ScanNotifier extends _$ScanNotifier {
  @override
  ScanState build() => const ScanState();

  Future<void> startScan() async {
    // Get enabled scan folders
    // Call ScanLibrary use case (which returns a Stream<ScanProgress>)
    // Update state as progress events come in
    // When done, invalidate library providers to refresh UI
  }
}
```

### 5.12 `lib/presentation/providers/eq_provider.dart`

**Purpose**: Manages equalizer state — enabled, current preset, band values.

```dart
@Riverpod(keepAlive: true)
class EqNotifier extends _$EqNotifier {
  // State: enabled, presets list, selectedPresetId, currentBands List<double>
  // Methods: toggleEq, selectPreset, setBandValue, saveCustomPreset, resetToPreset
  // On band change: apply to just_audio AudioPlayer's equalizer (if supported)
}
```

### 5.13 `lib/presentation/providers/settings_provider.dart`

**Purpose**: Manages individual settings values. Each setting is a separate provider that reads/writes via `SettingsRepository`.

```dart
// Individual setting providers:
@riverpod
class AutoScanSetting extends _$AutoScanSetting {
  @override
  Future<bool> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return (await repo.getBool('auto_scan')).valueOrNull ?? true;
  }

  Future<void> set(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setBool('auto_scan', value);
    ref.invalidateSelf();
  }
}

// Similar for: gaplessPlayback, resumeOnLaunch, gamepadEnabled,
// navSoundLevel, closeToTray, startWithOS, crossfadeSeconds
```

### 5.14 `lib/presentation/providers/scan_folder_provider.dart`

```dart
@riverpod
class ScanFoldersNotifier extends _$ScanFoldersNotifier {
  @override
  Future<List<ScanFolder>> build() async {
    // Get all scan folders
  }

  Future<void> addFolder(String path) async { /* ... */ }
  Future<void> removeFolder(int id) async { /* ... */ }
  Future<void> toggleEnabled(int id, bool enabled) async { /* ... */ }
}

// Derived provider for onboarding: are there any configured scan folders?
@riverpod
bool hasScanFolders(ref) {
  final folders = ref.watch(scanFoldersNotifierProvider).valueOrNull ?? [];
  return folders.isNotEmpty;
}
```

### 5.15 `lib/presentation/providers/navigation_provider.dart`

**Purpose**: Tracks current navigation state for button hints and focus memory.

```dart
@Riverpod(keepAlive: true)
class NavigationNotifier extends _$NavigationNotifier {
  @override
  String build() => '/home'; // Current route path

  void setCurrentRoute(String route) {
    state = route;
  }
}
```

### 5.16 `lib/presentation/providers/toast_provider.dart`

**Purpose**: Manages toast notification display queue.

```dart
@freezed
class ToastData with _$ToastData {
  const factory ToastData({
    required String message,
    @Default(false) bool isError,
    void Function()? undoAction,
    String? undoLabel,
  }) = _ToastData;
}

@Riverpod(keepAlive: true)
class ToastNotifier extends _$ToastNotifier {
  @override
  ToastData? build() => null;

  void show(String message, {bool isError = false, void Function()? undoAction}) {
    state = ToastData(message: message, isError: isError, undoAction: undoAction);
    // Auto-clear after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (state?.message == message) state = null;
    });
  }

  void dismiss() => state = null;
}
```

<!-- END PHASE 5 -->

## Phase 6: Presentation — Shared Widgets

All widget files live in `lib/presentation/widgets/`. Every widget uses `const` constructors where possible, references `Theme.of(context)` for colors/text styles, and uses Lucide icons (`lucide_icons` package) exclusively.

### 6.1 `lib/presentation/widgets/focus_highlight.dart`

**Purpose**: Wraps any child widget to show the focus indicator. This is the single source of truth for focus styling across the app. Used by every focusable widget.

```dart
import 'package:flutter/material.dart';

class FocusHighlight extends StatelessWidget {
  const FocusHighlight({
    super.key,
    required this.focusNode,
    required this.child,
    this.borderRadius = 16.0, // Match --card-radius
    this.padding = EdgeInsets.zero,
    this.onPressed,       // A button action
    this.onSecondary,     // X button action (context menu)
    this.canRequestFocus = true,
    this.isCard = false,  // True for grid cards (1.05x scale), false for tiles (1.02x)
  });

  final FocusNode focusNode;
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onPressed;
  final VoidCallback? onSecondary;
  final bool canRequestFocus;
  final bool isCard;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      onKeyEvent: (node, event) {
        // Handle A button (LogicalKeyboardKey.gameButtonA or Enter/Space) → onPressed
        // Handle X button (LogicalKeyboardKey.gameButtonX) → onSecondary
        // Return KeyEventResult.ignored for unhandled
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: focusNode.hasFocus
                ? Theme.of(context).colorScheme.primary // accent color
                : Colors.transparent,
            width: 3, // REQUIREMENTS §6.4: 3px focus border
          ),
          boxShadow: focusNode.hasFocus
              ? [BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                )]
              : null,
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          scale: focusNode.hasFocus
              ? (isCard ? 1.05 : 1.02) // REQUIREMENTS §6.4: 1.05x cards, 1.02x tiles
              : 1.0,
          child: child,
        ),
      ),
    );
  }
}
```

**Focus indicator spec** (per REQUIREMENTS §6.4): 3px accent-colored border, accent glow `rgba(accentColor, 0.3)` blur 12px, dual scale (1.02x tiles / 1.05x cards via `isCard` param), 150ms easeOut transition.

### 6.2 `lib/presentation/widgets/side_nav_rail.dart`

**Purpose**: Left navigation rail. 220px wide at ≥1200px breakpoint (with labels), 72px collapsed at 800–1199px (icons only).

**Visual spec from mockup**:
- Background: `Theme.of(context).extension<AppThemeExtension>()!.bgDeep` (--bg-deep: #000000)
- Right border: 1px `borderSubtle` (rgba(255,255,255,0.05))
- Items: Lucide icons, 20×20. Labels at 14sp `textSecondary`.
- Active item: `accent.withOpacity(0.08)` background, icon+label in `accent` color. (No left border — matches mockup).
- Item height: 48px min. Spacing between items: 4px.
- Top: App logo/title area (64px height).
- Bottom: Settings icon (always last).

**Nav items** (in order — matches REQUIREMENTS.md and mockup):
1. Home — `LucideIcons.home`
2. Library — `LucideIcons.library`
3. Search — `LucideIcons.search`
4. (separator)
5. Playlists — `LucideIcons.listMusic`
6. Favorites — `LucideIcons.heart`
7. (spacer — pushes Settings to bottom)
8. Settings — `LucideIcons.settings` (at bottom)

> **Note**: "Recently Played" is NOT a nav rail item. It is a smart playlist accessed from the Playlists screen (see REQUIREMENTS.md 6.3.9).

**Each item** is wrapped in `FocusHighlight`. Pressing A navigates via `GoRouter`. Active item determined by matching `GoRouter.of(context).location`.

**Layout**: `Column` in a `SizedBox` with `width: isCollapsed ? 72 : 220`. The collapse state is determined by `MediaQuery.of(context).size.width < 1200`.

```dart
class SideNavRail extends StatelessWidget {
  const SideNavRail({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCollapsed = width < 1200;
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: isCollapsed ? 72 : 220,
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppThemeExtension>()!.bgDeep,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).extension<AppThemeExtension>()!.borderSubtle,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo area: 64px
          // Nav items with FocusTraversalGroup
          // Spacer
          // Settings item
        ],
      ),
    );
  }
}
```

### 6.2a `lib/presentation/widgets/art_placeholder.dart`

**Purpose**: Standardized placeholder shown whenever album/artist/playlist art is missing. Used by `SongListTile`, `AlbumCard`, `ArtistCard`, `PlaylistCard`, `MiniPlayerBar`, and `NowPlayingPage`. Single source of truth for placeholder appearance.

**Visual spec**:
- Background: `bgCard` (`#0F1520` dark / theme-aware light equivalent) — matches the card surface it sits on. A subtle radial gradient from `bgCardHover` (center, 40% radius) to `bgCard` (edge) adds depth without being decorative.
- Icon: **Lucide `music`** in accent color, centered. This matches the app icon and is immediately recognizable.
- Icon sizes by context:
  - Song list tile (44×44 container): icon 20×20
  - Mini player (48×48 container): icon 20×20
  - Album/playlist card (~140×140 container): icon 32×32
  - Now Playing (300×300 container): icon 64×64
  - Queue item (36×36 container): icon 16×16
  - Detail header (200×200 container): icon 48×48
- **ArtistCard exception**: Uses Lucide `user` icon instead of `music` (per REQUIREMENTS.md 6.3.2).
- **PlaylistCard exception (empty playlist)**: Uses Lucide `list-music` icon instead of `music`.
- BorderRadius: inherits from parent (6px for song tile, 12px for cards, 50% for artist).
- The placeholder is a `const` widget where possible. It does NOT animate.

```dart
class ArtPlaceholder extends StatelessWidget {
  const ArtPlaceholder({
    super.key,
    required this.size,
    this.iconSize,
    this.icon, // Defaults to LucideIcons.music
    this.borderRadius,
  });

  final double size;
  final double? iconSize; // Auto-calculated if null: size * 0.45
  final IconData? icon;
  final BorderRadius? borderRadius;
}
```

### 6.3 `lib/presentation/widgets/mini_player_bar.dart`

**Purpose**: Persistent mini player at bottom. 84px height, shown when a song is loaded.

**Visual spec from mockup**:
- Height: 84px
- Background: `bgSurface` (#0A0E17) with top border 1px `borderSubtle`
- Layout: 3-column: left (240px) | center (1fr) | right (140px)
- **Left column**: Album art (48×48, borderRadius 12 per mockup CSS), title (13sp semibold white, 1 line ellipsis), artist (11sp secondary, 1 line ellipsis). Gap between art and text: 14px.
- **Center column**: Centered row of controls:
  - Shuffle icon (20×20, toggleable — accent when active, secondary when not)
  - Previous icon (20×20)
  - Play/Pause circle button (34×34 accent background, icon 16×16 white)
  - Next icon (20×20)
  - Repeat icon (20×20, toggleable). Repeat-one shows a small "1" badge.
  - Below controls: progress bar (full width of center column, max 520px, height 4px expanding to 6px on hover, accent fill, bgInput track, 2px borderRadius). Clickable to seek. Below bar: position text on left (11sp secondary, right-aligned e.g. `3:45`) and **remaining time** on right (11sp secondary, negative format e.g. `-2:37`), both with `font-variant-numeric: tabular-nums`.
- **Right column**: Volume icon + mini slider (optional).

**Focus behavior**: The Play/Pause button is the default focus target in this group. A button toggles play/pause. D-pad left/right moves focus to previous/next controls.

**Watches providers**: `currentSongProvider`, `isPlayingProvider`, `positionProvider`, `durationProvider`, `shuffleProvider`, `repeatModeProvider` — each with `select()` for minimal rebuilds.

**Tap on album art or song title** → navigates to Now Playing page.

```dart
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});
  // ...
}
```

### 6.4 `lib/presentation/widgets/song_list_tile.dart`

**Purpose**: A single song row used in all song lists (library, playlist, album detail, etc.).

**Visual spec from mockup**:
- Height: 56px
- Horizontal padding: 16px
- Album art: 44×44, borderRadius 6px. Placeholder: `ArtPlaceholder(size: 44)` — `bgCard` background with radial gradient, accent-colored Lucide `music` icon (20×20).
- Title: 14sp, `textPrimary`, 1 line ellipsis.
- Artist: 12sp, `textSecondary`, 1 line ellipsis.
- **Favorite indicator**: Heart icon (Lucide `heart`) between artist text and duration. If `isFavorite`: filled ♥ in accent color. If not: outline ♡ in `textTertiary`. Tappable / Y button toggles favorite. 200ms scale bounce (1.0→1.3→1.0) on toggle per animation spec.
- Duration: 12sp, `textTertiary`, right-aligned.
- Currently playing indicator: left 3px accent bar + title in accent color + animated playing icon (3-bar equalizer).
- Hover state (mouse): background `bgCardHover` (#151D2E).
- Track number column (optional): 28px wide, 13sp secondary, shown in album detail view.

**Constructor parameters**:
```dart
const SongListTile({
  required this.song,
  this.index,              // Track number to show (null = hide)
  this.isCurrentlyPlaying = false,
  this.isFavorite = false, // Shows filled/outline heart icon
  this.onTap,              // A button / click
  this.onContextMenu,      // X button / right-click
  this.onToggleFavorite,   // Y button / heart tap
  this.showArt = true,
  this.showDuration = true,
  this.trailing,           // Optional widget (e.g., drag handle)
});
```

Wrapped in `FocusHighlight` with borderRadius 12. A button → `onTap`. X button → `onContextMenu`.

### 6.5 `lib/presentation/widgets/album_card.dart`

**Purpose**: Album card for grid views.

**Visual spec from mockup**:
- Width: 165px (default), 210px in horizontal scroll rows.
- Padding: 12px.
- Art: square, borderRadius 12px, fills card width minus padding. Placeholder: `ArtPlaceholder(size: cardWidth - padding, borderRadius: 12)` — `bgCard` background with radial gradient, accent-colored Lucide `music` icon (32×32).
- Title: 14sp white, 1 line ellipsis. Margin-top 10px.
- Artist: 12sp secondary, 1 line ellipsis. Margin-top 2px.
- Background: `bgCard` (#0F1520). Border: 1px `borderCard` (rgba(255,255,255,0.04)).
- BorderRadius: 16px (--card-radius).

```dart
const AlbumCard({
  required this.albumName,
  required this.artistName,
  this.artPath,
  this.width = 165,
  this.onTap,
  this.onContextMenu,
});
```

Wrapped in `FocusHighlight` with borderRadius 16.

### 6.6 `lib/presentation/widgets/artist_card.dart`

**Purpose**: Artist card for grid views.

**Visual spec from mockup**:
- Same size as album card (165px / 210px).
- Art: **circular** (borderRadius 50%), fills card width minus padding. Placeholder: `ArtPlaceholder(size: cardWidth - padding, icon: LucideIcons.user, borderRadius: circular)` — `bgCard` background with radial gradient, accent-colored Lucide `user` icon (32×32).
- Name: 14sp white, centered, 1 line ellipsis.
- Song count: 12sp secondary, centered.
- Background, border, borderRadius same as album card.

### 6.7 `lib/presentation/widgets/playlist_card.dart`

**Purpose**: Playlist card for grid views.

**Visual spec from mockup**:
- Same base size as album card.
- Art: borderRadius 12px. If playlist has songs, use mosaic of first 4 song arts in 2×2 grid (each quadrant uses `ArtPlaceholder` if that song has no art). If empty playlist: `ArtPlaceholder(size: cardWidth - padding, icon: LucideIcons.listMusic, borderRadius: 12)` — `bgCard` background with radial gradient, accent-colored Lucide `list-music` icon (32×32).
- Name: 14sp white, 1 line ellipsis.
- Song count: 12sp secondary ("N songs").

### 6.8 `lib/presentation/widgets/genre_list_tile.dart`

**Purpose**: Genre list tile for list views (per REQUIREMENTS §6.3.2: "Genres: list with song count").

**Visual spec**:
- Height: 56px (standard list tile height).
- Left: 40×40 rounded square with colored gradient background (hash genre name → deterministic color). Genre initial letter centered, 16sp white.
- Center: Genre name (14sp white), song count (12sp secondary, e.g., "42 songs").
- Right: Chevron right icon (Lucide `chevron-right`, 16×16, textTertiary).

Wrapped in `FocusHighlight`. A navigates to genre detail page.

### 6.9 `lib/presentation/widgets/context_menu.dart`

**Purpose**: Reusable context menu overlay. Appears on X button press or right-click.

**Visual spec from mockup**:
- Width: 240px
- Background: `bgSurface` (#0A0E17)
- Border: 1px `borderSubtle`
- BorderRadius: 12px (--card-radius-sm)
- Box shadow: 0 8px 32px rgba(0,0,0,0.8)
- Item height: 40px
- Item padding: 0 16px
- Item text: 14sp, textPrimary
- Item icon: 18×18, textSecondary, 12px gap to text
- Hover/focus item: `bgCardHover` background
- Separator: 1px `borderSubtle`, margin 4px 0

**Constructor**:
```dart
const AppContextMenu({
  required this.items,
  required this.position, // Offset for positioning
});

class ContextMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDangerous; // If true, text in error color
  final List<ContextMenuItem>? submenu; // For "Add to Playlist" etc.
}
```

**Focus behavior**: When opened, focus goes to the first item. D-pad up/down navigates items. A selects. B closes menu. If item has submenu, A or D-pad right opens it. B or D-pad left returns to parent menu.

**Shown via** `Overlay` entry positioned near the focused widget.

### 6.10 `lib/presentation/widgets/gamepad_button_hints.dart`

**Purpose**: Horizontal bar at the bottom of the screen showing available gamepad button actions for the current context.

**Visual spec from mockup**:
- Height: 40px
- Background: `bgDeep` (#000000) with top border 1px `borderSubtle`
- Items: Row of [colored circle 22×22 + label 11sp secondary], spaced 20px apart
- Button colors: A=#4CAF50, B=#F44336, X=#2196F3, Y=#FFC107
- **Right-aligned** (`justify-content: flex-end`, `padding-right: 24px`) — matches mockup and REQUIREMENTS layout diagram

```dart
class GamepadButtonHints extends StatelessWidget {
  const GamepadButtonHints({
    super.key,
    this.aLabel,   // e.g., "Play", "Select"
    this.bLabel,   // e.g., "Back"
    this.xLabel,   // e.g., "Options"
    this.yLabel,   // e.g., "Favorite"
  });
  // Only shows buttons that have labels. Null = hidden.
}
```

### 6.11 `lib/presentation/widgets/toast_notification.dart`

**Purpose**: Overlay widget for toast messages. Positioned bottom-center, above mini player.

**Visual spec from mockup**:
- Background: `bgCard` (#0F1520) with 1px `borderSubtle`
- BorderRadius: 12px
- Padding: 12px 20px
- Text: 14sp white
- Undo button (if present): text button, accent color, 14sp
- Entry: slide up 200ms, fade in
- Exit: fade out 150ms
- Max width: 400px

**Implementation**: Listens to `toastNotifierProvider`. When non-null, shows the toast using `AnimatedPositioned` + `AnimatedOpacity` in an `Overlay` or a persistent positioned widget in the scaffold stack.

**Not focusable** — does not participate in focus traversal.

### 6.12 `lib/presentation/widgets/volume_osd.dart`

**Purpose**: On-screen volume indicator shown when volume changes via gamepad triggers.

**Visual spec from mockup**:
- Position: top-right corner, 24px margin
- Background: `bgSurface` with 80% opacity, borderRadius 12px
- Content: volume icon + horizontal bar + percentage text
- Width: ~200px, height: ~44px
- Auto-dismiss after 1.5 seconds of no change
- Entry/exit: fade 150ms

### 6.13 `lib/presentation/widgets/empty_state.dart`

**Purpose**: Reusable empty state placeholder for any screen with no content.

```dart
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,      // Lucide icon
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });
  // Centered column: icon (48×48, tertiary color), title (18sp secondary),
  // subtitle (14sp tertiary), action button (accent).
}
```

### 6.14 `lib/presentation/widgets/custom_title_bar.dart`

**Purpose**: Custom window title bar replacing native chrome. Implements drag-to-move and window control buttons.

**Visual spec from mockup**:
- Height: 36px
- Background: transparent (inherits from parent)
- Left: App icon (20×20) + app name "Music FSE" 13sp semibold (only at ≥1200px, otherwise just icon)
- Right: Minimize, Maximize/Restore, Close buttons. Each 46×36 hit area.
- Close button hover: red background (#E81123)
- Drag area: entire bar except buttons (uses `window_manager`'s `startDragging`)

### 6.15 `lib/presentation/widgets/loading_indicator.dart`

**Purpose**: Simple centered loading spinner.

```dart
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});
  final String? message;
  // CircularProgressIndicator with accent color + optional message text below
}
```

### 6.16 `lib/presentation/widgets/keyboard_shortcuts_overlay.dart`

**Purpose**: Full-screen overlay listing all keyboard shortcuts. Shown via a settings option or keyboard shortcut.

**Visual spec**: Dark modal backdrop, centered card 600×500, list of shortcut groups (Playback, Navigation, Library) with key combos and descriptions.

### 6.17 `lib/presentation/widgets/scroll_to_now_playing_button.dart`

**Purpose**: Small floating button in song list views that scrolls to the currently playing song. Appears only when the current song is in the list but off-screen.

**Visual spec**: 36×36 circle, accent background, down-arrow icon. Position: bottom-right of list, 16px margin.

<!-- END PHASE 6 -->

## Phase 7: Presentation — Pages & Screens

All page files live in `lib/presentation/pages/`. Each page extends `ConsumerWidget` or `ConsumerStatefulWidget`. Every page must:
- Define a default focus element
- Set up `FocusTraversalGroup` for each logical region
- Handle B button for back navigation
- Define `GamepadButtonHints` context
- Handle empty state where applicable

### 7.1 `lib/presentation/pages/shell_page.dart`

**Purpose**: The outer scaffold wrapping all main pages. Contains the `SideNavRail`, `CustomTitleBar`, `MiniPlayerBar`, `GamepadButtonHints`, `ToastNotification` overlay, and the content area that hosts child routes.

**Layout structure**:
```
Column
├── CustomTitleBar (36px)
└── Expanded
    └── Row
        ├── SideNavRail (220px or 72px)
        └── Expanded
            └── Column
                ├── Expanded → child (page content from GoRouter)
                ├── MiniPlayerBar (84px, only if song loaded)
                └── GamepadButtonHints (40px)
```

**Implementation**: Uses `StatefulShellRoute` from `go_router` for nested navigation. The `child` parameter from the shell route builder is placed in the content area.

**Focus management**: `FocusTraversalGroup` for the nav rail (order 0) and content area (order 1). D-pad left from content edge should reach nav rail.

### 7.2 `lib/presentation/pages/onboarding_page.dart`

**Purpose**: First-launch setup. Shown if no scan folders configured. Route: `/onboarding`.

**Visual spec from mockup**:
- Full-screen centered card, max width 500px
- Multi-step flow (4 steps per REQUIREMENTS.md 6.3.0):
  1. **Welcome**: App logo, title "Welcome to Music FSE", subtitle "Your music. Your controls. Full screen experience.", "Get Started" button
  2. **Add Folders**: "Select your music folders" heading, folder list with add/remove, file picker button, shows selected paths with remove buttons. Can skip (will prompt later)
  3. **Theme Selection**: Toggle Dark/Light/System, pick accent color from grid of predefined colors (same palette as Settings color picker). Preview applies immediately.
  4. **Scanning**: Progress indicator, file count, "Scanning..." message, "Done" button when complete (navigates to Home)
- Step indicator: 4 dots at bottom, accent = current, secondary = others
- Navigation: A = next/action, B = previous step (except step 1). Can skip entire onboarding.
- Background: `bgPrimary` (#050810)
- Card: `bgSurface` background, borderRadius 24px, padding 32px
- **Onboarding only shows once** (flag in settings DB). Can be re-triggered from Settings > About > "Re-run setup"
- **LB/RB disabled** during onboarding

**Focus**: Step 1 → "Get Started" button. Step 2 → "Add Folder" button. Step 3 → first color option or theme toggle. Step 4 → "Done" button (or non-interactive during scanning).

### 7.3 `lib/presentation/pages/home_page.dart`

**Purpose**: Landing page. Route: `/home`. Vertically scrollable layout with quick resume, rows of content, and library stats.

**Visual spec from mockup**:
- No heading text — content starts immediately (mockup shows hero card at top, not a "Home" title)
- Vertically scrollable via `CustomScrollView` with `SliverList`/`SliverToBoxAdapter`
- Card width in horizontal scroll rows: 210px
- Gap between cards: 16px
- Row horizontal padding: 24px

**Sections (in order per REQUIREMENTS.md 6.3.1 and mockup)**:

1. **Quick Resume Hero Card** (always visible if there's playback history)
   - Large hero card showing the last played context (album, playlist, or queue)
   - Layout: album art (left, large), title, subtitle ("Album · Artist" or "Playlist · N songs"), "Resume" button (primary, accent) + "Shuffle All" button (secondary)
   - A button resumes playback from where the user left off (same position in queue)
   - If no playback history exists (fresh install), this section is **hidden**
   - Uses a new `getResumeContext` use case that returns the last played album/playlist/song context

2. **Recently Played Row**
   - Section header: "Recently Played" (left) + focusable "See All →" text button (right, navigates to Recently Played full-screen list: last 100 songs, sorted by `played_at` desc, same layout as Library Songs tab; B returns to Home)
   - Horizontal scroll of last 10 distinct songs/albums played. Each card: album art (130×170 lp style from mockup), song title, artist name + time since played ("2h ago", "Yesterday")
   - If fewer than 3 items, row is **hidden** (not enough to be useful)
   - Uses `getRecentlyPlayed` use case

3. **Recommendation Rows** (conditional on play history — see REQUIREMENTS.md 3.7a)
   - Each recommendation category is a separate horizontal scroll row
   - Row header: category name (left) + "Refresh ↻" icon button (right)
   - Each card: album art, song title, artist name (130×170 lp)
   - If library < 20 songs or no play history: show empty state placeholder instead
   - Uses recommendations provider

4. **Quick Access Row** (always visible if user has playlists)
   - "Quick Access" header (no "See All")
   - Horizontal scroll of most recently updated playlists (sorted by `updated_at` desc, max 10)
   - Each card: playlist cover art mosaic (or auto-generated from first 4 song arts), playlist name, song count
   - If no playlists exist, show a "Create your first playlist" CTA card
   - Uses `getAllPlaylists` use case (sorted by `updated_at`)

5. **Library Stats Footer** (non-focusable)
   - Compact single line: "1,234 songs · 89 artists · 45 albums · 4d 12h total"
   - Subtle text (`textTertiary`), non-focusable (informational only)
   - Uses a new `getLibraryStats` use case

**Empty states** (per REQUIREMENTS.md 6.3a):
- If no library at all: EmptyState "No music yet. Add a folder to get started." → "Add Music Folder" button
- If no recently played: section hidden (not shown)
- If no recommendations: "Play more music to get personalized recommendations." → (no CTA, auto-populates)

**Focus**: Default focus → Quick Resume "Resume" button (or first Recently Played card if no resume context). D-pad down moves between sections. D-pad left/right scrolls within a horizontal row. A plays/opens focused item. X opens context menu on focused song/album card. Y toggles favorite on focused song. Left stick analog scrolls vertically. B does nothing on Home (root screen).

### 7.4 `lib/presentation/pages/library_page.dart`

**Purpose**: Tabbed library browser. Route: `/library`. Contains 5 tabs: Songs, Artists, Albums, Genres, Folders (order matches REQUIREMENTS.md 6.3.2 and mockup).

**Visual spec from mockup**:
- Heading: "Library" 26sp semibold, top-left
- Tab bar: horizontal, below heading. Each tab: 14sp, 40px height, 24px horizontal padding. Active tab: accent color text + bottom 2px accent border. Inactive: secondary color.
- Tab content fills remaining space below tab bar.
- LB/RB switches tabs.

**Tabs**:

#### Tab 1: Songs — `lib/presentation/pages/library/songs_tab.dart`
- Sort dropdown: top-right, options: Name A-Z, Name Z-A, Artist, Album, Date Added, Duration, Year (per mockup dropdown). Default: Name A-Z.
- Content: `ListView.builder` of `SongListTile`. Virtual scrolling.
- Empty: `EmptyState` with "No songs found", "Add music folders in Settings".
- Focus: Default → first song tile. A plays song. X opens context menu. Y toggles favorite.
- Shows song count: "N songs" badge next to tab label or below heading.

#### Tab 2: Artists — `lib/presentation/pages/library/artists_tab.dart`
- Sort dropdown: Name, Song Count.
- Content: `GridView.builder` of `ArtistCard`.
- Focus: Default → first artist card. A navigates to artist detail page.

#### Tab 3: Albums — `lib/presentation/pages/library/albums_tab.dart`
- Sort dropdown: Name A-Z, Artist, Year, Date Added (per mockup).
- Content: `GridView.builder` of `AlbumCard`. Columns: `crossAxisCount` = `(availableWidth / 180).floor()`, min 3.
- Focus: Default → first album card. A navigates to album detail page.

#### Tab 4: Genres — `lib/presentation/pages/library/genres_tab.dart`
- Sort dropdown: Name, Song Count.
- Content: `ListView.builder` of genre list tiles (per REQUIREMENTS §6.3.2: "Genres: list with song count"). Each tile: 56px height, colored gradient icon (hash genre name → deterministic color), genre name (14sp), song count (12sp secondary).
- Focus: Default → first genre tile. A navigates to genre detail page.

#### Tab 5: Folders — `lib/presentation/pages/library/folders_tab.dart`
- Sort: Files sortable by name, date modified, duration. Folders always sorted alphabetically.
- Content: Top-level shows scan folders as folder items. Navigating into a folder shows subfolders first, then audio files as `SongListTile` items. **Breadcrumb bar** at top showing current path relative to scan folder root (e.g., `Music / Rock / Pink Floyd / The Wall`). Non-focusable, informational only.
- **Folder item**: 56px height, Lucide `folder` icon, folder name, recursive audio file count.
- **Context menu (X)**: On a subfolder → "Play All in Folder", "Shuffle Folder", "Add Folder to Queue". On a file → standard song context menu.
- Focus: Default → first folder. A enters folder or plays file. B goes up one level (pops breadcrumb). At the root scan folder level, B returns to Library Folders tab. Y toggles favorite on focused song (disabled on folders). Left stick for analog scrolling.
- Folder item: 56px height, folder icon, folder name, song count.
- Focus: Default → first folder. A enters folder. B goes up one level (or exits tab if at root).

### 7.5 `lib/presentation/pages/album_detail_page.dart`

**Purpose**: Shows songs for a specific album. Route: `/library/album/:albumName/:albumArtist`.

**Visual spec from mockup**:
- Header area: Large album art (200×200, borderRadius 16), album name (22sp semibold), artist name (16sp secondary), year (14sp tertiary), "N songs · Xm" duration info.
- Action buttons row: Play All, Shuffle, Add to Queue, Add to Playlist (per REQUIREMENTS §FL-INPUT-008: album context). Each is a pill-shaped button (accent bg for primary, bgCard for secondary).
- Song list: `ListView.builder` of `SongListTile` with track numbers shown.
- Back button: top-left, or B button.

**Focus**: Default → "Play All" button. D-pad down → song list.

### 7.6 `lib/presentation/pages/artist_detail_page.dart`

**Purpose**: Shows albums and songs for a specific artist. Route: `/library/artist/:artistName`.

**Visual spec from mockup**:
- Header: Artist icon/image (circular, 120×120), artist name (24sp semibold), "N songs · N albums" (14sp secondary).
- Action buttons: Play All, Shuffle.
- Albums section: horizontal scroll of `AlbumCard`.
- Songs section: `ListView.builder` of `SongListTile`.

**Focus**: Default → "Play All". D-pad down → albums row → songs list.

### 7.7 `lib/presentation/pages/genre_detail_page.dart`

**Purpose**: Shows songs in a genre. Route: `/library/genre/:genreName`.

**Visual spec**: Similar to artist detail layout:
- Header: Genre name (22sp semibold) + song count and album count
- Action buttons: Play All, Shuffle
- **Albums in genre**: Horizontal scrollable row of `AlbumCard` widgets filtered to albums that contain songs of this genre. `SizedBox` height ~210. If genre has only 1 album or no album art, this section can be hidden.
- Song list: `ListView.builder` of `SongListTile`, sorted by album then track number by default. Sort dropdown available (Name A-Z, Name Z-A, Artist, Album, Date Added, Duration, Year — per REQUIREMENTS §6.3.6: same sort options as Library).
- Empty: EmptyState "No songs in this genre"

**Gamepad**: Default focus → Play All button. D-pad down → album row (left/right scrolls), D-pad down again → song list. X on song → context menu. Y on song → toggle favorite. B → back to library genres tab.

### 7.8 `lib/presentation/pages/now_playing_page.dart`

**Purpose**: Full-screen Now Playing view. Route: `/now-playing`. Accessed by pressing A on mini player, or tapping album art.

**Visual spec from mockup**:
- Background: Album art pre-blurred on a background isolate (Gaussian blur sigma 25, using `dart:ui` `ImageFilter.blur` or the `image` package on an isolate), overlaid at 15–20% opacity on the dark background color. Cached per song as a `Uint8List` in memory (not re-blurred every frame). **Do NOT use `BackdropFilter` widget** (recomputes every frame on GPU). When no album art is available, the art area shows `ArtPlaceholder` with accent Lucide `music` icon, and the background uses a subtle dark radial gradient (`bgDeep` center → `bgPrimary` edge) instead of the blurred art overlay. Static — no animation per spec.
- Center: Album art responsive size (per REQUIREMENTS §6.3.3: 60-70% of viewport width, clamped to min 280px / max 500px). Use `LayoutBuilder` to compute: `artSize = (constraints.maxWidth * 0.65).clamp(280.0, 500.0)`. borderRadius 16px, subtle shadow.
- Below art: Title (22sp semibold white), Artist (16sp secondary), Album (14sp tertiary).
- Below text: Progress bar (full width - 48px padding, height 6px, accent fill, bgInput track, 6px radius). Draggable/clickable to seek. Right stick seeks.
- Below bar: Position time (left, 12sp) and Duration time (right, 12sp).
- **Primary controls row** (centered):
  - Shuffle (24×24, toggle)
  - Previous (28×28)
  - Play/Pause circle (56×56, accent bg, icon 24×24 white)
  - Next (28×28)
  - Repeat (24×24, toggle)
- **Secondary controls row** (centered, below primary controls, per REQUIREMENTS.md 6.3.3):
  - Favorite/heart toggle (Lucide `heart`, Y button)
  - Add to Playlist button (Lucide `list-plus`, opens `AddToPlaylistDialog`)
  - Queue button (Lucide `list`, opens queue panel)
  - **Volume slider** (horizontal, 200px, accent fill) with **mute toggle** icon button left (Lucide `volume-2`, changes to `volume-x` when muted; A/click toggles mute; muted: slider track grays out, audio silent but playback continues; mute state NOT persisted across restarts)
  - Equalizer button (Lucide `sliders-horizontal`, navigates to `/equalizer`)

**Focus**: Default → Play/Pause button. D-pad up → progress bar (left/right seeks ±5s). D-pad down → secondary controls row. D-pad right on controls row → opens queue panel. Right stick horizontal → fine seek. LT/RT → volume. Y → favorite. B → minimize back to mini player.

**B button** → returns to previous page (closes now playing).

**Queue panel**: Slides in from right, 340px wide. Shows `QueueItems` as smaller song tiles (36×36 art). Current song highlighted. Reorder via gamepad: X to enter reorder mode, then D-pad up/down to move, A to drop (per REQUIREMENTS.md 6.3.4). Y on queue item → remove from queue.

### 7.9 `lib/presentation/pages/queue_panel.dart`

**Purpose**: Right-side panel showing the playback queue. Can be opened from Now Playing or mini player queue button.

**Visual spec from mockup**:
- Width: 340px
- Background: `bgSurface` with left border 1px `borderSubtle`
- Header: "Queue" 18sp semibold. Right side: **"Save as Playlist"** text button (accent) + **"Clear"** text button (accent)
  - **Save as Playlist flow** (per REQUIREMENTS.md 6.3.4): A on "Save as Playlist" opens `TextInputDialog` with default name "Queue – [localized date]" (e.g., "Queue – Apr 19, 2026"). A confirms → creates playlist with all queue songs copied as new `playlist_songs` entries. B cancels. After saving, toast: "Playlist created: [name]" with an "Open" action button on the toast. Uses `saveQueueAsPlaylist` use case.
- Queue source info: "Playing from: [source name]" 12sp secondary
- Song list: `ListView.builder`, each item: 48px height, 36×36 art, title 13sp, artist 11sp. Currently playing item: accent left bar.
- Drag handles on right for reordering (if on mouse). Gamepad: X to enter reorder mode, then D-pad up/down to move, A to drop, B to cancel reorder (per REQUIREMENTS.md 6.3.4).

**Gamepad**: Default focus on currently playing track. D-pad to navigate queue items. X to enter reorder mode. A on a track to play it immediately. Y to remove from queue. B to close panel.

### 7.10 `lib/presentation/pages/search_page.dart`

**Purpose**: Global search. Route: `/search`. Also accessible via Back/Select button on gamepad.

**Visual spec from mockup**:
- Search input: top, full-width minus padding. Height 48px, bgInput background, borderRadius 12px, 16sp text, search icon left, clear X icon right (visible when has text).
- **Search history** (shown when input is empty, per REQUIREMENTS.md 6.3.5):
  - Vertical list of up to 10 recent queries
  - Each item: Lucide `clock` icon + query text + trailing Lucide `x` icon button to remove that individual entry
  - **"Clear History"** text button at the bottom of the list (only visible when ≥1 history item exists)
  - Selecting a history item (A button / click) fills the search input with that query and immediately triggers the search
  - Gamepad in history: D-pad up/down navigates items, A selects (runs search), D-pad right focuses the "X" remove button on the current row, A on "X" removes the entry. B from history goes back to previous screen
- Results: 4 sections below input: Songs (max 5, "See All" link), Albums (horizontal scroll, max 8), Artists (horizontal scroll, max 8), Playlists (max 5 list items).
- Empty search result: EmptyState "No results found for '[query]'"
- Empty history: EmptyState "Search for songs, artists, albums, or playlists." (no CTA, show search input)

**Focus**: Default → search input. After typing (keyboard input), results appear live (debounced 300ms). D-pad down moves from input to first result section.

**Gamepad text input**: On gamepad, pressing A on the search field opens system on-screen keyboard (handled by Flutter).

### 7.11 `lib/presentation/pages/favorites_page.dart`

**Purpose**: Shows all favorite songs. Route: `/favorites`.

**Visual spec from mockup**:
- Heading: "Favorites" 26sp + heart icon in accent
- Sort dropdown: same as songs tab
- Action buttons: Play All, Shuffle
- Song list: `ListView.builder` of `SongListTile`
- Empty: EmptyState "No favorites yet", "Press Y on any song to add it to favorites"

**Y button** on any song tile toggles favorite. Heart icon animates (200ms scale bounce 1.0→1.3→1.0).

### 7.12 `lib/presentation/pages/recently_played_page.dart`

**Purpose**: Full list of recently played songs. Route: `/home/recently-played` (sub-route of Home to preserve shell/nav rail).

**Visual spec**: Heading "Recently Played" + clock icon. Song list ordered by last played (most recent first). Action buttons: Play All, Shuffle. Empty: EmptyState "No listening history", "Start playing some music!"

### 7.13 `lib/presentation/pages/playlist_list_page.dart`

**Purpose**: Shows all playlists (smart + user). Route: `/playlists`.

**Visual spec from mockup (per REQUIREMENTS.md 6.3.9)**:
- Heading: "Playlists" 26sp

- **Header row**: Two buttons on the right: **"Import M3U"** (Lucide `file-down` icon) and **"Create Playlist"** (Lucide `plus` icon + "New" label). Both focusable.

- **Smart Playlists section** (always visible, non-collapsible):
  - Subtle section header with Lucide `sparkles` icon badge and "Auto" label
  - Contains 3 smart playlists as list tiles:
    1. "Recently Added" — Lucide `sparkles` icon, shows song count
    2. "Most Played" — Lucide `sparkles` icon, shows song count
    3. "Recently Played" — Lucide `sparkles` icon, shows song count
  - Smart playlists are NOT editable (no rename, delete, or reorder in context menu)
  - Context menu (X): Play All, Shuffle, Add to Queue only

- **User Playlists section**:
  - Sort selector dropdown at top: by name A-Z (default), by date created, by date updated
  - Grid of `PlaylistCard`
  - Empty: EmptyState "No playlists yet", "Create your first playlist", action "Create Playlist"

**A on smart playlist** → navigates to a list view showing those songs (reuses the standard song list layout).
**A on user playlist card** → opens playlist detail. **X on user playlist card** → context menu (Play All, Shuffle, Rename, Duplicate, Delete, **Export as M3U**). **A on "Import M3U"** → opens file picker for .m3u/.m3u8 files, creates new playlist. **A on "Create Playlist"** → dialog to enter name.

**Gamepad**: Default focus on "Create Playlist" button (or first smart playlist if no user playlists exist). D-pad navigates between header buttons → smart playlists → user playlist grid. B does nothing (root-level screen). Y disabled (no favorites on playlists). LB/RB = prev/next track (global default).

### 7.14 `lib/presentation/pages/playlist_detail_page.dart`

**Purpose**: Shows songs in a playlist. Route: `/playlists/:id`.

**Visual spec from mockup**:
- Header: Playlist art mosaic (160×160), name (22sp), "N songs · Xm" info, creation date.
- Action buttons: Play All, Shuffle, Edit (opens reorder mode), **Delete** (danger button, opens `ConfirmDialog`).
- Song list: `SongListTile` items. In edit mode: drag handles visible. Gamepad reorder: X on track enters reorder mode — D-pad up/down moves the track, A confirms new position, B cancels. Visual drag handle appears on focused item (per REQUIREMENTS.md 6.3.6).
- X on song → context menu with "Remove from Playlist" and "Reorder" options.
- X on header area → playlist-level actions (Rename, Delete, Export as M3U).
- Empty: EmptyState "This playlist is empty", "Browse your library to add songs"

### 7.15 `lib/presentation/pages/equalizer_page.dart`

**Purpose**: EQ controls. Route: `/equalizer`. Full-screen overlay (not inline in settings). Also accessible from Now Playing secondary controls row EQ button.

**Visual spec from mockup**:
- Heading: "Equalizer" 26sp
- **Top row**: Enable toggle on/off switch (left), preset dropdown selector (right)
- Preset selector: horizontal list of preset names (pill buttons). Active = accent bg. **LB/RB cycle through presets** for quick A/B comparison.
- **Main area (full EQ available)**: Visual frequency response curve drawn above the sliders. Vertical sliders for each frequency band (60Hz, 170Hz, 310Hz, 600Hz, 1kHz, 3kHz, 6kHz, 12kHz, 14kHz, 16kHz — 10 bands). Each slider: vertical, height 200px, width 32px, accent fill. Label below: frequency. Label above: current gain in dB value.
- **Main area (bass/treble fallback)**: If `just_audio` doesn't support full parametric EQ at runtime, gracefully fall back to two large vertical sliders labeled "Bass" and "Treble" with a flat visual frequency curve. Check `just_audio` capabilities at runtime with conditional layout.
- **Bottom row**: "Save as Custom" button (opens `TextInputDialog` for name), "Reset" button (returns all bands to 0dB, secondary outline).

**Focus**: Default → first preset. D-pad right → next preset. D-pad down → band sliders. In band slider area, D-pad left/right moves between bands, D-pad up/down adjusts the focused band's gain (±1dB per press, hold for continuous). A on preset dropdown opens it (D-pad to select, A to confirm, B to cancel). LB/RB cycle presets. B closes the EQ overlay.

### 7.16 `lib/presentation/pages/settings_page.dart`

**Purpose**: App settings. Route: `/settings`.

**Visual spec from mockup**:
- Heading: "Settings" 26sp
- Sections, each with a title (16sp semibold secondary) and list of setting items:
  
**Section 1: Appearance** (per REQUIREMENTS.md section order)
- Theme — dropdown (Dark, Light, System)
- Accent Color — color picker (grid of predefined colors + custom hex input)

**Section 2: Library**
- Scan Folders — shows list of paths, "Add Folder" button, toggle enabled, remove. Tapping "Add" opens folder picker.
- Auto-scan on launch — toggle
- Rescan Library — button, triggers scan

**Section 3: Playback**
- Gapless playback — toggle
- Crossfade — slider (0-12 seconds, step 1)
- Resume on launch — toggle
- Default repeat mode — dropdown (Off, All, One)

**Section 4: Equalizer**
- Quick link: "Open Equalizer" button → navigates to `/equalizer`
- Currently active preset name shown as secondary text

**Section 5: Controls**
- Gamepad enabled — toggle
- Navigation sound — 3-position toggle: Off / Quiet / Normal (per REQUIREMENTS §FL-INPUT-005)
- Controller rumble — toggle

**Section 6: System**
- Language — dropdown (English, + others) (per REQUIREMENTS §6.3.7: under System)
- Close to tray — toggle
- Start with OS — toggle
- Minimize on close — toggle
- Window size (display only)

**Section 7: About**
- Version, build number
- Keyboard shortcuts — button → opens `KeyboardShortcutsOverlay`
- **Export Logs** — button, copies logs to clipboard or saves to file (per REQUIREMENTS §FL-LOG-005)
- **Re-run Setup Wizard** — button, navigates to onboarding flow (resets `hasCompletedOnboarding` flag, per REQUIREMENTS.md "About" section)
- Reset settings — danger button, confirms via dialog

**Setting item layout**: Height 56px. Label left (14sp white), control right (toggle/slider/dropdown). Separator 1px between items. Focusable — A toggles or opens control.

**Focus**: Default → first setting item.

### 7.17 `lib/presentation/pages/dialogs/`

Shared dialog widgets used across pages:

#### `confirm_dialog.dart`
Generic confirmation dialog. Title, message, confirm/cancel buttons. 380px wide, bgSurface, borderRadius 16, padding 24.

#### `text_input_dialog.dart`
Dialog with text field + confirm/cancel. Used for creating/renaming playlists. Same visual spec.

#### `color_picker_dialog.dart`
Accent color selector. Grid of predefined colors (12 options: orange, blue, green, red, purple, pink, teal, yellow, indigo, cyan, lime, amber). Plus custom hex input field. 380px wide. Selected color shows checkmark.

#### `add_to_playlist_dialog.dart`
Shows list of playlists + "Create New" option. Used from context menus. 380px wide, max height 500px, scrollable playlist list.

<!-- END PHASE 7 -->

## Phase 8: Platform Layer

All platform-specific code lives in `lib/platform/`. Each subdirectory handles a specific platform integration.

### 8.1 `lib/platform/xinput/xinput_binding.dart` (Windows only)

**Purpose**: FFI bindings to `xinput1_4.dll` for gamepad input on Windows.

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// XInput structs
base class XInputGamepad extends Struct {
  @Uint16() external int wButtons;
  @Uint8() external int bLeftTrigger;
  @Uint8() external int bRightTrigger;
  @Int16() external int sThumbLX;
  @Int16() external int sThumbLY;
  @Int16() external int sThumbRX;
  @Int16() external int sThumbRY;
}

base class XInputState extends Struct {
  @Uint32() external int dwPacketNumber;
  external XInputGamepad gamepad;
}

// Function typedefs
typedef XInputGetStateNative = Int32 Function(Uint32 dwUserIndex, Pointer<XInputState> pState);
typedef XInputGetStateDart = int Function(int dwUserIndex, Pointer<XInputState> pState);

// Button constants
class XInputButtons {
  static const int dpadUp = 0x0001;
  static const int dpadDown = 0x0002;
  static const int dpadLeft = 0x0004;
  static const int dpadRight = 0x0008;
  static const int start = 0x0010;
  static const int back = 0x0020;
  static const int leftThumb = 0x0040;
  static const int rightThumb = 0x0080;
  static const int leftShoulder = 0x0100;
  static const int rightShoulder = 0x0200;
  static const int a = 0x1000;
  static const int b = 0x2000;
  static const int x = 0x4000;
  static const int y = 0x8000;
}

class XInputBinding {
  late final XInputGetStateDart _getState;
  bool _isAvailable = false;

  XInputBinding() {
    try {
      final xinput = DynamicLibrary.open('xinput1_4.dll');
      _getState = xinput.lookupFunction<XInputGetStateNative, XInputGetStateDart>('XInputGetState');
      _isAvailable = true;
    } catch (e) {
      _isAvailable = false;
      // Log warning — XInput not available (not on Windows or DLL missing)
    }
  }

  bool get isAvailable => _isAvailable;

  /// Returns null if controller not connected. Returns XInputState if connected.
  XInputState? getState(int controllerIndex) {
    if (!_isAvailable) return null;
    final pState = calloc<XInputState>();
    try {
      final result = _getState(controllerIndex, pState);
      if (result == 0) return pState.ref; // ERROR_SUCCESS
      return null; // ERROR_DEVICE_NOT_CONNECTED
    } finally {
      calloc.free(pState);
    }
  }
}
```

### 8.2 `lib/platform/xinput/xinput_controller.dart` (Windows only)

**Purpose**: Polls XInput at 60Hz, translates gamepad state into Flutter key events and actions.

```dart
class XInputController {
  XInputController(this._binding);
  final XInputBinding _binding;
  Timer? _pollTimer;
  int _previousButtons = 0;
  int _previousPacketNumber = 0;

  // Callbacks
  void Function(LogicalKeyboardKey key)? onButtonDown;
  void Function(LogicalKeyboardKey key)? onButtonUp;
  void Function(double leftTrigger, double rightTrigger)? onTriggers; // 0.0–1.0
  void Function(double x, double y)? onLeftStick;  // -1.0 to 1.0
  void Function(double x, double y)? onRightStick;

  void start() {
    if (!_binding.isAvailable) return;
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60Hz
      (_) => _poll(),
    );
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _poll() {
    final state = _binding.getState(0); // Player 1
    if (state == null) return;
    if (state.dwPacketNumber == _previousPacketNumber) return; // No change
    _previousPacketNumber = state.dwPacketNumber;

    final buttons = state.gamepad.wButtons;
    final changed = buttons ^ _previousButtons;

    // For each button in XInputButtons, check if it changed:
    // If (changed & bit != 0): button state changed
    //   If (buttons & bit != 0): button pressed → onButtonDown
    //   Else: button released → onButtonUp

    // Map XInput buttons to LogicalKeyboardKey:
    // A → LogicalKeyboardKey.gameButtonA (or Enter as fallback)
    // B → LogicalKeyboardKey.gameButtonB (or Escape)
    // X → LogicalKeyboardKey.gameButtonX
    // Y → LogicalKeyboardKey.gameButtonY
    // D-pad → arrow keys
    // Start → LogicalKeyboardKey.gameButtonStart (or space/play-pause media key)
    // Back → LogicalKeyboardKey.gameButtonSelect
    // LB → LogicalKeyboardKey.gameButtonLeft1
    // RB → LogicalKeyboardKey.gameButtonRight1

    _previousButtons = buttons;

    // Triggers (analog 0-255 → 0.0-1.0)
    final lt = state.gamepad.bLeftTrigger / 255.0;
    final rt = state.gamepad.bRightTrigger / 255.0;
    if (lt > 0.1 || rt > 0.1) { // Dead zone
      onTriggers?.call(lt, rt);
    }

    // Sticks (analog -32768 to 32767, with dead zone ~7849)
    // Normalize and call onLeftStick / onRightStick
  }
}
```

**Integration**: A top-level provider creates `XInputController` on app start (Windows only). Trigger callbacks adjust volume (LT=down, RT=up). Right stick horizontal maps to seek. Stick callbacks generate simulated scroll events for list scrolling.

### 8.3 `lib/platform/xinput/gamepad_input_handler.dart`

**Purpose**: Bridges `XInputController` events with Flutter's focus system. Dispatches synthesized `KeyEvent`s to `ServicesBinding.instance.keyboard` or uses `Actions`/`Shortcuts` integration.

For button mapping (A=confirm, B=back, etc.), this handler interprets `XInputController` callbacks and:
- Dispatches `RawKeyDownEvent` / `RawKeyUpEvent` with appropriate `LogicalKeyboardKey` to Flutter's key event pipeline
- Handles LB/RB for tab switching by notifying the current page's tab controller
- Handles Start button for play/pause by calling `playbackNotifier.togglePlayPause()`
- Handles triggers for volume by calling `playbackNotifier.setVolume()` with analog value mapping

### 8.4 `lib/platform/smtc/smtc_binding.dart` + `smtc_controller.dart` (Windows only)

**Purpose**: System Media Transport Controls integration per REQUIREMENTS §10.4 file structure. `smtc_binding.dart` wraps the `smtc_windows` package. `smtc_controller.dart` provides the high-level API consumed by providers.

Uses `smtc_windows` package.

```dart
class SmtcHandler {
  SMTCWindows? _smtc;

  Future<void> initialize() async {
    _smtc = SMTCWindows(
      config: const SMTCConfig(
        fastForwardEnabled: true,
        rewindEnabled: true,
        nextEnabled: true,
        prevEnabled: true,
        playEnabled: true,
        pauseEnabled: true,
        stopEnabled: false,
      ),
    );

    _smtc!.buttonPressStream.listen((event) {
      switch (event) {
        case PressedButton.play: // → playbackNotifier.play()
        case PressedButton.pause: // → playbackNotifier.pause()
        case PressedButton.next: // → playbackNotifier.skipNext()
        case PressedButton.previous: // → playbackNotifier.skipPrevious()
        case PressedButton.fastForward: // → playbackNotifier.seekRelative(10000)
        case PressedButton.rewind: // → playbackNotifier.seekRelative(-10000)
        default: break;
      }
    });
  }

  void updateNowPlaying(Song song) {
    _smtc?.updateMetadata(MusicMetadata(
      title: song.title,
      artist: song.artist,
      album: song.album,
      thumbnail: song.artCachePath != null ? 'file://${song.artCachePath}' : null,
    ));
  }

  void updatePlaybackState(bool isPlaying, Duration position) {
    _smtc?.setPlaybackStatus(isPlaying ? PlaybackStatus.playing : PlaybackStatus.paused);
    _smtc?.setPosition(position);
  }

  void dispose() {
    _smtc?.dispose();
  }
}
```

### 8.5 `lib/platform/media_keys/media_key_handler.dart`

**Purpose**: Cross-platform media key handling for when XInput/SMTC is not available (macOS, Linux, or Windows without gamepad).

On **macOS**: Use platform channel to register for `MPRemoteCommandCenter` events.
On **Linux**: Use D-Bus MPRIS to receive media commands.

Provides a unified interface:
```dart
abstract class MediaKeyHandler {
  void Function()? onPlay;
  void Function()? onPause;
  void Function()? onNext;
  void Function()? onPrevious;
  void Function()? onPlayPause;
  Future<void> initialize();
  void dispose();
}
```

Factory constructor selects platform-specific implementation.

### 8.5a `lib/platform/nav_sounds/nav_sound_player.dart`

**Purpose**: UI navigation sounds system (per REQUIREMENTS §FL-INPUT-005 and §FL-INPUT-006).

**Assets** (bundled in `assets/sounds/`):
- `navigate.wav` — soft tick, ~50ms, played on focus change
- `select.wav` — confirmation chirp, ~80ms, played on A button press
- `back.wav` — descending tone, ~60ms, played on B button press
- `error.wav` — low buzz, ~100ms, played on invalid action

All WAV format, 22kHz, 16-bit mono. Total < 100KB.

**Sound level** (per REQUIREMENTS): 3-position toggle — `off` (0%), `quiet` (50%), `normal` (100%). Stored in settings KV as `nav_sound_level`: `"off"` | `"quiet"` | `"normal"`. Default: `"normal"`. Independent from music volume.

```dart
enum NavSoundType { navigate, select, back, error }
enum NavSoundLevel { off, quiet, normal }

class NavSoundPlayer {
  // On Windows: use Win32 `PlaySound` API via dart:ffi (fire-and-forget, separate from music stream)
  // On macOS/Linux: use a second lightweight AudioPlayer instance dedicated to UI sounds
  
  NavSoundLevel _level = NavSoundLevel.normal;

  void setLevel(NavSoundLevel level) { _level = level; }
  
  void play(NavSoundType type) {
    if (_level == NavSoundLevel.off) return;
    final volume = _level == NavSoundLevel.quiet ? 0.5 : 1.0;
    // Platform-specific playback at the given volume
  }
  
  void dispose() { /* Clean up audio player instance */ }
}
```

**Integration**: Injected via Riverpod provider. FocusHighlight widget calls `play(NavSoundType.navigate)` on focus gain. Button handlers call `play(NavSoundType.select)` on A press, `play(NavSoundType.back)` on B press.

### 8.6 `lib/platform/macos/now_playing_handler.dart` (macOS only)

**Purpose**: Updates macOS `MPNowPlayingInfoCenter` with current track info. Uses `MethodChannel` to bridge to Swift code in `macos/Runner/`.

### 8.7 `lib/platform/system_tray/system_tray_handler.dart`

**Purpose**: System tray icon with right-click menu (Play/Pause, Next, Previous, Show/Hide, Quit).

Uses `system_tray` package.

```dart
class SystemTrayHandler {
  final SystemTray _tray = SystemTray();

  Future<void> initialize() async {
    await _tray.initSystemTray(
      title: 'Music FSE',
      iconPath: 'assets/branding/icon/app_icon.ico', // .ico on Windows, .png on others
    );

    final menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Play/Pause', onClicked: (item) { /* toggle */ }),
      MenuItemLabel(label: 'Next Track', onClicked: (item) { /* skip next */ }),
      MenuItemLabel(label: 'Previous Track', onClicked: (item) { /* skip prev */ }),
      MenuSeparator(),
      MenuItemLabel(label: 'Show', onClicked: (item) { /* show window */ }),
      MenuItemLabel(label: 'Quit', onClicked: (item) { /* quit app */ }),
    ]);
    await _tray.setContextMenu(menu);

    _tray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        // Show/focus window
      }
    });
  }

  void updateTooltip(String text) {
    _tray.setToolTip(text);
  }

  void dispose() {
    _tray.destroy();
  }
}
```

### 8.8 `lib/platform/window/window_manager_helper.dart`

**Purpose**: Window management utilities using `window_manager` package. Sets minimum size, handles custom title bar drag, window controls.

```dart
class WindowManagerHelper {
  static Future<void> initialize() async {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(800, 500),
      center: true,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden, // Custom title bar
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  static Future<void> minimize() => windowManager.minimize();
  static Future<void> maximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }
  static Future<void> close() => windowManager.close();
  static Future<void> startDragging() => windowManager.startDragging();
}
```

### 8.9 `lib/platform/single_instance/single_instance.dart` (Windows only)

**Purpose**: Named mutex to enforce single app instance. If another instance is detected, bring existing window to front and exit.

Uses `dart:ffi` to call `CreateMutexW` from `kernel32.dll`. If `GetLastError()` returns `ERROR_ALREADY_EXISTS`, exit.

### 8.10 `lib/platform/keyboard/keyboard_shortcut_handler.dart`

**Purpose**: Global keyboard shortcut handler for desktop keyboard users (per REQUIREMENTS.md 4.1 FL-INPUT-003). Wraps the root widget tree in a `Shortcuts` + `Actions` widget (or uses `HardwareKeyboard` listener).

**Key bindings**:
- `Space` → Play/Pause toggle
- `Ctrl+Right` → Next track
- `Ctrl+Left` → Previous track
- `Ctrl+Up` → Volume up 5%
- `Ctrl+Down` → Volume down 5%
- `Ctrl+F` or `/` → Focus search input (navigate to `/search`)
- `Escape` → Back / close overlay / unfocus search
- `Ctrl+Q` → Quit app
- `F11` → Toggle fullscreen

**Implementation**: A stateless wrapper widget `KeyboardShortcutHandler` that wraps `child` with `Shortcuts` + `Actions`. Registered once at the top of the widget tree (in `main.dart` or `AppShell`). Actions call the corresponding Riverpod providers (playback, volume, router).

### 8.11 `lib/platform/file_association/file_association_handler.dart`

**Purpose**: Handle OS file association events — when a user double-clicks an audio file in their file manager and the OS opens it with Music FSE (per REQUIREMENTS.md 4.3 FL-SYS-003).

**Behavior**:
- On app launch: Check launch arguments for a file path. If present, add the file to the queue and begin playback.
- On running app: Listen for platform channel messages (Windows: WM_COPYDATA or custom protocol handler; macOS: `NSApplicationDelegate.application(_:open:)`; Linux: D-Bus activation or command-line args via single-instance relay).
- When a file is received: Look up the file in the library DB. If found, play it. If not found, create a temporary `Song` from metadata extraction and play it (do not add to library permanently).

**Platform-specific**:
- Windows: Register file associations in installer (`.mp3`, `.flac`, `.wav`, `.ogg`, `.m4a`, `.aac`, `.wma`, `.opus`). Relay file path from second instance via named pipe or shared memory to the running instance.
- macOS: Register UTIs in `Info.plist`. Handle via `FlutterAppDelegate` method channel.
- Linux: Register `.desktop` file with `MimeType` entries. Handle via D-Bus activation.

<!-- END PHASE 8 -->

## Phase 9: App Entry, Routing & Finalization

### 9.1 `lib/main.dart`

**Purpose**: App entry point. Initializes platform services, creates `ProviderScope`, runs the app.

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/utils/logger.dart';
import 'platform/window/window_manager_helper.dart';
import 'platform/single_instance/single_instance.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  AppLogger.initialize();

  // Single instance check (Windows)
  if (Platform.isWindows) {
    if (!SingleInstance.acquire()) {
      // Another instance running — focus it and exit
      exit(0);
    }
  }

  // Window manager setup
  await WindowManagerHelper.initialize();

  // Run app
  runApp(
    const ProviderScope(
      child: MusicFseApp(),
    ),
  );
}
```

### 9.2 `lib/presentation/app.dart`

**Purpose**: Root `MaterialApp.router` widget. Configures theme, locale, router. Initializes platform services lazily.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/router/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'widgets/toast_notification.dart';

class MusicFseApp extends ConsumerStatefulWidget {
  const MusicFseApp({super.key});
  @override
  ConsumerState<MusicFseApp> createState() => _MusicFseAppState();
}

class _MusicFseAppState extends ConsumerState<MusicFseApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPlatformServices();
  }

  Future<void> _initPlatformServices() async {
    // Lazy init: XInput controller, SMTC handler, media key handler, system tray
    // These are initialized via providers that self-start when first read
    // Read them to trigger initialization:
    ref.read(smtcHandlerProvider);
    ref.read(systemTrayHandlerProvider);
    if (Platform.isWindows) {
      ref.read(xinputControllerProvider);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      // Background mode: stop XInput polling, stop UI rendering, stop tickers
      ref.read(xinputControllerProvider.notifier).stop();
    } else if (state == AppLifecycleState.resumed) {
      // Foreground: restart XInput, resume UI
      ref.read(xinputControllerProvider.notifier).start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Music FSE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(themeState.accentColor),
      darkTheme: AppTheme.darkTheme(themeState.accentColor),
      themeMode: switch (themeState.mode) {
        ThemeModeSetting.dark => ThemeMode.dark,
        ThemeModeSetting.light => ThemeMode.light,
        ThemeModeSetting.system => ThemeMode.system,
      },
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        // Wrap with global overlays: toast notifications, volume OSD
        return Stack(
          children: [
            child!,
            const Positioned(
              bottom: 130, // Above mini player + button hints
              left: 0,
              right: 0,
              child: Center(child: ToastNotificationOverlay()),
            ),
            const Positioned(
              top: 24,
              right: 24,
              child: VolumeOsd(),
            ),
          ],
        );
      },
    );
  }
}
```

### 9.3 `lib/core/router/app_router.dart`

**Purpose**: GoRouter configuration with all routes, transitions, and redirect logic.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  // Watch scan folders to determine if onboarding is needed
  final hasFoldersAsync = ref.watch(hasScanFoldersProvider);

  // While the async provider is loading, show a splash/loading screen to avoid
  // flash-of-onboarding before the database loads
  final hasFolders = hasFoldersAsync.valueOrNull;
  final isLoading = hasFoldersAsync.isLoading;

  return GoRouter(
    initialLocation: isLoading ? '/splash' : (hasFolders == true ? '/home' : '/onboarding'),
    redirect: (context, state) {
      if (isLoading && state.uri.path != '/splash') return '/splash';
      if (!isLoading && state.uri.path == '/splash') {
        return hasFolders == true ? '/home' : '/onboarding';
      }
      // If no scan folders and not already on onboarding, redirect to onboarding
      if (hasFolders != true && state.uri.path != '/onboarding' && !isLoading) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      // Splash (shown while async providers load, prevents flash-of-onboarding)
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const MaterialPage(
          child: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      ),

      // Onboarding (standalone, no shell)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingPage(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),

      // Main shell with nav rail + mini player
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home (with recently-played as sub-route to preserve shell)
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const HomePage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
              routes: [
                GoRoute(
                  path: 'recently-played',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const RecentlyPlayedPage(),
                    transitionsBuilder: _fadeSlideTransition,
                  ),
                ),
              ],
            ),
          ]),

          // Branch 1: Library (with sub-routes for detail pages)
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const LibraryPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
              routes: [
                GoRoute(
                  path: 'album/:albumName/:albumArtist',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: AlbumDetailPage(
                      albumName: Uri.decodeComponent(state.pathParameters['albumName']!),
                      albumArtist: Uri.decodeComponent(state.pathParameters['albumArtist']!),
                    ),
                    transitionsBuilder: _fadeSlideTransition,
                  ),
                ),
                GoRoute(
                  path: 'artist/:artistName',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: ArtistDetailPage(
                      artistName: Uri.decodeComponent(state.pathParameters['artistName']!),
                    ),
                    transitionsBuilder: _fadeSlideTransition,
                  ),
                ),
                GoRoute(
                  path: 'genre/:genreName',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: GenreDetailPage(
                      genreName: Uri.decodeComponent(state.pathParameters['genreName']!),
                    ),
                    transitionsBuilder: _fadeSlideTransition,
                  ),
                ),
              ],
            ),
          ]),

          // Branch 2: Search
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/search',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const SearchPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
            ),
          ]),

          // Branch 3: Playlists
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/playlists',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const PlaylistListPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: PlaylistDetailPage(
                      playlistId: int.parse(state.pathParameters['id']!),
                    ),
                    transitionsBuilder: _fadeSlideTransition,
                  ),
                ),
              ],
            ),
          ]),

          // Branch 4: Favorites
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/favorites',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const FavoritesPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
            ),
          ]),

          // Branch 5: Settings
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const SettingsPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
            ),
          ]),
        ],
      ),

      // Now Playing (full screen, OUTSIDE the shell — no nav rail or mini player visible)
      // This is intentional: Now Playing replaces the entire screen. The mini player
      // is part of ShellPage and not shown here. B button navigates back to the shell.
      GoRoute(
        path: '/now-playing',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NowPlayingPage(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),

      // Equalizer (full-screen overlay per REQUIREMENTS §6.3.7a)
      GoRoute(
        path: '/equalizer',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EqualizerPage(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),
    ],
  );
}

// Standard 250ms easeInOut slide+fade transition per spec
Widget _fadeSlideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.02, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation),
      child: child,
    ),
  );
}
```

**Route transition**: All routes use `CustomTransitionPage` with the `_fadeSlideTransition` builder — 250ms easeInOut, subtle horizontal slide (2% offset) + fade.

### 9.4 Build & Code Generation

After all files are created, run these commands:

```bash
# 1. Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# 2. Generate Riverpod providers
# (covered by step 1 since build_runner handles all generators)

# 3. Generate Freezed classes
# (covered by step 1)

# 4. Generate localization files
flutter gen-l10n

# 5. Verify no analysis errors
flutter analyze

# 6. Run tests
flutter test
```

### 9.5 Implementation Order Summary

For optimal dependency resolution, implement files in this exact order:

1. **Phase 1**: `pubspec.yaml`, `l10n.yaml`, `analysis_options.yaml`, `build.yaml`, create all directories
2. **Phase 2**: Constants, strings, ARB, error types, Result, extensions, logger, debouncer, theme
3. **Phase 3**: Domain entities (Freezed), repository interfaces, use cases, service interfaces
4. **Phase 4**: Database tables, connection, DAOs, mappers, repository implementations, file scanner, metadata extractor
5. **Phase 5**: Providers — database first, then repositories, use cases, then feature providers (theme, playback, library, etc.)
6. **Phase 6**: Shared widgets — `FocusHighlight` first (everything depends on it), then `EmptyState`, `LoadingIndicator`, then complex widgets (nav rail, mini player, context menu, etc.)
7. **Phase 7**: Pages — `ShellPage` first, then `OnboardingPage`, then `HomePage`, then `LibraryPage` + tabs, then detail pages, then remaining pages
8. **Phase 8**: Platform layer — XInput binding, controller, gamepad handler, SMTC, media keys, system tray, window manager, single instance
9. **Phase 9**: `main.dart`, `app.dart`, `app_router.dart`, run code generation, analyze, test

### 9.6 Key Cross-Cutting Concerns

**Focus Management Pattern**: Every page follows this template:
```dart
class SomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SomePage> createState() => _SomePageState();
}

class _SomePageState extends ConsumerState<SomePage> {
  late final FocusNode _defaultFocus;

  @override
  void initState() {
    super.initState();
    _defaultFocus = FocusNode(debugLabel: 'SomePage-default');
    // Request focus after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _defaultFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _defaultFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: KeyboardListener(
        focusNode: FocusNode()..skipTraversal = true,
        onKeyEvent: (event) {
          // B button → GoRouter.of(context).pop() or context.go('/home')
        },
        child: /* page content */,
      ),
    );
  }
}
```

**Context Menu Pattern**: Any widget that supports X button / right-click:
```dart
FocusHighlight(
  focusNode: _node,
  onPressed: () { /* primary action */ },
  onSecondary: () {
    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    showContextMenu(
      context,
      position: position,
      items: [ /* ContextMenuItem list */ ],
    );
  },
  child: /* widget content */,
)
```

**Toast Pattern**: After any destructive or confirmatory action:
```dart
ref.read(toastNotifierProvider.notifier).show(
  'Song added to queue',
);

// For destructive actions with undo:
ref.read(toastNotifierProvider.notifier).show(
  'Removed from playlist',
  undoAction: () { /* re-add */ },
);
```

---

*End of Implementation Plan*

<!-- END PHASE 9 -->
