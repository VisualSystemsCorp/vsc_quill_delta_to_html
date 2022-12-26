import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';
import 'package:vsc_quill_delta_to_html/src/funcs_html.dart';
import 'package:vsc_quill_delta_to_html/src/helpers/js.dart';
import 'package:vsc_quill_delta_to_html/src/insert_data.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/op_to_html_converter.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';
import 'package:test/test.dart';

void main() {
  group('OpToHtmlConverter', () {
    group('prefixClass()', () {
      test('should prefix class if an empty string prefix is not given', () {
        var op = DeltaInsertOp('aa');
        var c = OpToHtmlConverter(op, OpConverterOptions(classPrefix: ''));
        var act = c.prefixClass('my-class');
        expect(act, 'my-class');

        c = OpToHtmlConverter(op, OpConverterOptions(classPrefix: 'xx'));
        act = c.prefixClass('my-class');
        expect(act, 'xx-my-class');

        c = OpToHtmlConverter(op);
        act = c.prefixClass('my-class');
        expect(act, 'ql-my-class');
      });
    });

    group('getCssStyles()', () {
      var op = DeltaInsertOp('hello');
      test('should return styles', () {
        var c = OpToHtmlConverter(op);
        expect(c.getCssStyles(), []);

        var o = DeltaInsertOp(
            'f', OpAttributes(background: 'red')..attrs['attr1'] = 'redish');
        c = OpToHtmlConverter(o, OpConverterOptions(
          customCssStyles: (op) {
            if (isTruthy(op.attributes['attr1'])) {
              return ['color:${op.attributes['attr1']}'];
            }
            return null;
          },
        ));
        expect(c.getCssStyles(), ['color:redish', 'background-color:red']);

        o = DeltaInsertOp('f', OpAttributes(background: 'red', color: 'blue'));
        c = OpToHtmlConverter(o);
        expect(c.getCssStyles(), [
          'color:blue',
          'background-color:red',
        ]);

        c = OpToHtmlConverter(
            o, OpConverterOptions(allowBackgroundClasses: true));
        expect(c.getCssStyles(), ['color:blue']);
      });

      test('should return inline styles', () {
        var op = DeltaInsertOp('hello');
        var c = OpToHtmlConverter(
            op, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssStyles(), []);

        var attrs = OpAttributes(
          indent: 1,
          align: AlignType.center,
          direction: DirectionType.rtl,
          font: 'roman',
          size: 'small',
          background: 'red',
        );
        var o = DeltaInsertOp('f', attrs);
        c = OpToHtmlConverter(
            o, OpConverterOptions(inlineStyles: InlineStyles({})));
        var styles = [
          'background-color:red',
          'padding-right:3.0em',
          'text-align:center',
          'direction:rtl',
          'font-family:roman',
          'font-size: 0.75em',
        ];
        expect(c.getCssStyles(), styles);

        o = DeltaInsertOp(InsertDataQuill(DataType.image, ''), attrs);
        c = OpToHtmlConverter(
            o, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssStyles(), styles);

        o = DeltaInsertOp(InsertDataQuill(DataType.video, ''), attrs);
        c = OpToHtmlConverter(
            o, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssStyles(), styles);

        o = DeltaInsertOp(InsertDataQuill(DataType.formula, ''), attrs);
        c = OpToHtmlConverter(
            o, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssStyles(), styles);

        o = DeltaInsertOp('f', attrs);
        c = OpToHtmlConverter(
            o, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssStyles(), styles);

        o = DeltaInsertOp(InsertDataQuill(DataType.image, ''),
            OpAttributes(direction: DirectionType.rtl));
        c = OpToHtmlConverter(
            o, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssStyles(), ['direction:rtl; text-align:inherit']);

        o = DeltaInsertOp(
            InsertDataQuill(DataType.image, ''), OpAttributes(indent: 2));
        c = OpToHtmlConverter(
            o, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssStyles(), ['padding-left:6.0em']);

        // Ignore invalid direction
        o = DeltaInsertOp(InsertDataQuill(DataType.image, ''),
            OpAttributes(direction: DirectionType.ltr));
        c = OpToHtmlConverter(
            o, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssStyles(), []);
      });

      test('should allow setting inline styles', () {
        var op = DeltaInsertOp('f', OpAttributes(size: 'huge'));
        var c = OpToHtmlConverter(
            op,
            OpConverterOptions(
                inlineStyles: InlineStyles(
              {
                'size': InlineStyleType(map: {
                  'huge': 'font-size: 6em',
                }),
              },
            )));
        expect(c.getCssStyles(), ['font-size: 6em']);
      });

      test(
          'should fall back to defaults for inline styles that are not specified',
          () {
        // Here there's no inlineStyle specified for "size", but we still render it
        // because we fall back to the default.
        var op = DeltaInsertOp('f', OpAttributes(size: 'huge'));
        var c = OpToHtmlConverter(
            op,
            OpConverterOptions(
                inlineStyles: InlineStyles(
              {
                'font': InlineStyleType(map: {
                  'serif': 'font-family: serif',
                }),
              },
            )));
        expect(c.getCssStyles(), ['font-size: 2.5em']);
      });

      test('should render default font inline styles correctly', () {
        var op = DeltaInsertOp('f', OpAttributes(font: 'monospace'));
        var c = OpToHtmlConverter(
            op, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssStyles(), [
          'font-family: Monaco, Courier New, monospace',
        ]);
      });

      test('should return nothing for an inline style with no mapped entry',
          () {
        var op = DeltaInsertOp('f', OpAttributes(size: 'biggest'));
        var c = OpToHtmlConverter(
            op,
            OpConverterOptions(
                inlineStyles: InlineStyles(
              {
                'size': InlineStyleType(map: {
                  'small': 'font-size: 0.75em',
                }),
              },
            )));
        expect(c.getCssStyles(), []);
      });

      test(
          'should return nothing for an inline style where the converter returns undefined',
          () {
        var op = DeltaInsertOp('f', OpAttributes(size: 'biggest'));
        var c = OpToHtmlConverter(
            op,
            OpConverterOptions(
              inlineStyles: InlineStyles({
                'size': InlineStyleType(fn: (_, __) => null),
              }),
            ));
        expect(c.getCssStyles(), []);
      });
    });

    group('getCssClasses()', () {
      test('should return prefixed classes', () {
        var op = DeltaInsertOp('hello');
        final options = OpConverterOptions(customCssClasses: (op) {
          if (op.attributes.size == 'small') {
            return ['small-size'];
          }
          return null;
        });
        var c = OpToHtmlConverter(op, options);
        expect(c.getCssClasses(), []);

        final attrs = OpAttributes(
          indent: 1,
          align: AlignType.center,
          direction: DirectionType.rtl,
          font: 'roman',
          size: 'small',
          background: 'red',
        );
        var o = DeltaInsertOp('f', attrs);
        c = OpToHtmlConverter(o, options);
        final classes = [
          'small-size',
          'ql-indent-1',
          'ql-align-center',
          'ql-direction-rtl',
          'ql-font-roman',
          'ql-size-small',
        ];
        expect(c.getCssClasses(), classes);

        o = DeltaInsertOp(InsertDataQuill(DataType.image, ''), attrs);
        c = OpToHtmlConverter(o, options);
        expect(c.getCssClasses(), [...classes, 'ql-image']);

        o = DeltaInsertOp(InsertDataQuill(DataType.video, ''), attrs);
        c = OpToHtmlConverter(o, options);
        expect(c.getCssClasses(), [...classes, 'ql-video']);

        o = DeltaInsertOp(InsertDataQuill(DataType.formula, ''), attrs);
        c = OpToHtmlConverter(o, options);
        expect(c.getCssClasses(), [...classes, 'ql-formula']);

        o = DeltaInsertOp('f', attrs);
        c = OpToHtmlConverter(o, options..allowBackgroundClasses = true);

        expect(c.getCssClasses(), [...classes, 'ql-background-red']);
      });

      test('should return no classes if `inlineStyles` is specified', () {
        var attrs = OpAttributes(
          indent: 1,
          align: AlignType.center,
          direction: DirectionType.rtl,
          font: 'roman',
          size: 'small',
          background: 'red',
        );
        var o = DeltaInsertOp('f', attrs);
        var c = OpToHtmlConverter(
            o, OpConverterOptions(inlineStyles: InlineStyles({})));
        expect(c.getCssClasses(), []);
      });
    });

    group('getTags()', () {
      test('should return tags to render this op', () {
        var op = DeltaInsertOp('hello');
        var c = OpToHtmlConverter(op);
        expect(c.getTags(), []);

        var o = DeltaInsertOp('', OpAttributes(code: true));
        c = OpToHtmlConverter(o);
        expect(c.getTags(), ['code']);

        for (final item in [
          [DataType.image, 'img'],
          [DataType.video, 'iframe'],
          [DataType.formula, 'span'],
        ]) {
          o = DeltaInsertOp(InsertDataQuill(item[0] as DataType, ''));
          c = OpToHtmlConverter(o);
          expect(c.getTags(), [item[1]]);
        }

        for (var item in [
          ['blockquote', 'blockquote'],
          ['code-block', 'pre'],
          ['list', 'li'],
          ['header', 'h2'],
        ]) {
          o = DeltaInsertOp(
              '',
              OpAttributes()
                ..attrs[item[0]] = true
                ..header = 2);
          c = OpToHtmlConverter(o);
          expect(c.getTags(), [item[1]]);
        }

        for (var item in [
          ['blockquote', 'blockquote'],
          ['code-block', 'div'],
          ['bold', 'h2'],
          ['list', 'li'],
          ['header', 'h2'],
        ]) {
          o = DeltaInsertOp(
              '',
              OpAttributes()
                ..attrs[item[0]] = true
                ..header = 2);
          c = OpToHtmlConverter(o, OpConverterOptions(customTag: (format, _) {
            if (format == 'code-block') {
              return 'div';
            }
            if (format == 'bold') {
              return 'b';
            }
            return null;
          }));
          expect(c.getTags(), [item[1]]);
        }

        for (var item in [
          ['blockquote', 'blockquote'],
          ['code-block', 'pre'],
          ['list', 'li'],
          ['attr1', 'attr1'],
        ]) {
          o = DeltaInsertOp(
              '', OpAttributes(renderAsBlock: true)..attrs[item[0]] = true);
          c = OpToHtmlConverter(o, OpConverterOptions(customTag: (format, op) {
            if (format == 'renderAsBlock' && op.attributes['attr1']) {
              return 'attr1';
            }
            return null;
          }));
          expect(c.getTags(), [item[1]]);
        }

        var attrs = OpAttributes(
          link: 'http',
          script: ScriptType.subscript,
          bold: true,
          italic: true,
          strike: true,
          underline: true,
        )..attrs['attr1'] = true;
        o = DeltaInsertOp('', attrs);
        c = OpToHtmlConverter(o, OpConverterOptions(
          customTag: (format, op) {
            if (format == 'bold') {
              return 'b';
            }
            if (format == 'attr1') {
              return 'attr2';
            }
            return null;
          },
        ));
        expect(c.getTags(), ['a', 'sub', 'b', 'em', 's', 'u', 'attr2']);
      });
    });

    group('getTagAttributes()', () {
      test('should return tag attributes', () {
        var op = DeltaInsertOp('hello');
        var c = OpToHtmlConverter(op);
        expect(c.getTagAttributes(), []);

        var o = DeltaInsertOp('', OpAttributes(code: true, color: 'red'));
        c = OpToHtmlConverter(o);
        expect(c.getTagAttributes(), []);

        o = DeltaInsertOp(InsertDataQuill(DataType.image, 'http:'),
            OpAttributes(color: 'red'));
        c = OpToHtmlConverter(o, OpConverterOptions(
          customTagAttributes: (op) {
            if (isTruthy(op.attributes.color)) {
              return {
                'data-color': op.attributes.color!,
              };
            }
            return null;
          },
        ));
        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'data-color', value: 'red'),
          TagKeyValue(key: 'class', value: 'ql-image'),
          TagKeyValue(key: 'style', value: 'color:red'),
          TagKeyValue(key: 'src', value: 'http:'),
        ]);

        o = DeltaInsertOp(InsertDataQuill(DataType.image, 'http:'),
            OpAttributes(width: '200'));
        c = OpToHtmlConverter(o);
        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'class', value: 'ql-image'),
          TagKeyValue(key: 'width', value: '200'),
          TagKeyValue(key: 'src', value: 'http:'),
        ]);

        o = DeltaInsertOp(
            InsertDataQuill(DataType.formula, '-'), OpAttributes(color: 'red'));
        c = OpToHtmlConverter(o);
        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'class', value: 'ql-formula'),
          TagKeyValue(key: 'style', value: 'color:red'),
        ]);

        o = DeltaInsertOp(InsertDataQuill(DataType.video, 'http:'),
            OpAttributes(color: 'red'));
        c = OpToHtmlConverter(o);
        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'class', value: 'ql-video'),
          TagKeyValue(key: 'style', value: 'color:red'),
          TagKeyValue(key: 'frameborder', value: '0'),
          TagKeyValue(key: 'allowfullscreen', value: 'true'),
          TagKeyValue(key: 'src', value: 'http:'),
        ]);

        o = DeltaInsertOp('link', OpAttributes(color: 'red', link: 'l'));

        c = OpToHtmlConverter(o);
        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'style', value: 'color:red'),
          TagKeyValue(key: 'href', value: 'l'),
        ]);

        c = OpToHtmlConverter(o, OpConverterOptions(linkRel: 'nofollow'));
        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'style', value: 'color:red'),
          TagKeyValue(key: 'href', value: 'l'),
          TagKeyValue(key: 'rel', value: 'nofollow'),
        ]);

        o = DeltaInsertOp(
            '', OpAttributes()..attrs['code-block'] = 'javascript');
        c = OpToHtmlConverter(o);
        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'data-language', value: 'javascript'),
        ]);

        o = DeltaInsertOp('', OpAttributes()..attrs['code-block'] = true);
        c = OpToHtmlConverter(o);
        expect(c.getTagAttributes(), []);
      });

      test('should support custom CSS styles for image', () {
        final o = DeltaInsertOp(InsertDataQuill(DataType.image, 'http:'),
            OpAttributes(color: 'red'));
        final c = OpToHtmlConverter(
            o,
            OpConverterOptions(
              customCssStyles: (op) =>
                  ['max-width: 100%', 'object-fit: contain'],
            ));

        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'class', value: 'ql-image'),
          TagKeyValue(
              key: 'style',
              value: 'max-width: 100%;object-fit: contain;color:red'),
          TagKeyValue(key: 'src', value: 'http:'),
        ]);
      });

      test('should support custom CSS styles for video', () {
        final o = DeltaInsertOp(InsertDataQuill(DataType.video, 'http:'),
            OpAttributes(color: 'red'));
        final c = OpToHtmlConverter(
            o,
            OpConverterOptions(
              customCssStyles: (op) =>
                  ['max-width: 100%', 'object-fit: contain'],
            ));

        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'class', value: 'ql-video'),
          TagKeyValue(
              key: 'style',
              value: 'max-width: 100%;object-fit: contain;color:red'),
          TagKeyValue(key: 'frameborder', value: '0'),
          TagKeyValue(key: 'allowfullscreen', value: 'true'),
          TagKeyValue(key: 'src', value: 'http:'),
        ]);
      });

      test('should support custom CSS styles for formula', () {
        final o = DeltaInsertOp(
            InsertDataQuill(DataType.formula, '-'), OpAttributes(color: 'red'));
        final c = OpToHtmlConverter(
            o,
            OpConverterOptions(
              customCssStyles: (op) =>
                  ['max-width: 100%', 'object-fit: contain'],
            ));

        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'class', value: 'ql-formula'),
          TagKeyValue(
              key: 'style',
              value: 'max-width: 100%;object-fit: contain;color:red'),
        ]);
      });

      test('should add special CSS classes for checked list item', () {
        final o = DeltaInsertOp('l1', OpAttributes(list: ListType.checked));
        final c = OpToHtmlConverter(o);

        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'data-checked', value: 'true'),
        ]);
      });

      test('should add special CSS classes for unchecked list item', () {
        final o = DeltaInsertOp('l1', OpAttributes(list: ListType.unchecked));
        final c = OpToHtmlConverter(o);

        expect(c.getTagAttributes(), [
          TagKeyValue(key: 'data-checked', value: 'false'),
        ]);
      });

      test('should add special inline CSS styles for checked list item', () {
        final o = DeltaInsertOp('l1', OpAttributes(list: ListType.checked));
        final c =
            OpToHtmlConverter(o, OpConverterOptions(inlineStylesFlag: true));

        expect(c.getTagAttributes(), [
          TagKeyValue(
              key: 'style',
              value: "list-style-type:'\\2611';padding-left: 0.5em;"),
          TagKeyValue(key: 'data-checked', value: 'true'),
        ]);
      });

      test('should add special inline CSS styles for unchecked list item', () {
        final o = DeltaInsertOp('l1', OpAttributes(list: ListType.unchecked));
        final c =
            OpToHtmlConverter(o, OpConverterOptions(inlineStylesFlag: true));

        expect(c.getTagAttributes(), [
          TagKeyValue(
              key: 'style',
              value: "list-style-type:'\\2610';padding-left: 0.5em;"),
          TagKeyValue(key: 'data-checked', value: 'false'),
        ]);
      });
    });

    group('getContent()', () {
      test('should return proper content depending on type', () {
        var o = DeltaInsertOp('aa', OpAttributes(indent: 1));
        var c = OpToHtmlConverter(o);
        expect(c.getContent(), '');

        o = DeltaInsertOp('sss<&>,', OpAttributes(bold: true));
        c = OpToHtmlConverter(o);
        expect(c.getContent(), 'sss&lt;&amp;&gt;,');

        o = DeltaInsertOp(
            InsertDataQuill(DataType.formula, 'ff'), OpAttributes(bold: true));
        c = OpToHtmlConverter(o);
        expect(c.getContent(), 'ff');

        o = DeltaInsertOp(
            InsertDataQuill(DataType.video, 'ff'), OpAttributes(bold: true));
        c = OpToHtmlConverter(o);
        expect(c.getContent(), '');
      });
    });

    group('html retrieval', () {
      var attributes = OpAttributes(
        link: 'http://',
        bold: true,
        italic: true,
        underline: true,
        strike: true,
        script: ScriptType.superscript,
        font: 'verdana',
        size: 'small',
        color: 'red',
        background: '#fff',
      );
      var op1 = DeltaInsertOp('aaa', attributes);
      var c1 = OpToHtmlConverter(op1);
      var result = [
        '<a class="ql-font-verdana ql-size-small"',
        ' style="color:red;background-color:#fff" href="http://">',
        '<sup>',
        '<strong><em><s><u>aaa</u></s></em></strong>',
        '</sup>',
        '</a>',
      ].join('');

      group('getHtmlParts()', () {
        test('should return inline html', () {
          var op = DeltaInsertOp('');
          var c1 = OpToHtmlConverter(op);
          var act = c1.getHtmlParts();
          expect(act.closingTag + act.content + act.openingTag, '');

          c1 = OpToHtmlConverter(op1);
          act = c1.getHtmlParts();
          expect(act.openingTag + act.content + act.closingTag, result);
        });
      });

      group('getHtml()', () {
        test('should return inline html', () {
          c1 = OpToHtmlConverter(op1);
          var act = c1.getHtml();
          expect(act, result);

          var op = DeltaInsertOp('\n', OpAttributes(bold: true));
          c1 = OpToHtmlConverter(op, OpConverterOptions(encodeHtml: false));
          expect(c1.getHtml(), '\n');

          op = DeltaInsertOp('&<>\n', OpAttributes(bold: true));
          c1 = OpToHtmlConverter(op, OpConverterOptions(encodeHtml: false));
          expect(c1.getHtml(), '<strong>&<>\n</strong>');

          op = DeltaInsertOp('\n', OpAttributes(color: '#fff'));
          c1 = OpToHtmlConverter(op);
          expect(c1.getHtml(), '\n');

          op = DeltaInsertOp(
              '\n', OpAttributes()..attrs['code-block'] = 'javascript');
          c1 = OpToHtmlConverter(op);
          expect(c1.getHtml(), '<pre data-language="javascript"></pre>');

          op = DeltaInsertOp(InsertDataQuill(DataType.image, 'http://'));
          c1 = OpToHtmlConverter(op, OpConverterOptions(
            customCssClasses: (_) {
              return ['ql-custom'];
            },
          ));
          expect(
              c1.getHtml(), '<img class="ql-custom ql-image" src="http://"/>');
        });
      });
    });
  });
}
