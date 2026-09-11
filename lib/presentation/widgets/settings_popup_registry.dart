import 'package:flutter/widgets.dart';

/// Tracks whether the settings theme mode popup is currently open.
final ValueNotifier<bool> settingsThemePopupVisible = ValueNotifier<bool>(false);

/// Dismiss action for the active settings theme mode popup.
final ValueNotifier<VoidCallback?> settingsThemePopupDismiss = ValueNotifier<VoidCallback?>(null);

/// Tracks whether the settings accent color popup is currently open.
final ValueNotifier<bool> settingsColorPopupVisible = ValueNotifier<bool>(false);

/// Dismiss action for the active settings accent color popup.
final ValueNotifier<VoidCallback?> settingsColorPopupDismiss = ValueNotifier<VoidCallback?>(null);

/// Tracks whether the settings app font popup is currently open.
final ValueNotifier<bool> settingsFontPopupVisible = ValueNotifier<bool>(false);

/// Dismiss action for the active settings app font popup.
final ValueNotifier<VoidCallback?> settingsFontPopupDismiss = ValueNotifier<VoidCallback?>(null);
