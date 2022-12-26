import 'package:vsc_quill_delta_to_html/src/helpers/array.dart';
import 'package:test/test.dart';

void main() {
  group('Array Helpers Module', () {
    group('preferSecond()', () {
      test('should return second element in an array, otherwise first or null',
          () {
        expect(preferSecond([1, 3]), 3);
        expect(preferSecond([5]), 5);
        expect(preferSecond([]), null);
      });
    });

    group('flatten()', () {
      test('should return deeply flattened array', () {
        expect(
            flatten([
              1,
              3,
              [
                4,
                [
                  5,
                  [6, 7]
                ]
              ]
            ]),
            [1, 3, 4, 5, 6, 7]);
        expect([], flatten([]));
      });
    });

    group('groupConsecutiveElementsWhile()', () {
      test('should move consecutive elements matching predicate into an arr',
          () {
        final arr = [1, 'ha', 3, 'ha', 'ha'];
        final grp = groupConsecutiveElementsWhile(
            arr, (v, v2) => v.runtimeType == v2.runtimeType);
        expect(grp, [
          1,
          'ha',
          3,
          ['ha', 'ha']
        ]);

        final arr2 = [1, 2, 3, 10, 11, 12];
        final grp2 =
            groupConsecutiveElementsWhile(arr2, (v, v2) => v - 1 == v2);
        expect(grp2, [
          [1, 2, 3],
          [10, 11, 12],
        ]);
      });
    });

    group('intersperse()', () {
      test('should put specified element between arr elements', () {
        expect(intersperse([1, 3, 4], 0), [1, 0, 3, 0, 4]);
        expect(intersperse([1], 2), [1]);
      });
    });
  });
}
