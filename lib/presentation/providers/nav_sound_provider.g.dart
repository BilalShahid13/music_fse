// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_sound_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the application-wide [NavSoundPlayer] singleton.
///
/// Initialises the player on first access and keeps its volume synchronised
/// with [NavSoundLevelNotifier].
///
/// keepAlive: the player holds an [AudioPlayer] instance that must survive
/// for the lifetime of the app.

@ProviderFor(navSoundPlayer)
final navSoundPlayerProvider = NavSoundPlayerProvider._();

/// Provides the application-wide [NavSoundPlayer] singleton.
///
/// Initialises the player on first access and keeps its volume synchronised
/// with [NavSoundLevelNotifier].
///
/// keepAlive: the player holds an [AudioPlayer] instance that must survive
/// for the lifetime of the app.

final class NavSoundPlayerProvider
    extends $FunctionalProvider<NavSoundPlayer, NavSoundPlayer, NavSoundPlayer>
    with $Provider<NavSoundPlayer> {
  /// Provides the application-wide [NavSoundPlayer] singleton.
  ///
  /// Initialises the player on first access and keeps its volume synchronised
  /// with [NavSoundLevelNotifier].
  ///
  /// keepAlive: the player holds an [AudioPlayer] instance that must survive
  /// for the lifetime of the app.
  NavSoundPlayerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'navSoundPlayerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$navSoundPlayerHash();

  @$internal
  @override
  $ProviderElement<NavSoundPlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NavSoundPlayer create(Ref ref) {
    return navSoundPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavSoundPlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavSoundPlayer>(value),
    );
  }
}

String _$navSoundPlayerHash() => r'1d854520e2f4f096c41e1227dc3d3904df6baff5';
