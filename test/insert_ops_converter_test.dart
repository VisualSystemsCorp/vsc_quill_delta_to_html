import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';
import 'package:vsc_quill_delta_to_html/src/insert_data.dart';
import 'package:vsc_quill_delta_to_html/src/insert_ops_converter.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';
import 'package:test/test.dart';

void main() {
  final ops = [
    {'insert': 'This '},
    {
      'attributes': {'font': 'monospace'},
      'insert': 'is'
    },
    {'insert': ' a '},
    {
      'attributes': {'size': 'large'},
      'insert': 'test'
    },
    {'insert': ' '},
    {
      'attributes': {'italic': true, 'bold': true},
      'insert': 'data'
    },
    {'insert': ' '},
    {
      'attributes': {'underline': true, 'strike': true},
      'insert': 'that'
    },
    {'insert': ' is '},
    {
      'attributes': {'color': '#e60000'},
      'insert': 'will'
    },
    {'insert': ' '},
    {
      'attributes': {'background': '#ffebcc'},
      'insert': 'test'
    },
    {'insert': ' '},
    {
      'attributes': {'script': 'sub'},
      'insert': 'the'
    },
    {'insert': ' '},
    {
      'attributes': {'script': 'super'},
      'insert': 'rendering'
    },
    {'insert': ' of '},
    {
      'attributes': {'link': 'yahoo'},
      'insert': 'inline'
    },
    {'insert': ' '},
    {
      'insert': {'formula': 'x=data'}
    },
    {'insert': '  formats.\n'},
  ];

  final noOptions = OpAttributeSanitizerOptions();

  group('InsertOpsConverter', () {
    group('#convert()', () {
      test('should transform raw delta ops to DeltaInsertOp[]', () {
        final objs = InsertOpsConverter.convert(ops, noOptions);

        expect(objs, [
          DeltaInsertOp(InsertDataQuill(DataType.text, 'This ')),
          DeltaInsertOp(InsertDataQuill(DataType.text, 'is'),
              OpAttributes()..font = 'monospace'),
          DeltaInsertOp(InsertDataQuill(DataType.text, ' a ')),
          DeltaInsertOp(InsertDataQuill(DataType.text, 'test'),
              OpAttributes()..size = 'large'),
          DeltaInsertOp(InsertDataQuill(DataType.text, ' ')),
          DeltaInsertOp(
              InsertDataQuill(DataType.text, 'data'),
              OpAttributes()
                ..bold = true
                ..italic = true),
          DeltaInsertOp(InsertDataQuill(DataType.text, ' ')),
          DeltaInsertOp(
              InsertDataQuill(DataType.text, 'that'),
              OpAttributes()
                ..underline = true
                ..strike = true),
          DeltaInsertOp(InsertDataQuill(DataType.text, ' is ')),
          DeltaInsertOp(InsertDataQuill(DataType.text, 'will'),
              OpAttributes()..color = '#e60000'),
          DeltaInsertOp(InsertDataQuill(DataType.text, ' ')),
          DeltaInsertOp(InsertDataQuill(DataType.text, 'test'),
              OpAttributes()..background = '#ffebcc'),
          DeltaInsertOp(InsertDataQuill(DataType.text, ' ')),
          DeltaInsertOp(InsertDataQuill(DataType.text, 'the'),
              OpAttributes()..script = ScriptType.subscript),
          DeltaInsertOp(InsertDataQuill(DataType.text, ' ')),
          DeltaInsertOp(InsertDataQuill(DataType.text, 'rendering'),
              OpAttributes()..script = ScriptType.superscript),
          DeltaInsertOp(InsertDataQuill(DataType.text, ' of ')),
          DeltaInsertOp(InsertDataQuill(DataType.text, 'inline'),
              OpAttributes()..link = 'unsafe:yahoo'),
          DeltaInsertOp(InsertDataQuill(DataType.text, ' ')),
          DeltaInsertOp(InsertDataQuill(DataType.formula, 'x=data')),
          DeltaInsertOp(InsertDataQuill(DataType.text, '  formats.')),
          DeltaInsertOp(InsertDataQuill(DataType.text, '\n')),
        ]);

        expect(InsertOpsConverter.convert(null, noOptions), []);

        expect(
            InsertOpsConverter.convert([
              {'insert': ''}
            ], noOptions),
            []);

        expect(
            InsertOpsConverter.convert([
              {
                'insert': {'cake': ''}
              }
            ], noOptions),
            [DeltaInsertOp(InsertDataCustom('cake', ''))]);

        expect(
            InsertOpsConverter.convert([
              {'insert': 2}
            ], noOptions),
            []);
      });
    });

    group('#convertInsertVal()', () {
      test('should convert raw .insert value to valid TInsert or null', () {
        for (var v in [null, 3, {}]) {
          final act = InsertOpsConverter.convertInsertVal(v, noOptions);
          expect(act, null);
        }

        for (var v in [
          'fdsf',
          {'image': 'ff'},
          {'video': ''},
          {'formula': ''}
        ]) {
          final act = InsertOpsConverter.convertInsertVal(v, noOptions);
          expect(act is InsertDataQuill, true);
          // TODO
        }
      });
    });
  });
}
