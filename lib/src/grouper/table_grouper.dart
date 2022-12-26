import 'package:vsc_quill_delta_to_html/src/helpers/array.dart';

import 'group_types.dart';

class TableGrouper {
  List<TDataGroup> group(List<TDataGroup> groups) {
    var tableBlocked = _convertTableBlocksToTableGroups(groups);
    return tableBlocked;
  }

  List<TDataGroup> _convertTableBlocksToTableGroups(List<TDataGroup> items) {
    var grouped = groupConsecutiveElementsWhile(items, (g, gPrev) {
      return g is BlockGroup &&
          gPrev is BlockGroup &&
          g.op.isTable() &&
          gPrev.op.isTable();
    });

    return grouped.map((/*TDataGroup | List<BlockGroup>*/ item) {
      if (item is! List) {
        if (item is BlockGroup && item.op.isTable()) {
          return TableGroup([
            TableRow([TableCell(item)])
          ]);
        }
        return item as TDataGroup;
      }

      return TableGroup(_convertTableBlocksToTableRows(List.castFrom(item)));
    }).toList();
  }

  List<TableRow> _convertTableBlocksToTableRows(List<TDataGroup> items) {
    var grouped = groupConsecutiveElementsWhile(items, (g, gPrev) {
      return g is BlockGroup &&
          gPrev is BlockGroup &&
          g.op.isTable() &&
          gPrev.op.isTable() &&
          g.op.isSameTableRowAs(gPrev.op);
    });

    return grouped.map((/*BlockGroup | List<BlockGroup>*/ item) {
      return TableRow(item is List
          ? item.map((it) => TableCell(it)).toList()
          : [TableCell(item)]);
    }).toList();
  }
}
