import 'package:vsc_quill_delta_to_html/src/mentions/mention_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('MentionSanitizer', () {
    group('#sanitize()', () {
      test('should return sanitized data', () {
        final sanitized = MentionSanitizer.sanitize(
            Mention()
              ..class_ = 'A-cls-9'
              ..id = 'An-id_9:.'
              ..target = '_blank'
              ..avatar = 'http://www.yahoo.com'
              ..endPoint = 'http://abc.com'
              ..slug = 'my-name',
            OpAttributeSanitizerOptions());

        expect(sanitized.attrs, {
          'class': 'A-cls-9',
          'id': 'An-id_9:.',
          'target': '_blank',
          'avatar': 'http://www.yahoo.com',
          'end-point': 'http://abc.com',
          'slug': 'my-name',
        });

        expect(
            MentionSanitizer.sanitize(
                    Mention()..id = 'sb', OpAttributeSanitizerOptions())
                .attrs,
            {'id': 'sb'});
      });
    });
  });
}
