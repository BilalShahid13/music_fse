// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_shortcuts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages configurable keyboard shortcuts.
///
/// Stores only overrides as JSON in the Settings KV table.
/// Missing keys fall back to [KeyboardShortcutConfig.defaults].

@ProviderFor(KeyboardShortcutsNotifier)
final keyboardShortcutsProvider = KeyboardShortcutsNotifierProvider._();

/// Manages configurable keyboard shortcuts.
///
/// Stores only overrides as JSON in the Settings KV table.
/// Missing keys fall back to [KeyboardShortcutConfig.defaults].
final class KeyboardShortcutsNotifierProvider extends $AsyncNotifierProvider<
    KeyboardShortcutsNotifier, List<KeyboardShortcutConfig>> {
  /// Manages configurable keyboard shortcuts.
  ///
  /// Stores only overrides as JSON in the Settings KV table.
  /// Missing keys fall back to [KeyboardShortcutConfig.defaults].
  KeyboardShortcutsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'keyboardShortcutsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$keyboardShortcutsNotifierHash();

  @$internal
  @override
  KeyboardShortcutsNotifier create() => KeyboardShortcutsNotifier();
}

String _$keyboardShortcutsNotifierHash() =>
    r'7cc156e9e40131594a6a15eacdbdf983906c1db6';

/// Manages configurable keyboard shortcuts.
///
/// Stores only overrides as JSON in the Settings KV table.
/// Missing keys fall back to [KeyboardShortcutConfig.defaults].

abstract class _$KeyboardShortcutsNotifier
    extends $AsyncNotifier<List<KeyboardShortcutConfig>> {
  FutureOr<List<KeyboardShortcutConfig>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<KeyboardShortcutConfig>>,
        List<KeyboardShortcutConfig>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<KeyboardShortcutConfig>>,
            List<KeyboardShortcutConfig>>,
        AsyncValue<List<KeyboardShortcutConfig>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
