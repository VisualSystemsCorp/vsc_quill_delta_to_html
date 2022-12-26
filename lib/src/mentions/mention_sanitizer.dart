import 'package:collection/collection.dart';
import 'package:vsc_quill_delta_to_html/src/helpers/js.dart';
import 'package:vsc_quill_delta_to_html/src/op_attribute_sanitizer.dart';
import 'package:vsc_quill_delta_to_html/src/op_link_sanitizer.dart';

class Mention {
  Mention();

  final Map<String, String?> attrs = {};

  String? get name => attrs['name'];
  set name(String? v) => attrs['name'] = v;

  String? get target => attrs['target'];
  set target(String? v) => attrs['target'] = v;

  String? get slug => attrs['slug'];
  set slug(String? v) => attrs['slug'] = v;

  String? get class_ => attrs['class'];
  set class_(String? v) => attrs['class'] = v;

  String? get avatar => attrs['avatar'];
  set avatar(String? v) => attrs['avatar'] = v;

  String? get id => attrs['id'];
  set id(String? v) => attrs['id'] = v;

  String? get endPoint => attrs['end-point'];
  set endPoint(String? v) => attrs['end-point'] = v;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpAttributes &&
          runtimeType == other.runtimeType &&
          MapEquality().equals(attrs, other.attrs);

  @override
  int get hashCode => attrs.hashCode;

  @override
  String toString() {
    return attrs.toString();
  }
}

class MentionSanitizer {
  static Mention sanitize(
      Mention dirtyObj, OpAttributeSanitizerOptions sanitizeOptions) {
    final cleanObj = Mention();

    if (isTruthy(dirtyObj.class_) &&
        MentionSanitizer.isValidClass(dirtyObj.class_!)) {
      cleanObj.class_ = dirtyObj.class_;
    }

    if (isTruthy(dirtyObj.id) && MentionSanitizer.isValidId(dirtyObj.id!)) {
      cleanObj.id = dirtyObj.id;
    }

    if (MentionSanitizer.isValidTarget(dirtyObj.target.toString())) {
      cleanObj.target = dirtyObj.target;
    }

    if (isTruthy(dirtyObj.avatar)) {
      cleanObj.avatar =
          OpLinkSanitizer.sanitize(dirtyObj.avatar.toString(), sanitizeOptions);
    }

    if (isTruthy(dirtyObj.endPoint)) {
      cleanObj.endPoint = OpLinkSanitizer.sanitize(
          dirtyObj.endPoint.toString(), sanitizeOptions);
    }

    if (isTruthy(dirtyObj.slug)) {
      cleanObj.slug = dirtyObj.slug.toString();
    }

    return cleanObj;
  }

  static bool isValidClass(String classAttr) {
    return RegExp(r'^[a-zA-Z0-9_\-]{1,500}$', caseSensitive: false)
        .hasMatch(classAttr);
  }

  static bool isValidId(String idAttr) {
    return RegExp(r'^[a-zA-Z0-9_\-:.]{1,500}$', caseSensitive: false)
        .hasMatch(idAttr);
  }

  static bool isValidTarget(String target) {
    return const ['_self', '_blank', '_parent', '_top'].contains(target);
  }
}
