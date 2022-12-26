import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/group_types.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/grouper.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/table_grouper.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('TableGrouper', () {
    group('empty table', () {
      var ops = [
        DeltaInsertOp('\n', OpAttributes()..table = 'row-1'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-1'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-1'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-2'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-2'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-2'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-3'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-3'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-3'),
      ];

      test('should return table with 3 rows and 3 cells', () {
        var groups = Grouper.pairOpsWithTheirBlock(ops);
        var tableGrouper = TableGrouper();
        var act = tableGrouper.group(groups);
        var exp = [
          TableGroup([
            TableRow([
              TableCell(groups[0] as BlockGroup),
              TableCell(groups[1] as BlockGroup),
              TableCell(groups[2] as BlockGroup),
            ]),
            TableRow([
              TableCell(groups[3] as BlockGroup),
              TableCell(groups[4] as BlockGroup),
              TableCell(groups[5] as BlockGroup),
            ]),
            TableRow([
              TableCell(groups[6] as BlockGroup),
              TableCell(groups[7] as BlockGroup),
              TableCell(groups[8] as BlockGroup),
            ]),
          ]),
        ];

        expect(act, exp);
      });
    });

    group('single 1 row table', () {
      var ops = [
        DeltaInsertOp('cell1'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-1'),
        DeltaInsertOp('cell2'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-1'),
      ];

      test('should return table with 1 row', () {
        var groups = Grouper.pairOpsWithTheirBlock(ops);
        var tableGrouper = TableGrouper();
        var act = tableGrouper.group(groups);
        var exp = [
          TableGroup([
            TableRow([
              TableCell(groups[0] as BlockGroup),
              TableCell(groups[1] as BlockGroup),
            ]),
          ]),
        ];

        expect(act, exp);
      });
    });

    group('single 1 col table', () {
      var ops = [
        DeltaInsertOp('cell1'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-1'),
        DeltaInsertOp('cell2'),
        DeltaInsertOp('\n', OpAttributes()..table = 'row-2'),
      ];

      test('should return table with 1 col', () {
        var groups = Grouper.pairOpsWithTheirBlock(ops);
        var tableGrouper = TableGrouper();
        var act = tableGrouper.group(groups);
        var exp = [
          TableGroup([
            TableRow([TableCell(groups[0] as BlockGroup)]),
            TableRow([TableCell(groups[1] as BlockGroup)]),
          ]),
        ];

        expect(act, exp);
      });
    });
  });
}
