import 'package:vsc_quill_delta_to_html/src/helpers/url.dart';
import 'package:test/test.dart';

void main() {
  group('Url Helpers Module', () {
    group('String#_sanitizeUrl() ', () {
      test('should add unsafe: for invalid protocols', () {
        var act = "http://www><.yahoo'.com";
        expect(sanitize(act), "http://www><.yahoo'.com");

        act = 'https://abc';
        expect(sanitize(act), 'https://abc');

        act = 'sftp://abc';
        expect(sanitize(act), 'sftp://abc');

        act = ' ftp://abc';
        expect(sanitize(act), 'ftp://abc');

        act = '  file://abc';
        expect(sanitize(act), 'file://abc');

        act = '   blob://abc';
        expect(sanitize(act), 'blob://abc');

        act = 'mailto://abc';
        expect(sanitize(act), 'mailto://abc');

        act = 'tel://abc';
        expect(sanitize(act), 'tel://abc');

        act = '#abc';
        expect(sanitize(act), '#abc');

        act = '/abc';
        expect(sanitize(act), '/abc');

        act = ' data:image//abc';
        expect(sanitize(act), 'data:image//abc');

        act = "javascript:alert('hi')";
        expect(sanitize(act), "unsafe:javascript:alert('hi')");
      });
    });
  });
}
