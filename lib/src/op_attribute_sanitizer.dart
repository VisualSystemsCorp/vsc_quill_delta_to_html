import 'dart:math';

import 'package:collection/collection.dart';
import 'package:vsc_quill_delta_to_html/src/mentions/mention_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';

import 'helpers/js.dart';
import 'op_link_sanitizer.dart';

class OpAttributes {
  OpAttributes({
    String? background,
    String? color,
    String? font,
    String? size,
    String? width,
    String? link,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strike,
    ScriptType? script,
    bool? code,
    ListType? list,
    bool? blockquote,
    num? header,
    AlignType? align,
    DirectionType? direction,
    num? indent,
    String? table,
    bool? mentions,
    Mention? mention,
    String? target,
    String? rel,
    bool? renderAsBlock,
  }) {
    this.background = background;
    this.color = color;
    this.font = font;
    this.size = size;
    this.width = width;
    this.link = link;
    this.bold = bold;
    this.italic = italic;
    this.underline = underline;
    this.strike = strike;
    this.script = script;
    this.code = code;
    this.list = list;
    this.blockquote = blockquote;
    this.header = header;
    this.align = align;
    this.direction = direction;
    this.indent = indent;
    this.table = table;
    this.mentions = mentions;
    this.mention = mention;
    this.target = target;
    this.rel = rel;
    this.renderAsBlock = renderAsBlock;
  }

  final Map<String, dynamic> attrs = {};

  String? get background => attrs['background'];
  set background(String? v) =>
      v == null ? attrs.remove('background') : attrs['background'] = v;

  String? get color => attrs['color'];
  set color(String? v) =>
      v == null ? attrs.remove('color') : attrs['color'] = v;

  String? get font => attrs['font'];
  set font(String? v) => v == null ? attrs.remove('font') : attrs['font'] = v;

  String? get size => _getSizeAsString('size');
  set size(String? v) => v == null ? attrs.remove('size') : attrs['size'] = v;

  String? get width => _getSizeAsString('width');
  set width(String? v) =>
      v == null ? attrs.remove('width') : attrs['width'] = v;

  String? _getSizeAsString(String attrName) {
    final size = attrs[attrName];
    return size is! String? ? size.toString() : size;
  }

  String? get link => attrs['link'];
  set link(String? v) => v == null ? attrs.remove('link') : attrs['link'] = v;

  bool? get bold => attrs['bold'];
  set bold(bool? v) => v == null ? attrs.remove('bold') : attrs['bold'] = v;

  bool? get italic => attrs['italic'];
  set italic(bool? v) =>
      v == null ? attrs.remove('italic') : attrs['italic'] = v;

  bool? get underline => attrs['underline'];
  set underline(bool? v) =>
      v == null ? attrs.remove('underline') : attrs['underline'] = v;

  bool? get strike => attrs['strike'];
  set strike(bool? v) =>
      v == null ? attrs.remove('strike') : attrs['strike'] = v;

  T? _getEnum<T extends EnumValueType>(List<T> values, String attrName) {
    final v = attrs[attrName];
    if (v == null) return null;
    return values.firstWhereOrNull((t) => t.value == v);
  }

  ScriptType? get script => _getEnum(ScriptType.values, 'script');
  set script(ScriptType? v) =>
      v == null ? attrs.remove('script') : attrs['script'] = v.value;

  bool? get code => attrs['code'];
  set code(bool? v) => v == null ? attrs.remove('code') : attrs['code'] = v;

  ListType? get list => _getEnum(ListType.values, 'list');
  set list(ListType? v) =>
      v == null ? attrs.remove('list') : attrs['list'] = v.value;

  bool? get blockquote => attrs['blockquote'];
  set blockquote(bool? v) =>
      v == null ? attrs.remove('blockquote') : attrs['blockquote'] = v;

  num? _getNumber(String attrName) {
    final v = attrs[attrName];
    if (v == null) return null;
    return asNumber(v);
  }

  num? get header => _getNumber('header');
  set header(num? v) =>
      v == null ? attrs.remove('header') : attrs['header'] = v;

  AlignType? get align => _getEnum(AlignType.values, 'align');
  set align(AlignType? v) =>
      v == null ? attrs.remove('align') : attrs['align'] = v.value;

  DirectionType? get direction => _getEnum(DirectionType.values, 'direction');
  set direction(DirectionType? v) =>
      v == null ? attrs.remove('direction') : attrs['direction'] = v.value;

  num? get indent => _getNumber('indent');
  set indent(num? v) =>
      v == null ? attrs.remove('indent') : attrs['indent'] = v;

  String? get table => attrs['table'];
  set table(String? v) =>
      v == null ? attrs.remove('table') : attrs['table'] = v;

  bool? get mentions => attrs['mentions'];
  set mentions(bool? v) =>
      v == null ? attrs.remove('mentions') : attrs['mentions'] = v;

  Mention? get mention {
    final mentionAttrs = attrs['mention'] as Map<String, String?>?;
    if (mentionAttrs == null) return null;
    return Mention()..attrs.addAll(mentionAttrs);
  }

  set mention(Mention? v) =>
      v == null ? attrs.remove('mention') : attrs['mention'] = v.attrs;

  String? get target => attrs['target'];
  set target(String? v) =>
      v == null ? attrs.remove('target') : attrs['target'] = v;

  String? get rel => attrs['rel'];
  set rel(String? v) => v == null ? attrs.remove('rel') : attrs['rel'] = v;

  // should this custom blot be rendered as block?
  bool? get renderAsBlock => attrs['renderAsBlock'];
  set renderAsBlock(bool? v) =>
      v == null ? attrs.remove('renderAsBlock') : attrs['renderAsBlock'] = v;

  dynamic operator [](String key) => attrs[key];
  void operator []=(String key, dynamic value) {
    attrs[key] = value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpAttributes &&
          runtimeType == other.runtimeType &&
          DeepCollectionEquality().equals(attrs, other.attrs);

  @override
  int get hashCode => attrs.hashCode;

  @override
  String toString() {
    return attrs.toString();
  }
}

typedef UrlSanitizerFn = String? Function(String url);

class OpAttributeSanitizerOptions {
  OpAttributeSanitizerOptions({
    this.urlSanitizer,
    this.allow8DigitHexColors = false,
  });

  UrlSanitizerFn? urlSanitizer;
  bool allow8DigitHexColors;
}

class OpAttributeSanitizer {
  static OpAttributes sanitize(
    OpAttributes dirtyAttrs,
    OpAttributeSanitizerOptions sanitizeOptions,
  ) {
    var cleanAttrs = OpAttributes();

    if (dirtyAttrs.attrs.isEmpty) {
      return cleanAttrs;
    }

    const booleanAttrs = [
      'bold',
      'italic',
      'underline',
      'strike',
      'code',
      'blockquote',
      'code-block',
      'renderAsBlock',
    ];

    const colorAttrs = ['background', 'color'];

    final font = dirtyAttrs.font;
    final size = dirtyAttrs.size;
    final link = dirtyAttrs.link;
    final script = dirtyAttrs.script;
    final list = dirtyAttrs.list;
    final header = dirtyAttrs.header;
    final align = dirtyAttrs.align;
    final direction = dirtyAttrs.direction;
    final indent = dirtyAttrs.indent;
    final mentions = dirtyAttrs.mentions;
    final mention = dirtyAttrs.mention;
    final width = dirtyAttrs.width;
    final target = dirtyAttrs.target;
    final rel = dirtyAttrs.rel;
    final codeBlock = dirtyAttrs['code-block'];

    const sanitizedAttrs = [
      ...booleanAttrs,
      ...colorAttrs,
      'font',
      'size',
      'link',
      'script',
      'list',
      'header',
      'align',
      'direction',
      'indent',
      'mentions',
      'mention',
      'width',
      'target',
      'rel',
      'code-block',
    ];

    for (var prop in booleanAttrs) {
      final v = dirtyAttrs[prop];
      if (isTruthy(v)) {
        cleanAttrs[prop] = true;
      }
    }

    for (var prop in colorAttrs) {
      final val = dirtyAttrs[prop];
      if (isTruthy(val)) {
        if (OpAttributeSanitizer.isValidColorLiteral(val.toString()) ||
            OpAttributeSanitizer.isValidRGBColor(val.toString())) {
          cleanAttrs[prop] = val;
        }
        if (OpAttributeSanitizer.isValidHexColor(val.toString())) {
          if (val.toString().length == 9) {
            if (sanitizeOptions.allow8DigitHexColors) {
              cleanAttrs[prop] =
                  '#${val.toString().substring(3)}${val.toString().substring(1, 3)}';
            }
          } else {
            cleanAttrs[prop] = val;
          }
        }
      }
    }

    if (isTruthy(font) &&
        OpAttributeSanitizer.isValidFontName(font.toString())) {
      cleanAttrs.font = font;
    }

    if (isTruthy(size) && OpAttributeSanitizer.isValidSize(size.toString())) {
      cleanAttrs.size = size;
    }

    if (isTruthy(width) &&
        OpAttributeSanitizer.isValidWidth(width.toString())) {
      cleanAttrs.width = width;
    }

    if (isTruthy(link)) {
      cleanAttrs.link =
          OpLinkSanitizer.sanitize(link.toString(), sanitizeOptions);
    }

    if (isTruthy(target) &&
        OpAttributeSanitizer.isValidTarget(target.toString())) {
      cleanAttrs.target = target;
    }

    if (isTruthy(rel) && OpAttributeSanitizer.isValidRel(rel.toString())) {
      cleanAttrs.rel = rel;
    }

    if (isTruthy(codeBlock)) {
      if (OpAttributeSanitizer.isValidLang(codeBlock)) {
        cleanAttrs['code-block'] = codeBlock;
      } else {
        cleanAttrs['code-block'] = isTruthy(codeBlock);
      }
    }

    if (script == ScriptType.subscript || ScriptType.superscript == script) {
      cleanAttrs.script = script;
    }

    if (list == ListType.bullet ||
        list == ListType.ordered ||
        list == ListType.checked ||
        list == ListType.unchecked) {
      cleanAttrs.list = list;
    }

    if (isTruthy(header)) {
      cleanAttrs.header = min(header!, 6);
    }

    const alignments = [
      AlignType.center,
      AlignType.right,
      AlignType.justify,
      AlignType.left
    ];
    if (alignments.contains(align)) {
      cleanAttrs.align = align;
    }

    if (direction == DirectionType.rtl) {
      cleanAttrs.direction = direction;
    }

    if (isTruthy(indent)) {
      cleanAttrs.indent = min(indent!, 30);
    }

    if (isTruthy(mentions) && isTruthy(mention)) {
      final sanitizedMention =
          MentionSanitizer.sanitize(mention!, sanitizeOptions);
      if (sanitizedMention.attrs.isNotEmpty) {
        cleanAttrs.mentions = mentions!;
        cleanAttrs.mention = sanitizedMention;
      }
    }

    // this is a custom attr, put it back
    cleanAttrs.attrs.addEntries(dirtyAttrs.attrs.entries
        .where((entry) => !sanitizedAttrs.contains(entry.key)));
    return cleanAttrs;
  }

  static bool isValidHexColor(String colorStr) {
    return RegExp(r'^#([0-9A-F]{6}|[0-9A-F]{3}|[0-9A-F]{8})$',
            caseSensitive: false)
        .hasMatch(colorStr);
  }

  static bool isValidColorLiteral(String colorStr) {
    return RegExp(r'^[a-z]{1,50}$', caseSensitive: false).hasMatch(colorStr);
  }

  static bool isValidRGBColor(String colorStr) {
    final re = RegExp(
        r'^rgb\(((0|25[0-5]|2[0-4]\d|1\d\d|0?\d?\d),\s*){2}(0|25[0-5]|2[0-4]\d|1\d\d|0?\d?\d)\)$',
        caseSensitive: false);
    return re.hasMatch(colorStr);
  }

  static bool isValidFontName(String fontName) {
    return RegExp(r'^[a-z\s0-9\-_ ]{1,30}$', caseSensitive: false)
        .hasMatch(fontName);
  }

  static bool isValidSize(String size) {
    return RegExp(r'^[a-z0-9\-.]{1,20}$', caseSensitive: false).hasMatch(size);
  }

  static bool isValidWidth(String width) {
    return RegExp(r'^[0-9]*(px|em|%)?$').hasMatch(width);
  }

  static bool isValidTarget(String target) {
    return RegExp(r'^[_a-zA-Z0-9\-]{1,50}$').hasMatch(target);
  }

  static bool isValidRel(String relStr) {
    return RegExp(r'^[a-zA-Z\s\-]{1,250}$', caseSensitive: false)
        .hasMatch(relStr);
  }

  static bool isValidLang(dynamic lang) {
    if (lang is bool) {
      return true;
    }
    return RegExp(r'^[a-zA-Z\s\-\\/+]{1,50}$', caseSensitive: false)
        .hasMatch(lang.toString());
  }
}
