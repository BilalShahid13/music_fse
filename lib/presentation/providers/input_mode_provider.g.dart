// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InputModeNotifier)
final inputModeProvider = InputModeNotifierProvider._();

final class InputModeNotifierProvider
    extends $NotifierProvider<InputModeNotifier, InputMode> {
  InputModeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inputModeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inputModeNotifierHash();

  @$internal
  @override
  InputModeNotifier create() => InputModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InputMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InputMode>(value),
    );
  }
}

String _$inputModeNotifierHash() => r'4864f78ae4a232aab45e9582b69af5a1d803a146';

abstract class _$InputModeNotifier extends $Notifier<InputMode> {
  InputMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<InputMode, InputMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<InputMode, InputMode>, InputMode, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
