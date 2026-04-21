import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/data/datasources/local/settings_dao.dart';
import 'package:music_fse/data/repositories/settings_repository_impl.dart';

class MockSettingsDao extends Mock implements SettingsDao {}

void main() {
  late MockSettingsDao mockDao;
  late SettingsRepositoryImpl repo;

  setUp(() {
    mockDao = MockSettingsDao();
    repo = SettingsRepositoryImpl(mockDao);
  });

  group('getString', () {
    test('returns value from dao', () async {
      when(() => mockDao.getValue('key')).thenAnswer((_) async => 'hello');

      final result = await repo.getString('key');

      expect(result.isSuccess, true);
      expect(result.valueOrNull, 'hello');
    });

    test('returns null for missing key', () async {
      when(() => mockDao.getValue('x')).thenAnswer((_) async => null);

      final result = await repo.getString('x');

      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNull);
    });

    test('returns failure on exception', () async {
      when(() => mockDao.getValue(any())).thenThrow(Exception('db error'));

      final result = await repo.getString('fail');

      expect(result.isFailure, true);
    });
  });

  group('getBool', () {
    test('returns true for "true" string', () async {
      when(() => mockDao.getValue('b')).thenAnswer((_) async => 'true');

      final result = await repo.getBool('b');

      expect(result.valueOrNull, true);
    });

    test('returns false for other strings', () async {
      when(() => mockDao.getValue('b')).thenAnswer((_) async => 'false');

      final result = await repo.getBool('b');

      expect(result.valueOrNull, false);
    });

    test('returns null when not set', () async {
      when(() => mockDao.getValue('b')).thenAnswer((_) async => null);

      final result = await repo.getBool('b');

      expect(result.valueOrNull, isNull);
    });
  });

  group('setString', () {
    test('delegates to dao', () async {
      when(() => mockDao.setValue('k', 'v')).thenAnswer((_) async {});

      final result = await repo.setString('k', 'v');

      expect(result.isSuccess, true);
      verify(() => mockDao.setValue('k', 'v')).called(1);
    });
  });

  group('setBool', () {
    test('stores "true" for true', () async {
      when(() => mockDao.setValue('b', 'true')).thenAnswer((_) async {});

      await repo.setBool('b', value: true);

      verify(() => mockDao.setValue('b', 'true')).called(1);
    });
  });

  group('setInt', () {
    test('stores int as string', () async {
      when(() => mockDao.setValue('n', '42')).thenAnswer((_) async {});

      await repo.setInt('n', 42);

      verify(() => mockDao.setValue('n', '42')).called(1);
    });
  });

  group('getInt', () {
    test('parses stored string', () async {
      when(() => mockDao.getValue('n')).thenAnswer((_) async => '42');

      final result = await repo.getInt('n');

      expect(result.valueOrNull, 42);
    });

    test('returns null for missing', () async {
      when(() => mockDao.getValue('n')).thenAnswer((_) async => null);

      final result = await repo.getInt('n');

      expect(result.valueOrNull, isNull);
    });
  });
}
