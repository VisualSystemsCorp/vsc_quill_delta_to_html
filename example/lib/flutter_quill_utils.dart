import 'package:example/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'simple_color_picker.dart';

const defaultSansSerifFamily = _genericSansSerifFamily;
const defaultSerifFamily = _genericSerifFamily;
const defaultMonospaceFamily = _genericMonospaceFamily;

const _genericSansSerifFamily = 'sans-serif';
const _genericSerifFamily = 'serif';
const _genericMonospaceFamily = 'monospace';

final fontFamilies = {
  'Sans Serif': defaultSansSerifFamily,
  'Serif': defaultSerifFamily,
  'Monospace': defaultMonospaceFamily,
  'Clear': 'Clear'
};

Widget createQuillUndoButton(QuillController controller) =>
    QuillToolbarHistoryButton(
      controller: controller,
      options: const QuillToolbarHistoryButtonOptions(isUndo: true),
    );

Widget createQuillRedoButton(QuillController controller) =>
    QuillToolbarHistoryButton(
      controller: controller,
      options: const QuillToolbarHistoryButtonOptions(isUndo: false),
    );

Widget createQuillFontFamilyButton(QuillController controller) =>
    QuillToolbarFontFamilyButton(
      options: QuillToolbarFontFamilyButtonOptions(
        rawItemsMap: fontFamilies,
      ),
      controller: controller,
      defaultDispalyText: 'Font',
    );

Widget createQuillFontSizeButton(QuillController controller) =>
    QuillToolbarFontSizeButton(
      controller: controller,
      options: QuillToolbarFontSizeButtonOptions(
        rawItemsMap: useCustomFontSizes
            ? const {
                'Small 8': '8',
                'Medium 24': '24',
                'Large 46': '46',
                'Clear': '0'
              }
            : null,
      ),
      defaultDisplayText: 'Size',
    );

Widget createQuillBoldButton(QuillController controller) =>
    QuillToolbarToggleStyleButton(
      attribute: Attribute.bold,
      controller: controller,
      options: const QuillToolbarToggleStyleButtonOptions(),
    );

Widget createQuillItalicButton(QuillController controller) =>
    QuillToolbarToggleStyleButton(
      attribute: Attribute.italic,
      controller: controller,
      options: const QuillToolbarToggleStyleButtonOptions(),
    );

Widget createQuillUnderlineButton(QuillController controller) =>
    QuillToolbarToggleStyleButton(
      attribute: Attribute.underline,
      controller: controller,
      options: const QuillToolbarToggleStyleButtonOptions(),
    );

Widget createQuillStrikeThroughButton(QuillController controller) =>
    QuillToolbarToggleStyleButton(
      attribute: Attribute.strikeThrough,
      controller: controller,
      options: const QuillToolbarToggleStyleButtonOptions(),
    );

Widget createQuillSimpleTextColorPickerButton(QuillController controller) =>
    QuillToolbarSimpleColorPickerButton(
      controller: controller,
      isBackground: false,
    );

Widget createQuillSimpleBackgroundColorPickerButton(
        QuillController controller) =>
    QuillToolbarSimpleColorPickerButton(
      controller: controller,
      isBackground: true,
    );

Widget createQuillClearFormatButton(QuillController controller) =>
    QuillToolbarClearFormatButton(
      controller: controller,
      options: const QuillToolbarClearFormatButtonOptions(),
    );

Widget createQuillLinkButton(QuillController controller) =>
    QuillToolbarLinkStyleButton(
      controller: controller,
      options: QuillToolbarLinkStyleButtonOptions(
        linkRegExp: RegExp(r'^(https?:.*|mailto:.*|tel:.*)$'),
      ),
    );

Widget createQuillSelectAlignmentButtons(
  QuillController controller, {
  bool showJustify = true,
}) =>
    QuillToolbarSelectAlignmentButton(
      controller: controller,
      options: const QuillToolbarSelectAlignmentButtonOptions(
        tooltips: QuillSelectAlignmentValues(
          leftAlignment: 'Left',
          centerAlignment: 'Center',
          rightAlignment: 'Right',
          justifyAlignment: 'Justify',
        ),
      ),
      showCenterAlignment: true,
      showRightAlignment: true,
      showJustifyAlignment: showJustify,
      showLeftAlignment: true,
    );

Widget createQuillSelectHeaderStyleButtons(QuillController controller) =>
    QuillToolbarSelectHeaderStyleButtons(
      controller: controller,
      options: const QuillToolbarSelectHeaderStyleButtonsOptions(),
    );

Widget createQuillNumberedListButton(QuillController controller) =>
    QuillToolbarToggleStyleButton(
      attribute: Attribute.ol,
      controller: controller,
      options: const QuillToolbarToggleStyleButtonOptions(),
    );

Widget createQuillBulletListButton(QuillController controller) =>
    QuillToolbarToggleStyleButton(
      attribute: Attribute.ul,
      controller: controller,
      options: const QuillToolbarToggleStyleButtonOptions(),
    );

Widget createQuillCheckedListButton(QuillController controller) =>
    QuillToolbarToggleStyleButton(
      attribute: Attribute.checked,
      controller: controller,
      options: const QuillToolbarToggleStyleButtonOptions(
        iconData: Icons.check_box,
        tooltip: 'Checklist',
      ),
    );

Widget createQuillCodeBlockButton(QuillController controller) =>
    QuillToolbarToggleStyleButton(
      attribute: Attribute.codeBlock,
      controller: controller,
      options: const QuillToolbarToggleStyleButtonOptions(),
    );

Widget createQuillBlockQuoteButton(QuillController controller) =>
    QuillToolbarToggleStyleButton(
      attribute: Attribute.blockQuote,
      controller: controller,
      options: const QuillToolbarToggleStyleButtonOptions(),
    );

Widget createQuillIncreaseIndentButton(QuillController controller) =>
    QuillToolbarIndentButton(
      controller: controller,
      isIncrease: true,
      options: const QuillToolbarIndentButtonOptions(),
    );

Widget createQuillDecreaseIndentButton(QuillController controller) =>
    QuillToolbarIndentButton(
      controller: controller,
      isIncrease: false,
      options: const QuillToolbarIndentButtonOptions(),
    );
