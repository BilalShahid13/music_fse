// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Music FSE';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSearch => 'Search';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navSettings => 'Settings';

  @override
  String get libTabSongs => 'Songs';

  @override
  String get libTabAlbums => 'Albums';

  @override
  String get libTabArtists => 'Artists';

  @override
  String get libTabGenres => 'Genres';

  @override
  String get libTabFolders => 'Folders';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeQuickResume => 'Quick Resume';

  @override
  String get homeRecentlyPlayed => 'Recently Played';

  @override
  String get homeMostPlayed => 'Most Played';

  @override
  String get homeRecentlyAdded => 'Recently Added';

  @override
  String get homeQuickAccess => 'Quick Access';

  @override
  String get homeRecommended => 'Recommended';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get sortNameAZ => 'Name (A–Z)';

  @override
  String get sortNameZA => 'Name (Z–A)';

  @override
  String get sortArtist => 'Artist';

  @override
  String get sortAlbum => 'Album';

  @override
  String get sortDateAdded => 'Date Added';

  @override
  String get sortDateUpdated => 'Date Updated';

  @override
  String get sortYear => 'Year';

  @override
  String get sortDuration => 'Duration';

  @override
  String get sortTrackNumber => 'Track Number';

  @override
  String get playAll => 'Play All';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get upNext => 'Up Next';

  @override
  String get queue => 'Queue';

  @override
  String get clearQueue => 'Clear Queue';

  @override
  String clearQueueConfirm(int count) {
    return 'Clear $count tracks from queue?';
  }

  @override
  String get searchPlaceholder => 'Search songs, artists, albums…';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noResults => 'No results';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String showAll(int count) {
    return 'Show all $count';
  }

  @override
  String songsResults(int count) {
    return '$count songs';
  }

  @override
  String artistsResults(int count) {
    return '$count artists';
  }

  @override
  String albumsResults(int count) {
    return '$count albums';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get noFavoritesMessage =>
      'Songs you mark as favorite will appear here.';

  @override
  String get browseLibrary => 'Browse Library';

  @override
  String get smartPlaylists => 'Smart Playlists';

  @override
  String get yourPlaylists => 'Your Playlists';

  @override
  String get newPlaylist => 'New Playlist';

  @override
  String get importM3U => 'Import M3U';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get recentlyAdded => 'Recently Added';

  @override
  String get mostPlayed => 'Most Played';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLibrary => 'Library';

  @override
  String get settingsPlayback => 'Playback';

  @override
  String get settingsControls => 'Controls';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsAccentColor => 'Accent Color';

  @override
  String get settingsMusicFolders => 'Music Folders';

  @override
  String get settingsRescanLibrary => 'Rescan Library';

  @override
  String get settingsCrossfade => 'Crossfade';

  @override
  String get settingsReplayGain => 'Replay Gain';

  @override
  String get settingsNavigationSounds => 'Navigation Sounds';

  @override
  String get settingsAnimateFocusScrolling => 'Animate Focus Scrolling';

  @override
  String get settingsGamepadSensitivity => 'Gamepad Sensitivity';

  @override
  String get settingsCloseToTray => 'Close to Tray';

  @override
  String get settingsStartWithSystem => 'Start with System';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get settingsOpenSourceProject =>
      'Open source project for handheld-first desktop listening.';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get navSoundOff => 'Off';

  @override
  String get navSoundQuiet => 'Quiet';

  @override
  String get navSoundNormal => 'Normal';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get eqSaveCustom => 'Save as Custom';

  @override
  String get eqReset => 'Reset';

  @override
  String get eqPresetFlat => 'Flat';

  @override
  String get eqPresetBassBoost => 'Bass Boost';

  @override
  String get eqPresetTrebleBoost => 'Treble Boost';

  @override
  String get eqPresetVocal => 'Vocal';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetElectronic => 'Electronic';

  @override
  String get eqPresetClassical => 'Classical';

  @override
  String get eqPresetCustom => 'Custom';

  @override
  String get ctxPlay => 'Play';

  @override
  String get ctxPlayNext => 'Play Next';

  @override
  String get ctxAddToQueue => 'Add to Queue';

  @override
  String get ctxAddToPlaylist => 'Add to Playlist';

  @override
  String get selectAll => 'Select All';

  @override
  String get ctxNewPlaylist => 'New Playlist';

  @override
  String get ctxToggleFavorite => 'Favorite';

  @override
  String get ctxGoToArtist => 'Go to Artist';

  @override
  String get ctxGoToAlbum => 'Go to Album';

  @override
  String get ctxRemoveFromQueue => 'Remove from Queue';

  @override
  String get ctxRemoveFromPlaylist => 'Remove from Playlist';

  @override
  String get ctxReorder => 'Reorder';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get confirm => 'Confirm';

  @override
  String get quit => 'Quit';

  @override
  String get minimizeToTray => 'Minimize to Tray';

  @override
  String get keepRunning => 'Keep Running';

  @override
  String get keepRunningDesc =>
      'Music FSE will continue playing in the background.';

  @override
  String get rememberChoice => 'Remember my choice';

  @override
  String get undo => 'Undo';

  @override
  String get addedToQueue => 'Added to queue';

  @override
  String addedManyToQueue(int count) {
    return 'Added $count songs to queue';
  }

  @override
  String get removedFromQueue => 'Removed from queue';

  @override
  String addedToPlaylist(String name) {
    return 'Added to \"$name\"';
  }

  @override
  String addedManyToPlaylist(int count, String name) {
    return 'Added $count songs to \"$name\"';
  }

  @override
  String removedFromPlaylist(String name) {
    return 'Removed from \"$name\"';
  }

  @override
  String get removedFromFavorites => 'Removed from Favorites';

  @override
  String get addedToFavorites => 'Added to Favorites';

  @override
  String get playlistCreated => 'Playlist created';

  @override
  String get playlistDeleted => 'Playlist deleted';

  @override
  String get playlistRenamed => 'Playlist renamed';

  @override
  String get noMusicYet => 'No music yet';

  @override
  String get noMusicMessage =>
      'Add a folder containing your music files to get started.';

  @override
  String get addMusicFolder => 'Add Music Folder';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String get queueEmptyMessage => 'Songs you add will appear here.';

  @override
  String get onboardingWelcome => 'Welcome to Music FSE';

  @override
  String get onboardingDesc =>
      'Your full-screen music experience for handheld gaming PCs.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingDone => 'Done';

  @override
  String get onboardingSelectFolders => 'Add Music Folders';

  @override
  String get onboardingSelectFoldersDesc =>
      'Choose folders where your music is stored. You can add or remove folders later in Settings.';

  @override
  String get onboardingChooseTheme => 'Choose Your Look';

  @override
  String get onboardingChooseThemeDesc =>
      'Pick a theme and accent color. You can change these any time in Settings.';

  @override
  String get onboardingScanProgress => 'Scanning Library';

  @override
  String get onboardingScanProgressDesc =>
      'Finding your music and loading metadata…';

  @override
  String get hintSelect => 'Select';

  @override
  String get hintBack => 'Back';

  @override
  String get hintOptions => 'Options';

  @override
  String get hintFavorite => 'Favorite';

  @override
  String get hintPlay => 'Play';

  @override
  String get hintOpen => 'Open';

  @override
  String get hintClose => 'Close';

  @override
  String get hintPrevTrack => 'Prev';

  @override
  String get hintNextTrack => 'Next';

  @override
  String get hintQueue => 'Queue';

  @override
  String get hintSearch => 'Search';

  @override
  String get scanComplete => 'Scan complete';

  @override
  String scanFoundSongs(int count) {
    return 'Found $count songs';
  }

  @override
  String scanFoldersInaccessible(int count) {
    return '$count folder(s) could not be accessed';
  }

  @override
  String get artist => 'Artist';

  @override
  String get album => 'Album';

  @override
  String get genre => 'Genre';

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String get unknownAlbum => 'Unknown Album';

  @override
  String get variousArtists => 'Various Artists';

  @override
  String addedXOfYSongs(int added, int total, int dupes) {
    return 'Added $added of $total songs ($dupes duplicates skipped)';
  }

  @override
  String get fileMissing => 'File not found';

  @override
  String get fileMissingMessage =>
      'The file for this track could not be found. It may have been moved or deleted.';

  @override
  String get rescanLibrary => 'Rescan Library';

  @override
  String get consecutiveMissingPrompt =>
      'Several tracks couldn\'t be found. Would you like to rescan your library?';

  @override
  String get playlistNameLabel => 'Playlist Name';

  @override
  String get playlistNameHint => 'Enter a name…';

  @override
  String get createPlaylistTitle => 'New Playlist';

  @override
  String get renamePlaylistTitle => 'Rename Playlist';

  @override
  String get songs => 'Songs';

  @override
  String get albums => 'Albums';

  @override
  String get artists => 'Artists';

  @override
  String get playlists => 'Playlists';

  @override
  String tracks(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tracks',
      one: '1 track',
    );
    return '$_temp0';
  }

  @override
  String songsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString songs',
      one: '1 song',
    );
    return '$_temp0';
  }

  @override
  String queueSaveDefaultName(String date) {
    return 'Queue — $date';
  }

  @override
  String get queueSaveTitle => 'Save Queue as Playlist';

  @override
  String get queueSaveHint => 'Playlist name';

  @override
  String get queueSaveConfirm => 'Save';

  @override
  String queueSaveSuccess(String name) {
    return 'Playlist created: $name';
  }

  @override
  String get closeToTrayDialogTitle => 'Keep Music FSE running?';

  @override
  String get closeToTrayDialogBody =>
      'Music FSE will continue playing in the background. You can find it in the system tray.';

  @override
  String get closeToTrayMinimize => 'Minimize to Tray';

  @override
  String get closeToTrayQuit => 'Quit';

  @override
  String get closeToTrayRemember => 'Remember my choice';

  @override
  String get keyboardShortcuts => 'Keyboard Shortcuts';

  @override
  String get editShortcut => 'Edit Shortcut';

  @override
  String pressKeyCombo(String action) {
    return 'Press the key combination for \"$action\"';
  }

  @override
  String shortcutConflict(String action) {
    return 'This key is already used for \"$action\". Reassign?';
  }

  @override
  String get shortcutConflictTitle => 'Shortcut Conflict';

  @override
  String get resetShortcut => 'Reset to Default';

  @override
  String get resetAllShortcuts => 'Reset All to Defaults';

  @override
  String get shortcutSaved => 'Shortcut updated';

  @override
  String get lyricsComingSoon => 'Lyrics coming soon';

  @override
  String get lyricsComingSoonDesc =>
      'This feature is planned for a future update';

  @override
  String scanningDroppedFiles(int count) {
    return 'Adding $count file(s) to library…';
  }

  @override
  String get ctxAddToFavorites => 'Add to Favorites';

  @override
  String get ctxRemoveFromFavorites => 'Remove from Favorites';

  @override
  String get ctxRename => 'Rename';

  @override
  String get ctxDuplicate => 'Duplicate';

  @override
  String get ctxDeletePlaylist => 'Delete Playlist';

  @override
  String get savePreset => 'Save Preset';

  @override
  String get presetNameHint => 'Preset name';

  @override
  String get trayPlayPause => 'Play / Pause';

  @override
  String get trayNextTrack => 'Next Track';

  @override
  String get trayPreviousTrack => 'Previous Track';

  @override
  String get trayShowApp => 'Show Music FSE';

  @override
  String get trayQuit => 'Quit';

  @override
  String get noPlaylistsYet => 'No Playlists Yet';

  @override
  String get noPlaylistsMessage => 'Create a playlist to organize your music.';

  @override
  String get myPlaylists => 'My Playlists';

  @override
  String get failedToLoadPlaylists => 'Failed to load playlists';

  @override
  String get failedToLoadSongs => 'Failed to load songs';

  @override
  String get failedToLoadFavorites => 'Failed to load favorites';

  @override
  String get noSongs => 'No Songs';

  @override
  String get noSongsMessage => 'Add a music folder in Settings to get started.';

  @override
  String get open => 'Open';

  @override
  String get back => 'Back';

  @override
  String get options => 'Options';

  @override
  String get play => 'Play';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get tryRescanLibrary => 'Try rescanning your library.';

  @override
  String get deletePlaylistBody =>
      'This will permanently delete this playlist. Songs won\'t be removed from your library.';

  @override
  String get newLabel => 'New';

  @override
  String get done => 'Done';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get playlist => 'Playlist';

  @override
  String get playlistIsEmpty => 'Playlist is Empty';

  @override
  String get addSongsFromLibrary => 'Add songs from your library.';

  @override
  String get exitReorder => 'Exit Reorder';

  @override
  String get smartTag => 'Smart';

  @override
  String songCountDuration(int count, String duration) {
    return '$count songs · $duration';
  }

  @override
  String get eqCustom => 'Custom';

  @override
  String get eqBuiltIn => 'Built-in';

  @override
  String get eqSaveAsPreset => 'Save as Preset';

  @override
  String get eqAdjust => 'Adjust';

  @override
  String get eqFailed => 'Failed to load equalizer';

  @override
  String get eqToggle => 'EQ';

  @override
  String get resetAll => 'Reset All';

  @override
  String get shortcutsResetToDefaults => 'Shortcuts reset to defaults';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String get reassign => 'Reassign';

  @override
  String get shortcutUpdated => 'Shortcut updated';

  @override
  String get errorLoadingShortcuts => 'Error loading shortcuts';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get customHex => 'Custom hex';

  @override
  String get apply => 'Apply';
}
