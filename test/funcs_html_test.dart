import 'package:vsc_quill_delta_to_html/src/funcs_html.dart';
import 'package:test/test.dart';

void main() {
  group('html module', () {
    group('makeStartTag()', () {
      test('should make proper html start tags', () {
        var act = makeStartTag('a');
        expect(act, '<a>');

        act = makeStartTag('');
        expect(act, '');

        act = makeStartTag('br');
        expect(act, '<br/>');

        act = makeStartTag('img', [TagKeyValue(key: 'src', value: 'http://')]);
        expect(act, '<img src="http://"/>');

        var attrs = [
          TagKeyValue(key: 'class', value: ' cl1 cl2'),
          TagKeyValue(key: 'style', value: 'color:#333'),
        ];
        act = makeStartTag('p', attrs);
        expect(act, '<p class=" cl1 cl2" style="color:#333">');

        expect(makeStartTag('p', [TagKeyValue(key: 'checked')]), '<p checked>');
      });
    });

    group('makeEndTag()', () {
      test('should make proper html end tags', () {
        var act = makeEndTag('a');
        expect(act, '</a>');

        act = makeEndTag();
        expect(act, '');
      });
    });

    group('encodeHtml()', () {
      test('should encode < > & " \' / characters', () {
        var act = encodeHtml('hello"my<lovely\'/>&amp;friend&here()', false);
        expect(act,
            'hello&quot;my&lt;lovely&#39;&#47;&gt;&amp;amp;friend&amp;here()');

        act = encodeHtml('hello"my<lovely\'/>&amp;friend&here()');
        expect(
            act, 'hello&quot;my&lt;lovely&#39;&#47;&gt;&amp;friend&amp;here()');
      });
    });

    group('decodeHtml()', () {
      test('should decode html', () {
        var act = decodeHtml(
            'hello&quot;my&lt;lovely&#x27;&#x2F;&gt;&amp;friend&amp;here');
        expect(act, 'hello"my<lovely\'/>&friend&here');
      });
    });

    group('encodeLink()', () {
      test('should encode link', () {
        var act = encodeLink('http://www.yahoo.com/?a=b&c=<>()"\'');
        expect(act, 'http://www.yahoo.com/?a=b&amp;c=&lt;&gt;()&quot;&#39;');
      });
    });
  });
}
