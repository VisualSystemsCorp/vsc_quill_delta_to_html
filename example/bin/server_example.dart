import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// An example which produces HTML suitable for use in an email.
void main() {
  final converter = QuillDeltaToHtmlConverter(
    ops,
    ConverterOptions.forEmail(),
  );

  var html = converter.convert();

  // Force HTML to layout in a maximum width of 800px.
  html = '<div style="max-width: 800px;">\n$html\n</div>';

  print(html);
}

const ops = [
  {'insert': 'Server-side example'},
  {
    'insert': '\n',
    'attributes': {'header': 1}
  },
  {'insert': '\n'},
  {
    'insert': {
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/e/e0/Tc_logo_magyar_logo.png'
    }
  },
  {
    'insert': '\n',
    'attributes': {'align': 'center'}
  },
  {
    'insert':
        '\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.'
  },
  {
    'insert': '\n',
    'attributes': {'align': 'justify'}
  },
  {'insert': '\n'}
];
