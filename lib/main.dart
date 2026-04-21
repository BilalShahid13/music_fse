import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';

import 'core/utils/logger.dart';
import 'platform/single_instance/single_instance.dart';
import 'platform/window/window_manager_helper.dart';
import 'presentation/app.dart';

/// Application entry point.
///
/// Startup sequence (each step must complete before the next):
///   1. [WidgetsFlutterBinding.ensureInitialized] — required before any
///      platform channel or FFI call.
///   2. Single-instance mutex (Windows only) — exit immediately if a second
///      instance is detected.
///   3. [WindowManagerHelper.initialize] — configures the native window
///      (size, title-bar style, centre-on-screen) and shows it.
///   4. Image cache limit — cap in-memory decoded image cache to the budget
///      defined in CLAUDE.md §5.2 (200 images / 50 MB).
///   5. [runApp] — start the widget tree inside a [ProviderScope].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize metadata_god's Rust library (must run after binding init).
  await MetadataGod.initialize();

  AppLogger.info('Music FSE starting', tag: 'main');

  // ── Single-instance enforcement (Windows only) ─────────────────────────────
  if (Platform.isWindows) {
    if (!SingleInstance.acquire()) {
      // A previous instance already holds the mutex.
      // Bring it to the foreground before terminating this duplicate process.
      AppLogger.info('Second instance detected — exiting', tag: 'main');
      SingleInstance.focusExistingInstanceAndExit();
      return;
    }
  }

  // ── Native window setup ────────────────────────────────────────────────────
  await WindowManagerHelper.initialize();

  // ── Image cache budget (CLAUDE.md §5.2) ───────────────────────────────────
  // Flutter's default is unlimited; cap it to avoid excessive RAM on low-end
  // handheld gaming PCs when the user browses large libraries.
  PaintingBinding.instance.imageCache
    ..maximumSize = 200 // max decoded images in memory
    ..maximumSizeBytes = 50 * 1024 * 1024; // 50 MB

  AppLogger.info('Startup complete — launching UI', tag: 'main');

  runApp(
    const ProviderScope(
      child: MusicFseApp(),
    ),
  );
}
