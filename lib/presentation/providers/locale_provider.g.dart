// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the active app locale.
///
/// Changing this triggers a full [MaterialApp] rebuild so the language switch
/// is instant — no app restart required. The chosen locale is persisted to
/// [SettingsRepository] and restored on next launch.

@ProviderFor(LocaleNotifier)
final localeProvider = LocaleNotifierProvider._();

/// Manages the active app locale.
///
/// Changing this triggers a full [MaterialApp] rebuild so the language switch
/// is instant — no app restart required. The chosen locale is persisted to
/// [SettingsRepository] and restored on next launch.
final class LocaleNotifierProvider
    extends $NotifierProvider<LocaleNotifier, Locale> {
  /// Manages the active app locale.
  ///
  /// Changing this triggers a full [MaterialApp] rebuild so the language switch
  /// is instant — no app restart required. The chosen locale is persisted to
  /// [SettingsRepository] and restored on next launch.
  LocaleNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localeNotifierHash();

  @$internal
  @override
  LocaleNotifier create() => LocaleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$localeNotifierHash() => r'd9f655aa5be389710bdd8b4f22ef259faf07bb6b';

/// Manages the active app locale.
///
/// Changing this triggers a full [MaterialApp] rebuild so the language switch
/// is instant — no app restart required. The chosen locale is persisted to
/// [SettingsRepository] and restored on next launch.

abstract class _$LocaleNotifier extends $Notifier<Locale> {
  Locale build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Locale, Locale>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Locale, Locale>, Locale, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
