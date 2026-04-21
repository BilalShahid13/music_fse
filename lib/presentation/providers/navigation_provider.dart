import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

/// Tracks the currently active route string so any widget can read it
/// without having to pass [BuildContext] or listen to the router.
///
/// Updated by the top-level [AppRouter]'s `redirect` / `onChanged` callback
/// whenever the active route changes.
@Riverpod(keepAlive: true)
class NavigationNotifier extends _$NavigationNotifier {
  @override
  String build() => '/home';

  /// Called by the router when a new route becomes active.
  void setCurrentRoute(String route) {
    if (state == route) return;
    state = route;
  }
}
