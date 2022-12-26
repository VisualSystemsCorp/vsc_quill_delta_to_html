const emailMetaTestOps = [
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
      'code': true,
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
  {'insert': '.\n\n'}
];

const emailMetaTestExpectedHtml = r'''
<h1>Heading 1 with HTML escapes &lt; &gt; &amp;</h1><h2>Heading 2</h2><h3>Heading 3</h3><p><br/>Images aligned left, center, and right:<br/><br/><img style="max-width: 100%;object-fit: contain" src="https://upload.wikimedia.org/wikipedia/commons/e/e0/Tc_logo_magyar_logo.png"/><br/></p><p style="text-align:center"><img style="max-width: 100%;object-fit: contain" src="https://upload.wikimedia.org/wikipedia/commons/e/e0/Tc_logo_magyar_logo.png"/></p><p style="text-align:center"><br/></p><p style="text-align:right"><img style="max-width: 100%;object-fit: contain" src="https://upload.wikimedia.org/wikipedia/commons/e/e0/Tc_logo_magyar_logo.png"/></p><p><br/>Image less than the email width (800px):<br/><img style="max-width: 100%;object-fit: contain" src="https://upload.wikimedia.org/wikipedia/commons/7/77/Avatar_cat.png"/><br/><br/>Image larger than email width is constrained to width:<br/><img style="max-width: 100%;object-fit: contain" src="https://images.pexels.com/photos/1054666/pexels-photo-1054666.jpeg"/><br/><br/>Inline text style features: <strong>bold</strong>, <em>italic</em>, <u>underline</u>, <s>strikethrough</s>, <code>code</code>, <span style="color:#e91e63">text color red</span>, <span style="background-color:#ffeb3b">text background color yellow</span>, normal, <strong><em><s><u><code>all at styles once</code></u></s></em></strong>.<br/><br/>Fonts: <span style="font-family: Georgia, Times New Roman, serif">Serif</span>, <span style="font-family:sans-serif">Sans-Serif</span>, <span style="font-family: Monaco, Courier New, monospace">Monospace</span>.<br/>Font sizes: <span style="font-size: 0.75em">Small</span>, <span style="font-size: 1.5em">Large</span>, <span style="font-size: 2.5em">Huge</span>.<br/>Code block:</p><pre>    final classes = getCssClasses();
    final tagAttrs = customAttr;
    if (classes.isNotEmpty) {
      tagAttrs.add(makeAttr(&#39;class&#39;, classes.join(&#39; &#39;)));
    }

    final styles = getCssStyles();
    if (styles.isNotEmpty) {
      tagAttrs.add(makeAttr(&#39;style&#39;, styles.join(&#39;;&#39;)));
    }</pre><p><br/>Left-aligned paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.<br/></p><p style="text-align:center">Centered paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.</p><p><br/></p><p style="text-align:right">Right aligned paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.</p><p><br/></p><p style="text-align:justify">Justified paragraph: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.</p><p><br/></p><ol><li>Numbered list</li><li>two<ol><li>nested 1st level<ol><li>nested 2nd level</li></ol></li></ol></li><li>three</li></ol><ul><li>Bullet list<ul><li>Nested 1st<ul><li>Nested 2nd</li></ul></li></ul></li><li>two</li><li>three</li></ul><ul><li style="list-style-type:'\2611';padding-left: 0.5em;" data-checked="true">Checked list (checked)</li><li style="list-style-type:'\2610';padding-left: 0.5em;" data-checked="false">unchecked</li></ul><p><br/></p><blockquote style="border-left: 4px solid #ccc;padding-left: 16px">One line blockquote.</blockquote><p><br/></p><blockquote style="border-left: 4px solid #ccc;padding-left: 16px">Paragraph blockquote: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eu turpis egestas pretium aenean pharetra.</blockquote><p><br/>No indent.</p><p style="padding-left:3.0em">Indent level 1.</p><p style="padding-left:6.0em">Indent level 2.</p><p style="padding-left:9.0em">Indent level 3.</p><p style="padding-left:6.0em">Back to level 2.</p><p style="padding-left:3.0em">Back to level 1.</p><p>Back to no indent.<br/><br/>And here is a <a href="https://vscorp.com" target="_blank">link</a>.<br/></p>''';
