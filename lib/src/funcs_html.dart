import 'dart:convert';

import 'package:html_unescape/html_unescape_small.dart';

class TagKeyValue {
  TagKeyValue({required this.key, this.value});

  String key;
  String? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagKeyValue &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value;

  @override
  int get hashCode => key.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'ITagKeyValue{key: $key, value: $value}';
  }
}

enum EncodeTarget {
  html,
  url,
}

String makeStartTag(String? tag, [List<TagKeyValue>? attrs]) {
  if (tag == null || tag.isEmpty) {
    return '';
  }

  var attrsStr = '';
  if (attrs != null) {
    var arrAttrs = <TagKeyValue>[...attrs];
    attrsStr = arrAttrs.map((attr) {
      return attr.key + (attr.value != null ? '="${attr.value}"' : '');
    }).join(' ');
  }

  var closing = '>';
  if (tag == 'img' || tag == 'br') {
    closing = '/>';
  }
  return attrsStr.isNotEmpty ? '<$tag $attrsStr$closing' : '<$tag$closing';
}

String makeEndTag([String tag = '']) {
  return tag.isNotEmpty ? '</$tag>' : '';
}

String decodeHtml(String str) {
  return HtmlUnescape().convert(str);
}

String encodeHtml(String str, [bool preventDoubleEncoding = true]) {
  if (preventDoubleEncoding) {
    str = decodeHtml(str);
  }

  return HtmlEscape(HtmlEscapeMode(
    escapeApos: true,
    escapeLtGt: true,
    escapeQuot: true,
    escapeSlash: true,
  )).convert(str);
}

String encodeLink(String str) {
  // TODO Decode first? Conditionally?
  return HtmlEscape(HtmlEscapeMode(
    escapeApos: true,
    escapeLtGt: true,
    escapeQuot: true,
    escapeSlash: false,
  )).convert(str);
}
