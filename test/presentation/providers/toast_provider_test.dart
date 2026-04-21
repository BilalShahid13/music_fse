import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/presentation/providers/toast_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('starts with no toast', () {
    expect(container.read(toastProvider), isNull);
  });

  test('show sets toast data', () {
    container.read(toastProvider.notifier).show('Hello');
    final data = container.read(toastProvider);
    expect(data, isNotNull);
    expect(data!.message, 'Hello');
    expect(data.isError, false);
    expect(data.hasUndo, false);
  });

  test('show with isError flag', () {
    container.read(toastProvider.notifier).show('Err', isError: true);
    final data = container.read(toastProvider);
    expect(data!.isError, true);
  });

  test('show with undo action', () {
    var undone = false;
    container.read(toastProvider.notifier).show(
          'Removed',
          undoAction: () => undone = true,
          undoLabel: 'Undo',
        );
    final data = container.read(toastProvider);
    expect(data!.hasUndo, true);
    expect(data.undoLabel, 'Undo');
    data.undoAction!();
    expect(undone, true);
  });

  test('dismiss clears toast', () {
    container.read(toastProvider.notifier).show('X');
    container.read(toastProvider.notifier).dismiss();
    expect(container.read(toastProvider), isNull);
  });

  test('show replaces previous toast', () {
    container.read(toastProvider.notifier).show('First');
    container.read(toastProvider.notifier).show('Second');
    expect(container.read(toastProvider)!.message, 'Second');
  });
}
