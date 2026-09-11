import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_fse/core/constants/app_enums.dart';
import 'package:music_fse/core/theme/app_theme.dart';
import 'package:riverpod/misc.dart' show Override;

/// Wraps [child] in a [ProviderScope] and [MaterialApp] for widget testing.
///
/// Pass [overrides] to inject mock providers.
Widget testApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.buildTheme(
        accentColor: Colors.blue,
        accentTextColor: AccentTextColorSetting.auto,
        appFont: AppFontSetting.inter,
        brightness: Brightness.dark,
      ),
      home: Scaffold(body: child),
    ),
  );
}
