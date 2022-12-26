const newLine = '\n';

abstract class EnumValueType {
  String get value;
}

enum ListType implements EnumValueType {
  ordered('ordered'),
  bullet('bullet'),
  checked('checked'),
  unchecked('unchecked');

  const ListType(this.value);

  @override
  final String value;
}

enum ScriptType implements EnumValueType {
  subscript('sub'),
  superscript('super');

  const ScriptType(this.value);

  @override
  final String value;
}

enum DirectionType implements EnumValueType {
  rtl('rtl'),
  ltr('ltr');

  const DirectionType(this.value);

  @override
  final String value;
}

enum AlignType implements EnumValueType {
  left('left'),
  center('center'),
  right('right'),
  justify('justify');

  const AlignType(this.value);

  @override
  final String value;
}

enum DataType implements EnumValueType {
  image('image'),
  video('video'),
  formula('formula'),
  text('text');

  const DataType(this.value);

  @override
  final String value;
}

enum GroupType implements EnumValueType {
  block('block'),
  inlineGroup('inline-group'),
  list('list'),
  video('video'),
  table('table');

  const GroupType(this.value);

  @override
  final String value;
}
