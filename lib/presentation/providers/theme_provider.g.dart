// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages theme brightness and accent color.
///
/// Values are persisted to [SettingsRepository] and loaded at startup so the
/// user's preference survives app restarts.

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

/// Manages theme brightness and accent color.
///
/// Values are persisted to [SettingsRepository] and loaded at startup so the
/// user's preference survives app restarts.
final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, ThemeState> {
  /// Manages theme brightness and accent color.
  ///
  /// Values are persisted to [SettingsRepository] and loaded at startup so the
  /// user's preference survives app restarts.
  ThemeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeState>(value),
    );
  }
}

String _$themeNotifierHash() => r'25f05f1638fb328d65e8e5d4686f8abcc081851f';

/// Manages theme brightness and accent color.
///
/// Values are persisted to [SettingsRepository] and loaded at startup so the
/// user's preference survives app restarts.

abstract class _$ThemeNotifier extends $Notifier<ThemeState> {
  ThemeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeState, ThemeState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ThemeState, ThemeState>, ThemeState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Current accent color — avoids rebuilding widgets that only care about color.

@ProviderFor(accentColor)
final accentColorProvider = AccentColorProvider._();

/// Current accent color — avoids rebuilding widgets that only care about color.

final class AccentColorProvider extends $FunctionalProvider<Color, Color, Color>
    with $Provider<Color> {
  /// Current accent color — avoids rebuilding widgets that only care about color.
  AccentColorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accentColorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accentColorHash();

  @$internal
  @override
  $ProviderElement<Color> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Color create(Ref ref) {
    return accentColor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color>(value),
    );
  }
}

String _$accentColorHash() => r'16e92544bb3aab63dc79e3300cbfbc35edfca7e8';

/// Current theme mode setting.

@ProviderFor(themeModeSetting)
final themeModeSettingProvider = ThemeModeSettingProvider._();

/// Current theme mode setting.

final class ThemeModeSettingProvider extends $FunctionalProvider<
    ThemeModeSetting,
    ThemeModeSetting,
    ThemeModeSetting> with $Provider<ThemeModeSetting> {
  /// Current theme mode setting.
  ThemeModeSettingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeModeSettingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeModeSettingHash();

  @$internal
  @override
  $ProviderElement<ThemeModeSetting> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeModeSetting create(Ref ref) {
    return themeModeSetting(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeModeSetting value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeModeSetting>(value),
    );
  }
}

String _$themeModeSettingHash() => r'8cddec7ae891159cdfb839e0071677c7e72d554f';
