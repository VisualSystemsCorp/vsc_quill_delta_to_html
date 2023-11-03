import 'dart:convert';
import 'dart:io';

import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

void main(List<String> args) {
  final json = File(args[0]).readAsStringSync();
  final converter = QuillDeltaToHtmlConverter(
    List.castFrom(jsonDecode(json)),
    ConverterOptions.forEmail(),
  );

  print(converter.convert());
}
