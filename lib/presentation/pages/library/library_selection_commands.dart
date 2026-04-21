import 'package:flutter/foundation.dart';

/// Shell-facing callbacks for Songs tab multi-select actions.
final ValueNotifier<VoidCallback?> librarySelectionAddToQueue = ValueNotifier<VoidCallback?>(null);
final ValueNotifier<VoidCallback?> librarySelectionAddToPlaylist = ValueNotifier<VoidCallback?>(null);
final ValueNotifier<VoidCallback?> librarySelectionSelectAll = ValueNotifier<VoidCallback?>(null);
final ValueNotifier<VoidCallback?> librarySelectionCancel = ValueNotifier<VoidCallback?>(null);
