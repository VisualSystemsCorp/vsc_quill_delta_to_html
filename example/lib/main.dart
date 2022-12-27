import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:url_launcher/url_launcher.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

void main() {
  runApp(const MyApp());
}

const title = 'vsc_quill_delta_to_html Demo';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String html = 'html';
  final quillController = QuillController(
      document: Document.fromJson(sampleOps),
      selection: const TextSelection.collapsed(offset: 0));
  final focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    quillController.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          QuillToolbar.basic(
            controller: quillController,
            showSearchButton: false,
            embedButtons: [
              (_, toolbarIconSize, iconTheme, __) => _ImageToolbarButton(
                    quillController: quillController,
                    focusNode: focusNode,
                    toolbarIconSize: toolbarIconSize,
                    iconTheme: iconTheme,
                  ),
            ],
            showAlignmentButtons: true,
            afterButtonPressed: focusNode.requestFocus,
          ),
          const Divider(height: 8, thickness: 1),
          SizedBox(
            height: 400,
            child: _Editor(
              quillController: quillController,
              focusNode: focusNode,
            ),
          ),
          const Divider(height: 8, thickness: 1),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child: _DeltaViewer(
                    quillController: quillController,
                  ),
                ),
                const VerticalDivider(
                  width: 8,
                  thickness: 2,
                ),
                Expanded(
                  flex: 3,
                  child: _HtmlViewer(
                    quillController: quillController,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaViewer extends StatefulWidget {
  const _DeltaViewer({
    Key? key,
    required this.quillController,
  }) : super(key: key);

  final QuillController quillController;

  @override
  State<_DeltaViewer> createState() => _DeltaViewerState();
}

class _DeltaViewerState extends State<_DeltaViewer> {
  String _delta = '';

  @override
  void initState() {
    super.initState();
    widget.quillController.addListener(_onDocumentUpdated);
    _onDocumentUpdated();
  }

  void _onDocumentUpdated() {
    final deltaJson = widget.quillController.document.toDelta().toJson();
    const encoder = JsonEncoder.withIndent('  ');
    _delta = encoder.convert(deltaJson);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Delta',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 8, thickness: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(child: SelectableText(_delta)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HtmlViewer extends StatefulWidget {
  const _HtmlViewer({
    Key? key,
    required this.quillController,
  }) : super(key: key);

  final QuillController quillController;

  @override
  State<_HtmlViewer> createState() => _HtmlViewerState();
}

class _HtmlViewerState extends State<_HtmlViewer> {
  String _html = '';
  bool _previewMode = true;
  bool _isPreviewable = false;

  @override
  void initState() {
    super.initState();
    widget.quillController.addListener(_onDocumentUpdated);
    _onDocumentUpdated();
    _isPreviewable = kIsWeb || Platform.isAndroid || Platform.isIOS;
    _previewMode = _isPreviewable;
  }

  void _onDocumentUpdated() {
    try {
      _onDocumentUpdatedOrThrow();
    } catch (e, st) {
      print('Error converting: $e\n$st');
      rethrow;
    }
  }

  void _onDocumentUpdatedOrThrow() {
    final deltaJson = widget.quillController.document.toDelta().toJson();
    final converter = QuillDeltaToHtmlConverter(
      List.castFrom(deltaJson),
      ConverterOptions.forEmail(),
    );

    _html = converter.convert();

    // Force HTML to layout in a maximum width of 800px.
    _html = '<div style="max-width: 800px;">\n$_html\n</div>';

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'HTML',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 32),
              const Text('Preview:'),
              Switch(
                value: _previewMode,
                onChanged: (value) => setState(() {
                  _previewMode = value;
                }),
              ),
            ],
          ),
          const Divider(height: 8, thickness: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(builder: (context, constraints) {
                Widget viewer;
                if (_previewMode) {
                  if (_isPreviewable) {
                    viewer = WebViewX(
                      key: ValueKey(_html),
                      initialContent:
                          '<html><body style="font-family: sans-serif;">$_html</body></html>',
                      initialSourceType: SourceType.html,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    );
                  } else {
                    viewer = const Text(
                        'No HTML preview is available for this platform. Try running for web.');
                  }
                } else {
                  viewer = SelectableText(_html);
                }

                return SingleChildScrollView(
                  child: viewer,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Editor extends StatefulWidget {
  const _Editor({
    Key? key,
    required this.quillController,
    required this.focusNode,
  }) : super(key: key);

  final QuillController quillController;
  final FocusNode focusNode;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: QuillEditor(
        controller: widget.quillController,
        focusNode: widget.focusNode,
        scrollController: scrollController,
        scrollable: true,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        onLaunchUrl: _launchUrl,
        autoFocus: false,
        enableSelectionToolbar: true,
        expands: false,
        maxContentWidth: 800,
        embedBuilders: [
          _ImageEmbedBuilder(800),
        ],
        readOnly: false,
      ),
    );
  }

  void _launchUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    final canLaunch = await canLaunchUrl(uri);
    if (canLaunch) {
      await launchUrl(uri);
    }
  }
}

class _ImageEmbedBuilder extends EmbedBuilder {
  _ImageEmbedBuilder(this.maxContentWidth);

  final double? maxContentWidth;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, QuillController controller, Embed node,
      bool readOnly) {
    final url = node.value.data as String;
    final image = Image.network(
      url,
      fit: BoxFit.scaleDown,
    );

    final alignment = node.parent?.style.attributes['align'];
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxContentWidth ?? double.infinity),
      child: Align(
        alignment: alignment?.value == 'right'
            ? Alignment.topRight
            : alignment?.value == 'center'
                ? Alignment.topCenter
                : Alignment.topLeft,
        child: image,
      ),
    );
  }
}

class _ImageToolbarButton extends StatelessWidget {
  const _ImageToolbarButton({
    Key? key,
    required this.quillController,
    required this.focusNode,
    required this.toolbarIconSize,
    required this.iconTheme,
  }) : super(key: key);

  final QuillController quillController;
  final FocusNode focusNode;
  final double toolbarIconSize;
  final QuillIconTheme? iconTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;

    return QuillIconButton(
      icon: Icon(Icons.image, size: toolbarIconSize, color: iconColor),
      highlightElevation: 0,
      hoverElevation: 0,
      size: toolbarIconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      afterPressed: () => focusNode.requestFocus(),
      onPressed: () => _onPressed(context),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    final textController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Paste an Image Link (URL)'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Image link (URL)'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Insert'),
              onPressed: () async {
                Navigator.pop(context);
                final url = textController.text.trim();
                if (url.isEmpty) return;
                _insertImageIntoDocument(url);
              },
            ),
          ],
        );
      },
    );

    textController.dispose();
  }

  void _insertImageIntoDocument(String url) {
    final obj = BlockEmbed.image(url);
    // extentOffset can be < baseOffset if selection was done right-to-left.
    var index = quillController.selection.baseOffset;
    var extent = quillController.selection.extentOffset;
    if (extent < index) {
      final t = index;
      index = extent;
      extent = t;
    }

    final length = extent - index;
    // Move the cursor to the beginning of the line right after the embed.
    final newSelection = quillController.selection.copyWith(
      baseOffset: index + 1,
      extentOffset: index + 1,
    );

    quillController.replaceText(index, length, obj, newSelection);
  }
}

const sampleOps = [
  {'insert': 'Heading 1 with HTML escapes < > &'},
  {
    'insert': '\n',
    'attributes': {'header': 1}
  },
  {'insert': 'Heading 2'},
  {
    'insert': '\n',
    'attributes': {'header': 2}
  },
  {'insert': 'Heading 3'},
  {
    'insert': '\n',
    'attributes': {'header': 3}
  },
  {'insert': '\nImages aligned left, center, and right:\n\n'},
  {
    'insert': {
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/e/e0/Tc_logo_magyar_logo.png'
    }
  },
  {'insert': '\n\n'},
  {
    'insert': {
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/e/e0/Tc_logo_magyar_logo.png'
    }
  },
  {
    'insert': '\n\n',
    'attributes': {'align': 'center'}
  },
  {
    'insert': {
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/e/e0/Tc_logo_magyar_logo.png'
    }
  },
  {
    'insert': '\n',
    'attributes': {'align': 'right'}
  },
  {'insert': '\nImage less than the email width (800px):\n'},
  {
    'insert': {
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/7/77/Avatar_cat.png'
    }
  },
  {'insert': '\n\nImage larger than email width is constrained to width:\n'},
  {
    'insert': {
      'image':
          'https://images.pexels.com/photos/1054666/pexels-photo-1054666.jpeg'
    }
  },
  {'insert': '\n\nInline text style features: '},
  {
    'insert': 'bold',
    'attributes': {'bold': true}
  },
  {'insert': ', '},
  {
    'insert': 'italic',
    'attributes': {'italic': true}
  },
  {'insert': ', '},
  {
    'insert': 'underline',
    'attributes': {'underline': true}
  },
  {'insert': ', '},
  {
    'insert': 'strikethrough',
    'attributes': {'strike': true}
  },
  {'insert': ', '},
  {
    'insert': 'code',
    'attributes': {'code': true}
  },
  {'insert': ', '},
  {
    'insert': 'text color red',
    'attributes': {'color': '#e91e63'}
  },
  {'insert': ', '},
  {
    'insert': 'text background color yellow',
    'attributes': {'background': '#ffeb3b'}
  },
  {'insert': ', normal, '},
  {
    'insert': 'all at styles once',
    'attributes': {
      'bold': true,
      'color': '#f44336',
      'italic': true,
      'strike': true,
      'underline': true,
      'background': '#ffeb3b'
    }
  },
  {'insert': '.\n\nFonts: '},
  {
    'insert': 'Serif',
    'attributes': {'font': 'serif'}
  },
  {'insert': ', '},
  {
    'insert': 'Sans-Serif',
    'attributes': {'font': 'sans-serif'}
  },
  {'insert': ', '},
  {
    'insert': 'Monospace',
    'attributes': {'font': 'monospace'}
  },
  {'insert': '.\nFont sizes: '},
  {
    'insert': 'Small',
    'attributes': {'size': 'small'}
  },
  {'insert': ', '},
  {
    'insert': 'Large',
    'attributes': {'size': 'large'}
  },
  {'insert': ', '},
  {
    'insert': 'Huge',
    'attributes': {'size': 'huge'}
  },
  {'insert': '.\nCode block:\n    final classes = getCssClasses();'},
  {
    'insert': '\n',
    'attributes': {'code-block': true}
  },
  {'insert': '    final tagAttrs = customAttr;'},
  {
    'insert': '\n',
    'attributes': {'code-block': true}
  },
  {'insert': '    if (classes.isNotEmpty) {'},
  {
    'insert': '\n',
    'attributes': {'code-block': true}
  },
  {'insert': "      tagAttrs.add(makeAttr('class', classes.join(' ')));"},
  {
    'insert': '\n',
    'attributes': {'code-block': true}
  },
  {'insert': '    }'},
  {
    'insert': '\n\n',
    'attributes': {'code-block': true}
  },
  {'insert': '    final styles = getCssStyles();'},
  {
    'insert': '\n',
    'attributes': {'code-block': true}
  },
  {'insert': '    if (styles.isNotEmpty) {'},
  {
    'insert': '\n',
    'attributes': {'code-block': true}
  },
  {'insert': "      tagAttrs.add(makeAttr('style', styles.join(';')));"},
  {
    'insert': '\n',
    'attributes': {'code-block': true}
  },
  {'insert': '    }'},
  {
    'insert': '\n',
    'attributes': {'code-block': true}
  },
  {
    'insert':
        '\nLeft-aligned paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.\n\nCentered paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.'
  },
  {
    'insert': '\n',
    'attributes': {'align': 'center'}
  },
  {
    'insert':
        '\nRight aligned paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.'
  },
  {
    'insert': '\n',
    'attributes': {'align': 'right'}
  },
  {
    'insert':
        '\nJustified paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.'
  },
  {
    'insert': '\n',
    'attributes': {'align': 'justify'}
  },
  {'insert': '\nNumbered list'},
  {
    'insert': '\n',
    'attributes': {'list': 'ordered'}
  },
  {'insert': 'two'},
  {
    'insert': '\n',
    'attributes': {'list': 'ordered'}
  },
  {'insert': 'nested 1st level'},
  {
    'insert': '\n',
    'attributes': {'list': 'ordered', 'indent': 1}
  },
  {'insert': 'nested 2nd level'},
  {
    'insert': '\n',
    'attributes': {'list': 'ordered', 'indent': 2}
  },
  {'insert': 'three'},
  {
    'insert': '\n',
    'attributes': {'list': 'ordered'}
  },
  {'insert': 'Bullet list'},
  {
    'insert': '\n',
    'attributes': {'list': 'bullet'}
  },
  {'insert': 'Nested 1st'},
  {
    'insert': '\n',
    'attributes': {'list': 'bullet', 'indent': 1}
  },
  {'insert': 'Nested 2nd'},
  {
    'insert': '\n',
    'attributes': {'list': 'bullet', 'indent': 2}
  },
  {'insert': 'two'},
  {
    'insert': '\n',
    'attributes': {'list': 'bullet'}
  },
  {'insert': 'three'},
  {
    'insert': '\n',
    'attributes': {'list': 'bullet'}
  },
  {'insert': 'Checked list (checked)'},
  {
    'insert': '\n',
    'attributes': {'list': 'checked'}
  },
  {'insert': 'unchecked'},
  {
    'insert': '\n',
    'attributes': {'list': 'unchecked'}
  },
  {'insert': '\nOne line blockquote.'},
  {
    'insert': '\n',
    'attributes': {'blockquote': true}
  },
  {
    'insert':
        '\nParagraph blockquote: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.'
  },
  {
    'insert': '\n',
    'attributes': {'blockquote': true}
  },
  {'insert': '\nNo indent.\nIndent level 1.'},
  {
    'insert': '\n',
    'attributes': {'indent': 1}
  },
  {'insert': 'Indent level 2.'},
  {
    'insert': '\n',
    'attributes': {'indent': 2}
  },
  {'insert': 'Indent level 3.'},
  {
    'insert': '\n',
    'attributes': {'indent': 3}
  },
  {'insert': 'Back to level 2.'},
  {
    'insert': '\n',
    'attributes': {'indent': 2}
  },
  {'insert': 'Back to level 1.'},
  {
    'insert': '\n',
    'attributes': {'indent': 1}
  },
  {'insert': 'Back to no indent.\n\nAnd here is a '},
  {
    'insert': 'link',
    'attributes': {'link': 'https://vscorp.com'}
  },
  {'insert': '. (Ctrl+Click this link)\n\n'}
];
