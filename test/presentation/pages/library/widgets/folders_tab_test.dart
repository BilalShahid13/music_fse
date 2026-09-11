import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/constants/app_enums.dart';
import 'package:music_fse/core/constants/app_sizes.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/core/localization/generated/app_localizations.dart';
import 'package:music_fse/core/theme/app_theme.dart';
import 'package:music_fse/domain/entities/playback_state.dart';
import 'package:music_fse/domain/entities/song.dart';
import 'package:music_fse/domain/usecases/get_folder_contents.dart';
import 'package:music_fse/platform/nav_sounds/nav_sound_player.dart';
import 'package:music_fse/presentation/pages/library/library_selection_commands.dart';
import 'package:music_fse/presentation/pages/library/widgets/folders_tab.dart';
import 'package:music_fse/presentation/providers/multi_select_provider.dart';
import 'package:music_fse/presentation/providers/nav_sound_provider.dart';
import 'package:music_fse/presentation/providers/playback_provider.dart';
import 'package:music_fse/presentation/providers/use_case_providers.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../../../helpers/mocks.dart';

void main() {
  late MockSongRepository repository;
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

  Widget testAppWithLocalizations({
    required Widget child,
    List<Override> overrides = const [],
    ProviderContainer? container,
  }) {
    final app = AppSizes(
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
        home: Scaffold(body: child),
      ),
    );

    if (container != null) {
      return UncontrolledProviderScope(container: container, child: app);
    }

    return ProviderScope(overrides: overrides, child: app);
  }

  bool primaryFocusContainsText(WidgetTester tester, String text) {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;

    final focusedNode = find.byWidgetPredicate(
      (widget) => widget is Focus && widget.focusNode == primaryFocus,
    );

    return find
        .ancestor(of: find.text(text), matching: focusedNode)
        .evaluate()
        .isNotEmpty;
  }

  setUp(() {
    repository = MockSongRepository();
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

  testWidgets('shows songs inside a folder and B returns to the parent folder', (
    tester,
  ) async {
    const folderPath = r'C:\Music\Album';
    final song = makeSong(
      id: 1,
      filePath: r'C:\Music\Album\track_01.mp3',
      title: 'Track 01',
    );

    when(
      () => repository.getTopLevelFolders(),
    ).thenAnswer((_) async => const Result.success(<String>[folderPath]));
    when(
      () => repository.getSubFolders(folderPath),
    ).thenAnswer((_) async => const Result.success(<String>[]));
    when(
      () => repository.getSongsByFolder(folderPath),
    ).thenAnswer((_) async => Result.success(<Song>[song]));

    await tester.pumpWidget(
      testAppWithLocalizations(
        child: const FoldersTab(),
        overrides: [
          getFolderContentsProvider.overrideWithValue(
            GetFolderContents(repository),
          ),
          playbackProvider.overrideWithValue(const PlaybackState()),
          navSoundPlayerProvider.overrideWithValue(navSoundPlayer),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Track 01'), findsNothing);
    expect(find.text('Empty Folder'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonA);
    await tester.pumpAndSettle();

    expect(find.text('Track 01'), findsOneWidget);
    expect(find.text('Empty Folder'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonB);
    await tester.pumpAndSettle();

    expect(find.text('Track 01'), findsNothing);
  });

  testWidgets('X opens the focused folder song context menu without throwing', (
    tester,
  ) async {
    const folderPath = r'C:\Music\Album';
    final song = makeSong(
      id: 1,
      filePath: r'C:\Music\Album\track_01.mp3',
      title: 'Track 01',
    );

    when(
      () => repository.getTopLevelFolders(),
    ).thenAnswer((_) async => const Result.success(<String>[folderPath]));
    when(
      () => repository.getSubFolders(folderPath),
    ).thenAnswer((_) async => const Result.success(<String>[]));
    when(
      () => repository.getSongsByFolder(folderPath),
    ).thenAnswer((_) async => Result.success(<Song>[song]));

    await tester.pumpWidget(
      testAppWithLocalizations(
        child: const FoldersTab(),
        overrides: [
          getFolderContentsProvider.overrideWithValue(
            GetFolderContents(repository),
          ),
          playbackProvider.overrideWithValue(const PlaybackState()),
          navSoundPlayerProvider.overrideWithValue(navSoundPlayer),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonA);
    await tester.pumpAndSettle();

    expect(find.text('Track 01'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonX);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Add to Queue'), findsOneWidget);
  });

  testWidgets('keeps the focused folder song across rebuilds', (tester) async {
    const folderPath = r'C:\Music\Album';
    final rebuildTick = ValueNotifier<int>(0);
    addTearDown(rebuildTick.dispose);
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
      () => repository.getTopLevelFolders(),
    ).thenAnswer((_) async => const Result.success(<String>[folderPath]));
    when(
      () => repository.getSubFolders(folderPath),
    ).thenAnswer((_) async => const Result.success(<String>[]));
    when(
      () => repository.getSongsByFolder(folderPath),
    ).thenAnswer((_) async => Result.success(songs));

    await tester.pumpWidget(
      testAppWithLocalizations(
        child: ValueListenableBuilder<int>(
          valueListenable: rebuildTick,
          builder: (context, _, __) => const FoldersTab(),
        ),
        overrides: [
          getFolderContentsProvider.overrideWithValue(
            GetFolderContents(repository),
          ),
          playbackProvider.overrideWithValue(const PlaybackState()),
          navSoundPlayerProvider.overrideWithValue(navSoundPlayer),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonA);
    await tester.pumpAndSettle();
    expect(primaryFocusContainsText(tester, 'Track 01'), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(primaryFocusContainsText(tester, 'Track 02'), isTrue);

    rebuildTick.value += 1;
    await tester.pumpAndSettle();

    expect(primaryFocusContainsText(tester, 'Track 02'), isTrue);
    verify(() => repository.getSongsByFolder(folderPath)).called(1);
    verify(() => repository.getSubFolders(folderPath)).called(1);
  });

  testWidgets('supports folder multi-select with shell batch callbacks', (
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
      () => repository.getTopLevelFolders(),
    ).thenAnswer((_) async => const Result.success(<String>[folderPath]));
    when(
      () => repository.getSubFolders(folderPath),
    ).thenAnswer((_) async => const Result.success(<String>[]));
    when(
      () => repository.getSongsByFolder(folderPath),
    ).thenAnswer((_) async => Result.success(songs));

    final container = ProviderContainer(
      overrides: [
        getFolderContentsProvider.overrideWithValue(
          GetFolderContents(repository),
        ),
        playbackProvider.overrideWithValue(const PlaybackState()),
        navSoundPlayerProvider.overrideWithValue(navSoundPlayer),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      testAppWithLocalizations(
        container: container,
        child: const FoldersTab(isActive: true),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonA);
    await tester.pumpAndSettle();

    container.read(multiSelectProvider.notifier).activate();
    await tester.pumpAndSettle();

    expect(librarySelectionAddToPlaylist.value, isNotNull);
    expect(librarySelectionSelectAll.value, isNotNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonA);
    await tester.pumpAndSettle();

    expect(container.read(multiSelectProvider).selectedIds, {1});
    expect(find.byIcon(LucideIcons.squareCheck), findsOneWidget);

    librarySelectionSelectAll.value!.call();
    await tester.pumpAndSettle();

    expect(container.read(multiSelectProvider).selectedIds, {1, 2});

    librarySelectionCancel.value!.call();
    await tester.pumpAndSettle();

    expect(container.read(multiSelectProvider).isActive, isFalse);
    expect(librarySelectionAddToPlaylist.value, isNull);
  });
}
