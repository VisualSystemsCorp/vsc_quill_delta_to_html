// import 'package:vsc_quill_delta_to_html/src/value_types.dart';

import 'value_types.dart';

abstract class InsertData {
  Object get type;
  dynamic get value;
}

class InsertDataQuill extends InsertData {
  InsertDataQuill(this.type, this.value);

  @override
  final DataType type;
  @override
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsertDataQuill &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;

  @override
  String toString() {
    return '$runtimeType:{type: $type, value: $value}';
  }
}

class InsertDataCustom extends InsertData {
  InsertDataCustom(this.type, this.value);

  @override
  final String type;
  @override
  final dynamic value;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsertDataCustom &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;

  @override
  String toString() {
    return '$runtimeType:{type: $type, value: $value}';
  }
}
