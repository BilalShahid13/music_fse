// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singleton provider for the Drift [AppDatabase] instance.
///
/// Marked [keepAlive] so the connection is never torn down while the app is
/// running. [ref.onDispose] closes the connection on hot-restart / test teardown.

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

/// Singleton provider for the Drift [AppDatabase] instance.
///
/// Marked [keepAlive] so the connection is never torn down while the app is
/// running. [ref.onDispose] closes the connection on hot-restart / test teardown.

final class DatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Singleton provider for the Drift [AppDatabase] instance.
  ///
  /// Marked [keepAlive] so the connection is never torn down while the app is
  /// running. [ref.onDispose] closes the connection on hot-restart / test teardown.
  DatabaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'databaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$databaseHash() => r'0d11495272a3ce572b22efba37c8c78cad38aed0';
