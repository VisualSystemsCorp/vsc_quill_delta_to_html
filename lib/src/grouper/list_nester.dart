import 'package:vsc_quill_delta_to_html/src/helpers/array.dart';

import 'group_types.dart';

class ListNester {
  List<TDataGroup> nest(List<TDataGroup> groups) {
    var listBlocked = _convertListBlocksToListGroups(groups);
    var groupedByListGroups = _groupConsecutiveListGroups(listBlocked);

    // convert grouped ones into listgroup
    final nested = flatten<TDataGroup>(groupedByListGroups.map((group) {
      if (group is! List) {
        return group as TDataGroup;
      }

      return _nestListSection(List.castFrom(group));
    }));

    final groupRootLists = groupConsecutiveElementsWhile(nested, (curr, prev) {
      if (!(curr is ListGroup && prev is ListGroup)) {
        return false;
      }

      return curr.items[0].item.op.isSameListAs(prev.items[0].item.op);
    });

    return groupRootLists.map((/*TDataGroup | List<ListGroup>*/ v) {
      if (v is! List) {
        return v as TDataGroup;
      }

      final listOfItems =
          List.castFrom<dynamic, ListGroup>(v).map((g) => g.items);
      return ListGroup(flatten(listOfItems));
    }).toList();
  }

  List<TDataGroup> _convertListBlocksToListGroups(List<TDataGroup> items) {
    var grouped = groupConsecutiveElementsWhile(items, (g, gPrev) {
      return g is BlockGroup &&
          gPrev is BlockGroup &&
          g.op.isList() &&
          gPrev.op.isList() &&
          g.op.isSameListAs(gPrev.op) &&
          g.op.hasSameIndentationAs(gPrev.op);
    });

    return grouped.map((/*TDataGroup | BlockGroup[]*/ item) {
      if (item is! List) {
        if (item is BlockGroup && item.op.isList()) {
          return ListGroup([ListItem(item)]);
        }
        return item as TDataGroup;
      }
      return ListGroup(item.map((g) => ListItem(g as BlockGroup)).toList());
    }).toList();
  }

  List<dynamic /*Array<TDataGroup | List<ListGroup>*/ >
      _groupConsecutiveListGroups(List<TDataGroup> items) {
    return groupConsecutiveElementsWhile(items, (curr, prev) {
      return curr is ListGroup && prev is ListGroup;
    });
  }

  List<ListGroup> _nestListSection(List<ListGroup> sectionItems) {
    final indentGroups = _groupByIndent(sectionItems);

    final indentLevels = indentGroups.keys.toList();
    indentLevels.sort();
    for (final indent in indentLevels.reversed) {
      for (final lg in indentGroups[indent]!) {
        final idx = sectionItems.indexOf(lg);
        if (_placeUnderParent(lg, sectionItems.sublist(0, idx))) {
          sectionItems.removeAt(idx);
        }
      }
    }

    return sectionItems;
  }

  Map<num, List<ListGroup>> _groupByIndent(List<ListGroup> items) {
    return items.fold(<int, List<ListGroup>>{}, (pv, cv) {
      final indent = cv.items[0].item.op.attributes.indent;
      if (indent != null) {
        pv[indent] = pv[indent] ?? [];
        pv[indent]!.add(cv);
      }
      return pv;
    });
  }

  bool _placeUnderParent(ListGroup target, List<ListGroup> items) {
    for (var i = items.length - 1; i >= 0; i--) {
      var elm = items[i];
      if (target.items[0].item.op.hasHigherIndentThan(elm.items[0].item.op)) {
        var parent = elm.items[elm.items.length - 1];
        if (parent.innerList != null) {
          parent.innerList!.items.addAll(target.items);
        } else {
          parent.innerList = target;
        }
        return true;
      }
    }
    return false;
  }
}
