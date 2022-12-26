import 'package:collection/collection.dart';

import 'helpers/js.dart';
import 'insert_data.dart';
import 'op_attribute_sanitizer.dart';
import 'value_types.dart';

class DeltaInsertOp {
  DeltaInsertOp(Object /*InsertData | string*/ insertVal,
      [OpAttributes? attrs]) {
    if (insertVal is String) {
      insertVal = InsertDataQuill(DataType.text, insertVal);
    }

    insert = insertVal as InsertData;
    attributes = attrs ?? OpAttributes();
  }

  late final InsertData insert;
  late final OpAttributes attributes;

  static createNewLineOp() {
    return DeltaInsertOp(newLine);
  }

  isContainerBlock() {
    return (isBlockquote() ||
        isList() ||
        isTable() ||
        isCodeBlock() ||
        isHeader() ||
        isBlockAttribute() ||
        isCustomTextBlock());
  }

  bool isBlockAttribute() {
    return attributes.align != null ||
        attributes.direction != null ||
        attributes.indent != null;
  }

  bool isBlockquote() {
    return attributes.blockquote ?? false;
  }

  bool isHeader() {
    return attributes.header != null;
  }

  bool isTable() {
    return attributes.table != null;
  }

  bool isSameHeaderAs(DeltaInsertOp op) {
    return op.attributes.header == attributes.header && isHeader();
  }

  // adi: alignment direction indentation
  bool hasSameAdiAs(DeltaInsertOp op) {
    return (attributes.align == op.attributes.align &&
        attributes.direction == op.attributes.direction &&
        attributes.indent == op.attributes.indent);
  }

  bool hasSameIndentationAs(DeltaInsertOp op) {
    return attributes.indent == op.attributes.indent;
  }

  bool hasSameAttr(DeltaInsertOp op) {
    return DeepCollectionEquality()
        .equals(attributes.attrs, op.attributes.attrs);
  }

  bool hasHigherIndentThan(DeltaInsertOp op) {
    return (attributes.indent ?? 0) > (op.attributes.indent ?? 0);
  }

  bool isInline() {
    return !(isContainerBlock() || isVideo() || isCustomEmbedBlock());
  }

  bool isCodeBlock() {
    return isTruthy(attributes['code-block']);
  }

  bool hasSameLangAs(DeltaInsertOp op) {
    return attributes['code-block'] == op.attributes['code-block'];
  }

  bool isJustNewline() {
    return insert.value == newLine;
  }

  bool isList() {
    return (isOrderedList() ||
        isBulletList() ||
        isCheckedList() ||
        isUncheckedList());
  }

  bool isOrderedList() {
    return attributes.list == ListType.ordered;
  }

  bool isBulletList() {
    return attributes.list == ListType.bullet;
  }

  bool isCheckedList() {
    return attributes.list == ListType.checked;
  }

  bool isUncheckedList() {
    return attributes.list == ListType.unchecked;
  }

  bool isACheckList() {
    return attributes.list == ListType.unchecked ||
        attributes.list == ListType.checked;
  }

  bool isSameListAs(DeltaInsertOp op) {
    return op.attributes.list != null &&
        (attributes.list == op.attributes.list ||
            (op.isACheckList() && isACheckList()));
  }

  bool isSameTableRowAs(DeltaInsertOp op) {
    return (op.isTable() &&
        isTable() &&
        attributes.table == op.attributes.table);
  }

  bool isText() {
    return insert.type == DataType.text;
  }

  bool isImage() {
    return insert.type == DataType.image;
  }

  bool isFormula() {
    return insert.type == DataType.formula;
  }

  bool isVideo() {
    return insert.type == DataType.video;
  }

  bool isLink() {
    return isText() && isTruthy(attributes.link);
  }

  bool isCustomEmbed() {
    return insert is InsertDataCustom;
  }

  bool isCustomEmbedBlock() {
    return isCustomEmbed() && isTruthy(attributes.renderAsBlock);
  }

  bool isCustomTextBlock() {
    return isText() && isTruthy(attributes.renderAsBlock);
  }

  bool isMentions() {
    return isText() && isTruthy(attributes.mentions);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeltaInsertOp &&
          runtimeType == other.runtimeType &&
          insert == other.insert &&
          attributes == other.attributes;

  @override
  int get hashCode => insert.hashCode ^ attributes.hashCode;

  @override
  String toString() {
    return 'DeltaInsertOp{insert: $insert, attributes: $attributes}';
  }
}
