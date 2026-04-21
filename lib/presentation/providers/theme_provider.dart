import 'package:flutter/material.dart' show Brightness, Color;
import 'package:riverpod/riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_enums.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/settings_repository.dart';
import 'repository_providers.dart';

part 'theme_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Immutable snapshot of the current theme configuration.
final class ThemeState {
  const ThemeState({
    this.mode = ThemeModeSetting.dark,
    this.accentColor = const Color(AppConstants.defaultAccentColorValue),
  });

  final ThemeModeSetting mode;
  final Color accentColor;

  ThemeState copyWith({
    ThemeModeSetting? mode,
    Color? accentColor,
  }) =>
      ThemeState(
        mode: mode ?? this.mode,
        accentColor: accentColor ?? this.accentColor,
      );

  @override
  bool operator ==(Object other) => identical(this, other) || other is ThemeState && other.mode == mode && other.accentColor == accentColor;

  @override
  int get hashCode => Object.hash(mode, accentColor);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Manages theme brightness and accent color.
///
/// Values are persisted to [SettingsRepository] and loaded at startup so the
/// user's preference survives app restarts.
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeState build() {
    _loadFromSettings();
    return const ThemeState();
  }

  Future<void> _loadFromSettings() async {
    final repo = ref.read(settingsRepositoryProvider);

    final modeResult = await repo.getString(SettingsKeys.themeMode);
    final colorResult = await repo.getInt(SettingsKeys.accentColor);

    final modeStr = modeResult.valueOrNull;
    final colorInt = colorResult.valueOrNull;

    final mode = switch (modeStr) {
      'light' => ThemeModeSetting.light,
      'system' => ThemeModeSetting.system,
      _ => ThemeModeSetting.dark,
    };

    final accentColor = colorInt != null ? Color(colorInt) : const Color(AppConstants.defaultAccentColorValue);

    state = ThemeState(mode: mode, accentColor: accentColor);
  }

  /// Changes the theme brightness and persists the choice.
  Future<void> setThemeMode(ThemeModeSetting mode) async {
    state = state.copyWith(mode: mode);
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setString(SettingsKeys.themeMode, mode.name);
    if (result.isFailure) {
      AppLogger.error(
        'ThemeNotifier: failed to persist theme mode',
        tag: 'ThemeNotifier',
        error: result.errorOrNull,
      );
    }
  }

  /// Changes the accent color and persists the choice.
  Future<void> setAccentColor(Color color) async {
    state = state.copyWith(accentColor: color);
    final repo = ref.read(settingsRepositoryProvider);
    // Store as ARGB int — zero-loss representation.
    final result = await repo.setInt(SettingsKeys.accentColor, color.value);
    if (result.isFailure) {
      AppLogger.error(
        'ThemeNotifier: failed to persist accent color',
        tag: 'ThemeNotifier',
        error: result.errorOrNull,
      );
    }
  }

  /// Returns the resolved [Brightness] for the current platform.
  ///
  /// When [ThemeModeSetting.system], falls back to dark since we cannot read
  /// the platform brightness from a provider (no [BuildContext]). The
  /// [MaterialApp] correctly handles system mode via [ThemeMode.system].
  Brightness get brightness => switch (state.mode) {
        ThemeModeSetting.dark => Brightness.dark,
        ThemeModeSetting.light => Brightness.light,
        ThemeModeSetting.system => Brightness.dark,
      };
}

// ---------------------------------------------------------------------------
// Convenience selector providers
// ---------------------------------------------------------------------------

/// Current accent color — avoids rebuilding widgets that only care about color.
@riverpod
Color accentColor(Ref ref) => ref.watch(themeProvider.select((s) => s.accentColor));

/// Current theme mode setting.
@riverpod
ThemeModeSetting themeModeSetting(Ref ref) => ref.watch(themeProvider.select((s) => s.mode));
