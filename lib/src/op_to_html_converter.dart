import 'package:meta/meta.dart';

import 'delta_insert_op.dart';
import 'funcs_html.dart';
import 'helpers/array.dart' as arr;
import 'helpers/js.dart';
import 'op_attribute_sanitizer.dart';
import 'value_types.dart';

class InlineStyleType {
  InlineStyleType({this.fn, this.map});

  final String? Function(String value, DeltaInsertOp op)? fn;
  final Map<String, String>? map;
}

class InlineStyles {
  InlineStyles(this.attrs);

  final Map<String, InlineStyleType> attrs;

  InlineStyleType? operator [](String key) => attrs[key];
}

const Map<String, String> defaultInlineFonts = {
  'serif': 'font-family: Georgia, Times New Roman, serif',
  'monospace': 'font-family: Monaco, Courier New, monospace'
};

final defaultInlineStyles = InlineStyles({
  'font': InlineStyleType(
      fn: (value, _) => defaultInlineFonts[value] ?? 'font-family:$value'),
  'size': InlineStyleType(map: {
    'small': 'font-size: 0.75em',
    'large': 'font-size: 1.5em',
    'huge': 'font-size: 2.5em',
  }),
  'indent': InlineStyleType(fn: (value, op) {
    final indentSize = (double.tryParse(value) ?? double.nan) * 3;
    final side = op.attributes['direction'] == 'rtl' ? 'right' : 'left';
    return 'padding-$side:${indentSize}em';
  }),
  'direction': InlineStyleType(fn: (value, op) {
    if (value == 'rtl') {
      final textAlign =
          isTruthy(op.attributes['align']) ? '' : '; text-align:inherit';
      return ('direction:rtl$textAlign');
    } else {
      return null;
    }
  }),
  'list': InlineStyleType(map: {
    'checked': "list-style-type:'\\2611';padding-left: 0.5em;",
    'unchecked': "list-style-type:'\\2610';padding-left: 0.5em;",
  }),
});

class OpConverterOptions {
  OpConverterOptions({
    this.classPrefix = 'ql',
    this.inlineStylesFlag = false,
    this.inlineStyles,
    this.encodeHtml = true,
    this.listItemTag = 'li',
    this.paragraphTag = 'p',
    this.linkRel,
    this.linkTarget,
    this.allowBackgroundClasses = false,
    this.customTag,
    this.customTagAttributes,
    this.customCssClasses,
    this.customCssStyles,
  }) {
    if (inlineStyles == null && inlineStylesFlag == true) {
      inlineStyles = InlineStyles({});
    }
  }

  String classPrefix;
  bool? inlineStylesFlag;
  InlineStyles? inlineStyles;
  bool encodeHtml;
  String listItemTag;
  String paragraphTag;
  String? linkRel;
  String? linkTarget;
  bool? allowBackgroundClasses;
  String? Function(String format, DeltaInsertOp op)? customTag;
  Map<String, String>? Function(DeltaInsertOp op)? customTagAttributes;
  List<String>? Function(DeltaInsertOp op)? customCssClasses;
  List<String>? Function(DeltaInsertOp op)? customCssStyles;
}

class HtmlParts {
  HtmlParts({
    required this.openingTag,
    required this.content,
    required this.closingTag,
  });

  final String openingTag;
  final String content;
  final String closingTag;
}

/// Converts a single Delta op to HTML.
class OpToHtmlConverter {
  OpToHtmlConverter(this.op, [OpConverterOptions? options]) {
    this.options = options ?? OpConverterOptions();
  }

  late final OpConverterOptions options;
  final DeltaInsertOp op;

  @visibleForTesting
  String prefixClass(String className) {
    if (!isTruthy(options.classPrefix)) {
      return className;
    }
    return '${options.classPrefix}-$className';
  }

  String getHtml() {
    final parts = getHtmlParts();
    return parts.openingTag + parts.content + parts.closingTag;
  }

  HtmlParts getHtmlParts() {
    if (op.isJustNewline() && !op.isContainerBlock()) {
      return HtmlParts(openingTag: '', closingTag: '', content: newLine);
    }

    final tags = getTags();
    var attrs = getTagAttributes();

    if (tags.isEmpty && attrs.isNotEmpty) {
      tags.add('span');
    }

    final beginTags = <String>[];
    final endTags = <String>[];
    const imgTag = 'img';
    bool isImageLink(tag) => tag == imgTag && isTruthy(op.attributes.link);
    for (final tag in tags) {
      if (isImageLink(tag)) {
        beginTags.add(makeStartTag('a', getLinkAttrs()));
      }

      beginTags.add(makeStartTag(tag, attrs));
      endTags.add(tag == imgTag ? '' : makeEndTag(tag));
      if (isImageLink(tag)) {
        endTags.add(makeEndTag('a'));
      }
      // consumed in first tag
      attrs = [];
    }

    return HtmlParts(
      openingTag: beginTags.join(),
      content: getContent(),
      closingTag: endTags.reversed.join(),
    );
  }

  String getContent() {
    if (op.isContainerBlock()) {
      return '';
    }

    if (op.isMentions()) {
      return op.insert.value;
    }

    var content = op.isFormula() || op.isText() ? op.insert.value : '';

    return options.encodeHtml == true ? encodeHtml(content) : content;
  }

  bool _supportInlineStyles() =>
      options.inlineStylesFlag == true || options.inlineStyles != null;

  List<String> getCssClasses() {
    var attrs = op.attributes;

    if (_supportInlineStyles()) {
      return [];
    }

    var propsArr = ['indent', 'align', 'direction', 'font', 'size'];
    if (options.allowBackgroundClasses == true) {
      propsArr.add('background');
    }

    var props = propsArr
        .where((prop) =>
            isTruthy(attrs[prop]) &&
            (prop != 'background' ||
                OpAttributeSanitizer.isValidColorLiteral(attrs[prop])))
        .map((prop) => '$prop-${attrs[prop]}')
        .toList();
    if (op.isFormula()) props.add('formula');
    if (op.isVideo()) props.add('video');
    if (op.isImage()) props.add('image');
    props = props.map((prop) => prefixClass(prop)).toList();

    final customClasses = getCustomCssClasses();
    if (customClasses != null) props.insertAll(0, customClasses);

    return props;
  }

  List<String> getCssStyles() {
    final attrs = op.attributes;

    final propsArr = [
      ['color']
    ];
    final inlineStyles = _supportInlineStyles();
    if (inlineStyles || options.allowBackgroundClasses != true) {
      propsArr.add(['background', 'background-color']);
    }
    if (inlineStyles) {
      propsArr.addAll([
        ['indent'],
        ['align', 'text-align'],
        ['direction'],
        ['font', 'font-family'],
        ['size'],
        ['list'],
      ]);
    }

    final props = propsArr
        .where((item) => isTruthy(attrs[item[0]]))
        .map((item) {
          final attribute = item[0];
          final attrValue = attrs[attribute];

          final attributeConverter = (_supportInlineStyles()
                  ? (options.inlineStyles?[attribute])
                  : null) ??
              defaultInlineStyles[attribute];

          if (attributeConverter?.map != null) {
            return attributeConverter!.map![attrValue];
          } else if (attributeConverter?.fn != null) {
            return attributeConverter!.fn!(attrValue.toString(), op);
          } else {
            return '${arr.preferSecond(item)}:$attrValue';
          }
        })
        .where((item) => item != null)
        .map((item) => item!)
        .toList();

    final customCssStyles = getCustomCssStyles();
    if (customCssStyles != null) props.insertAll(0, customCssStyles);

    return props;
  }

  List<TagKeyValue> getTagAttributes() {
    if (op.attributes.code == true && !op.isLink()) {
      return [];
    }

    final customTagAttributes = getCustomTagAttributes();
    final customAttr = customTagAttributes?.entries
            .map((entry) => makeAttr(entry.key, entry.value))
            .toList() ??
        [];
    final classes = getCssClasses();
    final tagAttrs = customAttr;
    if (classes.isNotEmpty) {
      tagAttrs.add(makeAttr('class', classes.join(' ')));
    }

    final styles = getCssStyles();
    if (styles.isNotEmpty) {
      tagAttrs.add(makeAttr('style', styles.join(';')));
    }

    if (op.isImage()) {
      if (isTruthy(op.attributes.width)) {
        tagAttrs.add(makeAttr('width', op.attributes.width!));
      }
      tagAttrs.add(makeAttr('src', op.insert.value));
      return tagAttrs;
    }

    if (op.isACheckList()) {
      tagAttrs
          .add(makeAttr('data-checked', op.isCheckedList() ? 'true' : 'false'));
      return tagAttrs;
    }

    if (op.isFormula()) {
      return tagAttrs;
    }

    if (op.isVideo()) {
      tagAttrs.addAll([
        makeAttr('frameborder', '0'),
        makeAttr('allowfullscreen', 'true'),
        makeAttr('src', op.insert.value),
      ]);
      return tagAttrs;
    }

    if (op.isMentions()) {
      final mention = op.attributes.mention!;
      if (isTruthy(mention.class_)) {
        tagAttrs.add(makeAttr('class', mention.class_!));
      }
      if (isTruthy(mention.endPoint) && isTruthy(mention.slug)) {
        tagAttrs.add(makeAttr('href', '${mention.endPoint!}/${mention.slug!}'));
      } else {
        tagAttrs.add(makeAttr('href', 'about:blank'));
      }

      if (isTruthy(mention.target)) {
        tagAttrs.add(makeAttr('target', mention.target!));
      }
      return tagAttrs;
    }

    if (op.isCodeBlock() && op.attributes['code-block'] is String) {
      tagAttrs.add(makeAttr('data-language', op.attributes['code-block']));
      return tagAttrs;
    }

    if (op.isContainerBlock()) {
      return tagAttrs;
    }

    if (op.isLink()) {
      tagAttrs.addAll(getLinkAttrs());
    }

    return tagAttrs;
  }

  TagKeyValue makeAttr(String k, String v) => TagKeyValue(key: k, value: v);

  List<TagKeyValue> getLinkAttrs() {
    final targetForAll =
        OpAttributeSanitizer.isValidTarget(options.linkTarget ?? '')
            ? options.linkTarget
            : null;

    final relForAll = OpAttributeSanitizer.isValidRel(options.linkRel ?? '')
        ? options.linkRel
        : null;

    final target = op.attributes.target ?? targetForAll;
    final rel = op.attributes.rel ?? relForAll;

    final tagAttrs = [makeAttr('href', op.attributes.link!)];
    if (isTruthy(target)) tagAttrs.add(makeAttr('target', target!));
    if (isTruthy(rel)) tagAttrs.add(makeAttr('rel', rel!));
    return tagAttrs;
  }

  String? getCustomTag(String format) => options.customTag?.call(format, op);

  Map<String, String>? getCustomTagAttributes() =>
      options.customTagAttributes?.call(op);

  List<String>? getCustomCssClasses() => options.customCssClasses?.call(op);

  List<String>? getCustomCssStyles() => options.customCssStyles?.call(op);

  List<String> getTags() {
    final attrs = op.attributes;

    // embeds
    if (!op.isText()) {
      return [
        op.isVideo()
            ? 'iframe'
            : op.isImage()
                ? 'img'
                : 'span', // formula
      ];
    }

    // blocks
    final positionTag = options.paragraphTag;
    final blocks = [
      ['blockquote'],
      ['code-block', 'pre'],
      ['list', options.listItemTag],
      ['header'],
      ['align', positionTag],
      ['direction', positionTag],
      ['indent', positionTag],
    ];
    for (final item in blocks) {
      var firstItem = item[0];
      if (isTruthy(attrs[firstItem])) {
        final customTag = getCustomTag(firstItem);
        return isTruthy(customTag)
            ? [customTag!]
            : firstItem == 'header'
                ? ['h${attrs[firstItem]}']
                : [arr.preferSecond(item)!];
      }
    }

    if (op.isCustomTextBlock()) {
      final customTag = getCustomTag('renderAsBlock');
      return isTruthy(customTag) ? [customTag!] : [positionTag];
    }

    // inlines
    final customTagsMap = attrs.attrs.keys.fold(<String, String>{}, (res, it) {
      final customTag = getCustomTag(it);
      if (isTruthy(customTag)) {
        res[it] = customTag!;
      }
      return res;
    });

    const inlineTags = [
      ['link', 'a'],
      ['mentions', 'a'],
      ['script'],
      ['bold', 'strong'],
      ['italic', 'em'],
      ['strike', 's'],
      ['underline', 'u'],
      ['code'],
    ];

    final tl = [
      ...inlineTags.where((item) => isTruthy(attrs[item[0]])).toList(),
      ...customTagsMap.keys
          .where((t) => !inlineTags.any((it) => it[0] == t))
          .map((t) => [t, customTagsMap[t]!]),
    ];
    return tl.map((item) {
      final v = customTagsMap[item[0]];
      return isTruthy(v)
          ? v!
          : item[0] == 'script'
              ? attrs[item[0]] == ScriptType.subscript.value
                  ? 'sub'
                  : 'sup'
              : arr.preferSecond(item)!;
    }).toList();
  }
}
