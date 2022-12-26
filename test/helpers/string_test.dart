import 'package:vsc_quill_delta_to_html/src/helpers/string.dart';
import 'package:test/test.dart';

void main() {
  group('String Extensions Module', () {
    group('String#_tokenizeWithNewLines()', () {
      test('should split and return an array of strings ', () {
        var act = '';
        expect(tokenizeWithNewLines(act), ['']);

        act = '\n';
        expect(tokenizeWithNewLines(act), ['\n']);

        act = 'abc';
        expect(tokenizeWithNewLines(act), ['abc']);

        act = 'abc\nd';
        expect(tokenizeWithNewLines(act), ['abc', '\n', 'd']);

        act = '\n\n';
        expect(tokenizeWithNewLines(act), ['\n', '\n']);

        act = '\n \n';
        expect(tokenizeWithNewLines(act), ['\n', ' ', '\n']);

        act = ' \nabc\n';
        expect(tokenizeWithNewLines(act), [' ', '\n', 'abc', '\n']);

        act = '\n\nabc\n\n6\n';
        expect(tokenizeWithNewLines(act),
            ['\n', '\n', 'abc', '\n', '\n', '6', '\n']);
      });
    });
  });
}
