import 'package:collection/collection.dart';
import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';

abstract class TDataGroup {}

class InlineGroup implements TDataGroup {
  InlineGroup(this.ops);

  final List<DeltaInsertOp> ops;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineGroup &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(ops, other.ops);

  @override
  int get hashCode => ops.hashCode;

  @override
  String toString() {
    return 'InlineGroup{ops: $ops}';
  }
}

class SingleItem {
  SingleItem(this.op);

  final DeltaInsertOp op;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SingleItem && runtimeType == other.runtimeType && op == other.op;

  @override
  int get hashCode => op.hashCode;

  @override
  String toString() {
    return '$runtimeType{op: $op}';
  }
}

class VideoItem extends SingleItem implements TDataGroup {
  VideoItem(super.op);
}

class BlotBlock extends SingleItem implements TDataGroup {
  BlotBlock(super.op);
}

class BlockGroup implements TDataGroup {
  BlockGroup(this.op, this.ops);

  final DeltaInsertOp op;
  List<DeltaInsertOp> ops;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockGroup &&
          runtimeType == other.runtimeType &&
          op == other.op &&
          ListEquality().equals(ops, other.ops);

  @override
  int get hashCode => op.hashCode ^ ops.hashCode;

  @override
  String toString() {
    return 'BlockGroup{op: $op, ops: $ops}';
  }
}

class ListGroup implements TDataGroup {
  ListGroup(this.items);

  List<ListItem> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListGroup &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(items, other.items);

  @override
  int get hashCode => items.hashCode;

  @override
  String toString() {
    return 'ListGroup{items: $items}';
  }
}

class ListItem implements TDataGroup {
  ListItem(this.item, [this.innerList]);

  final BlockGroup item;
  ListGroup? innerList;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListItem &&
          runtimeType == other.runtimeType &&
          item == other.item &&
          innerList == other.innerList;

  @override
  int get hashCode => item.hashCode ^ innerList.hashCode;

  @override
  String toString() {
    return 'ListItem{item: $item, innerList: $innerList}';
  }
}

class TableGroup implements TDataGroup {
  TableGroup(this.rows);

  List<TableRow> rows;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableGroup &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(rows, other.rows);

  @override
  int get hashCode => rows.hashCode;

  @override
  String toString() {
    return 'TableGroup{rows: $rows}';
  }
}

class TableRow implements TDataGroup {
  TableRow(this.cells);

  List<TableCell> cells;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableRow &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(cells, other.cells);

  @override
  int get hashCode => cells.hashCode;

  @override
  String toString() {
    return 'TableRow{cells: $cells}';
  }
}

class TableCell implements TDataGroup {
  TableCell(this.item);

  final BlockGroup item;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableCell &&
          runtimeType == other.runtimeType &&
          item == other.item;

  @override
  int get hashCode => item.hashCode;

  @override
  String toString() {
    return 'TableCell{item: $item}';
  }
}
