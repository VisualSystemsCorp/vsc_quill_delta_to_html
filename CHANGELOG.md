## 1.0.5

- @windows7lake Fixed: flutter_quill: 9.4.1 custom font size and convert to html, will loose font size #20.

## 1.0.4

- Updated example to use a simplified color picker.
  This color picker produces 6 digit hex colors, as supported by the Quill JS format.
- Merged PR #16 ("8-digit hexadecimal color support") to optionally allow 8 digit hex colors to be 
  processed. These hex colors are erroneously produced by `flutter_quill`. This feature is controlled by 
  `sanitizerOptions.allow8DigitHexColors` and defaults to `false`.

## 1.0.3

- Flutter 3.10.0/Dart 3 upgrade.

## 1.0.2

- If you give `flutter_quill` font sizes that are numeric strings, like `'8.0'`, it
  is providing the Delta `'size'` attribute as a `int` or `double` rather than a `String`.
  Changed `OpAttributes` to allow `num` types for the `'size'` and `'width'` attributes.

## 1.0.1+1

- Fix package.yaml description

## 1.0.1

- Fix analysis error.

## 1.0.0

- Initial public release.
