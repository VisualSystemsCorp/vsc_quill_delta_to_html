import 'package:collection/collection.dart';

///  Splits by new line character ("\n") by putting new line characters into the
///  array as well. Ex: "hello\n\nworld\n " => ["hello", "\n", "\n", "world", "\n", " "]
List<String> tokenizeWithNewLines(String str) {
  const newLine = '\n';

  if (str == newLine) {
    return [str];
  }

  var lines = str.split(newLine);

  if (lines.length == 1) {
    return lines;
  }

  var lastIndex = lines.length - 1;

  return lines.foldIndexed(<String>[], (int ind, List<String> pv, String line) {
    if (ind != lastIndex) {
      if (line != '') {
        pv.add(line);
        pv.add(newLine);
      } else {
        pv.add(newLine);
      }
    } else if (line != '') {
      pv.add(line);
    }
    return pv;
  });
}
