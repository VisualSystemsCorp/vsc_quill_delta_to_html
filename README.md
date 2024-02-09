# VSC Quill Delta to HTML Converter

Converts [Quill's Delta](https://quilljs.com/docs/delta/) format to HTML (insert ops only) with properly nested lists.
It has full support for Quill operations - including images, videos, formulas, tables, and mentions. Conversion
can be performed in vanilla Dart (i.e., server-side or CLI) or in Flutter.

This is a complete port of the popular [quill-delta-to-html](https://www.npmjs.com/package/quill-delta-to-html)
Typescript/Javascript package to Dart.

This converter can convert to HTML for a number of purposes, not the least of which is for generating
HTML-based emails. It makes a great pairing with [Flutter Quill](https://pub.dev/packages/flutter_quill).

You can try a live demo of the conversion by running the example Flutter app.

## Quickstart

To get started, add this package to your `pubspec.yaml` dependencies.

Usage
```dart
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

void main() {
  final deltaOps = [
    {'insert': 'Hello\n'},
    {
      'insert': 'This is colorful',
      'attributes': {'color': '#f00'}
    }
  ];

  final converter = QuillDeltaToHtmlConverter(
    ops,
    ConverterOptions.forEmail(),
  );

  final html = converter.convert();
  print(html);
}
```

## Configuration 

`QuillDeltaToHtmlConverter` accepts a few configuration (`ConverterOptions`, `OpConverterOptions`, 
and `OpAttributeSanitizerOptions`) options as shown below:

| Option                                  | Type                                                  | Default        | Description                                                                                                                                                                                                                                                                                                                                                                                                                     
|-----------------------------------------|-------------------------------------------------------|----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `converterOptions.paragraphTag`         | string                                                | 'p'            | Custom tag to wrap inline html elements                                                                                                                                                                                                                                                                                                                                                                                         |
| `converterOptions.encodeHtml`           | boolean                                               | true           | If true, `<, >, /, ', ", &` characters in content will be encoded.                                                                                                                                                                                                                                                                                                                                                              |
| `converterOptions.classPrefix`          | string                                                | 'ql'           | A css class name to prefix class generating styles such as `size`, `font`, etc.                                                                                                                                                                                                                                                                                                                                                 |
| `converterOptions.inlineStylesFlag`     | boolean                                               | false          | If true, use inline styles instead of classes.                                                                                                                                                                                                                                                                                                                                                                                  |
| `converterOptions.inlineStyles`         | InlineStyles                                          | null           | If non-null, use inline styles instead of classes. See Rendering Inline Styles section below for usage.                                                                                                                                                                                                                                                                                                                         |
| `multiLineBlockquote`                   | boolean                                               | true           | Instead of rendering multiple `blockquote` elements for quotes that are consecutive and have same styles(`align`, `indent`, and `direction`), it renders them into only one                                                                                                                                                                                                                                                     |
| `multiLineHeader`                       | boolean                                               | true           | Same deal as `multiLineBlockquote` for headers                                                                                                                                                                                                                                                                                                                                                                                  |
| `multiLineCodeblock`                    | boolean                                               | true           | Same deal as `multiLineBlockquote` for code-blocks                                                                                                                                                                                                                                                                                                                                                                              |
| `multiLineParagraph`                    | boolean                                               | true           | Set to false to generate a new paragraph tag after each enter press (new line)                                                                                                                                                                                                                                                                                                                                                  |
| `multiLineCustomBlock`                  | boolean                                               | true           | Same deal as `multiLineBlockquote` for custom blocks.                                                                                                                                                                                                                                                                                                                                                                           |
| `bulletListTag`                         | string                                                | 'ul'           | Tag for unordered bullet lists.                                                                                                                                                                                                                                                                                                                                                                                                 |
| `orderedListTag`                        | string                                                | 'ol'           | Tag for ordered/numbered lists.                                                                                                                                                                                                                                                                                                                                                                                                 |
| `converterOptions.linkRel`              | string                                                | none generated | Specifies a value to put on the `rel` attr on all links. This can be overridden by an individual link op by specifying the `rel` attribute in the respective op's attributes                                                                                                                                                                                                                                                    |
| `converterOptions.linkTarget`           | string                                                | '_blank'       | Specifies target for all links; use `''` (empty string) to not generate `target` attribute. This can be overridden by an individual link op by specifiying the `target` with a value in the respective op's attributes.                                                                                                                                                                                                         |
| `converterOptions.allowBackgroundClasses` | boolean                                               | false          | If true, css classes will be added for background attr                                                                                                                                                                                                                                                                                                                                                                          |
| `sanitizerOptions.urlSanitizer`         | `String? Function(String url)`                                 | null           | A function that is called once per url in the ops (image, video, link) for you to do custom sanitization. If your function returns a string, it is assumed that you sanitized the url and no further sanitization will be done by the library; when anything other than a string is returned (e.g. undefined), it is assumed that no sanitization has been done and the library's own function will be used to clean up the url |                                                                                                                                                                                                              
| `sanitizerOptions.allow8DigitHexColors` | boolean                                               | false          | If true, hex colors in `#AARRGGBB` format are allowed in the ops                                                                                                                                                                                                                                                                                                                                                                     |
| `converterOptions.customTag`            | `String? Function(String format, DeltaInsertOp op)`   | null           | Callback allows to provide custom html tag for some format                                                                                                                                                                                                                                                                                                                                                                      |
| `converterOptions.customTagAttributes`  | `Map<String, String>? Function(DeltaInsertOp op)` | null           | Allows custom html tag attributes for the given op                                                                                                                                                                                                                                                                                                                                                                              | 
| `converterOptions.customCssClasses`     | `List<String>? Function(DeltaInsertOp op)`           | null           | Allows custom CSS classes for the given op                                                                                                                                                                                                                                                                                                                                                                                      | 
| `converterOptions.customCssStyles`      | `List<String>? Function(DeltaInsertOp op)`              | null           | Allows custom CSS styles attributes for the given op                                                                                                                                                                                                                                                                                                                                                                            | 


## Rendering Quill Formats

You can customize the rendering of Quill formats by registering render callbacks before calling the `convert()` method.

There is a `beforeRender` and an `afterRender` callback. They are called multiple times before and after rendering each group. A group is one of:

- continuous sets of inline elements
- a video element
- list elements
- block elements (header, code-block, blockquote, align, indent, and direction)

`beforeRender` event is called with raw operation objects for you to generate and return your own html. If you return `null`, the 
system will return its own generated html.

`afterRender` event is called with generated html for you to inspect, maybe make some changes, and return your modified or original html.

```dart
converter.beforeRender = (GroupType groupType, TDataGroup data) {
    // ... generate your own html 
    // return your html
};

converter.afterRender = (GroupType groupType, String htmlString) {
    // modify if you wish
    // return the html
};

html = converter.convert();
```

Following shows the parameter formats for `beforeRender` event:



|groupType|data|
|---|---|
|`video`|`VideoItem`|
|`block`|`BlockGroup`|
|`list`| `ListGroup`|
|`inline-group`|`InlineGroup`|

## Rendering Inline Styles

If you are rendering to HTML that you intend to include in an email, using classes and a style sheet are not recommended, 
as [not all browsers support style sheets](https://www.campaignmonitor.com/css/style-element/style-in-head/). 
`vsc_quill_delta_to_html` supports rendering inline styles instead.  The easiest way to enable this is to pass the option `inlineStylesFlag: true`.

You can customize styles by passing an object to `inlineStyles` instead:

```dart
inlineStyles: InlineStyles({
  'font': InlineStyleType(
      fn: (value, _) => defaultInlineFonts[value] ?? 'font-family:$value'),
  'size': InlineStyleType(map: {
    'small': 'font-size: 0.75em',
    'large': 'font-size: 1.5em',
    'huge': 'font-size: 2.5em',
  }),
  'indent': InlineStyleType(fn: (value, op) {
    final indentSize = (double.tryParse(value) ?? double.nan) * 3;
    final side = op.attributes['direction'] == 'rtl' ? 'right' : 'left';
    return 'padding-$side:${indentSize}em';
  }),
  'direction': InlineStyleType(fn: (value, op) {
    if (value == 'rtl') {
      final textAlign =
      isTruthy(op.attributes['align']) ? '' : '; text-align:inherit';
      return ('direction:rtl$textAlign');
    } else {
      return null;
    }
  }),
  'list': InlineStyleType(map: {
    'checked': "list-style-type:'\\2611';padding-left: 0.5em;",
    'unchecked': "list-style-type:'\\2610';padding-left: 0.5em;",
  }),
});
```

Keys to this object are the names of attributes from Quill.  The values are either a simple lookup table (like in the `list` example above) used 
to map values to styles, or a `fn(value, op)` which returns a style string.

## Rendering Custom Blot Formats

You need to tell system how to render your custom blot by registering a renderer callback function 
to `renderCustomWith` method before calling the `convert()` method.

If you would like your custom blot to be rendered as a block (not inside another block or grouped 
as part of inlines), then add `renderAsBlock: true` to its attributes.

Example:
```dart 
final ops = [
    {insert: {'my-blot': {id: 2, text: 'xyz'}}, attributes: {renderAsBlock: true|false}}
];

let converter = new QuillDeltaToHtmlConverter(ops);

// customOp is your custom blot op
// contextOp is the block op that wraps this op, if any. 
// If, for example, your custom blot is located inside a list item,
// then contextOp would provide that op. 
converter.renderCustomWith = (DeltaInsertOp customOp, DeltaInsertOp? contextOp) {
    if (customOp.insert.type == 'my-blot') {
        return '<span>Some custom blot</span>';
    } else {
        return 'Unmanaged custom blot!';
    }
});

html = converter.convert();
```

`customOp object` will have the following format:

```javascript
{
    insert: {
        type: string //whatever you specified as key for insert, in above example: 'my-blot'
        value: any // value for the custom blot  
    }, 
    attributes: {
        // ... any attributes custom blot may have
    }
}
```

## Advanced Custom Rendering Using Grouped Ops

If you want to do the full rendering yourself, you can do so
by getting the processed & grouped ops.

```dart
final groupedOps = converter.getGroupedOps();
```

Each element in groupedOps array will be an instance of the
following types: `InlineGroup`, `VideoItem`, `BlockGroup`, `ListGroup`, `ListItem`, `BlotBlock`.

`BlotBlock` represents custom blots with `renderAsBlock:true` property pair in its attributes
