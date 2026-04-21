import 'package:flutter/widgets.dart';

/// Tracks mini player popup state so shell-level hints can reflect modal behavior.
final ValueNotifier<bool> miniPlayerVolumePopupVisible = ValueNotifier<bool>(false);

/// Dismiss action for the currently open mini player volume popup.
final ValueNotifier<VoidCallback?> miniPlayerVolumePopupDismiss = ValueNotifier<VoidCallback?>(null);
