import 'package:test/test.dart';
import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';
import 'package:vsc_quill_delta_to_html/src/insert_data.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';

void main() {
  group('DeltaInsertOp', () {
    group('constructor()', () {
      test('should instantiate', () {
        var embed = InsertDataQuill(DataType.image, 'https://');
        var t = DeltaInsertOp(embed);
        // expect(t is DeltaInsertOp, true);
        expect(t.insert is InsertDataQuill, true);
        // expect(t.attributes is Object, true);

        t = DeltaInsertOp('test');
        expect(t.insert.value, 'test');

        t = DeltaInsertOp(InsertDataQuill(DataType.formula, 'x=data'));
        expect(t.insert.value, 'x=data');
      });
    });

    group('isContainerBlock()', () {
      test('should successfully check if the op is a block container', () {
        var op = DeltaInsertOp('test');
        expect(op.isContainerBlock(), false);

        op = DeltaInsertOp('test', OpAttributes()..blockquote = true);
        expect(op.isContainerBlock(), true);
      });
    });

    group('hasSameAdiAs()', () {
      test(
          'should successfully if two ops have same align indent and direction',
          () {
        var op1 = DeltaInsertOp(
            '\n',
            OpAttributes()
              ..align = AlignType.right
              ..indent = 2);
        var op2 = DeltaInsertOp(
            '\n',
            OpAttributes()
              ..align = AlignType.right
              ..indent = 2);

        expect(op1.hasSameAdiAs(op2), true);

        op2 = DeltaInsertOp(
            '\n',
            OpAttributes()
              ..align = AlignType.right
              ..indent = 3);
        expect(op1.hasSameAdiAs(op2), false);
      });
    });

    group('hasHigherIndentThan()', () {
      test(
          'should successfully if two ops have same align indent and direction',
          () {
        var op1 = DeltaInsertOp('\n', OpAttributes()..indent = null);
        var op2 = DeltaInsertOp('\n', OpAttributes()..indent = null);

        expect(!op1.hasHigherIndentThan(op2), true);
      });
    });

    group('isInline()', () {
      test('should return true if op is an inline', () {
        var op = DeltaInsertOp('\n');
        expect(op.isInline(), true);
      });
    });

    group('isJustNewline()', () {
      test('should return true if op is a list', () {
        var op = DeltaInsertOp('\n');
        expect(op.isJustNewline(), true);

        op = DeltaInsertOp('\n\n ', OpAttributes()..list = ListType.ordered);
        expect(op.isJustNewline(), false);
      });
    });

    group('isList()', () {
      test('should return true if op is a list', () {
        var op = DeltaInsertOp('\n');
        expect(op.isList(), false);

        op = DeltaInsertOp('fds ', OpAttributes()..list = ListType.ordered);
        expect(op.isList(), true);

        op = DeltaInsertOp('fds ', OpAttributes()..list = ListType.unchecked);
        expect(op.isList(), true);
      });
    });

    group('isBulletList()', () {
      test('should return true if op is a bullet list', () {
        var op = DeltaInsertOp('\n', OpAttributes()..list = ListType.bullet);
        expect(op.isBulletList(), true);

        op = DeltaInsertOp('fds ', OpAttributes()..list = ListType.ordered);
        expect(op.isBulletList(), false);
      });
    });

    group('isOrderedList()', () {
      test('should return true if op is an ordered list', () {
        var op = DeltaInsertOp('\n', OpAttributes()..list = ListType.bullet);
        expect(op.isOrderedList(), false);

        op = DeltaInsertOp('fds ', OpAttributes()..list = ListType.ordered);
        expect(op.isOrderedList(), true);
      });
    });

    group('isCheckedList()', () {
      test('should return true if op is an checked list', () {
        var op = DeltaInsertOp('\n', OpAttributes()..list = ListType.unchecked);
        expect(op.isCheckedList(), false);

        op = DeltaInsertOp('fds ', OpAttributes()..list = ListType.checked);
        expect(op.isCheckedList(), true);
      });
    });

    group('isUncheckedList()', () {
      test('should return true if op is an unchecked list', () {
        var op = DeltaInsertOp('\n', OpAttributes()..list = ListType.bullet);
        expect(op.isUncheckedList(), false);

        op = DeltaInsertOp('fds ', OpAttributes()..list = ListType.unchecked);
        expect(op.isUncheckedList(), true);
      });
    });

    group('isSameListAs()', () {
      test('should return true if op list type same as the comparison', () {
        var op = DeltaInsertOp('\n', OpAttributes()..list = ListType.bullet);
        var op2 = DeltaInsertOp('ds', OpAttributes()..list = ListType.bullet);
        expect(op.isSameListAs(op2), true);

        var op3 =
            DeltaInsertOp('fds ', OpAttributes()..list = ListType.ordered);
        expect(op.isSameListAs(op3), false);
      });
    });

    group('isText()', () {
      test('should correctly identify insert type', () {
        var op = DeltaInsertOp('\n', OpAttributes()..list = ListType.bullet);
        expect(op.isVideo(), false);
        expect(op.isText(), true);

        op = DeltaInsertOp(InsertDataQuill(DataType.image, 'd'),
            OpAttributes()..list = ListType.ordered);
        expect(op.isImage(), true);
        expect(op.isText(), false);
      });
    });

    group('isVideo()/isImage()/isFormula()', () {
      test('should correctly identify embed type', () {
        var op = DeltaInsertOp(InsertDataQuill(DataType.video, ''));
        expect(op.isVideo(), true);
        expect(op.isFormula(), false);
        expect(op.isImage(), false);

        op = DeltaInsertOp(InsertDataQuill(DataType.image, 'd'));
        expect(op.isImage(), true);
        expect(op.isFormula(), false);

        op = DeltaInsertOp(InsertDataQuill(DataType.formula, 'd'));
        expect(op.isVideo(), false);
        expect(op.isFormula(), true);
      });
    });

    group('isLink()', () {
      test('should correctly identify if op is a link', () {
        var op = DeltaInsertOp(InsertDataQuill(DataType.video, ''),
            OpAttributes()..link = 'http://');
        expect(op.isLink(), false);

        op = DeltaInsertOp('http', OpAttributes()..link = 'http://');
        expect(op.isLink(), true);
      });
    });
  });
}
