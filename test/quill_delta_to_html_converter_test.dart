import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/group_types.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/op_to_html_converter.dart';
import 'package:vsc_quill_delta_to_html/src/quill_delta_to_html_converter.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';
import 'package:test/test.dart';

import 'data/delta1.dart';
import 'data/html_email_meta_delta_and_html.dart';

void main() {
  group('QuillDeltaToHtmlConverter', () {
    group('constructor()', () {
      final hugeOps = [
        {
          'insert': 'huge',
          'attributes': {'size': 'huge', 'attr1': 'red'}
        },
        {'insert': '\n'},
      ];

      test('should instantiate return proper html', () {
        final qdc = QuillDeltaToHtmlConverter(
            delta1Ops,
            ConverterOptions(
              converterOptions: OpConverterOptions(
                classPrefix: 'noz',
              ),
            ));
        final html = qdc.convert();
        expect(html, delta1Html);
      });

      test('should set default inline styles for ', () {
        final qdc = QuillDeltaToHtmlConverter(
            hugeOps,
            ConverterOptions(
              converterOptions: OpConverterOptions(
                inlineStylesFlag: true,
                customCssStyles: (op) =>
                    op.attributes['attr1'] == 'red' ? ['color:red'] : null,
              ),
            ));
        final html = qdc.convert();
        expect(
            html.contains(
                '<span style="color:red;font-size: 2.5em">huge</span>'),
            true,
            reason: html);
      });

      test('should allow setting inline styles', () {
        final qdc = QuillDeltaToHtmlConverter(
            hugeOps,
            ConverterOptions(
              converterOptions: OpConverterOptions(
                inlineStyles: InlineStyles(
                  {
                    'size': InlineStyleType(map: {
                      'huge': 'font-size: 6em',
                    }),
                  },
                ),
              ),
            ));
        final html = qdc.convert();
        expect(html.contains('<span style="font-size: 6em">huge</span>'), true,
            reason: html);
      });
    });

    group('convert()', () {
      final ops2 = [
        {'insert': 'this is text'},
        {'insert': '\n'},
        {'insert': 'this is code'},
        {
          'insert': '\n',
          'attributes': {'code-block': true}
        },
        {'insert': 'this is code TOO!'},
        {
          'insert': '\n',
          'attributes': {'code-block': true}
        },
      ];

      test('should render html', () {
        final qdc = QuillDeltaToHtmlConverter(ops2);

        final html = qdc.convert();
        expect(
            html,
            '<p>this is text</p><pre>this is code\n'
            'this is code TOO!</pre>');
      });

      test('should render mention', () {
        final ops = [
          {
            'insert': 'mention',
            'attributes': {
              'mentions': true,
              'mention': {
                'end-point': 'http://abc.com',
                'slug': 'a',
                'class': 'abc',
                'target': '_blank',
              },
            },
          },
        ];
        var qdc = QuillDeltaToHtmlConverter(ops);
        var html = qdc.convert();
        expect(
            html,
            '<p><a class="abc"'
            ' href="http://abc.com/a" target="_blank"'
            '>mention</a></p>');

        qdc = QuillDeltaToHtmlConverter([
          {
            'insert': 'mention',
            'attributes': {
              'mentions': true,
              'mention': {'slug': 'aa'},
            },
          },
        ]);
        html = qdc.convert();
        expect(html, '<p><a href="about:blank">mention</a></p>');
      });

      test('should render links with rels', () {
        final ops = [
          {
            'attributes': {
              'link': '#',
              'rel': 'nofollow noopener',
            },
            'insert': 'external link',
          },
          {
            'attributes': {
              'link': '#',
            },
            'insert': 'internal link',
          },
        ];
        var qdc = QuillDeltaToHtmlConverter(
            ops,
            ConverterOptions(
              converterOptions: OpConverterOptions(linkRel: 'license'),
            ));
        var html = qdc.convert();
        expect(html,
            '<p><a href="#" target="_blank" rel="nofollow noopener">external link</a><a href="#" target="_blank" rel="license">internal link</a></p>');

        qdc = QuillDeltaToHtmlConverter(ops);
        html = qdc.convert();
        expect(html,
            '<p><a href="#" target="_blank" rel="nofollow noopener">external link</a><a href="#" target="_blank">internal link</a></p>');
      });

      test('should render image and image links', () {
        final ops = [
          {
            'insert': {'image': 'http://yahoo.com/abc.jpg'}
          },
          {
            'insert': {'image': 'http://yahoo.com/def.jpg'},
            'attributes': {'link': 'http://aha'},
          },
        ];
        final qdc = QuillDeltaToHtmlConverter(ops);
        final html = qdc.convert();
        expect(
            html,
            '<p>'
            '<img class="ql-image" src="http://yahoo.com/abc.jpg"/>'
            '<a href="http://aha" target="_blank">'
            '<img class="ql-image" src="http://yahoo.com/def.jpg"/>'
            '</a>'
            '</p>');
      });

      test('should open and close list tags', () {
        final ops4 = [
          {'insert': 'mr\n'},
          {'insert': 'hello'},
          {
            'insert': '\n',
            'attributes': {'list': 'ordered'}
          },
          {'insert': 'there'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'}
          },
          {
            'insert': '\n',
            'attributes': {'list': 'ordered'}
          },
        ];
        final qdc = QuillDeltaToHtmlConverter(ops4);
        final html = qdc.convert();

        expect(html,
            '<p>mr</p><ol><li>hello</li></ol><ul><li>there</li></ul><ol><li><br/></li></ol>');
      });

      test('should render as separate paragraphs', () {
        final ops4 = [
          {'insert': 'hello\nhow areyou?\n\nbye'}
        ];
        final qdc = QuillDeltaToHtmlConverter(
            ops4, ConverterOptions(multiLineParagraph: false));
        final html = qdc.convert();

        expect(html, '<p>hello</p><p>how areyou?</p><p><br/></p><p>bye</p>');
      });

      test('should create checked/unchecked lists', () {
        final ops4 = [
          {'insert': 'hello'},
          {
            'insert': '\n',
            'attributes': {'list': 'checked'}
          },
          {'insert': 'there'},
          {
            'insert': '\n',
            'attributes': {'list': 'unchecked'}
          },
          {'insert': 'man'},
          {
            'insert': '\n',
            'attributes': {'list': 'checked'}
          },
          {'insert': 'not done'},
          {
            'insert': '\n',
            'attributes': {'indent': 1, 'list': 'unchecked'}
          },
        ];
        // TODO checked lists don't honor inlineStylesFlag=true
        final qdc = QuillDeltaToHtmlConverter(ops4);
        final html = qdc.convert();
        expect(
            html,
            '<ul>'
            '<li data-checked="true">hello</li>'
            '<li data-checked="false">there</li>'
            '<li data-checked="true">man'
            '<ul><li data-checked="false">not done</li></ul>'
            '</li>'
            '</ul>');
      });

      test('should wrap positional styles in right tag', () {
        final ops4 = [
          {'insert': 'mr'},
          {
            'insert': '\n',
            'attributes': {'align': 'center'}
          },
          {
            'insert': '\n',
            'attributes': {'direction': 'rtl'}
          },
          {
            'insert': '\n',
            'attributes': {'indent': 2}
          },
        ];
        var qdc = QuillDeltaToHtmlConverter(
            ops4,
            ConverterOptions(
                converterOptions: OpConverterOptions(paragraphTag: 'div')));
        var html = qdc.convert();
        expect(
            html,
            '<div class="ql-align-center">mr</div>'
            '<div class="ql-direction-rtl"><br/></div>'
            '<div class="ql-indent-2"><br/></div>');

        qdc = QuillDeltaToHtmlConverter(ops4);
        html = qdc.convert();
        expect(
            html,
            '<p class="ql-align-center">mr</p>'
            '<p class="ql-direction-rtl"><br/></p>'
            '<p class="ql-indent-2"><br/></p>');
      });

      test('should render target attr correctly', () {
        final ops = [
          {
            'attributes': {'target': '_self', 'link': 'http://#'},
            'insert': 'A'
          },
          {
            'attributes': {'target': '_blank', 'link': 'http://#'},
            'insert': 'B'
          },
          {
            'attributes': {'link': 'http://#'},
            'insert': 'C'
          },
          {'insert': '\n'},
        ];
        var qdc = QuillDeltaToHtmlConverter(
            ops,
            ConverterOptions(
                converterOptions: OpConverterOptions(linkTarget: '')));
        var html = qdc.convert();
        expect(
            html,
            '<p><a href="http://#" target="_self">A</a>'
            '<a href="http://#" target="_blank">B</a>'
            '<a href="http://#">C</a></p>');

        qdc = QuillDeltaToHtmlConverter(ops);
        html = qdc.convert();
        expect(
            html,
            '<p><a href="http://#" target="_self">A</a>'
            '<a href="http://#" target="_blank">B</a>'
            '<a href="http://#" target="_blank">C</a></p>');

        qdc = QuillDeltaToHtmlConverter(
            ops,
            ConverterOptions(
                converterOptions: OpConverterOptions(linkTarget: '_top')));
        html = qdc.convert();
        expect(
            html,
            '<p><a href="http://#" target="_self">A</a>'
            '<a href="http://#" target="_blank">B</a>'
            '<a href="http://#" target="_top">C</a></p>');
      });

      test('should convert using custom url sanitizer', () {
        final ops = [
          {
            'attributes': {'link': 'http://yahoo<%=abc%>/ed'},
            'insert': 'test'
          },
          {
            'attributes': {'link': 'http://abc<'},
            'insert': 'hi'
          },
        ];

        final qdc = QuillDeltaToHtmlConverter(
            ops,
            ConverterOptions(
                sanitizerOptions: OpAttributeSanitizerOptions(
              urlSanitizer: (link) => link.contains('<%') ? link : null,
            )));
        expect(
            qdc.convert(),
            '<p><a href="http://yahoo<%=abc%>/ed" target="_blank">test</a>'
            '<a href="http://abc&lt;" target="_blank">hi</a></p>');
      });

      test('should render empty table', () {
        final ops = [
          {
            'insert': '\n\n\n',
            'attributes': {
              'table': 'row-1',
            },
          },
          {
            'attributes': {
              'table': 'row-2',
            },
            'insert': '\n\n\n',
          },
          {
            'attributes': {
              'table': 'row-3',
            },
            'insert': '\n\n\n',
          },
          {
            'insert': '\n',
          },
        ];

        final qdc = QuillDeltaToHtmlConverter(ops);
        expect(
            qdc.convert(),
            '<table><tbody>'
            '<tr><td data-row="row-1"><br/></td><td data-row="row-1"><br/></td><td data-row="row-1"><br/></td></tr>'
            '<tr><td data-row="row-2"><br/></td><td data-row="row-2"><br/></td><td data-row="row-2"><br/></td></tr>'
            '<tr><td data-row="row-3"><br/></td><td data-row="row-3"><br/></td><td data-row="row-3"><br/></td></tr>'
            '</tbody></table>'
            '<p><br/></p>');
      });

      test('should render singe cell table', () {
        final ops = [
          {
            'insert': 'cell',
          },
          {
            'insert': '\n',
            'attributes': {
              'table': 'row-1',
            },
          },
        ];

        final qdc = QuillDeltaToHtmlConverter(ops);
        expect(
            qdc.convert(),
            '<table><tbody>'
            '<tr><td data-row="row-1">cell</td></tr>'
            '</tbody></table>');
      });

      test('should render filled table', () {
        final ops = [
          {
            'insert': '11',
          },
          {
            'attributes': {
              'table': 'row-1',
            },
            'insert': '\n',
          },
          {
            'insert': '12',
          },
          {
            'attributes': {
              'table': 'row-1',
            },
            'insert': '\n',
          },
          {
            'insert': '13',
          },
          {
            'attributes': {
              'table': 'row-1',
            },
            'insert': '\n',
          },
          {
            'insert': '21',
          },
          {
            'attributes': {
              'table': 'row-2',
            },
            'insert': '\n',
          },
          {
            'insert': '22',
          },
          {
            'attributes': {
              'table': 'row-2',
            },
            'insert': '\n',
          },
          {
            'insert': '23',
          },
          {
            'attributes': {
              'table': 'row-2',
            },
            'insert': '\n',
          },
          {
            'insert': '31',
          },
          {
            'attributes': {
              'table': 'row-3',
            },
            'insert': '\n',
          },
          {
            'insert': '32',
          },
          {
            'attributes': {
              'table': 'row-3',
            },
            'insert': '\n',
          },
          {
            'insert': '33',
          },
          {
            'attributes': {
              'table': 'row-3',
            },
            'insert': '\n',
          },
          {
            'insert': '\n',
          },
        ];

        final qdc = QuillDeltaToHtmlConverter(ops);
        expect(
            qdc.convert(),
            '<table><tbody>'
            '<tr><td data-row="row-1">11</td><td data-row="row-1">12</td><td data-row="row-1">13</td></tr>'
            '<tr><td data-row="row-2">21</td><td data-row="row-2">22</td><td data-row="row-2">23</td></tr>'
            '<tr><td data-row="row-3">31</td><td data-row="row-3">32</td><td data-row="row-3">33</td></tr>'
            '</tbody></table>'
            '<p><br/></p>');
      });
    });

    group('custom types', () {
      test('should return empty string if renderer not defined for custom blot',
          () {
        final ops = [
          {
            'insert': {'customstuff': 'my val'}
          }
        ];
        final qdc = QuillDeltaToHtmlConverter(ops);
        expect(qdc.convert(), '<p></p>');
      });

      test('should render custom insert types with given renderer', () {
        final ops = [
          {
            'insert': {'bolditalic': 'my text'}
          },
          {
            'insert': {'blah': 1}
          },
        ];
        final qdc = QuillDeltaToHtmlConverter(ops);
        qdc.renderCustomWith = (op, _) {
          if (op.insert.type == 'bolditalic') {
            return '<b><i>${op.insert.value}</i></b>';
          }
          return 'unknown';
        };
        final html = qdc.convert();
        expect(html, '<p><b><i>my text</i></b>unknown</p>');
      });

      test(
          'should render custom insert types as blocks if renderAsBlock is specified',
          () {
        final ops = [
          {'insert': 'hello '},
          {
            'insert': {'myblot': 'my friend'}
          },
          {'insert': '!'},
          {
            'insert': {'myblot': 'how r u?'},
            'attributes': {'renderAsBlock': true}
          },
        ];
        final qdc = QuillDeltaToHtmlConverter(ops);
        qdc.renderCustomWith = (op, _) {
          if (op.insert.type == 'myblot') {
            return op.attributes.renderAsBlock == true
                ? '<div>${op.insert.value}</div>'
                : op.insert.value;
          }
          return 'unknown';
        };
        final html = qdc.convert();
        expect(html, '<p>hello my friend!</p><div>how r u?</div>');
      });

      test(
          'should render custom insert types in code blocks with given renderer',
          () {
        final ops = [
          {
            'insert': {'colonizer': ':'}
          },
          {
            'insert': '\n',
            'attributes': {'code-block': true}
          },
          {'insert': 'code1'},
          {
            'insert': '\n',
            'attributes': {'code-block': true}
          },
          {
            'insert': {'colonizer': ':'}
          },
          {
            'insert': '\n',
            'attributes': {'code-block': true}
          },
        ];

        String renderer(DeltaInsertOp op, DeltaInsertOp? _) {
          if (op.insert.type == 'colonizer') {
            return op.insert.value;
          }
          return '';
        }

        var qdc = QuillDeltaToHtmlConverter(ops.sublist(0, 2));
        qdc.renderCustomWith = renderer;
        expect(qdc.convert(), '<pre>:</pre>');

        qdc = QuillDeltaToHtmlConverter(ops);
        qdc.renderCustomWith = renderer;
        expect(qdc.convert(), '<pre>:\ncode1\n:</pre>');

        qdc = QuillDeltaToHtmlConverter(
          ops,
          ConverterOptions(
            converterOptions: OpConverterOptions(
              customTag: (format, _) => format == 'code-block' ? 'code' : null,
            ),
          ),
        );
        qdc.renderCustomWith = renderer;
        expect(qdc.convert(), '<code>:\ncode1\n:</code>');
      });

      test('should render custom insert types in headers with given renderer',
          () {
        final ops = [
          {
            'insert': {'colonizer': ':'}
          },
          {
            'insert': '\n',
            'attributes': {'header': 1}
          },
          {'insert': 'hello'},
          {
            'insert': '\n',
            'attributes': {'header': 1}
          },
          {
            'insert': {'colonizer': ':'}
          },
          {
            'insert': '\n',
            'attributes': {'header': 1}
          },
        ];

        String renderer(DeltaInsertOp op, DeltaInsertOp? _) {
          if (op.insert.type == 'colonizer') {
            return op.insert.value;
          }
          return '';
        }

        var qdc = QuillDeltaToHtmlConverter(ops.sublist(0, 2));
        qdc.renderCustomWith = renderer;
        expect(qdc.convert(), '<h1>:</h1>');

        qdc = QuillDeltaToHtmlConverter(ops);
        qdc.renderCustomWith = renderer;
        expect(qdc.convert(), '<h1>:<br/>hello<br/>:</h1>');
      });
    });

    group('getListTag()', () {
      test('should return proper list tag', () {
        var op = DeltaInsertOp('\n', OpAttributes(list: ListType.ordered));
        final qdc = QuillDeltaToHtmlConverter(delta1Ops);
        expect(qdc.getListTag(op), 'ol');

        op = DeltaInsertOp('\n', OpAttributes(list: ListType.bullet));
        expect(qdc.getListTag(op), 'ul');

        op = DeltaInsertOp('\n', OpAttributes(list: ListType.checked));
        expect(qdc.getListTag(op), 'ul');

        op = DeltaInsertOp('\n', OpAttributes(list: ListType.unchecked));
        expect(qdc.getListTag(op), 'ul');

        op = DeltaInsertOp('d');
        expect(qdc.getListTag(op), '');
      });
    });

    group(' prepare data before inline and block renders', () {
      List<DeltaInsertOp> ops = [];
      setUp(() {
        ops = [
          DeltaInsertOp(''),
          DeltaInsertOp('Hello'),
          DeltaInsertOp(' my ', OpAttributes(italic: true)),
          DeltaInsertOp('\n', OpAttributes(italic: true)),
          DeltaInsertOp(' name is joey'),
        ];
      });

      group('renderInlines()', () {
        test('should render inlines', () {
          var qdc = QuillDeltaToHtmlConverter([]);
          var inlines = qdc.renderInlines(ops);
          expect(inlines, '<p>Hello<em> my </em><br/> name is joey</p>');

          qdc = QuillDeltaToHtmlConverter(
            [],
            ConverterOptions(
              converterOptions: OpConverterOptions(paragraphTag: 'div'),
            ),
          );
          inlines = qdc.renderInlines(ops);
          expect(inlines, '<div>Hello<em> my </em><br/> name is joey</div>');

          qdc = QuillDeltaToHtmlConverter(
            [],
            ConverterOptions(
              converterOptions: OpConverterOptions(paragraphTag: ''),
            ),
          );
          inlines = qdc.renderInlines(ops);
          expect(inlines, 'Hello<em> my </em><br/> name is joey');
        });

        test('should render inlines custom tag', () {
          var qdc = QuillDeltaToHtmlConverter(
            [],
            ConverterOptions(
              converterOptions: OpConverterOptions(
                customTag: (format, _) => format == 'italic' ? 'i' : null,
              ),
            ),
          );
          var inlines = qdc.renderInlines(ops);
          expect(inlines,
              ['<p>Hello', '<i> my </i><br/> name is joey</p>'].join(''));

          qdc = QuillDeltaToHtmlConverter(
            [],
            ConverterOptions(
              converterOptions: OpConverterOptions(paragraphTag: 'div'),
            ),
          );
          inlines = qdc.renderInlines(ops);
          expect(inlines, '<div>Hello<em> my </em><br/> name is joey</div>');

          qdc = QuillDeltaToHtmlConverter(
            [],
            ConverterOptions(
              converterOptions: OpConverterOptions(paragraphTag: ''),
            ),
          );
          inlines = qdc.renderInlines(ops);
          expect(inlines, 'Hello<em> my </em><br/> name is joey');
        });

        test('should render plain  line string', () {
          final ops = [DeltaInsertOp('\n')];
          final qdc = QuillDeltaToHtmlConverter([]);
          expect(qdc.renderInlines(ops), '<p><br/></p>');
        });

        test('should render styled newline string', () {
          final ops = [DeltaInsertOp('\n', OpAttributes(font: 'arial'))];
          var qdc = QuillDeltaToHtmlConverter([]);
          expect(qdc.renderInlines(ops), '<p><br/></p>');

          qdc = QuillDeltaToHtmlConverter(
            [],
            ConverterOptions(
              converterOptions: OpConverterOptions(paragraphTag: ''),
            ),
          );
          expect(qdc.renderInlines(ops), '<br/>');
        });

        test('should render when first line is newline', () {
          final ops = [DeltaInsertOp('\n'), DeltaInsertOp('aa')];
          final qdc = QuillDeltaToHtmlConverter([]);
          expect(qdc.renderInlines(ops), '<p><br/>aa</p>');
        });

        test('should render when last line is newline', () {
          final ops = [DeltaInsertOp('aa'), DeltaInsertOp('\n')];
          final qdc = QuillDeltaToHtmlConverter([]);
          expect(qdc.renderInlines(ops), '<p>aa</p>');
        });

        test('should render mixed lines', () {
          final ops = [DeltaInsertOp('aa'), DeltaInsertOp('bb')];
          final nlop = DeltaInsertOp('\n');
          final stylednlop = DeltaInsertOp(
              '\n',
              OpAttributes(
                color: '#333',
                italic: true,
              ));
          final qdc = QuillDeltaToHtmlConverter([]);
          expect(qdc.renderInlines(ops), '<p>aabb</p>');

          final ops0 = [nlop, ops[0], nlop, ops[1]];
          expect(qdc.renderInlines(ops0), '<p><br/>aa<br/>bb</p>');

          final ops4 = [ops[0], stylednlop, stylednlop, stylednlop, ops[1]];
          expect(
              qdc.renderInlines(ops4), ['<p>aa<br/><br/><br/>bb</p>'].join(''));
        });
      });

      group('renderBlock()', () {
        final op = DeltaInsertOp('\n', OpAttributes(header: 3, indent: 2));
        final inlineop = DeltaInsertOp('hi there');
        test('should render container block', () {
          var qdc = QuillDeltaToHtmlConverter([]);
          var blockhtml = qdc.renderBlock(op, [inlineop]);
          expect(blockhtml,
              ['<h3 class="ql-indent-2">', 'hi there</h3>'].join(''));

          qdc = QuillDeltaToHtmlConverter([]);
          blockhtml = qdc.renderBlock(op, []);
          expect(
              blockhtml, ['<h3 class="ql-indent-2">', '<br/></h3>'].join(''));
        });

        test('should correctly render code block', () {
          final ops = [
            {
              'insert': 'line 1',
            },
            {
              'attributes': {
                'code-block': true,
              },
              'insert': '\n',
            },
            {
              'insert': 'line 2',
            },
            {
              'attributes': {
                'code-block': true,
              },
              'insert': '\n',
            },
            {
              'insert': 'line 3',
            },
            {
              'attributes': {
                'code-block': 'javascript',
              },
              'insert': '\n',
            },
            {
              'insert': '<p>line 4</p>',
            },
            {
              'attributes': {
                'code-block': true,
              },
              'insert': '\n',
            },
            {
              'insert': 'line 5',
            },
            {
              'attributes': {
                'code-block': 'ja"va',
              },
              'insert': '\n',
            },
          ];

          var qdc = QuillDeltaToHtmlConverter(ops);
          var html = qdc.convert();
          expect(
              html,
              '<pre>line 1\nline 2</pre>'
              '<pre data-language="javascript">line 3</pre>'
              '<pre>'
              '&lt;p&gt;line 4&lt;&#47;p&gt;'
              '\nline 5'
              '</pre>');

          qdc = QuillDeltaToHtmlConverter(
              ops,
              ConverterOptions(
                multiLineCodeblock: false,
              ));
          html = qdc.convert();
          expect(
              html,
              '<pre>line 1</pre><pre>line 2</pre>'
              '<pre data-language="javascript">line 3</pre>'
              '<pre>'
              '&lt;p&gt;line 4&lt;&#47;p&gt;'
              '</pre>'
              '<pre>line 5</pre>');

          qdc = QuillDeltaToHtmlConverter([ops[0], ops[1]]);
          html = qdc.convert();
          expect(html, '<pre>line 1</pre>');
        });
      });

      test('should correctly render custom text block', () {
        final ops = [
          {
            'insert': 'line 1',
          },
          {
            'attributes': {
              'renderAsBlock': true,
              'attr1': true,
            },
            'insert': '\n',
          },
          {
            'insert': 'line 2',
          },
          {
            'attributes': {
              'renderAsBlock': true,
              'attr1': true,
            },
            'insert': '\n',
          },
          {
            'insert': 'line 3',
          },
          {
            'attributes': {
              'renderAsBlock': true,
              'attr2': true,
            },
            'insert': '\n',
          },
          {
            'insert': '<p>line 4</p>',
          },
          {
            'attributes': {
              'renderAsBlock': true,
              'attr1': true,
            },
            'insert': '\n',
          },
          {
            'insert': 'line 5',
          },
          {
            'attributes': {
              'renderAsBlock': true,
              'attr1': 'test',
            },
            'insert': '\n',
          },
        ];

        var qdc = QuillDeltaToHtmlConverter(
          ops,
          ConverterOptions(
            converterOptions: OpConverterOptions(
              customTag: (format, op) {
                if (format == 'renderAsBlock' &&
                    op.attributes['attr1'] == 'test') {
                  return 'test';
                }
                return null;
              },
              customTagAttributes: (op) {
                if (op.attributes['attr1'] == 'test') {
                  return {
                    'attr1': op.attributes['attr1'],
                  };
                }
                return null;
              },
              customCssClasses: (op) {
                if (op.attributes['attr1'] == 'test') {
                  return ['ql-test'];
                }
                return null;
              },
              customCssStyles: (op) {
                if (op.attributes['attr1'] == 'test') {
                  return ['color:red'];
                }
                return null;
              },
            ),
          ),
        );

        var html = qdc.convert();
        expect(
            html,
            '<p>line 1<br/>line 2</p>'
            '<p>line 3</p>'
            '<p>'
            '&lt;p&gt;line 4&lt;&#47;p&gt;'
            '</p>'
            '<test attr1="test" class="ql-test" style="color:red">line 5</test>');

        qdc = QuillDeltaToHtmlConverter(
          ops,
          ConverterOptions(multiLineCustomBlock: false),
        );
        html = qdc.convert();
        expect(
            html,
            '<p>line 1</p><p>line 2</p>'
            '<p>line 3</p>'
            '<p>'
            '&lt;p&gt;line 4&lt;&#47;p&gt;'
            '</p>'
            '<p>line 5</p>');

        qdc = QuillDeltaToHtmlConverter([ops[0], ops[1]]);
        html = qdc.convert();
        expect(html, '<p>line 1</p>');
      });

      group('before n after renders()', () {
        final ops = [
          {
            'insert': 'hello',
            'attributes': {'bold': true}
          },
          {
            'insert': '\n',
            'attributes': {'bold': true}
          },
          {'insert': 'how r u?'},
          {'insert': 'r u fine'},
          {
            'insert': '\n',
            'attributes': {'blockquote': true}
          },
          {
            'insert': {'video': 'http://'}
          },
          {'insert': 'list item 1'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'}
          },
          {'insert': 'list item 1 indented'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet', 'indent': 1}
          },
        ];
        final qdc = QuillDeltaToHtmlConverter(ops);

        test('should call before/after render callbacks ', () {
          var status = 0;
          qdc.beforeRender = (groupType, data) {
            if (groupType == GroupType.inlineGroup) {
              final op = (data as InlineGroup).ops[0];
              expect(op.attributes.bold, true);
            } else if (groupType == GroupType.video) {
              final op = (data as VideoItem).op;
              expect(op.insert.type, DataType.video);
            } else if (groupType == GroupType.block) {
              final d = data as BlockGroup;
              expect(d.op.attributes.blockquote, true);
              expect(d.ops.length, 2);
            } else {
              final d = data as ListGroup;
              expect(d.items.length, 1);
            }

            status++;
            return '';
          };

          qdc.afterRender = (groupType, html) {
            if (groupType == GroupType.inlineGroup) {
              expect(html, contains('<strong>hello'));
            } else if (groupType == GroupType.video) {
              expect(html, contains('<iframe'));
            } else if (groupType == GroupType.block) {
              expect(html, contains('<blockquote'));
            } else {
              expect(html, contains('list item 1<ul><li'));
            }

            status++;
            return html;
          };

          qdc.convert();
          expect(status, 8);
        });

        test(
            'should call before render with block grouptype for align indent and direction',
            () {
          final ops = [
            {'insert': 'align'},
            {
              'insert': '\n',
              'attributes': {'align': 'right'}
            },
            {'insert': 'rtl'},
            {
              'insert': '\n',
              'attributes': {'direction': 'rtl'}
            },
            {'insert': 'indent 1'},
            {
              'insert': '\n',
              'attributes': {'indent': 1}
            },
          ];
          var status = 0;
          final qdc = QuillDeltaToHtmlConverter(ops);
          qdc.beforeRender = (gtype, _) {
            if (gtype == GroupType.block) status++;
            return '';
          };

          qdc.convert();
          expect(status, 3);
        });

        test('should use my custom html if I return from before call back', () {
          final c = QuillDeltaToHtmlConverter([
            {
              'insert': {'video': 'http'}
            },
            {'insert': 'aa'},
          ]);
          c.beforeRender = (_, __) {
            return '<my custom video html>';
          };

          final v = c.convert();
          expect(v, contains('<my custom'));
        });

        test('should register and use callbacks if they are functions', () {
          final c = QuillDeltaToHtmlConverter([
            {
              'insert': {'video': 'http'}
            },
            {'insert': 'aa'},
          ]);

          String? dummyBefore(GroupType g, TDataGroup d) => '<fake/>';
          String? dummyAfter(GroupType g, String html) => '';

          var v = c.convert();
          expect(
              v,
              '<iframe class="ql-video" frameborder="0" allowfullscreen="true" src="unsafe:http"></iframe>'
              '<p>aa</p>');

          c.beforeRender = dummyBefore;
          v = c.convert();
          expect(v, '<fake/><fake/>');

          c.afterRender = dummyAfter;
          v = c.convert();
          expect(v, '');
        });
      });
    });
  });

  group('HTML Email meta-test', () {
    test('HTML email full test', () {
      final converter = QuillDeltaToHtmlConverter(
          emailMetaTestOps, ConverterOptions.forEmail());
      final html = converter.convert();

      expect(html, emailMetaTestExpectedHtml);
    });
  });
}
