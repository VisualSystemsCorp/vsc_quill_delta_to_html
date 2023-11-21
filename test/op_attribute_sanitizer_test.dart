import 'package:test/test.dart';
import 'package:vsc_quill_delta_to_html/src/mentions/mention_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';

void main() {
  group('OpAttributeSanitizer', () {
    group('#IsValidHexColor()', () {
      test('should return true if hex color is valid', () {
        expect(OpAttributeSanitizer.isValidHexColor('#234'), true);
        expect(OpAttributeSanitizer.isValidHexColor('#f23'), true);
        expect(OpAttributeSanitizer.isValidHexColor('#fFe234'), true);
        expect(OpAttributeSanitizer.isValidHexColor('#g34'), false);
        expect(OpAttributeSanitizer.isValidHexColor('#fFe234a5'), true);
        expect(OpAttributeSanitizer.isValidHexColor('#fFe234b'), false);
        expect(OpAttributeSanitizer.isValidHexColor('#aabb'), false);

        expect(OpAttributeSanitizer.isValidHexColor('e34'), false);
        expect(OpAttributeSanitizer.isValidHexColor('123434'), false);
      });
    });

    group('#IsValidFontName()', () {
      test('should return true if font name is valid', () {
        expect(OpAttributeSanitizer.isValidFontName('gooD-ol times 2'), true);
        expect(OpAttributeSanitizer.isValidHexColor('bad"times?'), false);
      });
    });

    group('#IsValidSize()', () {
      test('should return true if size is valid', () {
        expect(OpAttributeSanitizer.isValidSize('bigfaT-size'), true);
        expect(OpAttributeSanitizer.isValidSize('small.sizetimes?'), false);
      });
    });

    group('#IsValidWidth()', () {
      test('should return true if width is valid', () {
        expect(OpAttributeSanitizer.isValidWidth('150'), true);
        expect(OpAttributeSanitizer.isValidWidth('100px'), true);
        expect(OpAttributeSanitizer.isValidWidth('150em'), true);
        expect(OpAttributeSanitizer.isValidWidth('10%'), true);
        expect(OpAttributeSanitizer.isValidWidth('250%px'), false);
        expect(OpAttributeSanitizer.isValidWidth('250% border-box'), false);
        expect(OpAttributeSanitizer.isValidWidth('250.80'), false);
        expect(OpAttributeSanitizer.isValidWidth('250x'), false);
      });
    });

    group('#IsValidColorLiteral()', () {
      test('should return true if color literal is valid', () {
        expect(OpAttributeSanitizer.isValidColorLiteral('yellow'), true);
        expect(OpAttributeSanitizer.isValidColorLiteral('r'), true);
        expect(OpAttributeSanitizer.isValidColorLiteral('#234'), false);
        expect(OpAttributeSanitizer.isValidColorLiteral('#fFe234'), false);
        expect(OpAttributeSanitizer.isValidColorLiteral('red1'), false);
        expect(OpAttributeSanitizer.isValidColorLiteral('red-green'), false);
        expect(OpAttributeSanitizer.isValidColorLiteral(''), false);
      });
    });

    group('#IsValidRGBColor()', () {
      test('should return true if rgb color is valid', () {
        expect(OpAttributeSanitizer.isValidRGBColor('rgb(0,0,0)'), true);
        expect(OpAttributeSanitizer.isValidRGBColor('rgb(255, 99, 1)'), true);
        expect(
            OpAttributeSanitizer.isValidRGBColor('RGB(254, 249, 109)'), true);
        expect(OpAttributeSanitizer.isValidRGBColor('yellow'), false);
        expect(OpAttributeSanitizer.isValidRGBColor('#FFF'), false);
        expect(OpAttributeSanitizer.isValidRGBColor('rgb(256,0,0)'), false);
        expect(OpAttributeSanitizer.isValidRGBColor('rgb(260,0,0)'), false);
        expect(OpAttributeSanitizer.isValidRGBColor('rgb(2000,0,0)'), false);
      });
    });

    group('#IsValidRGBColor()', () {
      test('should return true if rgba color is valid', () {
        expect(OpAttributeSanitizer.isValidRGBAColor('rgba(0,0,0, 0)'), true);
        expect(OpAttributeSanitizer.isValidRGBAColor('rgba(255, 99, 55, 1)'),
            true);
        expect(
            OpAttributeSanitizer.isValidRGBAColor('RGBA(254, 249, 109, 0.25)'),
            true);
        expect(OpAttributeSanitizer.isValidRGBAColor('yellow'), false);
        expect(OpAttributeSanitizer.isValidRGBAColor('#FFF'), false);
        expect(OpAttributeSanitizer.isValidRGBAColor('rgba(256,0,0,0)'), false);
        expect(OpAttributeSanitizer.isValidRGBAColor('rgba(0,0,0,1.5)'), false);
        expect(
            OpAttributeSanitizer.isValidRGBAColor('rgba(2000,0,0,0.5)'), false);
      });
    });

    group('#IsValidRel()', () {
      test('should return true if rel is valid', () {
        expect(OpAttributeSanitizer.isValidRel('nofollow'), true);
        expect(OpAttributeSanitizer.isValidRel('tag'), true);
        expect(OpAttributeSanitizer.isValidRel('tag nofollow'), true);
        expect(OpAttributeSanitizer.isValidRel('no"follow'), false);
        expect(OpAttributeSanitizer.isValidRel('tag1'), false);
        expect(OpAttributeSanitizer.isValidRel(''), false);
      });
    });
    group('#IsValidLang()', () {
      test('should return true if lang is valid', () {
        expect(OpAttributeSanitizer.isValidLang('javascript'), true);
        expect(OpAttributeSanitizer.isValidLang(true), true);
        expect(OpAttributeSanitizer.isValidLang('C++'), true);
        expect(OpAttributeSanitizer.isValidLang('HTML/XML'), true);
        expect(OpAttributeSanitizer.isValidLang('lang"uage'), false);
        expect(OpAttributeSanitizer.isValidLang(''), false);
      });
    });

    group('#sanitize()', () {
      final mention = Mention()
        ..class_ = 'A-cls-9'
        ..id = 'An-id_9:.'
        ..target = '_blank'
        ..avatar = 'http://www.yahoo.com'
        ..endPoint = 'http://abc.com'
        ..slug = 'my-name';
      final attrs = OpAttributes()
        ..attrs['bold'] = 'nonboolval'
        ..attrs['script'] = 'supper'
        ..attrs['header'] = '3'
        ..attrs['customAttr1'] = 'shouldnt be touched'
        ..color = '#12345H'
        ..background = '#333'
        ..font = 'times new roman'
        ..size = 'x.large'
        ..link = 'http://<'
        ..list = ListType.ordered
        ..indent = 40
        ..direction = DirectionType.rtl
        ..align = AlignType.center
        ..width = '3'
        ..mentions = true
        ..mention = mention;

      test('should return sanitized attributes', () {
        expect(
            OpAttributeSanitizer.sanitize(attrs, OpAttributeSanitizerOptions())
                .attrs,
            {
              'bold': true,
              'background': '#333',
              'font': 'times new roman',
              'link': 'http://&lt;',
              'list': 'ordered',
              'header': 3,
              'indent': 30,
              'direction': 'rtl',
              'align': 'center',
              'width': '3',
              'customAttr1': 'shouldnt be touched',
              'mentions': true,
              'mention': {
                'class': 'A-cls-9',
                'id': 'An-id_9:.',
                'target': '_blank',
                'avatar': 'http://www.yahoo.com',
                'end-point': 'http://abc.com',
                'slug': 'my-name'
              }
            });

        expect(
            OpAttributeSanitizer.sanitize(
                OpAttributes()
                  ..mentions = true
                  ..mention = null,
                OpAttributeSanitizerOptions()),
            OpAttributes());

        expect(
            OpAttributeSanitizer.sanitize(
                    OpAttributes()..header = 1, OpAttributeSanitizerOptions())
                .attrs,
            {
              'header': 1,
            });

        expect(
            OpAttributeSanitizer.sanitize(OpAttributes()..header = null,
                    OpAttributeSanitizerOptions())
                .attrs,
            {});

        expect(
            OpAttributeSanitizer.sanitize(
                    OpAttributes()..header = 100, OpAttributeSanitizerOptions())
                .attrs,
            {
              'header': 6,
            });

        expect(
            OpAttributeSanitizer.sanitize(
                    OpAttributes()..align = AlignType.center,
                    OpAttributeSanitizerOptions())
                .attrs,
            {'align': 'center'});

        expect(
            OpAttributeSanitizer.sanitize(
                    OpAttributes()..direction = DirectionType.rtl,
                    OpAttributeSanitizerOptions())
                .attrs,
            {'direction': 'rtl'});

        expect(
            OpAttributeSanitizer.sanitize(
                    OpAttributes()..indent = 2, OpAttributeSanitizerOptions())
                .attrs,
            {
              'indent': 2,
            });

        expect(
            OpAttributeSanitizer.sanitize(OpAttributes()..color = '#112233',
                    OpAttributeSanitizerOptions())
                .attrs,
            {
              'color': '#112233',
            });

        expect(
            OpAttributeSanitizer.sanitize(OpAttributes()..color = '#FF112233',
                    OpAttributeSanitizerOptions())
                .attrs,
            {
              'color': '#112233FF',
            });

        expect(
            OpAttributeSanitizer.sanitize(
                OpAttributes()..color = '#FF112233',
                OpAttributeSanitizerOptions(
                  argbHexColors: false,
                )).attrs,
            {
              'color': '#FF112233',
            });

        expect(
            OpAttributeSanitizer.sanitize(
                    OpAttributes()..background = '#FF112233',
                    OpAttributeSanitizerOptions())
                .attrs,
            {
              'background': '#112233FF',
            });

        expect(
            OpAttributeSanitizer.sanitize(OpAttributes()..color = 'rgba(255, 99, 71, 0.5)',
                    OpAttributeSanitizerOptions())
                .attrs,
            {
              'color': 'rgba(255, 99, 71, 0.5)',
            });
      });

      test('OpAttributes size and width should handle numerics', () {
        expect((OpAttributes()..['size'] = 8.0).size, '8.0');
        expect((OpAttributes()..['width'] = 8.0).width, '8.0');
        expect((OpAttributes()..['size'] = 42).size, '42');
        expect((OpAttributes()..['width'] = 42).width, '42');
        expect((OpAttributes()..['size'] = 'small').size, 'small');
        expect((OpAttributes()..['width'] = 'wide').width, 'wide');
      });
    });
  });
}
