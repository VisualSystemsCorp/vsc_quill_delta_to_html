import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/group_types.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/grouper.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/list_nester.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';
import 'package:test/test.dart';

void main() {
  group('ListNester', () {
    group('nest()', () {
      test('should not nest different types of lists', () {
        var ops = [
          DeltaInsertOp('ordered list 1 item 1'),
          DeltaInsertOp('\n', OpAttributes()..list = ListType.ordered),
          DeltaInsertOp('bullet list 1 item 1'),
          DeltaInsertOp('\n', OpAttributes()..list = ListType.bullet),
          DeltaInsertOp('bullet list 1 item 2'),
          DeltaInsertOp('\n', OpAttributes()..list = ListType.bullet),
          DeltaInsertOp('haha'),
          DeltaInsertOp('\n'),
          DeltaInsertOp('\n', OpAttributes()..list = ListType.bullet),
          DeltaInsertOp('\n', OpAttributes()..list = ListType.checked),
          DeltaInsertOp('\n', OpAttributes()..list = ListType.unchecked),
        ];

        var groups = Grouper.pairOpsWithTheirBlock(ops);
        var nester = ListNester();
        var act = nester.nest(groups);
        //console.log(JSON.stringify(act, null, 3));
        expect(act, [
          ListGroup([ListItem(groups[0] as BlockGroup)]),
          ListGroup([
            ListItem(groups[1] as BlockGroup),
            ListItem(groups[2] as BlockGroup),
          ]),
          InlineGroup([ops[6], ops[7]]),
          ListGroup([ListItem(BlockGroup(ops[8], []))]),
          ListGroup([
            ListItem(BlockGroup(ops[9], [])),
            ListItem(BlockGroup(ops[10], [])),
          ]),
        ]);
      });

      test('should nest if lists are same and later ones have higher indent',
          () {
        var ops = [
          DeltaInsertOp('item 1'),
          DeltaInsertOp('\n', OpAttributes()..list = ListType.ordered),
          DeltaInsertOp('item 1a'),
          DeltaInsertOp(
              '\n',
              OpAttributes()
                ..list = ListType.ordered
                ..indent = 1),
          DeltaInsertOp('item 1a-i'),
          DeltaInsertOp(
              '\n',
              OpAttributes()
                ..list = ListType.ordered
                ..indent = 3),
          DeltaInsertOp('item 1b'),
          DeltaInsertOp(
              '\n',
              OpAttributes()
                ..list = ListType.ordered
                ..indent = 1),
          DeltaInsertOp('item 2'),
          DeltaInsertOp('\n', OpAttributes()..list = ListType.ordered),
          DeltaInsertOp('haha'),
          DeltaInsertOp('\n'),
          DeltaInsertOp(
              '\n',
              OpAttributes()
                ..list = ListType.ordered
                ..indent = 5),
          DeltaInsertOp(
              '\n',
              OpAttributes()
                ..list = ListType.bullet
                ..indent = 4),
        ];
        var pairs = Grouper.pairOpsWithTheirBlock(ops);

        var nester = ListNester();
        var act = nester.nest(pairs);
        //console.log(JSON.stringify( act, null, 4));

        var l1b = ListItem(pairs[3] as BlockGroup);
        var lai = ListGroup([ListItem(pairs[2] as BlockGroup)]);
        var l1a = ListGroup([ListItem(pairs[1] as BlockGroup, lai)]);

        var li1 = ListGroup([ListItem(pairs[0] as BlockGroup)]);
        li1.items[0].innerList = ListGroup(List.from(l1a.items)..add(l1b));
        var li2 = ListGroup([ListItem(pairs[4] as BlockGroup)]);
        expect(act, [
          ListGroup(List.from(li1.items)..addAll(li2.items)),
          InlineGroup([ops[10], ops[11]]),
          ListGroup([ListItem(BlockGroup(ops[12], []))]),
          ListGroup([ListItem(BlockGroup(ops[13], []))]),
        ]);
      });
    });
  });
}
