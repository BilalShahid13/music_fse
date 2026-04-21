import 'package:flutter/widgets.dart' show Locale;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/logger.dart';
import '../../domain/repositories/settings_repository.dart';
import 'repository_providers.dart';

part 'locale_provider.g.dart';

/// Supported locale tags.
const List<String> _supportedLocaleTags = ['en'];

/// Manages the active app locale.
///
/// Changing this triggers a full [MaterialApp] rebuild so the language switch
/// is instant — no app restart required. The chosen locale is persisted to
/// [SettingsRepository] and restored on next launch.
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    _loadFromSettings();
    return const Locale('en');
  }

  Future<void> _loadFromSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    // Reuse the key convention — locale is stored under its own key.
    final localeResult =
        await repo.getString('locale'); // Not in SettingsKeys — raw string.
    final tag = localeResult.valueOrNull;
    if (tag != null && _supportedLocaleTags.contains(tag)) {
      state = Locale(tag);
    }
  }

  /// Sets the active locale and persists the change.
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final repo = ref.read(settingsRepositoryProvider);
    final result = await repo.setString('locale', locale.languageCode);
    if (result.isFailure) {
      AppLogger.error(
        'LocaleNotifier: failed to persist locale',
        tag: 'LocaleNotifier',
        error: result.errorOrNull,
      );
    }
  }
}
