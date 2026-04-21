import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'multi_select_provider.g.dart';

@riverpod
class MultiSelectNotifier extends _$MultiSelectNotifier {
  @override
  ({bool isActive, Set<int> selectedIds}) build() => (isActive: false, selectedIds: const {});

  void activate() {
    state = (isActive: true, selectedIds: state.selectedIds);
  }

  void deactivate() {
    state = (isActive: false, selectedIds: const {});
  }

  void toggleSelection(int songId) {
    final ids = Set<int>.from(state.selectedIds);
    if (ids.contains(songId)) {
      ids.remove(songId);
    } else {
      ids.add(songId);
    }
    state = (isActive: state.isActive, selectedIds: ids);
  }

  void selectAll(List<int> allIds) {
    state = (isActive: true, selectedIds: Set<int>.from(allIds));
  }

  void deselectAll() {
    state = (isActive: state.isActive, selectedIds: const {});
  }

  int get count => state.selectedIds.length;
}
