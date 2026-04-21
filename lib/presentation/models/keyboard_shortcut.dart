import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Represents a single configurable keyboard shortcut action.
///
/// Each action has a unique [actionId], a human-readable [label],
/// the currently bound [keySet], and the factory [defaultKeySet].
class KeyboardShortcutConfig {
  const KeyboardShortcutConfig({
    required this.actionId,
    required this.label,
    required this.keySet,
    required this.defaultKeySet,
  });

  final String actionId;
  final String label;
  final SingleActivator keySet;
  final SingleActivator defaultKeySet;

  KeyboardShortcutConfig copyWith({SingleActivator? keySet}) => KeyboardShortcutConfig(
        actionId: actionId,
        label: label,
        keySet: keySet ?? this.keySet,
        defaultKeySet: defaultKeySet,
      );

  /// All configurable action IDs.
  static const allActionIds = [
    'playPause',
    'nextTrack',
    'previousTrack',
    'volumeUp',
    'volumeDown',
    'focusSearch',
    'quitApp',
    'toggleFullscreen',
  ];

  /// Factory default shortcuts.
  static final Map<String, SingleActivator> defaults = {
    'playPause': const SingleActivator(LogicalKeyboardKey.space),
    'nextTrack': const SingleActivator(LogicalKeyboardKey.arrowRight, control: true),
    'previousTrack': const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true),
    'volumeUp': const SingleActivator(LogicalKeyboardKey.arrowUp, control: true),
    'volumeDown': const SingleActivator(LogicalKeyboardKey.arrowDown, control: true),
    'focusSearch': const SingleActivator(LogicalKeyboardKey.keyF, control: true),
    'quitApp': const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
    'toggleFullscreen': const SingleActivator(LogicalKeyboardKey.f11),
  };

  /// Human-readable labels for each action.
  static const Map<String, String> labels = {
    'playPause': 'Play / Pause',
    'nextTrack': 'Next Track',
    'previousTrack': 'Previous Track',
    'volumeUp': 'Volume Up',
    'volumeDown': 'Volume Down',
    'focusSearch': 'Search',
    'quitApp': 'Quit',
    'toggleFullscreen': 'Toggle Fullscreen',
  };

  /// Serialize a [SingleActivator] to a string like "Ctrl+Shift+A".
  static String activatorToString(SingleActivator activator) {
    final parts = <String>[];
    if (activator.control) parts.add('Ctrl');
    if (activator.shift) parts.add('Shift');
    if (activator.alt) parts.add('Alt');
    if (activator.meta) parts.add('Meta');
    parts.add(activator.trigger.keyLabel.isNotEmpty ? activator.trigger.keyLabel : activator.trigger.debugName ?? 'Unknown');
    return parts.join('+');
  }

  /// Deserialize a string like "Ctrl+Shift+A" to a [SingleActivator].
  static SingleActivator? activatorFromString(String s) {
    final parts = s.split('+');
    if (parts.isEmpty) return null;

    bool ctrl = false, shift = false, alt = false, meta = false;
    String? keyLabel;

    for (final part in parts) {
      switch (part) {
        case 'Ctrl':
          ctrl = true;
        case 'Shift':
          shift = true;
        case 'Alt':
          alt = true;
        case 'Meta':
          meta = true;
        default:
          keyLabel = part;
      }
    }

    if (keyLabel == null) return null;

    // Find key by label
    final key = _findKeyByLabel(keyLabel);
    if (key == null) return null;

    return SingleActivator(key, control: ctrl, shift: shift, alt: alt, meta: meta);
  }

  static LogicalKeyboardKey? _findKeyByLabel(String label) {
    // Check common keys first
    final lower = label.toLowerCase();

    // Special keys
    const specialMap = <String, LogicalKeyboardKey>{
      'space': LogicalKeyboardKey.space,
      'enter': LogicalKeyboardKey.enter,
      'escape': LogicalKeyboardKey.escape,
      'tab': LogicalKeyboardKey.tab,
      'backspace': LogicalKeyboardKey.backspace,
      'delete': LogicalKeyboardKey.delete,
      'arrow up': LogicalKeyboardKey.arrowUp,
      'arrow down': LogicalKeyboardKey.arrowDown,
      'arrow left': LogicalKeyboardKey.arrowLeft,
      'arrow right': LogicalKeyboardKey.arrowRight,
      'f1': LogicalKeyboardKey.f1,
      'f2': LogicalKeyboardKey.f2,
      'f3': LogicalKeyboardKey.f3,
      'f4': LogicalKeyboardKey.f4,
      'f5': LogicalKeyboardKey.f5,
      'f6': LogicalKeyboardKey.f6,
      'f7': LogicalKeyboardKey.f7,
      'f8': LogicalKeyboardKey.f8,
      'f9': LogicalKeyboardKey.f9,
      'f10': LogicalKeyboardKey.f10,
      'f11': LogicalKeyboardKey.f11,
      'f12': LogicalKeyboardKey.f12,
    };

    if (specialMap.containsKey(lower)) return specialMap[lower];

    // Letter keys
    if (lower.length == 1) {
      final code = lower.codeUnitAt(0);
      if (code >= 0x61 && code <= 0x7A) {
        // a-z
        return LogicalKeyboardKey(code - 0x61 + LogicalKeyboardKey.keyA.keyId);
      }
      if (code >= 0x30 && code <= 0x39) {
        // 0-9
        return LogicalKeyboardKey(code - 0x30 + LogicalKeyboardKey.digit0.keyId);
      }
    }

    // Try matching keyLabel from known keys
    for (final entry in LogicalKeyboardKey.knownLogicalKeys) {
      if (entry.keyLabel.toLowerCase() == lower || (entry.debugName?.toLowerCase() ?? '') == lower) {
        return entry;
      }
    }

    return null;
  }
}
