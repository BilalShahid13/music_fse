// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_folder_dao.dart';

// ignore_for_file: type=lint
mixin _$ScanFolderDaoMixin on DatabaseAccessor<AppDatabase> {
  $ScanFoldersTable get scanFolders => attachedDatabase.scanFolders;
  ScanFolderDaoManager get managers => ScanFolderDaoManager(this);
}

class ScanFolderDaoManager {
  final _$ScanFolderDaoMixin _db;
  ScanFolderDaoManager(this._db);
  $$ScanFoldersTableTableManager get scanFolders =>
      $$ScanFoldersTableTableManager(_db.attachedDatabase, _db.scanFolders);
}
