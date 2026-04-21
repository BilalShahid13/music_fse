// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toast_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the currently visible [ToastData], or `null` when no toast is shown.
///
/// Toasts auto-dismiss after [AppConstants.toastDurationSec] seconds.
/// Toasts are non-focusable overlays — they must never steal keyboard/gamepad
/// focus.
///
/// Usage:
/// ```dart
/// ref.read(toastProvider.notifier).show('Added to queue');
/// ref.read(toastProvider.notifier).show(
///   'Removed from playlist',
///   undoAction: () => ref.read(playlistSongsProvider(id).notifier).addSong(songId),
/// );
/// ```

@ProviderFor(ToastNotifier)
final toastProvider = ToastNotifierProvider._();

/// Holds the currently visible [ToastData], or `null` when no toast is shown.
///
/// Toasts auto-dismiss after [AppConstants.toastDurationSec] seconds.
/// Toasts are non-focusable overlays — they must never steal keyboard/gamepad
/// focus.
///
/// Usage:
/// ```dart
/// ref.read(toastProvider.notifier).show('Added to queue');
/// ref.read(toastProvider.notifier).show(
///   'Removed from playlist',
///   undoAction: () => ref.read(playlistSongsProvider(id).notifier).addSong(songId),
/// );
/// ```
final class ToastNotifierProvider
    extends $NotifierProvider<ToastNotifier, ToastData?> {
  /// Holds the currently visible [ToastData], or `null` when no toast is shown.
  ///
  /// Toasts auto-dismiss after [AppConstants.toastDurationSec] seconds.
  /// Toasts are non-focusable overlays — they must never steal keyboard/gamepad
  /// focus.
  ///
  /// Usage:
  /// ```dart
  /// ref.read(toastProvider.notifier).show('Added to queue');
  /// ref.read(toastProvider.notifier).show(
  ///   'Removed from playlist',
  ///   undoAction: () => ref.read(playlistSongsProvider(id).notifier).addSong(songId),
  /// );
  /// ```
  ToastNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'toastProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$toastNotifierHash();

  @$internal
  @override
  ToastNotifier create() => ToastNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToastData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToastData?>(value),
    );
  }
}

String _$toastNotifierHash() => r'905d6bd2b2c39ff1bb329a655515eec91000f90b';

/// Holds the currently visible [ToastData], or `null` when no toast is shown.
///
/// Toasts auto-dismiss after [AppConstants.toastDurationSec] seconds.
/// Toasts are non-focusable overlays — they must never steal keyboard/gamepad
/// focus.
///
/// Usage:
/// ```dart
/// ref.read(toastProvider.notifier).show('Added to queue');
/// ref.read(toastProvider.notifier).show(
///   'Removed from playlist',
///   undoAction: () => ref.read(playlistSongsProvider(id).notifier).addSong(songId),
/// );
/// ```

abstract class _$ToastNotifier extends $Notifier<ToastData?> {
  ToastData? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ToastData?, ToastData?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ToastData?, ToastData?>, ToastData?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
