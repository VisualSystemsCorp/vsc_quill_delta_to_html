import 'package:collection/collection.dart';

class ArraySlice<T> {
  ArraySlice(this.sliceStartsAt, this.elements);

  int sliceStartsAt;
  List<T> elements;
}

T? preferSecond<T>(List<T> arr) {
  if (arr.isEmpty) {
    return null;
  }
  return arr.length >= 2 ? arr[1] : arr[0];
}

List<T> flatten<T>(Iterable list) => [
      for (var element in list)
        if (element is! Iterable) element else ...flatten(element as List),
    ];

/// Returns a new array by putting consecutive elements satisfying predicate into a new
/// array and returning others as they are.
/// Ex: [1, "ha", 3, "ha", "ha"] => [1, "ha", 3, ["ha", "ha"]]
///      where predicate: (v, vprev) => typeof v === typeof vPrev
List groupConsecutiveElementsWhile<T>(
    List<T> arr, bool Function(T currElm, T prevElm) predicate) {
  var groups = [];

  dynamic currElm;
  List currGroup;
  for (var i = 0; i < arr.length; i++) {
    currElm = arr[i];

    if (i > 0 && predicate(currElm, arr[i - 1])) {
      currGroup = groups[groups.length - 1];
      currGroup.add(currElm);
    } else {
      groups.add([currElm]);
    }
  }
  return groups.map((g) => (g.length == 1 ? g[0] : g)).toList();
}

/// Returns consecutive list of elements satisfying the predicate starting from startIndex
/// and traversing the array in reverse order.
ArraySlice<T> sliceFromReverseWhile<T>(
  List<T> arr,
  int startIndex,
  bool Function(T currElm) predicate,
) {
  var result = ArraySlice(-1, <T>[]);
  for (var i = startIndex; i >= 0; i--) {
    if (!predicate(arr[i])) {
      break;
    }
    result.sliceStartsAt = i;
    result.elements.insert(0, arr[i]);
  }
  return result;
}

/// (arr: [1, 3, 4], item: 0) yields: [1, 0, 3, 0, 4]
List<T> intersperse<T>(List<T> arr, T item) {
  return arr.foldIndexed(<T>[], (int index, List<T> pv, T v) {
    pv.add(v);
    if (index < arr.length - 1) {
      pv.add(item);
    }
    return pv;
  });
}
