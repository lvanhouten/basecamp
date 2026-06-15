import 'package:basecamp/features/lists/data/apply_reorder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('applyReorder', () {
    test('move down: index reported one-past gets the off-by-one fix', () {
      // ReorderableListView reports newIndex = 2 when dragging item 0 down past
      // item 1; the helper decrements it so 10 lands right after 20.
      expect(applyReorder([10, 20, 30, 40], 0, 2), [20, 10, 30, 40]);
    });

    test('move down to last', () {
      expect(applyReorder([10, 20, 30, 40], 0, 4), [20, 30, 40, 10]);
    });

    test('move up', () {
      expect(applyReorder([10, 20, 30, 40], 3, 1), [10, 40, 20, 30]);
    });

    test('move to first', () {
      expect(applyReorder([10, 20, 30, 40], 2, 0), [30, 10, 20, 40]);
    });

    test('move to last (from middle)', () {
      // newIndex = length reported when dropping at the very bottom.
      expect(applyReorder([10, 20, 30, 40], 1, 4), [10, 30, 40, 20]);
    });

    test('no-op when oldIndex == newIndex', () {
      expect(applyReorder([10, 20, 30, 40], 2, 2), [10, 20, 30, 40]);
    });

    test('no-op after off-by-one resolves to same slot', () {
      // Dragging item 1 "down" to reported index 2 resolves to index 1 again.
      expect(applyReorder([10, 20, 30, 40], 1, 2), [10, 20, 30, 40]);
    });

    test('single-element list is unchanged', () {
      expect(applyReorder([10], 0, 0), [10]);
    });

    test('two-element list: swap via move down', () {
      expect(applyReorder([10, 20], 0, 2), [20, 10]);
    });

    test('two-element list: swap via move up', () {
      expect(applyReorder([10, 20], 1, 0), [20, 10]);
    });

    test('two-element list: no-op', () {
      expect(applyReorder([10, 20], 0, 1), [10, 20]);
    });

    test('does not mutate the input list', () {
      final input = [10, 20, 30];
      applyReorder(input, 0, 3);
      expect(input, [10, 20, 30]);
    });
  });
}
