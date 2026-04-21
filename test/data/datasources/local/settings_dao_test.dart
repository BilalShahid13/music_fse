import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/data/datasources/local/database.dart';
import 'package:music_fse/data/datasources/local/settings_dao.dart';

void main() {
  late AppDatabase db;
  late SettingsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = SettingsDao(db);
  });

  tearDown(() => db.close());

  test('getValue returns null for missing key', () async {
    expect(await dao.getValue('absent'), isNull);
  });

  test('setValue and getValue round-trip', () async {
    await dao.setValue('theme', 'dark');
    expect(await dao.getValue('theme'), 'dark');
  });

  test('setValue overwrites existing key', () async {
    await dao.setValue('vol', '0.5');
    await dao.setValue('vol', '0.8');
    expect(await dao.getValue('vol'), '0.8');
  });

  test('remove deletes a key', () async {
    await dao.setValue('tmp', 'x');
    await dao.remove('tmp');
    expect(await dao.getValue('tmp'), isNull);
  });

  test('remove on absent key is a no-op', () async {
    await dao.remove('nonexistent');
    // No exception thrown
  });
}
