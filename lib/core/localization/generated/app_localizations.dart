import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Music FSE'**
  String get appName;

  /// Navigation item: Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Navigation item: Library
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Navigation item: Search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Navigation item: Playlists
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// Navigation item: Favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// Navigation item: Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Library tab: Songs
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get libTabSongs;

  /// Library tab: Albums
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get libTabAlbums;

  /// Library tab: Artists
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get libTabArtists;

  /// Library tab: Genres
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get libTabGenres;

  /// Library tab: Folders
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get libTabFolders;

  /// Home greeting in the morning
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// Home greeting in the afternoon
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// Home greeting in the evening
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// Home section: Quick Resume
  ///
  /// In en, this message translates to:
  /// **'Quick Resume'**
  String get homeQuickResume;

  /// Home section: Recently Played
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get homeRecentlyPlayed;

  /// Home section: Most Played
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get homeMostPlayed;

  /// Home section: Recently Added
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get homeRecentlyAdded;

  /// Home section: Quick Access
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get homeQuickAccess;

  /// Home section: Recommended
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get homeRecommended;

  /// See all button
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// Sort option: name ascending
  ///
  /// In en, this message translates to:
  /// **'Name (A–Z)'**
  String get sortNameAZ;

  /// Sort option: name descending
  ///
  /// In en, this message translates to:
  /// **'Name (Z–A)'**
  String get sortNameZA;

  /// Sort option: by artist
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get sortArtist;

  /// Sort option: by album
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get sortAlbum;

  /// Sort option: by date added
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get sortDateAdded;

  /// Sort option: by date updated
  ///
  /// In en, this message translates to:
  /// **'Date Updated'**
  String get sortDateUpdated;

  /// Sort option: by year
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get sortYear;

  /// Sort option: by duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sortDuration;

  /// Sort option: by track number
  ///
  /// In en, this message translates to:
  /// **'Track Number'**
  String get sortTrackNumber;

  /// Button: Play All
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get playAll;

  /// Button: Shuffle
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// Now Playing label
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// Up Next label
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get upNext;

  /// Queue label
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// Button: Clear Queue
  ///
  /// In en, this message translates to:
  /// **'Clear Queue'**
  String get clearQueue;

  /// Confirmation prompt for clearing queue
  ///
  /// In en, this message translates to:
  /// **'Clear {count} tracks from queue?'**
  String clearQueueConfirm(int count);

  /// Search input placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search songs, artists, albums…'**
  String get searchPlaceholder;

  /// Section header: Recent Searches
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// Button: Clear All
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Empty state: no search results
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// Empty state message with query
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// Link to show all results in a category
  ///
  /// In en, this message translates to:
  /// **'Show all {count}'**
  String showAll(int count);

  /// Count label for songs in search results
  ///
  /// In en, this message translates to:
  /// **'{count} songs'**
  String songsResults(int count);

  /// Count label for artists in search results
  ///
  /// In en, this message translates to:
  /// **'{count} artists'**
  String artistsResults(int count);

  /// Count label for albums in search results
  ///
  /// In en, this message translates to:
  /// **'{count} albums'**
  String albumsResults(int count);

  /// Favorites section/page title
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Empty state: no favorites
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// Empty state message for favorites
  ///
  /// In en, this message translates to:
  /// **'Songs you mark as favorite will appear here.'**
  String get noFavoritesMessage;

  /// CTA button: Browse Library
  ///
  /// In en, this message translates to:
  /// **'Browse Library'**
  String get browseLibrary;

  /// Section header: smart playlists
  ///
  /// In en, this message translates to:
  /// **'Smart Playlists'**
  String get smartPlaylists;

  /// Section header: Your Playlists
  ///
  /// In en, this message translates to:
  /// **'Your Playlists'**
  String get yourPlaylists;

  /// Button: New Playlist
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get newPlaylist;

  /// Button: Import M3U
  ///
  /// In en, this message translates to:
  /// **'Import M3U'**
  String get importM3U;

  /// Confirmation prompt for deleting a playlist
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deletePlaylistConfirm(String name);

  /// Smart playlist name: Recently Added
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get recentlyAdded;

  /// Smart playlist name: Most Played
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get mostPlayed;

  /// Smart playlist name: Recently Played
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// Settings section: Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Settings section: Library
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get settingsLibrary;

  /// Settings section: Playback
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsPlayback;

  /// Settings section: Controls
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get settingsControls;

  /// Settings section: System
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  /// Settings section: About
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Settings item: Theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Settings item: Accent Color
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settingsAccentColor;

  /// Settings item: Music Folders
  ///
  /// In en, this message translates to:
  /// **'Music Folders'**
  String get settingsMusicFolders;

  /// Settings item: Rescan Library
  ///
  /// In en, this message translates to:
  /// **'Rescan Library'**
  String get settingsRescanLibrary;

  /// Settings item: Crossfade
  ///
  /// In en, this message translates to:
  /// **'Crossfade'**
  String get settingsCrossfade;

  /// Settings item: Replay Gain
  ///
  /// In en, this message translates to:
  /// **'Replay Gain'**
  String get settingsReplayGain;

  /// Settings item: Navigation Sounds
  ///
  /// In en, this message translates to:
  /// **'Navigation Sounds'**
  String get settingsNavigationSounds;

  /// Settings item: Animate Focus Scrolling
  ///
  /// In en, this message translates to:
  /// **'Animate Focus Scrolling'**
  String get settingsAnimateFocusScrolling;

  /// Settings item: Gamepad Sensitivity
  ///
  /// In en, this message translates to:
  /// **'Gamepad Sensitivity'**
  String get settingsGamepadSensitivity;

  /// Settings item: Close to Tray
  ///
  /// In en, this message translates to:
  /// **'Close to Tray'**
  String get settingsCloseToTray;

  /// Settings item: Start with System
  ///
  /// In en, this message translates to:
  /// **'Start with System'**
  String get settingsStartWithSystem;

  /// Settings item: Version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// Settings item: Credits
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get settingsCredits;

  /// Settings about card helper text
  ///
  /// In en, this message translates to:
  /// **'Open source project for handheld-first desktop listening.'**
  String get settingsOpenSourceProject;

  /// Theme option: Dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Theme option: Light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option: System
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Navigation sound option: Off
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get navSoundOff;

  /// Navigation sound option: Quiet
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get navSoundQuiet;

  /// Navigation sound option: Normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get navSoundNormal;

  /// Equalizer page title
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// EQ button: Save as Custom
  ///
  /// In en, this message translates to:
  /// **'Save as Custom'**
  String get eqSaveCustom;

  /// EQ button: Reset
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get eqReset;

  /// EQ preset: Flat
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get eqPresetFlat;

  /// EQ preset: Bass Boost
  ///
  /// In en, this message translates to:
  /// **'Bass Boost'**
  String get eqPresetBassBoost;

  /// EQ preset: Treble Boost
  ///
  /// In en, this message translates to:
  /// **'Treble Boost'**
  String get eqPresetTrebleBoost;

  /// EQ preset: Vocal
  ///
  /// In en, this message translates to:
  /// **'Vocal'**
  String get eqPresetVocal;

  /// EQ preset: Rock
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get eqPresetRock;

  /// EQ preset: Electronic
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get eqPresetElectronic;

  /// EQ preset: Classical
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get eqPresetClassical;

  /// EQ preset: Custom
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get eqPresetCustom;

  /// Context menu: Play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get ctxPlay;

  /// Context menu: Play Next
  ///
  /// In en, this message translates to:
  /// **'Play Next'**
  String get ctxPlayNext;

  /// Context menu: Add to Queue
  ///
  /// In en, this message translates to:
  /// **'Add to Queue'**
  String get ctxAddToQueue;

  /// Context menu: Add to Playlist
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get ctxAddToPlaylist;

  /// Button: select all items
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Context menu: New Playlist
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get ctxNewPlaylist;

  /// Context menu: Toggle Favorite
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get ctxToggleFavorite;

  /// Context menu: Go to Artist
  ///
  /// In en, this message translates to:
  /// **'Go to Artist'**
  String get ctxGoToArtist;

  /// Context menu: Go to Album
  ///
  /// In en, this message translates to:
  /// **'Go to Album'**
  String get ctxGoToAlbum;

  /// Context menu: Remove from Queue
  ///
  /// In en, this message translates to:
  /// **'Remove from Queue'**
  String get ctxRemoveFromQueue;

  /// Context menu: Remove from Playlist
  ///
  /// In en, this message translates to:
  /// **'Remove from Playlist'**
  String get ctxRemoveFromPlaylist;

  /// Context menu: Reorder
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get ctxReorder;

  /// Generic button: Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic button: Delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Generic button: Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic button: Create
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Generic button: Confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Button: Quit app
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// Button: Minimize to Tray
  ///
  /// In en, this message translates to:
  /// **'Minimize to Tray'**
  String get minimizeToTray;

  /// Button: Keep Running in tray
  ///
  /// In en, this message translates to:
  /// **'Keep Running'**
  String get keepRunning;

  /// Description for keep running option
  ///
  /// In en, this message translates to:
  /// **'Music FSE will continue playing in the background.'**
  String get keepRunningDesc;

  /// Checkbox: Remember choice
  ///
  /// In en, this message translates to:
  /// **'Remember my choice'**
  String get rememberChoice;

  /// Toast button: Undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Toast: song added to queue
  ///
  /// In en, this message translates to:
  /// **'Added to queue'**
  String get addedToQueue;

  /// Toast: multiple songs added to queue
  ///
  /// In en, this message translates to:
  /// **'Added {count} songs to queue'**
  String addedManyToQueue(int count);

  /// Toast: song removed from queue
  ///
  /// In en, this message translates to:
  /// **'Removed from queue'**
  String get removedFromQueue;

  /// Toast: song added to playlist
  ///
  /// In en, this message translates to:
  /// **'Added to \"{name}\"'**
  String addedToPlaylist(String name);

  /// Toast: multiple songs added to playlist
  ///
  /// In en, this message translates to:
  /// **'Added {count} songs to \"{name}\"'**
  String addedManyToPlaylist(int count, String name);

  /// Toast: song removed from playlist
  ///
  /// In en, this message translates to:
  /// **'Removed from \"{name}\"'**
  String removedFromPlaylist(String name);

  /// Toast: removed from favorites
  ///
  /// In en, this message translates to:
  /// **'Removed from Favorites'**
  String get removedFromFavorites;

  /// Toast: added to favorites
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get addedToFavorites;

  /// Toast: playlist created
  ///
  /// In en, this message translates to:
  /// **'Playlist created'**
  String get playlistCreated;

  /// Toast: playlist deleted
  ///
  /// In en, this message translates to:
  /// **'Playlist deleted'**
  String get playlistDeleted;

  /// Toast: playlist renamed
  ///
  /// In en, this message translates to:
  /// **'Playlist renamed'**
  String get playlistRenamed;

  /// Empty state: no music in library
  ///
  /// In en, this message translates to:
  /// **'No music yet'**
  String get noMusicYet;

  /// Empty state message for empty library
  ///
  /// In en, this message translates to:
  /// **'Add a folder containing your music files to get started.'**
  String get noMusicMessage;

  /// CTA: Add Music Folder
  ///
  /// In en, this message translates to:
  /// **'Add Music Folder'**
  String get addMusicFolder;

  /// Empty state: queue is empty
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// Empty state message for empty queue
  ///
  /// In en, this message translates to:
  /// **'Songs you add will appear here.'**
  String get queueEmptyMessage;

  /// Onboarding: Welcome heading
  ///
  /// In en, this message translates to:
  /// **'Welcome to Music FSE'**
  String get onboardingWelcome;

  /// Onboarding: Welcome description
  ///
  /// In en, this message translates to:
  /// **'Your full-screen music experience for handheld gaming PCs.'**
  String get onboardingDesc;

  /// Onboarding: Get Started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// Onboarding: Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Onboarding: Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Onboarding: Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// Onboarding: Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onboardingDone;

  /// Onboarding step: Select Folders heading
  ///
  /// In en, this message translates to:
  /// **'Add Music Folders'**
  String get onboardingSelectFolders;

  /// Onboarding step: Select Folders description
  ///
  /// In en, this message translates to:
  /// **'Choose folders where your music is stored. You can add or remove folders later in Settings.'**
  String get onboardingSelectFoldersDesc;

  /// Onboarding step: Choose Theme heading
  ///
  /// In en, this message translates to:
  /// **'Choose Your Look'**
  String get onboardingChooseTheme;

  /// Onboarding step: Choose Theme description
  ///
  /// In en, this message translates to:
  /// **'Pick a theme and accent color. You can change these any time in Settings.'**
  String get onboardingChooseThemeDesc;

  /// Onboarding step: Scan Progress heading
  ///
  /// In en, this message translates to:
  /// **'Scanning Library'**
  String get onboardingScanProgress;

  /// Onboarding step: Scan Progress description
  ///
  /// In en, this message translates to:
  /// **'Finding your music and loading metadata…'**
  String get onboardingScanProgressDesc;

  /// Button hint: Select (A)
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get hintSelect;

  /// Button hint: Back (B)
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get hintBack;

  /// Button hint: Options (X)
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get hintOptions;

  /// Button hint: Favorite (Y)
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get hintFavorite;

  /// Button hint: Play (A)
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get hintPlay;

  /// Button hint: Open (A)
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get hintOpen;

  /// Button hint: Close (B)
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get hintClose;

  /// Button hint: Previous Track (LB)
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get hintPrevTrack;

  /// Button hint: Next Track (RB)
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get hintNextTrack;

  /// Button hint: Open Queue
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get hintQueue;

  /// Button hint: Open Search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get hintSearch;

  /// Toast: scan complete
  ///
  /// In en, this message translates to:
  /// **'Scan complete'**
  String get scanComplete;

  /// Toast: found N songs during scan
  ///
  /// In en, this message translates to:
  /// **'Found {count} songs'**
  String scanFoundSongs(int count);

  /// Warning toast: N folders were inaccessible during scan
  ///
  /// In en, this message translates to:
  /// **'{count} folder(s) could not be accessed'**
  String scanFoldersInaccessible(int count);

  /// Generic label: Artist
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// Generic label: Album
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// Generic label: Genre
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// Fallback label for unknown artist
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get unknownArtist;

  /// Fallback label for unknown album
  ///
  /// In en, this message translates to:
  /// **'Unknown Album'**
  String get unknownAlbum;

  /// Compilation album artist label
  ///
  /// In en, this message translates to:
  /// **'Various Artists'**
  String get variousArtists;

  /// Summary of how many songs were added during import
  ///
  /// In en, this message translates to:
  /// **'Added {added} of {total} songs ({dupes} duplicates skipped)'**
  String addedXOfYSongs(int added, int total, int dupes);

  /// Toast: audio file is missing
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileMissing;

  /// Toast detail message for missing file
  ///
  /// In en, this message translates to:
  /// **'The file for this track could not be found. It may have been moved or deleted.'**
  String get fileMissingMessage;

  /// Button/prompt: Rescan Library
  ///
  /// In en, this message translates to:
  /// **'Rescan Library'**
  String get rescanLibrary;

  /// Dialog prompt when multiple consecutive tracks are missing
  ///
  /// In en, this message translates to:
  /// **'Several tracks couldn\'t be found. Would you like to rescan your library?'**
  String get consecutiveMissingPrompt;

  /// Text field label for playlist name
  ///
  /// In en, this message translates to:
  /// **'Playlist Name'**
  String get playlistNameLabel;

  /// Text field hint for playlist name
  ///
  /// In en, this message translates to:
  /// **'Enter a name…'**
  String get playlistNameHint;

  /// Dialog title: Create new playlist
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get createPlaylistTitle;

  /// Dialog title: Rename playlist
  ///
  /// In en, this message translates to:
  /// **'Rename Playlist'**
  String get renamePlaylistTitle;

  /// Generic label: Songs
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// Generic label: Albums
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// Generic label: Artists
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// Generic label: Playlists
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// Track count label with plural form
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track} other{{count} tracks}}'**
  String tracks(num count);

  /// Song count label with plural form
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song} other{{count} songs}}'**
  String songsCount(num count);

  /// Default playlist name when saving queue
  ///
  /// In en, this message translates to:
  /// **'Queue — {date}'**
  String queueSaveDefaultName(String date);

  /// Title for save queue dialog
  ///
  /// In en, this message translates to:
  /// **'Save Queue as Playlist'**
  String get queueSaveTitle;

  /// Hint text for save queue name field
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get queueSaveHint;

  /// Confirm button for save queue dialog
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get queueSaveConfirm;

  /// Toast shown after saving queue as playlist
  ///
  /// In en, this message translates to:
  /// **'Playlist created: {name}'**
  String queueSaveSuccess(String name);

  /// Title for close-to-tray first-time dialog
  ///
  /// In en, this message translates to:
  /// **'Keep Music FSE running?'**
  String get closeToTrayDialogTitle;

  /// Body text for close-to-tray dialog
  ///
  /// In en, this message translates to:
  /// **'Music FSE will continue playing in the background. You can find it in the system tray.'**
  String get closeToTrayDialogBody;

  /// Button to minimize to tray
  ///
  /// In en, this message translates to:
  /// **'Minimize to Tray'**
  String get closeToTrayMinimize;

  /// Button to quit the app
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get closeToTrayQuit;

  /// Checkbox label in close-to-tray dialog
  ///
  /// In en, this message translates to:
  /// **'Remember my choice'**
  String get closeToTrayRemember;

  /// Settings label for keyboard shortcuts editor
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get keyboardShortcuts;

  /// Button to edit a keyboard shortcut
  ///
  /// In en, this message translates to:
  /// **'Edit Shortcut'**
  String get editShortcut;

  /// Instruction in shortcut capture dialog
  ///
  /// In en, this message translates to:
  /// **'Press the key combination for \"{action}\"'**
  String pressKeyCombo(String action);

  /// Conflict warning in shortcut editor
  ///
  /// In en, this message translates to:
  /// **'This key is already used for \"{action}\". Reassign?'**
  String shortcutConflict(String action);

  /// Title for shortcut conflict dialog
  ///
  /// In en, this message translates to:
  /// **'Shortcut Conflict'**
  String get shortcutConflictTitle;

  /// Button to reset a single shortcut
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetShortcut;

  /// Button to reset all shortcuts
  ///
  /// In en, this message translates to:
  /// **'Reset All to Defaults'**
  String get resetAllShortcuts;

  /// Toast after saving a shortcut
  ///
  /// In en, this message translates to:
  /// **'Shortcut updated'**
  String get shortcutSaved;

  /// Now Playing: lyrics feature placeholder title
  ///
  /// In en, this message translates to:
  /// **'Lyrics coming soon'**
  String get lyricsComingSoon;

  /// Now Playing: lyrics feature placeholder description
  ///
  /// In en, this message translates to:
  /// **'This feature is planned for a future update'**
  String get lyricsComingSoonDesc;

  /// Toast shown when files are dropped onto the app
  ///
  /// In en, this message translates to:
  /// **'Adding {count} file(s) to library…'**
  String scanningDroppedFiles(int count);

  /// Context menu: add to favorites
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get ctxAddToFavorites;

  /// Context menu: remove from favorites
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get ctxRemoveFromFavorites;

  /// Context menu: rename item
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get ctxRename;

  /// Context menu: duplicate item
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get ctxDuplicate;

  /// Context menu: delete a playlist
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get ctxDeletePlaylist;

  /// Equalizer: save preset button
  ///
  /// In en, this message translates to:
  /// **'Save Preset'**
  String get savePreset;

  /// Equalizer: preset name input hint
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get presetNameHint;

  /// System tray menu: play/pause
  ///
  /// In en, this message translates to:
  /// **'Play / Pause'**
  String get trayPlayPause;

  /// System tray menu: next track
  ///
  /// In en, this message translates to:
  /// **'Next Track'**
  String get trayNextTrack;

  /// System tray menu: previous track
  ///
  /// In en, this message translates to:
  /// **'Previous Track'**
  String get trayPreviousTrack;

  /// System tray menu: show app window
  ///
  /// In en, this message translates to:
  /// **'Show Music FSE'**
  String get trayShowApp;

  /// System tray menu: quit app
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get trayQuit;

  /// Empty state: no playlists title
  ///
  /// In en, this message translates to:
  /// **'No Playlists Yet'**
  String get noPlaylistsYet;

  /// Empty state: no playlists subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a playlist to organize your music.'**
  String get noPlaylistsMessage;

  /// Section header: user playlists
  ///
  /// In en, this message translates to:
  /// **'My Playlists'**
  String get myPlaylists;

  /// Error state: playlists load failure
  ///
  /// In en, this message translates to:
  /// **'Failed to load playlists'**
  String get failedToLoadPlaylists;

  /// Error state: songs load failure
  ///
  /// In en, this message translates to:
  /// **'Failed to load songs'**
  String get failedToLoadSongs;

  /// Error state: favorites load failure
  ///
  /// In en, this message translates to:
  /// **'Failed to load favorites'**
  String get failedToLoadFavorites;

  /// Empty state: no songs title
  ///
  /// In en, this message translates to:
  /// **'No Songs'**
  String get noSongs;

  /// Empty state: no songs subtitle
  ///
  /// In en, this message translates to:
  /// **'Add a music folder in Settings to get started.'**
  String get noSongsMessage;

  /// Button hint: open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Button hint: back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Button hint: options
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// Button hint: play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Button hint: unfavorite
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// Error state: hint to rescan
  ///
  /// In en, this message translates to:
  /// **'Try rescanning your library.'**
  String get tryRescanLibrary;

  /// Delete playlist confirmation body text
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this playlist. Songs won\'t be removed from your library.'**
  String get deletePlaylistBody;

  /// Short label for create/new button
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// Generic done label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Selection mode label showing how many songs are selected
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// Generic fallback playlist label
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// Empty state: playlist has no songs
  ///
  /// In en, this message translates to:
  /// **'Playlist is Empty'**
  String get playlistIsEmpty;

  /// Empty state: hint to add songs
  ///
  /// In en, this message translates to:
  /// **'Add songs from your library.'**
  String get addSongsFromLibrary;

  /// Button hint: exit reorder mode
  ///
  /// In en, this message translates to:
  /// **'Exit Reorder'**
  String get exitReorder;

  /// Tag label for smart playlists
  ///
  /// In en, this message translates to:
  /// **'Smart'**
  String get smartTag;

  /// Playlist subtitle with song count and duration
  ///
  /// In en, this message translates to:
  /// **'{count} songs · {duration}'**
  String songCountDuration(int count, String duration);

  /// Equalizer: custom preset name
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get eqCustom;

  /// Equalizer: built-in preset tag
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get eqBuiltIn;

  /// Equalizer: save as preset button
  ///
  /// In en, this message translates to:
  /// **'Save as Preset'**
  String get eqSaveAsPreset;

  /// Equalizer: gamepad hint
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get eqAdjust;

  /// Equalizer: error state
  ///
  /// In en, this message translates to:
  /// **'Failed to load equalizer'**
  String get eqFailed;

  /// Equalizer: toggle label
  ///
  /// In en, this message translates to:
  /// **'EQ'**
  String get eqToggle;

  /// Button: reset all to defaults
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// Toast: shortcuts were reset
  ///
  /// In en, this message translates to:
  /// **'Shortcuts reset to defaults'**
  String get shortcutsResetToDefaults;

  /// Tooltip: reset single shortcut
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// Button: reassign a shortcut
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get reassign;

  /// Toast: shortcut was updated
  ///
  /// In en, this message translates to:
  /// **'Shortcut updated'**
  String get shortcutUpdated;

  /// Error state: shortcuts failed to load
  ///
  /// In en, this message translates to:
  /// **'Error loading shortcuts'**
  String get errorLoadingShortcuts;

  /// Color picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// Color picker: custom hex input label
  ///
  /// In en, this message translates to:
  /// **'Custom hex'**
  String get customHex;

  /// Generic apply button label
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
