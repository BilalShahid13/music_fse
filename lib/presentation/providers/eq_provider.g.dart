// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eq_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EqNotifier)
final eqProvider = EqNotifierProvider._();

final class EqNotifierProvider
    extends $AsyncNotifierProvider<EqNotifier, EqState> {
  EqNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'eqProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$eqNotifierHash();

  @$internal
  @override
  EqNotifier create() => EqNotifier();
}

String _$eqNotifierHash() => r'7074c60ba8947d0518fb856f2cbc2149db0231dd';

abstract class _$EqNotifier extends $AsyncNotifier<EqState> {
  FutureOr<EqState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EqState>, EqState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<EqState>, EqState>,
        AsyncValue<EqState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Whether the equalizer is currently enabled.

@ProviderFor(isEqEnabled)
final isEqEnabledProvider = IsEqEnabledProvider._();

/// Whether the equalizer is currently enabled.

final class IsEqEnabledProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the equalizer is currently enabled.
  IsEqEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isEqEnabledProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isEqEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isEqEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isEqEnabledHash() => r'eb1921a9740189f1884b0060977f0ef8bbe3db0f';

/// The current per-band gains as an unmodifiable list.

@ProviderFor(eqBands)
final eqBandsProvider = EqBandsProvider._();

/// The current per-band gains as an unmodifiable list.

final class EqBandsProvider
    extends $FunctionalProvider<List<double>, List<double>, List<double>>
    with $Provider<List<double>> {
  /// The current per-band gains as an unmodifiable list.
  EqBandsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'eqBandsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$eqBandsHash();

  @$internal
  @override
  $ProviderElement<List<double>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<double> create(Ref ref) {
    return eqBands(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<double>>(value),
    );
  }
}

String _$eqBandsHash() => r'1b225f6036d6aa66b3122719c11d0175a69605e4';
