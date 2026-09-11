import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/constants/app_enums.dart';
import 'package:music_fse/core/constants/app_sizes.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/core/localization/generated/app_localizations.dart';
import 'package:music_fse/core/theme/app_theme.dart';
import 'package:music_fse/domain/entities/playback_state.dart';
import 'package:music_fse/domain/entities/song.dart';
import 'package:music_fse/platform/nav_sounds/nav_sound_player.dart';
import 'package:music_fse/presentation/pages/library/library_page.dart';
import 'package:music_fse/presentation/pages/library/library_selection_commands.dart';
import 'package:music_fse/presentation/providers/multi_select_provider.dart';
import 'package:music_fse/presentation/providers/nav_sound_provider.dart';
import 'package:music_fse/presentation/providers/playback_provider.dart';
import 'package:music_fse/presentation/providers/repository_providers.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockSongRepository songRepository;
  late MockSettingsRepository settingsRepository;
  late NavSoundPlayer navSoundPlayer;

  Song makeSong({
    required int id,
    required String filePath,
    required String title,
  }) {
    return Song(
      id: id,
      filePath: filePath,
      title: title,
      artist: 'Artist',
      album: 'Album',
      albumArtist: 'Artist',
      genre: 'Rock',
      durationMs: 180000,
      fileSize: 5000000,
      fileModifiedAt: DateTime(2024),
      dateAdded: DateTime(2024),
    );
  }

  Widget testApp() {
    return AppSizes(
      tier: DensityTier.standard,
      child: MaterialApp(
        theme: AppTheme.buildTheme(
          accentColor: Colors.blue,
          accentTextColor: AccentTextColorSetting.auto,
          appFont: AppFontSetting.inter,
          brightness: Brightness.dark,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: LibraryPage()),
      ),
    );
  }

  FocusNode nearestFocusNode(WidgetTester tester, Finder target) {
    final focusElements = find
        .ancestor(
          of: target,
          matching: find.byWidgetPredicate(
            (widget) => widget is Focus && (widget.focusNode?.canRequestFocus ?? false),
          ),
        )
        .evaluate()
        .toList()
      ..sort((a, b) => b.depth.compareTo(a.depth));

    final focusWidget = focusElements.first.widget as Focus;
    return focusWidget.focusNode!;
  }

  setUp(() {
    songRepository = MockSongRepository();
    settingsRepository = MockSettingsRepository();
    navSoundPlayer = NavSoundPlayer()
      ..setSuppressed(true)
      ..setVolume(0);
  });

  tearDown(() {
    librarySelectionAddToQueue.value = null;
    librarySelectionAddToPlaylist.value = null;
    librarySelectionSelectAll.value = null;
    librarySelectionCancel.value = null;
    navSoundPlayer.dispose();
  });

  testWidgets('LB selects all in folder multi-select even with header focus', (
    tester,
  ) async {
    const folderPath = r'C:\Music\Album';
    final songs = [
      makeSong(
        id: 1,
        filePath: r'C:\Music\Album\track_01.mp3',
        title: 'Track 01',
      ),
      makeSong(
        id: 2,
        filePath: r'C:\Music\Album\track_02.mp3',
        title: 'Track 02',
      ),
    ];

    when(
      () => songRepository.getAllSongs(
        sortBy: any(named: 'sortBy'),
        ascending: any(named: 'ascending'),
      ),
    ).thenAnswer((_) async => const Result.success(<Song>[]));
    when(
      () => songRepository.getTopLevelFolders(),
    ).thenAnswer((_) async => const Result.success(<String>[folderPath]));
    when(
      () => songRepository.getSubFolders(folderPath),
    ).thenAnswer((_) async => const Result.success(<String>[]));
    when(
      () => songRepository.getSongsByFolder(folderPath),
    ).thenAnswer((_) async => Result.success(songs));
    when(
      () => settingsRepository.getString(any()),
    ).thenAnswer((_) async => const Result.success(null));
    when(
      () => settingsRepository.getBool(any()),
    ).thenAnswer((_) async => const Result.success(null));

    final container = ProviderContainer(
      overrides: [
        songRepositoryProvider.overrideWithValue(songRepository),
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        playbackProvider.overrideWithValue(const PlaybackState()),
        navSoundPlayerProvider.overrideWithValue(navSoundPlayer),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Folders'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonA);
    await tester.pumpAndSettle();

    container.read(multiSelectProvider.notifier).activate();
    await tester.pumpAndSettle();

    final cancelButtonFocus = nearestFocusNode(tester, find.text('Cancel').first);
    cancelButtonFocus.requestFocus();
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonLeft1);
    await tester.pumpAndSettle();

    expect(container.read(multiSelectProvider).selectedIds, {1, 2});
    expect(find.text('Folders'), findsOneWidget);
  });
}