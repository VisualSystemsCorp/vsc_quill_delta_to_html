import 'package:vsc_quill_delta_to_html/src/insert_op_denormalizer.dart';
import 'package:test/test.dart';

void main() {
  group('InsertOpDenormalizer', () {
    group('#denormalize()', () {
      test('should return denormalized op as array of ops', () {
        var op = {'insert': '\n'};
        var act = InsertOpDenormalizer.denormalize(op);
        expect(act, [op]);

        op = {'insert': 'abc'};
        act = InsertOpDenormalizer.denormalize(op);
        expect(act, [op]);

        var op2 = {
          'insert': 'abc\n',
          'attributes': {'link': 'cold'}
        };
        act = InsertOpDenormalizer.denormalize(op2);
        expect(act, [
          {
            'insert': 'abc',
            'attributes': {'link': 'cold'}
          },
          {
            'insert': '\n',
            'attributes': {'link': 'cold'}
          }
        ]);

        var op3 = {
          'insert': '\n\n',
          'attributes': {'bold': true}
        };
        act = InsertOpDenormalizer.denormalize(op3);
        expect(act, [
          {
            'insert': '\n',
            'attributes': {'bold': true}
          },
          {
            'insert': '\n',
            'attributes': {'bold': true}
          }
        ]);
      });
    });
  });
}
