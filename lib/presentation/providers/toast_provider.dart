import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';

part 'toast_provider.g.dart';

// ---------------------------------------------------------------------------
// Toast data
// ---------------------------------------------------------------------------

/// Immutable payload for a single toast notification.
///
/// [undoAction] and [undoLabel] are populated only for destructive operations
/// that offer an "Undo" affordance (e.g. removing a song from a playlist).
@immutable
final class ToastData {
  const ToastData({
    required this.message,
    this.isError = false,
    this.undoAction,
    this.undoLabel,
  });

  final String message;
  final bool isError;

  /// Called when the user presses the "Undo" button.
  final VoidCallback? undoAction;

  /// Label for the undo button. Defaults to "Undo" if [undoAction] is set
  /// and this is null.
  final String? undoLabel;

  bool get hasUndo => undoAction != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToastData &&
          other.message == message &&
          other.isError == isError;

  @override
  int get hashCode => Object.hash(message, isError);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

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
@Riverpod(keepAlive: true)
class ToastNotifier extends _$ToastNotifier {
  Timer? _dismissTimer;

  @override
  ToastData? build() {
    ref.onDispose(() => _dismissTimer?.cancel());
    return null;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Displays a toast with [message].
  ///
  /// If a toast is already visible it is replaced immediately. The dismiss
  /// timer resets.
  void show(
    String message, {
    bool isError = false,
    VoidCallback? undoAction,
    String? undoLabel,
  }) {
    _dismissTimer?.cancel();
    state = ToastData(
      message: message,
      isError: isError,
      undoAction: undoAction,
      undoLabel: undoLabel,
    );
    _dismissTimer = Timer(
      const Duration(seconds: AppConstants.toastDurationSec),
      dismiss,
    );
  }

  /// Immediately hides the current toast.
  void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    state = null;
  }
}
