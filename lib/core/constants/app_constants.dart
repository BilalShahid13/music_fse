/// All magic numbers, sizes, durations, and limits used across the app.
/// Never inline these values in widget code — always reference this class.
abstract final class AppConstants {
  // ---------------------------------------------------------------------------
  // App identity
  // ---------------------------------------------------------------------------
  static const String appTitle = 'Music FSE';
  static const String packageName = 'com.musicfse.player';
  static const String appVersion = '1.0.0';
  static const String appCreatorName = 'Bilal Shahid';

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------
  static const double minWindowWidth = 800.0;
  static const double minWindowHeight = 500.0;
  static const double navRailExpandedWidth = 220.0;
  static const double navRailCollapsedWidth = 72.0;
  static const double layoutBreakpoint = 1200.0;
  static const double screenEdgePadding = 20.0;
  static const double miniPlayerHeight = 84.0;
  static const double buttonHintsHeight = 44.0;
  static const double titleBarHeight = 36.0;
  static const double queuePanelWidth = 340.0;

  // ---------------------------------------------------------------------------
  // Focusable minimums (WCAG + CLAUDE.md §2.2)
  // ---------------------------------------------------------------------------
  static const double minFocusableSize = 48.0;
  static const double listTileHeight = 56.0;
  static const double gridCardWidth = 165.0;
  static const double gridCardHeight = 210.0;
  static const double gridCardScrollRowWidth = 210.0;
  static const double focusableSpacing = 8.0;

  // ---------------------------------------------------------------------------
  // Cards & radii
  // ---------------------------------------------------------------------------
  static const double cardRadius = 16.0;
  static const double cardRadiusSm = 12.0;
  static const double btnRadius = 12.0;
  static const double cardPadding = 12.0;

  // ---------------------------------------------------------------------------
  // Focus indicator (3px border, dual scale, glow — per REQUIREMENTS §6.4)
  // ---------------------------------------------------------------------------
  static const double focusBorderWidth = 2.0;
  static const double focusScaleTile = 1.02;
  static const double focusScaleCard = 1.05;
  static const double focusGlowBlur = 0.0;
  static const double focusGlowSpread = 2.0;
  static const double focusGlowOpacity = 0.15;
  static const int focusScrollDurationMs = 180;

  // ---------------------------------------------------------------------------
  // Animation durations (milliseconds)
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Toast
  // ---------------------------------------------------------------------------
  static const int toastDurationSec = 3;

  // ---------------------------------------------------------------------------
  // Playback — consecutive missing threshold
  // ---------------------------------------------------------------------------
  static const int consecutiveMissingThreshold = 3;

  // ---------------------------------------------------------------------------
  // Mini player
  // ---------------------------------------------------------------------------
  static const double miniPlayerArtSize = 48.0;
  static const double miniPlayerPlayBtnSize = 34.0;

  // ---------------------------------------------------------------------------
  // Now Playing (responsive: 65% of viewport width)
  // ---------------------------------------------------------------------------
  static const double nowPlayingArtMinSize = 280.0;
  static const double nowPlayingArtMaxSize = 500.0;
  static const double nowPlayingArtViewportFraction = 0.65;
  static const double nowPlayingPlayBtnSize = 56.0;

  // ---------------------------------------------------------------------------
  // Song tile
  // ---------------------------------------------------------------------------
  static const double songTileArtSize = 44.0;
  static const double songTilePadding = 14.0;

  // ---------------------------------------------------------------------------
  // Queue
  // ---------------------------------------------------------------------------
  static const double queueItemArtSize = 36.0;

  // ---------------------------------------------------------------------------
  // Detail header
  // ---------------------------------------------------------------------------
  static const double detailArtSize = 200.0;

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------
  static const int searchHistoryMax = 10;
  static const int searchResultsPerCategory = 5;

  // ---------------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------------
  static const int playCountThresholdMs = 30000;
  static const double playCountThresholdPercent = 0.5;
  static const int seekStepMs = 5000;
  static const int recentlyPlayedMax = 100;
  static const double defaultVolume = 0.7;
  static const int queueSaveDebounceSeconds = 2;

  // ---------------------------------------------------------------------------
  // Image cache
  // ---------------------------------------------------------------------------
  static const int imageCacheMaxImages = 200;
  static const int imageCacheMaxSizeMB = 50;

  // ---------------------------------------------------------------------------
  // XInput
  // ---------------------------------------------------------------------------
  static const int xinputPollHz = 60;

  // ---------------------------------------------------------------------------
  // Context menu & dialogs
  // ---------------------------------------------------------------------------
  static const double contextMenuWidth = 240.0;
  static const double dialogWidth = 380.0;
  static const double dialogPadding = 24.0;

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------
  static const double onboardingCardWidth = 500.0;

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------
  static const double colorChipSize = 28.0;
  static const bool defaultNavSoundEnabled = false;
  static const double defaultNavSoundLevel = 1.0;

  // ---------------------------------------------------------------------------
  // Equalizer
  // ---------------------------------------------------------------------------
  static const int eqBandCount = 10;
  static const double eqSliderHeight = 180.0;
  static const double eqSliderWidth = 6.0;
  static const double eqThumbSize = 16.0;
  static const List<String> eqBandLabels = [
    '60',
    '170',
    '310',
    '600',
    '1k',
    '3k',
    '6k',
    '12k',
    '14k',
    '16k',
  ];
  static const List<double> eqBandFrequencies = [
    60,
    170,
    310,
    600,
    1000,
    3000,
    6000,
    12000,
    14000,
    16000,
  ];

  // ---------------------------------------------------------------------------
  // Playlist
  // ---------------------------------------------------------------------------
  static const int playlistNameMaxLength = 100;
  static const String playlistDefaultName = 'My Playlist';
  static const int addToPlaylistMaxVisible = 8;

  // ---------------------------------------------------------------------------
  // Supported audio formats
  // ---------------------------------------------------------------------------
  static const List<String> supportedAudioExtensions = [
    '.mp3',
    '.flac',
    '.wav',
    '.aac',
    '.m4a',
    '.ogg',
    '.wma',
    '.opus',
    '.aiff',
    '.alac',
  ];

  // ---------------------------------------------------------------------------
  // Default accent color
  // ---------------------------------------------------------------------------
  /// The default accent color value (Dark Orange). Stored as ARGB int to avoid
  /// importing Flutter's [Color] into this pure-Dart constants file.
  static const int defaultAccentColorValue = 0xFFC76E00;

  // ---------------------------------------------------------------------------
  // Accent color palette (ARGB hex values — user-configurable in settings)
  // ---------------------------------------------------------------------------
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
