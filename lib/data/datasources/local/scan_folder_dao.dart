import 'package:drift/drift.dart';

import 'database.dart';

part 'scan_folder_dao.g.dart';

@DriftAccessor(tables: [ScanFolders])
class ScanFolderDao extends DatabaseAccessor<AppDatabase>
    with _$ScanFolderDaoMixin {
  ScanFolderDao(super.db);

  Future<List<ScanFolder>> getAll() =>
      (select(scanFolders)
            ..orderBy([(f) => OrderingTerm.asc(f.path)]))
          .get();

  Future<int> addFolder(String path) =>
      into(scanFolders)
          .insertReturning(ScanFoldersCompanion.insert(path: path))
          .then((row) => row.id);

  Future<void> removeFolder(int id) =>
      (delete(scanFolders)..where((f) => f.id.equals(id))).go();

  Future<void> toggleEnabled(int id, {required bool enabled}) =>
      (update(scanFolders)..where((f) => f.id.equals(id))).write(
        ScanFoldersCompanion(enabled: Value(enabled)),
      );

  Future<void> updateLastScanned(int id, DateTime time) =>
      (update(scanFolders)..where((f) => f.id.equals(id))).write(
        ScanFoldersCompanion(lastScannedAt: Value(time)),
      );
}
