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
