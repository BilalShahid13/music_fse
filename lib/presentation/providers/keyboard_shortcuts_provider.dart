import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/logger.dart';
import '../../presentation/models/keyboard_shortcut.dart';
import 'repository_providers.dart';

part 'keyboard_shortcuts_provider.g.dart';

/// Settings key for stored shortcut overrides.
const _kShortcutsKey = 'keyboard_shortcuts';

/// Manages configurable keyboard shortcuts.
///
/// Stores only overrides as JSON in the Settings KV table.
/// Missing keys fall back to [KeyboardShortcutConfig.defaults].
@Riverpod(keepAlive: true)
class KeyboardShortcutsNotifier extends _$KeyboardShortcutsNotifier {
  @override
  Future<List<KeyboardShortcutConfig>> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.getString(_kShortcutsKey);
    final json = result.valueOrNull;

    Map<String, String> overrides = {};
    if (json != null && json.isNotEmpty) {
      try {
        overrides = Map<String, String>.from(jsonDecode(json) as Map);
      } catch (e) {
        AppLogger.warn('KeyboardShortcutsNotifier: failed to parse overrides', tag: 'KeyboardShortcuts', error: e);
      }
    }

    return _buildConfigs(overrides);
  }

  List<KeyboardShortcutConfig> _buildConfigs(Map<String, String> overrides) {
    return KeyboardShortcutConfig.allActionIds.map((id) {
      final defaultKey = KeyboardShortcutConfig.defaults[id]!;
      final label = KeyboardShortcutConfig.labels[id] ?? id;

      SingleActivator keySet = defaultKey;
      final overrideStr = overrides[id];
      if (overrideStr != null) {
        final parsed = KeyboardShortcutConfig.activatorFromString(overrideStr);
        if (parsed != null) keySet = parsed;
      }

      return KeyboardShortcutConfig(
        actionId: id,
        label: label,
        keySet: keySet,
        defaultKeySet: defaultKey,
      );
    }).toList();
  }

  /// Update a single shortcut. Returns the conflicting action ID if any.
  Future<String?> updateShortcut(String actionId, SingleActivator newKeySet) async {
    final configs = state.value ?? [];

    // Check for conflicts
    for (final config in configs) {
      if (config.actionId != actionId && _activatorsEqual(config.keySet, newKeySet)) {
        return config.actionId;
      }
    }

    await _persistOverride(actionId, newKeySet, configs);
    return null;
  }

  /// Force-update a shortcut, clearing any conflict by resetting the
  /// conflicting action to its default.
  Future<void> forceUpdateShortcut(String actionId, SingleActivator newKeySet) async {
    final configs = state.value ?? [];

    // Find and reset conflicting action
    final updated = <KeyboardShortcutConfig>[];
    for (final config in configs) {
      if (config.actionId == actionId) {
        updated.add(config.copyWith(keySet: newKeySet));
      } else if (_activatorsEqual(config.keySet, newKeySet)) {
        // Reset conflicting to default
        updated.add(config.copyWith(keySet: config.defaultKeySet));
      } else {
        updated.add(config);
      }
    }

    await _persistAll(updated);
  }

  Future<void> resetSingle(String actionId) async {
    final configs = state.value ?? [];
    final updated = configs.map((c) {
      if (c.actionId == actionId) return c.copyWith(keySet: c.defaultKeySet);
      return c;
    }).toList();

    await _persistAll(updated);
  }

  Future<void> resetAll() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setString(_kShortcutsKey, '{}');
    state = AsyncData(_buildConfigs({}));
  }

  Future<void> _persistOverride(String actionId, SingleActivator newKeySet, List<KeyboardShortcutConfig> configs) async {
    final updated = configs.map((c) {
      if (c.actionId == actionId) return c.copyWith(keySet: newKeySet);
      return c;
    }).toList();

    await _persistAll(updated);
  }

  Future<void> _persistAll(List<KeyboardShortcutConfig> configs) async {
    final overrides = <String, String>{};
    for (final config in configs) {
      if (!_activatorsEqual(config.keySet, config.defaultKeySet)) {
        overrides[config.actionId] = KeyboardShortcutConfig.activatorToString(config.keySet);
      }
    }

    final repo = ref.read(settingsRepositoryProvider);
    await repo.setString(_kShortcutsKey, jsonEncode(overrides));
    state = AsyncData(configs);
  }

  bool _activatorsEqual(SingleActivator a, SingleActivator b) =>
      a.trigger == b.trigger && a.control == b.control && a.shift == b.shift && a.alt == b.alt && a.meta == b.meta;
}
