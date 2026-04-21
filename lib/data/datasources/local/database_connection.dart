import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

/// Creates and returns the [AppDatabase] instance connected to the on-disk
/// SQLite file inside the application's support directory.
///
/// This is the platform-specific factory used by the database Riverpod
/// provider. It uses [LazyDatabase] so the file path is resolved
/// asynchronously after platform channels are ready.
AppDatabase constructDatabase() {
  return AppDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'music_fse.sqlite'));

      // Use NativeDatabase on the main isolate instead of
      // createInBackground to avoid a cross-isolate FFI callback
      // race condition during engine shutdown (SIGABRT in
      // DLRT_GetFfiCallbackMetadata when sqlite3Close runs after
      // the main isolate's FFI metadata is torn down).
      return NativeDatabase(
        file,
        // Enable WAL mode for better concurrent read performance.
        setup: (rawDb) {
          rawDb.execute('PRAGMA journal_mode=WAL;');
          rawDb.execute('PRAGMA foreign_keys=ON;');
          rawDb.execute('PRAGMA synchronous=NORMAL;');
        },
      );
    }),
  );
}
