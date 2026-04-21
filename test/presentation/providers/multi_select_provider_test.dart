import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/presentation/providers/multi_select_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('starts inactive with empty selection', () {
    final state = container.read(multiSelectProvider);
    expect(state.isActive, false);
    expect(state.selectedIds, isEmpty);
  });

  test('activate enables multi-select mode', () {
    container.read(multiSelectProvider.notifier).activate();
    expect(container.read(multiSelectProvider).isActive, true);
  });

  test('deactivate clears selection', () {
    container.read(multiSelectProvider.notifier).activate();
    container.read(multiSelectProvider.notifier).toggleSelection(1);
    container.read(multiSelectProvider.notifier).deactivate();
    final state = container.read(multiSelectProvider);
    expect(state.isActive, false);
    expect(state.selectedIds, isEmpty);
  });

  test('toggleSelection adds and removes ids', () {
    final notifier = container.read(multiSelectProvider.notifier);
    notifier.toggleSelection(1);
    expect(container.read(multiSelectProvider).selectedIds, {1});
    notifier.toggleSelection(2);
    expect(container.read(multiSelectProvider).selectedIds, {1, 2});
    notifier.toggleSelection(1);
    expect(container.read(multiSelectProvider).selectedIds, {2});
  });

  test('toggleSelection last item keeps selection mode active', () {
    final notifier = container.read(multiSelectProvider.notifier);
    notifier.activate();
    notifier.toggleSelection(1);
    notifier.toggleSelection(1); // removes last
    final state = container.read(multiSelectProvider);
    expect(state.isActive, true);
    expect(state.selectedIds, isEmpty);
  });

  test('selectAll selects all provided ids', () {
    container.read(multiSelectProvider.notifier).selectAll([1, 2, 3]);
    final state = container.read(multiSelectProvider);
    expect(state.isActive, true);
    expect(state.selectedIds, {1, 2, 3});
  });

  test('deselectAll clears selected ids without exiting selection mode', () {
    final notifier = container.read(multiSelectProvider.notifier);
    notifier.activate();
    notifier.selectAll([1, 2]);
    notifier.deselectAll();
    final state = container.read(multiSelectProvider);
    expect(state.isActive, true);
    expect(state.selectedIds, isEmpty);
  });

  test('count returns number of selected items', () {
    final notifier = container.read(multiSelectProvider.notifier);
    notifier.selectAll([1, 2, 3]);
    expect(notifier.count, 3);
  });
}
