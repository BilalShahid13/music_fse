// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_select_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MultiSelectNotifier)
final multiSelectProvider = MultiSelectNotifierProvider._();

final class MultiSelectNotifierProvider extends $NotifierProvider<
    MultiSelectNotifier,
    ({
      bool isActive,
      Set<int> selectedIds,
    })> {
  MultiSelectNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'multiSelectProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$multiSelectNotifierHash();

  @$internal
  @override
  MultiSelectNotifier create() => MultiSelectNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
      ({
        bool isActive,
        Set<int> selectedIds,
      }) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<
          ({
            bool isActive,
            Set<int> selectedIds,
          })>(value),
    );
  }
}

String _$multiSelectNotifierHash() =>
    r'f2fcfa2f2c7bfd760dd5b87fd11c77fa57882324';

abstract class _$MultiSelectNotifier extends $Notifier<
    ({
      bool isActive,
      Set<int> selectedIds,
    })> {
  ({
    bool isActive,
    Set<int> selectedIds,
  }) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<
        ({
          bool isActive,
          Set<int> selectedIds,
        }),
        ({
          bool isActive,
          Set<int> selectedIds,
        })>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<
            ({
              bool isActive,
              Set<int> selectedIds,
            }),
            ({
              bool isActive,
              Set<int> selectedIds,
            })>,
        ({
          bool isActive,
          Set<int> selectedIds,
        }),
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
