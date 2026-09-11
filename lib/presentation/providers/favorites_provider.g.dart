// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All songs marked as favorites, optionally sorted.
///
/// [sortBy] accepts: 'title' | 'artist' | 'album' | 'dateAdded'.

@ProviderFor(FavoritesNotifier)
final favoritesProvider = FavoritesNotifierFamily._();

/// All songs marked as favorites, optionally sorted.
///
/// [sortBy] accepts: 'title' | 'artist' | 'album' | 'dateAdded'.
final class FavoritesNotifierProvider
    extends $AsyncNotifierProvider<FavoritesNotifier, List<Song>> {
  /// All songs marked as favorites, optionally sorted.
  ///
  /// [sortBy] accepts: 'title' | 'artist' | 'album' | 'dateAdded'.
  FavoritesNotifierProvider._(
      {required FavoritesNotifierFamily super.from,
      required ({
        String sortBy,
        bool ascending,
      })
          super.argument})
      : super(
          retry: null,
          name: r'favoritesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$favoritesNotifierHash();

  @override
  String toString() {
    return r'favoritesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  FavoritesNotifier create() => FavoritesNotifier();

  @override
  bool operator ==(Object other) {
    return other is FavoritesNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$favoritesNotifierHash() => r'f519b5ff4878b536ec95f3aabde548458e3e09fc';

/// All songs marked as favorites, optionally sorted.
///
/// [sortBy] accepts: 'title' | 'artist' | 'album' | 'dateAdded'.

final class FavoritesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            FavoritesNotifier,
            AsyncValue<List<Song>>,
            List<Song>,
            FutureOr<List<Song>>,
            ({
              String sortBy,
              bool ascending,
            })> {
  FavoritesNotifierFamily._()
      : super(
          retry: null,
          name: r'favoritesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// All songs marked as favorites, optionally sorted.
  ///
  /// [sortBy] accepts: 'title' | 'artist' | 'album' | 'dateAdded'.

  FavoritesNotifierProvider call({
    String sortBy = 'title',
    bool ascending = true,
  }) =>
      FavoritesNotifierProvider._(argument: (
        sortBy: sortBy,
        ascending: ascending,
      ), from: this);

  @override
  String toString() => r'favoritesProvider';
}

/// All songs marked as favorites, optionally sorted.
///
/// [sortBy] accepts: 'title' | 'artist' | 'album' | 'dateAdded'.

abstract class _$FavoritesNotifier extends $AsyncNotifier<List<Song>> {
  late final _$args = ref.$arg as ({
    String sortBy,
    bool ascending,
  });
  String get sortBy => _$args.sortBy;
  bool get ascending => _$args.ascending;

  FutureOr<List<Song>> build({
    String sortBy = 'title',
    bool ascending = true,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Song>>, List<Song>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Song>>, List<Song>>,
        AsyncValue<List<Song>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              sortBy: _$args.sortBy,
              ascending: _$args.ascending,
            ));
  }
}
