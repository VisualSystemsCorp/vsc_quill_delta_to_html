import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/group_types.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/grouper.dart';
import 'package:vsc_quill_delta_to_html/src/insert_data.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';
import 'package:test/test.dart';

void main() {
  group('Grouper', () {
    group('#pairOpsWithTheirBlock()', () {
      var ops = [
        DeltaInsertOp(InsertDataQuill(DataType.video, 'http://')),
        DeltaInsertOp('hello'),
        DeltaInsertOp('\n'),
        DeltaInsertOp('how are you?'),
        DeltaInsertOp('\n'),
        DeltaInsertOp('Time is money'),
        DeltaInsertOp('\n', OpAttributes()..blockquote = true),
      ];

      test('should return ops grouped by group type', () {
        var act = Grouper.pairOpsWithTheirBlock(ops);
        var exp = [
          VideoItem(ops[0]),
          InlineGroup([ops[1], ops[2], ops[3], ops[4]]),
          BlockGroup(ops[6], [ops[5]]),
        ];
        expect(act, exp);
      });
    });

    group('#groupConsecutiveSameStyleBlocks()', () {
      test('should combine blocks with same type and style into an []', () {
        var ops = [
          DeltaInsertOp('this is code'),
          DeltaInsertOp('\n', OpAttributes()..attrs['code-block'] = true),
          DeltaInsertOp('this is code TOO!'),
          DeltaInsertOp('\n', OpAttributes()..attrs['code-block'] = true),
          DeltaInsertOp('\n', OpAttributes()..blockquote = true),
          DeltaInsertOp('\n', OpAttributes()..blockquote = true),
          DeltaInsertOp('\n'),
          DeltaInsertOp('\n', OpAttributes()..header = 1),
          DeltaInsertOp('\n', OpAttributes()..header = 1),
          DeltaInsertOp(
              '\n',
              OpAttributes()
                ..attrs['attr1'] = true
                ..renderAsBlock = true),
          DeltaInsertOp(
              '\n',
              OpAttributes()
                ..attrs['attr1'] = true
                ..renderAsBlock = true),
          DeltaInsertOp(
              '\n',
              OpAttributes()
                ..attrs['attr1'] = 'test'
                ..renderAsBlock = true),
          DeltaInsertOp(
              '\n',
              OpAttributes()
                ..attrs['attr2'] = 'test'
                ..renderAsBlock = true),
        ];
        var pairs = Grouper.pairOpsWithTheirBlock(ops);
        var groups = Grouper.groupConsecutiveSameStyleBlocks(
          pairs,
          header: true,
          codeBlocks: true,
          blockquotes: true,
          customBlocks: true,
        );
        expect(groups, [
          [
            BlockGroup(ops[1], [ops[0]]),
            BlockGroup(ops[1], [ops[2]])
          ],
          [BlockGroup(ops[4], []), BlockGroup(ops[4], [])],
          InlineGroup([ops[6]]),
          [BlockGroup(ops[7], []), BlockGroup(ops[8], [])],
          [BlockGroup(ops[9], []), BlockGroup(ops[10], [])],
          BlockGroup(ops[11], []),
          BlockGroup(ops[12], []),
        ]);
      });
    });

    group('#reduceConsecutiveSameStyleBlocksToOne()', () {
      test('should return ops of combined groups moved to 1st group', () {
        var ops = [
          DeltaInsertOp('this is code'),
          DeltaInsertOp('\n', OpAttributes()..attrs['code-block'] = true),
          DeltaInsertOp('this is code TOO!'),
          DeltaInsertOp('\n', OpAttributes()..attrs['code-block'] = true),
          DeltaInsertOp('\n', OpAttributes()..blockquote = true),
          DeltaInsertOp('\n', OpAttributes()..blockquote = true),
          DeltaInsertOp('\n'),
          DeltaInsertOp('\n', OpAttributes()..header = 1),
        ];
        var pairs = Grouper.pairOpsWithTheirBlock(ops);
        var groups = Grouper.groupConsecutiveSameStyleBlocks(pairs);
        var act = Grouper.reduceConsecutiveSameStyleBlocksToOne(groups);
        expect(act, [
          BlockGroup(ops[1], [ops[0], ops[6], ops[2]]),
          BlockGroup(ops[4], [ops[6], ops[6]]),
          InlineGroup([ops[6]]),
          BlockGroup(ops[7], [ops[6]]),
        ]);
      });
    });
  });
}
