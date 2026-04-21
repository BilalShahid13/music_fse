import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/pages/album_detail/album_detail_page.dart';
import '../../presentation/pages/artist_detail/artist_detail_page.dart';
import '../../presentation/pages/equalizer/equalizer_page.dart';
import '../../presentation/pages/favorites/favorites_page.dart';
import '../../presentation/pages/genre_detail/genre_detail_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/library/library_page.dart';
import '../../presentation/pages/now_playing/now_playing_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/playlist/playlist_detail_page.dart';
import '../../presentation/pages/playlist/playlist_list_page.dart';
import '../../presentation/pages/recently_played/recently_played_page.dart';
import '../../presentation/pages/search/search_page.dart';
import '../../presentation/pages/settings/keyboard_shortcut_editor_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/shell_page.dart';
import '../../presentation/providers/navigation_provider.dart';
import '../../presentation/providers/scan_folder_provider.dart';

part 'app_router.g.dart';

/// Root GoRouter provider — keepAlive so the router object is never discarded.
///
/// Redirect logic:
///  - While folders are loading → `/splash`
///  - No folders configured → `/onboarding`
///  - Otherwise → normal navigation
///
/// Route tracking:
///  The router registers a [RouterDelegate] listener so that
///  [NavigationNotifier] is always up to date with the current path. This
///  allows any provider or widget to know the active route without needing
///  a [BuildContext].
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final hasFoldersAsync = ref.watch(scanFoldersProvider);
  final hasFolders = (hasFoldersAsync.value ?? []).isNotEmpty;
  final isLoading = hasFoldersAsync.isLoading;

  final router = GoRouter(
    // Initial location is only used on first app launch.
    // Once a route is active, this is not used.
    initialLocation: isLoading ? '/splash' : (hasFolders ? '/home' : '/onboarding'),
    redirect: (context, state) {
      final path = state.uri.path;

      if (isLoading) {
        return path == '/splash' ? null : '/splash';
      }
      if (path == '/splash') {
        return hasFolders ? '/home' : '/onboarding';
      }
      // Allow onboarding to complete even if folders are added during the process.
      // The onboarding page will navigate to /home when complete via _completeOnboarding().
      if (path == '/onboarding') {
        return null; // Never redirect away from onboarding
      }
      // Guard: if no folders yet and not on onboarding, go to onboarding.
      // Exception: allow /now-playing and /equalizer even before onboarding completes.
      if (!hasFolders && path != '/now-playing' && path != '/equalizer') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      // Splash (async loading placeholder)
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const MaterialPage(
          child: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),

      // Onboarding (no shell)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingPage(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),

      // ── Main shell ────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ShellPage(navigationShell: navigationShell),
        branches: [
          // Branch 0 — Home
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

          // Branch 1 — Library
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

          // Branch 2 — Search
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

          // Branch 3 — Playlists
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

          // Branch 4 — Favorites
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

          // Branch 5 — Settings
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const SettingsPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
              routes: [
                GoRoute(
                  path: 'shortcuts',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const KeyboardShortcutEditorPage(),
                    transitionsBuilder: _fadeSlideTransition,
                  ),
                ),
              ],
            ),
          ]),
        ],
      ),

      // Now Playing — full-screen overlay (outside shell)
      GoRoute(
        path: '/now-playing',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NowPlayingPage(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),

      // Equalizer — full-screen (outside shell)
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

  // ── Route tracking ─────────────────────────────────────────────────────────
  // Keep NavigationNotifier in sync so non-widget code can query the active
  // route without a BuildContext. The listener is removed automatically when
  // the provider rebuilds (ref.onDispose removes it via the cancel closure).
  void onRouteChanged() {
    final path = router.routerDelegate.currentConfiguration.uri.path;
    // GoRouterDelegate.notifyListeners fires synchronously during the initial
    // route setup (inside didChangeDependencies → widget tree build phase).
    // Deferring via Future.microtask avoids Riverpod's "Tried to modify a
    // provider while the widget tree was building" error.
    Future.microtask(
      () => ref.read(navigationProvider.notifier).setCurrentRoute(path),
    );
  }

  router.routerDelegate.addListener(onRouteChanged);
  ref.onDispose(() {
    router.routerDelegate.removeListener(onRouteChanged);
    router.dispose();
  });

  return router;
}

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
