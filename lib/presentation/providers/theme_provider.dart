import 'package:flutter/material.dart' show Brightness, Color;
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
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
    this.accentTextColor = AccentTextColorSetting.auto,
    this.appFont = AppFontSetting.inter,
    this.uiScale = 1.0,
  });

  final ThemeModeSetting mode;
  final Color accentColor;
  final AccentTextColorSetting accentTextColor;
  final AppFontSetting appFont;
  final double uiScale;

  ThemeState copyWith({
    ThemeModeSetting? mode,
    Color? accentColor,
    AccentTextColorSetting? accentTextColor,
    AppFontSetting? appFont,
    double? uiScale,
  }) =>
      ThemeState(
        mode: mode ?? this.mode,
        accentColor: accentColor ?? this.accentColor,
        accentTextColor: accentTextColor ?? this.accentTextColor,
        appFont: appFont ?? this.appFont,
        uiScale: uiScale ?? this.uiScale,
      );

  static const double minUiScale = 0.85;
  static const double maxUiScale = 1.15;

  @override
  bool operator ==(Object other) => identical(this, other) ||
      other is ThemeState &&
          other.mode == mode &&
          other.accentColor == accentColor &&
          other.accentTextColor == accentTextColor &&
          other.appFont == appFont &&
          other.uiScale == uiScale;

  @override
  int get hashCode => Object.hash(mode, accentColor, accentTextColor, appFont, uiScale);
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
    final accentTextColorResult = await repo.getString(SettingsKeys.accentTextColor);
    final appFontResult = await repo.getString(SettingsKeys.appFont);
    final uiScaleResult = await repo.getDouble(SettingsKeys.uiScale);

    final modeStr = modeResult.valueOrNull;
    final colorInt = colorResult.valueOrNull;
    final accentTextColorStr = accentTextColorResult.valueOrNull;
    final appFontStr = appFontResult.valueOrNull;
    final uiScale = (uiScaleResult.valueOrNull ?? 1.0).clamp(
      ThemeState.minUiScale,
      ThemeState.maxUiScale,
    );

    final mode = switch (modeStr) {
      'light' => ThemeModeSetting.light,
      'system' => ThemeModeSetting.system,
      _ => ThemeModeSetting.dark,
    };
    final appFont = switch (appFontStr) {
      'poppins' => AppFontSetting.poppins,
      'roboto' => AppFontSetting.roboto,
      'nunitoSans' => AppFontSetting.nunitoSans,
      _ => AppFontSetting.inter,
    };
    final accentTextColor = switch (accentTextColorStr) {
      'dark' => AccentTextColorSetting.dark,
      'light' => AccentTextColorSetting.light,
      _ => AccentTextColorSetting.auto,
    };

    final accentColor = colorInt != null ? Color(colorInt) : const Color(AppConstants.defaultAccentColorValue);

    state = ThemeState(
      mode: mode,
      accentColor: accentColor,
      accentTextColor: accentTextColor,
      appFont: appFont,
      uiScale: uiScale,
    );
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
    final result = await repo.setInt(SettingsKeys.accentColor, color.toARGB32());
    if (result.isFailure) {
      AppLogger.error(
        'ThemeNotifier: failed to persist accent color',
        tag: 'ThemeNotifier',
        error: result.errorOrNull,
      );
    }
  }

  /// Changes the foreground color mode used on accent surfaces.
  Future<void> setAccentTextColor(AccentTextColorSetting accentTextColor) async {
    state = state.copyWith(accentTextColor: accentTextColor);
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setString(
      SettingsKeys.accentTextColor,
      accentTextColor.name,
    );
    if (result.isFailure) {
      AppLogger.error(
        'ThemeNotifier: failed to persist accent text color',
        tag: 'ThemeNotifier',
        error: result.errorOrNull,
      );
    }
  }

  /// Changes the application font family and persists the choice.
  Future<void> setAppFont(AppFontSetting appFont) async {
    state = state.copyWith(appFont: appFont);
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setString(SettingsKeys.appFont, appFont.name);
    if (result.isFailure) {
      AppLogger.error(
        'ThemeNotifier: failed to persist app font',
        tag: 'ThemeNotifier',
        error: result.errorOrNull,
      );
    }
  }

  /// Changes the global UI scale and persists the choice.
  Future<void> setUiScale(double scale) async {
    final clampedScale = scale.clamp(
      ThemeState.minUiScale,
      ThemeState.maxUiScale,
    );
    state = state.copyWith(uiScale: clampedScale);

    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setDouble(SettingsKeys.uiScale, clampedScale);
    if (result.isFailure) {
      AppLogger.error(
        'ThemeNotifier: failed to persist UI scale',
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
