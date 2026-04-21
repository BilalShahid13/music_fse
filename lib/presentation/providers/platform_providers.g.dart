// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the [XInputController] + [GamepadInputHandler] lifecycle.
///
/// State is `true` when polling is active, `false` when stopped or
/// unavailable. On non-Windows platforms the controller is not created and
/// state is always `false`.
///
/// Lifecycle:
/// ```dart
/// // Start polling (resumed from background)
/// ref.read(xinputControllerNotifierProvider.notifier).start();
/// // Stop polling (app backgrounded)
/// ref.read(xinputControllerNotifierProvider.notifier).stop();
/// ```

@ProviderFor(XInputControllerNotifier)
final xInputControllerProvider = XInputControllerNotifierProvider._();

/// Manages the [XInputController] + [GamepadInputHandler] lifecycle.
///
/// State is `true` when polling is active, `false` when stopped or
/// unavailable. On non-Windows platforms the controller is not created and
/// state is always `false`.
///
/// Lifecycle:
/// ```dart
/// // Start polling (resumed from background)
/// ref.read(xinputControllerNotifierProvider.notifier).start();
/// // Stop polling (app backgrounded)
/// ref.read(xinputControllerNotifierProvider.notifier).stop();
/// ```
final class XInputControllerNotifierProvider
    extends $NotifierProvider<XInputControllerNotifier, bool> {
  /// Manages the [XInputController] + [GamepadInputHandler] lifecycle.
  ///
  /// State is `true` when polling is active, `false` when stopped or
  /// unavailable. On non-Windows platforms the controller is not created and
  /// state is always `false`.
  ///
  /// Lifecycle:
  /// ```dart
  /// // Start polling (resumed from background)
  /// ref.read(xinputControllerNotifierProvider.notifier).start();
  /// // Stop polling (app backgrounded)
  /// ref.read(xinputControllerNotifierProvider.notifier).stop();
  /// ```
  XInputControllerNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'xInputControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$xInputControllerNotifierHash();

  @$internal
  @override
  XInputControllerNotifier create() => XInputControllerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$xInputControllerNotifierHash() =>
    r'06a081a99a2d340f9849a9bf44150fa5c98f2364';

/// Manages the [XInputController] + [GamepadInputHandler] lifecycle.
///
/// State is `true` when polling is active, `false` when stopped or
/// unavailable. On non-Windows platforms the controller is not created and
/// state is always `false`.
///
/// Lifecycle:
/// ```dart
/// // Start polling (resumed from background)
/// ref.read(xinputControllerNotifierProvider.notifier).start();
/// // Stop polling (app backgrounded)
/// ref.read(xinputControllerNotifierProvider.notifier).stop();
/// ```

abstract class _$XInputControllerNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Manages the Windows SMTC overlay lifecycle and keeps it in sync with
/// [PlaybackNotifier] state.
///
/// Triggers async init on first read:
/// ```dart
/// ref.read(smtcHandlerProvider);
/// ```
///
/// On non-Windows platforms [SmtcBinding] and [SmtcController] are safe
/// no-ops (conditional import).

@ProviderFor(SmtcHandlerNotifier)
final smtcHandlerProvider = SmtcHandlerNotifierProvider._();

/// Manages the Windows SMTC overlay lifecycle and keeps it in sync with
/// [PlaybackNotifier] state.
///
/// Triggers async init on first read:
/// ```dart
/// ref.read(smtcHandlerProvider);
/// ```
///
/// On non-Windows platforms [SmtcBinding] and [SmtcController] are safe
/// no-ops (conditional import).
final class SmtcHandlerNotifierProvider
    extends $AsyncNotifierProvider<SmtcHandlerNotifier, void> {
  /// Manages the Windows SMTC overlay lifecycle and keeps it in sync with
  /// [PlaybackNotifier] state.
  ///
  /// Triggers async init on first read:
  /// ```dart
  /// ref.read(smtcHandlerProvider);
  /// ```
  ///
  /// On non-Windows platforms [SmtcBinding] and [SmtcController] are safe
  /// no-ops (conditional import).
  SmtcHandlerNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'smtcHandlerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$smtcHandlerNotifierHash();

  @$internal
  @override
  SmtcHandlerNotifier create() => SmtcHandlerNotifier();
}

String _$smtcHandlerNotifierHash() =>
    r'0fb8c4392601527e1ae670f0d6b951957b3bc8e7';

/// Manages the Windows SMTC overlay lifecycle and keeps it in sync with
/// [PlaybackNotifier] state.
///
/// Triggers async init on first read:
/// ```dart
/// ref.read(smtcHandlerProvider);
/// ```
///
/// On non-Windows platforms [SmtcBinding] and [SmtcController] are safe
/// no-ops (conditional import).

abstract class _$SmtcHandlerNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Manages the system-tray icon and its context menu, and routes tray actions
/// to the playback layer.
///
/// Triggers async init on first read:
/// ```dart
/// ref.read(systemTrayHandlerProvider);
/// ```

@ProviderFor(SystemTrayHandlerNotifier)
final systemTrayHandlerProvider = SystemTrayHandlerNotifierProvider._();

/// Manages the system-tray icon and its context menu, and routes tray actions
/// to the playback layer.
///
/// Triggers async init on first read:
/// ```dart
/// ref.read(systemTrayHandlerProvider);
/// ```
final class SystemTrayHandlerNotifierProvider
    extends $AsyncNotifierProvider<SystemTrayHandlerNotifier, void> {
  /// Manages the system-tray icon and its context menu, and routes tray actions
  /// to the playback layer.
  ///
  /// Triggers async init on first read:
  /// ```dart
  /// ref.read(systemTrayHandlerProvider);
  /// ```
  SystemTrayHandlerNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'systemTrayHandlerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$systemTrayHandlerNotifierHash();

  @$internal
  @override
  SystemTrayHandlerNotifier create() => SystemTrayHandlerNotifier();
}

String _$systemTrayHandlerNotifierHash() =>
    r'59869415797ec104876638e99ff47d78d2b61df4';

/// Manages the system-tray icon and its context menu, and routes tray actions
/// to the playback layer.
///
/// Triggers async init on first read:
/// ```dart
/// ref.read(systemTrayHandlerProvider);
/// ```

abstract class _$SystemTrayHandlerNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
