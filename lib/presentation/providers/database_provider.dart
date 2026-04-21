import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/local/database.dart';
import '../../data/datasources/local/database_connection.dart';

part 'database_provider.g.dart';

/// Singleton provider for the Drift [AppDatabase] instance.
///
/// Marked [keepAlive] so the connection is never torn down while the app is
/// running. [ref.onDispose] closes the connection on hot-restart / test teardown.
@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = constructDatabase();
  ref.onDispose(db.close);
  return db;
}
