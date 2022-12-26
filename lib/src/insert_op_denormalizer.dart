import 'package:vsc_quill_delta_to_html/src/helpers/string.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';

/// Denormalization is splitting a text insert operation that has new lines into multiple
/// ops where each op is either a new line or a text containing no new lines.
///
/// Why? It makes things easier when picking op that needs to be inside a block when
/// rendering to html.
///
/// Example:
/// ```
///  {insert: 'hello\n\nhow are you?\n', attributes: {bold: true}}
/// ```
///
/// Denormalized:
/// ```
///  [
///      {insert: 'hello', attributes: {bold: true}},
///      {insert: '\n', attributes: {bold: true}},
///      {insert: '\n', attributes: {bold: true}},
///      {insert: 'how are you?', attributes: {bold: true}},
///      {insert: '\n', attributes: {bold: true}}
///  ]
///  ```
///
/// This is designed to work on a raw map from decoded delta JSON.
class InsertOpDenormalizer {
  static List<Map<String, dynamic>> denormalize(Map<String, dynamic> op) {
    final insertValue = op['insert'];
    if (insertValue is Map || insertValue == newLine) {
      return [op];
    }

    final newlinedArray = tokenizeWithNewLines(insertValue.toString());

    if (newlinedArray.length == 1) {
      return [op];
    }

    // Copy op in to keep its attributes, but replace the insert value with a newline.
    final nlObj = {
      ...op,
      ...{'insert': newLine}
    };

    return newlinedArray.map((line) {
      if (line == newLine) {
        return nlObj;
      }
      return {
        ...op,
        ...{'insert': line},
      };
    }).toList();
  }
}
