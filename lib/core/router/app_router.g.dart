// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

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

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
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
  AppRouterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appRouterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'505ca494ba360aeead03fc4484ddcce7f1408d0a';
