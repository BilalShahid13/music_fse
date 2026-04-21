// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_preference_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Per-tab sort preference loaded from the settings store.
///
/// Family parameter [tab] identifies the library tab (e.g. 'songs', 'albums').
/// Returns `(sortBy, ascending)`.

@ProviderFor(SortPreferenceNotifier)
final sortPreferenceProvider = SortPreferenceNotifierFamily._();

/// Per-tab sort preference loaded from the settings store.
///
/// Family parameter [tab] identifies the library tab (e.g. 'songs', 'albums').
/// Returns `(sortBy, ascending)`.
final class SortPreferenceNotifierProvider extends $AsyncNotifierProvider<
    SortPreferenceNotifier,
    ({
      bool ascending,
      String sortBy,
    })> {
  /// Per-tab sort preference loaded from the settings store.
  ///
  /// Family parameter [tab] identifies the library tab (e.g. 'songs', 'albums').
  /// Returns `(sortBy, ascending)`.
  SortPreferenceNotifierProvider._(
      {required SortPreferenceNotifierFamily super.from,
      required (
        String, {
        String defaultSortBy,
      })
          super.argument})
      : super(
          retry: null,
          name: r'sortPreferenceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sortPreferenceNotifierHash();

  @override
  String toString() {
    return r'sortPreferenceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SortPreferenceNotifier create() => SortPreferenceNotifier();

  @override
  bool operator ==(Object other) {
    return other is SortPreferenceNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sortPreferenceNotifierHash() =>
    r'c18939208ff4f78de4109c12580fa6bdfbf8a19c';

/// Per-tab sort preference loaded from the settings store.
///
/// Family parameter [tab] identifies the library tab (e.g. 'songs', 'albums').
/// Returns `(sortBy, ascending)`.

final class SortPreferenceNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            SortPreferenceNotifier,
            AsyncValue<
                ({
                  bool ascending,
                  String sortBy,
                })>,
            ({
              bool ascending,
              String sortBy,
            }),
            FutureOr<
                ({
                  bool ascending,
                  String sortBy,
                })>,
            (
              String, {
              String defaultSortBy,
            })> {
  SortPreferenceNotifierFamily._()
      : super(
          retry: null,
          name: r'sortPreferenceProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Per-tab sort preference loaded from the settings store.
  ///
  /// Family parameter [tab] identifies the library tab (e.g. 'songs', 'albums').
  /// Returns `(sortBy, ascending)`.

  SortPreferenceNotifierProvider call(
    String tab, {
    String defaultSortBy = 'title',
  }) =>
      SortPreferenceNotifierProvider._(argument: (
        tab,
        defaultSortBy: defaultSortBy,
      ), from: this);

  @override
  String toString() => r'sortPreferenceProvider';
}

/// Per-tab sort preference loaded from the settings store.
///
/// Family parameter [tab] identifies the library tab (e.g. 'songs', 'albums').
/// Returns `(sortBy, ascending)`.

abstract class _$SortPreferenceNotifier extends $AsyncNotifier<
    ({
      bool ascending,
      String sortBy,
    })> {
  late final _$args = ref.$arg as (
    String, {
    String defaultSortBy,
  });
  String get tab => _$args.$1;
  String get defaultSortBy => _$args.defaultSortBy;

  FutureOr<
      ({
        bool ascending,
        String sortBy,
      })> build(
    String tab, {
    String defaultSortBy = 'title',
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<
        AsyncValue<
            ({
              bool ascending,
              String sortBy,
            })>,
        ({
          bool ascending,
          String sortBy,
        })>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<
            AsyncValue<
                ({
                  bool ascending,
                  String sortBy,
                })>,
            ({
              bool ascending,
              String sortBy,
            })>,
        AsyncValue<
            ({
              bool ascending,
              String sortBy,
            })>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args.$1,
              defaultSortBy: _$args.defaultSortBy,
            ));
  }
}
