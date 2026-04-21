// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks the currently active route string so any widget can read it
/// without having to pass [BuildContext] or listen to the router.
///
/// Updated by the top-level [AppRouter]'s `redirect` / `onChanged` callback
/// whenever the active route changes.

@ProviderFor(NavigationNotifier)
final navigationProvider = NavigationNotifierProvider._();

/// Tracks the currently active route string so any widget can read it
/// without having to pass [BuildContext] or listen to the router.
///
/// Updated by the top-level [AppRouter]'s `redirect` / `onChanged` callback
/// whenever the active route changes.
final class NavigationNotifierProvider
    extends $NotifierProvider<NavigationNotifier, String> {
  /// Tracks the currently active route string so any widget can read it
  /// without having to pass [BuildContext] or listen to the router.
  ///
  /// Updated by the top-level [AppRouter]'s `redirect` / `onChanged` callback
  /// whenever the active route changes.
  NavigationNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'navigationProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$navigationNotifierHash();

  @$internal
  @override
  NavigationNotifier create() => NavigationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$navigationNotifierHash() =>
    r'97d4730903bd715f127b0b8c5dd438e1fc989945';

/// Tracks the currently active route string so any widget can read it
/// without having to pass [BuildContext] or listen to the router.
///
/// Updated by the top-level [AppRouter]'s `redirect` / `onChanged` callback
/// whenever the active route changes.

abstract class _$NavigationNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
