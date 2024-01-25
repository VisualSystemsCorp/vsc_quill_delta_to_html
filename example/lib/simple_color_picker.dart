/*
 From https://github.com/yomio/faabul_color_picker/blob/main/lib/faabul_color_picker.dart
 as of 2023-12-01. Modified to not accept alpha channel for hex colors.

MIT License

Copyright (c) 2023 Yomio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

String _colorToHex(Color color) {
  // Skip alpha channel
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

Color? _colorFromHex(String? hex) {
  if (hex == null) return null;
  final value = int.tryParse(hex.substring(1), radix: 16);
  if (value == null) return null;
  return Color(value);
}

/// Shows a dialog with the color picker
///
/// Returns the selected color or `null` if the dialog was dismissed.
/// You can also listen to the [onChanged] callback to get notified when the color changes.
Future<Color?> showSimpleColorPickerDialog({
  /// Current context
  required BuildContext context,

  /// Colors to display.
  /// Defaults to [FaabulColorShades.materialColors] if not specified.
  List<FaabulColorShades>? colors,

  /// The currently selected color
  Color? selected,

  /// The callback to execute when a color is selected
  void Function(Color? color)? onChanged,

  /// Title of the dialog
  Widget? title,

  /// Content of the done button. Defaults to `Text('Done')` if not specified.
  Widget? doneButtonContent,

  /// When `true`, unselect button will be added as the last to [colors] and `null` will be passed to [onSelected]
  /// when the button is pressed.
  bool allowUnselectButton = false,

  /// Duration of the animations
  Duration animationsDuration = const Duration(milliseconds: 200),

  /// Curve used for the animations
  Curve animationsCurve = Curves.easeInOut,

  /// Label text for the color input
  String inputLabelText = 'Hex Color',

  /// Hint text for the color input
  String inputHintText = 'E.g. #8D3B72',

  /// Error text for the color input
  String inputErrorText = 'Invalid color',

  /// Tooltip for the unselect button
  String? unselectButtonTooltip,

  /// Icon to display when the color is selected
  ///
  /// Defaults to `Icon(Icons.check, size: colorSampleSize * 0.8)` if not specified.
  Widget? selectedIcon,

  /// Icon to display when the color shade is selected
  ///
  /// Defaults to `Icon(Icons.expand_more, size: colorSampleSize * 0.8)` if not specified.
  Widget? shadeSelectedIcon,

  /// Icon to display when the color is unselected
  ///
  /// Defaults to `Icon(Icons.format_color_reset_outlined, size: colorSampleSize * 0.8)` if not specified.
  Widget? unselectButtonIcon,

  /// Size of the color samples
  double colorSampleSize = 32,

  /// Constraints for the dialog
  BoxConstraints constraints = const BoxConstraints(maxWidth: 600),

  /// If `true`, tooltips will be shown over the color samples
  ///
  /// Currently the names of colors are only in English
  bool showColorTooltips = false,
}) async {
  Color? result = selected;

  await showDialog(
      context: context,
      builder: (context) {
        return WebViewAware(
          child: AlertDialog(
            title: title,
            content: ConstrainedBox(
              constraints: constraints,
              child: FaabulColorPicker(
                colors: colors ?? FaabulColorShades.materialColors(),
                selected: selected,
                onSelected: (Color? color) => {
                  onChanged?.call(color),
                  result = color,
                },
                allowUnselectButton: allowUnselectButton,
                animationsDuration: animationsDuration,
                animationsCurve: animationsCurve,
                inputLabelText: inputLabelText,
                inputHintText: inputHintText,
                inputErrorText: inputErrorText,
                unselectButtonTooltip: unselectButtonTooltip,
                selectedIcon: selectedIcon,
                shadeSelectedIcon: shadeSelectedIcon,
                unselectButtonIcon: unselectButtonIcon,
                colorSampleSize: colorSampleSize,
                showColorTooltips: showColorTooltips,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: doneButtonContent ?? const Text('Done'),
                onPressed: () => Navigator.maybeOf(context)?.pop(),
              ),
            ],
          ),
        );
      });
  return result;
}

/// Widget that builds the color picker
///
/// You may want to use [showColorPickerDialog] instead of using this widget directly.
/// Supply the list of [colors] to be shown in the picker, the [selected] color and [onSelected] callback.
///
/// See also: [showColorPickerDialog]
class FaabulColorPicker extends StatefulWidget {
  const FaabulColorPicker({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
    this.allowUnselectButton = false,
    this.animationsDuration = const Duration(milliseconds: 200),
    this.animationsCurve = Curves.easeInOut,
    this.inputLabelText = 'Hex Color',
    this.inputHintText = 'E.g. #8D3B72',
    this.inputErrorText = 'Invalid color',
    this.unselectButtonTooltip,
    this.selectedIcon,
    this.shadeSelectedIcon,
    this.unselectButtonIcon,
    this.colorSampleSize = 32,
    this.showColorTooltips = false,
  });

  /// The currently selected color
  final Color? selected;

  /// The colors to display
  final List<FaabulColorShades> colors;

  /// The callback to execute when a color is selected
  final Function(Color? color) onSelected;

  /// When `true`, unselect button will be added as the last to [colors] and `null` will be passed to [onSelected]
  /// when the button is pressed.
  final bool allowUnselectButton;

  /// Duration of the animations
  final Duration animationsDuration;

  /// Curve used for the animations
  final Curve animationsCurve;

  /// Label text for the color input
  final String inputLabelText;

  /// Hint text for the color input
  final String inputHintText;

  /// Error text for the color input
  final String inputErrorText;

  /// Tooltip for the unselect button (if specified)
  final String? unselectButtonTooltip;

  /// Icon to display when the color is selected
  ///
  /// Defaults to `Icon(Icons.check, size: colorSampleSize * 0.8)` if not specified.
  final Widget? selectedIcon;

  /// Icon to display when the color shade is selected
  ///
  /// Defaults to `Icon(Icons.expand_more, size: colorSampleSize * 0.8)` if not specified.
  final Widget? shadeSelectedIcon;

  /// Icon to display when the color is unselected
  ///
  /// Defaults to `Icon(Icons.format_color_reset_outlined, size: colorSampleSize * 0.8)` if not specified.
  final Widget? unselectButtonIcon;

  /// Size of the color samples
  final double colorSampleSize;

  /// If `true`, tooltips will be shown over the color samples
  ///
  /// Currently the names of colors are only in English
  final bool showColorTooltips;

  @override
  State<FaabulColorPicker> createState() => _FaabulColorPickerState();
}

class _FaabulColorPickerState extends State<FaabulColorPicker> {
  Color? _selected;
  late final _colorInputController = TextEditingController();
  bool? _colorInputValid;

  @override
  void initState() {
    super.initState();
    _updateState(widget.selected);
    _colorInputController.addListener(_colorInputListener);
  }

  @override
  dispose() {
    _colorInputController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FaabulColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final FaabulColorShades? selectedColorShade = widget.colors
        .where((colorShade) => colorShade.contains(_selected))
        .firstOrNull;
    final selectedIcon = widget.selectedIcon ??
        Icon(Icons.check, size: widget.colorSampleSize * 0.8);
    final shadeSelectedIcon = widget.shadeSelectedIcon ??
        Icon(Icons.expand_more, size: widget.colorSampleSize * 0.8);
    final unselectButtonIcon = widget.unselectButtonIcon ??
        Icon(Icons.format_color_reset_outlined,
            size: widget.colorSampleSize * 0.8);

    final showShades = selectedColorShade != null &&
        selectedColorShade.shades != null &&
        selectedColorShade.shades!.isNotEmpty;
    final isUnselected = _selected == null;

    return SingleChildScrollView(
      child: AnimatedSize(
        duration: widget.animationsDuration,
        curve: widget.animationsCurve,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                for (final colorShade in widget.colors)
                  FaabulColorButton(
                    color: colorShade.color,
                    tooltip: widget.showColorTooltips ? colorShade.name : null,
                    onSelected: _handleSelected,
                    isSelected: selectedColorShade != null &&
                        _Utilities.colorEquals(
                            colorShade.color, selectedColorShade.color),
                    size: widget.colorSampleSize,
                    selectedIcon: selectedColorShade == null ||
                            _Utilities.colorEquals(colorShade.color, _selected!)
                        ? selectedIcon
                        : shadeSelectedIcon,
                  ),
                if (widget.allowUnselectButton)
                  FaabulColorButton(
                    color: null,
                    tooltip: widget.unselectButtonTooltip,
                    onSelected: _handleSelected,
                    isSelected: isUnselected,
                    size: widget.colorSampleSize,
                    icon: unselectButtonIcon,
                    selectedIcon: selectedIcon,
                  ),
              ],
            ),
            if (showShades) ...[
              const Divider(height: 16),
              Wrap(
                children: [
                  for (final color in selectedColorShade.shades!)
                    FaabulColorButton(
                      color: color,
                      onSelected: _handleSelected,
                      isSelected: _selected != null &&
                          _Utilities.colorEquals(color, _selected!),
                      selectedIcon: selectedIcon,
                    ),
                ],
              ),
            ],
            if (!isUnselected) ...[
              const Divider(height: 16),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedContainer(
                      width: widget.colorSampleSize,
                      height: widget.colorSampleSize,
                      duration: widget.animationsDuration,
                      curve: widget.animationsCurve,
                      decoration: BoxDecoration(
                          color: _selected,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 16),
                  _buildInput(context),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateState(Color? color) {
    setState(() => _selected = color);
    if (color == null) {
      _colorInputController.text = '';
      return;
    }

    _colorInputController.text = _colorToHex(color);
  }

  void _handleSelected(Color? color) {
    if (color == _selected) return;
    _updateState(color);
    widget.onSelected(color);
  }

  Widget _buildInput(BuildContext context) {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: _colorInputController,
        decoration: InputDecoration(
          hintText: widget.inputHintText,
          labelText: widget.inputLabelText,
          errorText: _colorInputValid == false ? widget.inputErrorText : null,
        ),
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        autocorrect: false,
      ),
    );
  }

  void _colorInputListener() {
    final color = _colorInputController.text.toColorShortMaybeNull(true);
    if (color == null) {
      setState(() => _colorInputValid = false);
    } else {
      setState(() {
        _colorInputValid = true;
        _selected = color;
      });
      widget.onSelected(color);
    }
  }
}

/// Widget that shows the color as a button
class FaabulColorButton extends StatelessWidget {
  const FaabulColorButton({
    super.key,
    required this.color,
    required this.onSelected,
    this.isSelected = false,
    this.selectedIcon,
    this.tooltip,
    this.icon,
    this.size = 32,
  });

  /// Color to display
  final Color? color;

  /// Tooltip for the color preview
  final String? tooltip;

  /// Icon over the color
  final Widget? icon;

  /// Called when the color is changed
  final Function(Color? color) onSelected;

  /// Whether the color is selected
  final bool isSelected;

  /// Icon to display when the color is selected
  final Widget? selectedIcon;

  /// Size of the color sample
  final double size;

  @override
  Widget build(BuildContext context) {
    final focusColor = (color ?? Theme.of(context).colorScheme.outlineVariant)
        .withOpacity(0.3);
    final highLightColor =
        (color ?? Theme.of(context).colorScheme.outlineVariant)
            .withOpacity(0.7);

    return IconButton(
      hoverColor: focusColor,
      focusColor: focusColor,
      highlightColor: highLightColor,
      icon: FaabulColorSample(color: color, size: size, icon: icon),
      selectedIcon:
          FaabulColorSample(color: color, size: size, icon: selectedIcon),
      onPressed: () => onSelected(color),
      tooltip: tooltip,
      isSelected: isSelected,
    );
  }
}

/// Widget that shows a color sample
class FaabulColorSample extends StatelessWidget {
  const FaabulColorSample({
    super.key,
    required this.color,
    this.size = 20,
    this.icon,
  });

  /// Color to show in the sample
  final Color? color;

  /// Size of the sample
  final double size;

  /// Icon inside the sample
  ///
  /// If specified, [IconTheme] is set for convenience with either [Colors.white] or [Colors.black]
  /// depending on the luminance of [color]. This can be overridden by setting the icon's color explicitly
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(size * 0.5))),
      child: icon != null
          ? IconTheme(
              data: _iconThemeOver(
                  color ?? Theme.of(context).colorScheme.surface),
              child: icon!)
          : null,
    );
  }

  IconThemeData _iconThemeOver(Color color) {
    return IconThemeData(
        color: color.computeLuminance() > 0.3 ? Colors.black : Colors.white);
  }
}

/// Utility functions
abstract class _Utilities {
  static colorEquals(Color a, Color b) => a.value == b.value;
}

/// Holds a color and its shades
class FaabulColorShades {
  const FaabulColorShades({required this.color, this.shades, this.name});

  /// Material colors and shades
  static List<FaabulColorShades> materialColors({
    /// By default, shades of white are excluded because Material shades of white are realized on the alpha channel
    bool includeShadesOfWhite = false,

    /// By default, shades of black are excluded because Material shades of black are realized on the alpha channel
    bool includeShadesOfBlack = false,
  }) {
    return [
      FaabulColorShades(
        color: Colors.white,
        name: 'White',
        shades: includeShadesOfWhite
            ? [
                Colors.white10,
                Colors.white12,
                Colors.white24,
                Colors.white30,
                Colors.white38,
                Colors.white54,
                Colors.white60,
                Colors.white70,
                Colors.white,
              ]
            : null,
      ),
      FaabulColorShades(
        color: Colors.grey.shade500,
        name: 'Grey',
        shades: [
          Colors.grey.shade50,
          Colors.grey.shade100,
          Colors.grey.shade200,
          Colors.grey.shade300,
          Colors.grey.shade400,
          Colors.grey.shade500,
          Colors.grey.shade600,
          Colors.grey.shade700,
          Colors.grey.shade800,
          Colors.grey.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.black,
        name: 'Black',
        shades: includeShadesOfBlack
            ? [
                Colors.black12,
                Colors.black26,
                Colors.black38,
                Colors.black45,
                Colors.black54,
                Colors.black87,
                Colors.black,
              ]
            : null,
      ),
      FaabulColorShades(
        color: Colors.brown.shade500,
        name: 'Brown',
        shades: [
          Colors.brown.shade50,
          Colors.brown.shade100,
          Colors.brown.shade200,
          Colors.brown.shade300,
          Colors.brown.shade400,
          Colors.brown.shade500,
          Colors.brown.shade600,
          Colors.brown.shade700,
          Colors.brown.shade800,
          Colors.brown.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.purple.shade500,
        name: 'Purple',
        shades: [
          Colors.purple.shade50,
          Colors.purple.shade100,
          Colors.purple.shade200,
          Colors.purple.shade300,
          Colors.purple.shade400,
          Colors.purple.shade500,
          Colors.purple.shade600,
          Colors.purple.shade700,
          Colors.purple.shade800,
          Colors.purple.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.deepPurple.shade500,
        name: 'Deep Purple',
        shades: [
          Colors.deepPurple.shade50,
          Colors.deepPurple.shade100,
          Colors.deepPurple.shade200,
          Colors.deepPurple.shade300,
          Colors.deepPurple.shade400,
          Colors.deepPurple.shade500,
          Colors.deepPurple.shade600,
          Colors.deepPurple.shade700,
          Colors.deepPurple.shade800,
          Colors.deepPurple.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.indigo.shade500,
        name: 'Indigo',
        shades: [
          Colors.indigo.shade50,
          Colors.indigo.shade100,
          Colors.indigo.shade200,
          Colors.indigo.shade300,
          Colors.indigo.shade400,
          Colors.indigo.shade500,
          Colors.indigo.shade600,
          Colors.indigo.shade700,
          Colors.indigo.shade800,
          Colors.indigo.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.blue.shade500,
        name: 'Blue',
        shades: [
          Colors.blue.shade50,
          Colors.blue.shade100,
          Colors.blue.shade200,
          Colors.blue.shade300,
          Colors.blue.shade400,
          Colors.blue.shade500,
          Colors.blue.shade600,
          Colors.blue.shade700,
          Colors.blue.shade800,
          Colors.blue.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.lightBlue.shade500,
        name: 'Light Blue',
        shades: [
          Colors.lightBlue.shade50,
          Colors.lightBlue.shade100,
          Colors.lightBlue.shade200,
          Colors.lightBlue.shade300,
          Colors.lightBlue.shade400,
          Colors.lightBlue.shade500,
          Colors.lightBlue.shade600,
          Colors.lightBlue.shade700,
          Colors.lightBlue.shade800,
          Colors.lightBlue.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.cyan.shade500,
        name: 'Cyan',
        shades: [
          Colors.cyan.shade50,
          Colors.cyan.shade100,
          Colors.cyan.shade200,
          Colors.cyan.shade300,
          Colors.cyan.shade400,
          Colors.cyan.shade500,
          Colors.cyan.shade600,
          Colors.cyan.shade700,
          Colors.cyan.shade800,
          Colors.cyan.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.blueGrey.shade500,
        name: 'Blue Grey',
        shades: [
          Colors.blueGrey.shade50,
          Colors.blueGrey.shade100,
          Colors.blueGrey.shade200,
          Colors.blueGrey.shade300,
          Colors.blueGrey.shade400,
          Colors.blueGrey.shade500,
          Colors.blueGrey.shade600,
          Colors.blueGrey.shade700,
          Colors.blueGrey.shade800,
          Colors.blueGrey.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.teal.shade500,
        name: 'Teal',
        shades: [
          Colors.teal.shade50,
          Colors.teal.shade100,
          Colors.teal.shade200,
          Colors.teal.shade300,
          Colors.teal.shade400,
          Colors.teal.shade500,
          Colors.teal.shade600,
          Colors.teal.shade700,
          Colors.teal.shade800,
          Colors.teal.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.green.shade500,
        name: 'Green',
        shades: [
          Colors.green.shade50,
          Colors.green.shade100,
          Colors.green.shade200,
          Colors.green.shade300,
          Colors.green.shade400,
          Colors.green.shade500,
          Colors.green.shade600,
          Colors.green.shade700,
          Colors.green.shade800,
          Colors.green.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.lightGreen.shade500,
        name: 'Light Green',
        shades: [
          Colors.lightGreen.shade50,
          Colors.lightGreen.shade100,
          Colors.lightGreen.shade200,
          Colors.lightGreen.shade300,
          Colors.lightGreen.shade400,
          Colors.lightGreen.shade500,
          Colors.lightGreen.shade600,
          Colors.lightGreen.shade700,
          Colors.lightGreen.shade800,
          Colors.lightGreen.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.lime.shade500,
        name: 'Lime',
        shades: [
          Colors.lime.shade50,
          Colors.lime.shade100,
          Colors.lime.shade200,
          Colors.lime.shade300,
          Colors.lime.shade400,
          Colors.lime.shade500,
          Colors.lime.shade600,
          Colors.lime.shade700,
          Colors.lime.shade800,
          Colors.lime.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.yellow.shade500,
        name: 'Yellow',
        shades: [
          Colors.yellow.shade50,
          Colors.yellow.shade100,
          Colors.yellow.shade200,
          Colors.yellow.shade300,
          Colors.yellow.shade400,
          Colors.yellow.shade500,
          Colors.yellow.shade600,
          Colors.yellow.shade700,
          Colors.yellow.shade800,
          Colors.yellow.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.amber.shade500,
        name: 'Amber',
        shades: [
          Colors.amber.shade50,
          Colors.amber.shade100,
          Colors.amber.shade200,
          Colors.amber.shade300,
          Colors.amber.shade400,
          Colors.amber.shade500,
          Colors.amber.shade600,
          Colors.amber.shade700,
          Colors.amber.shade800,
          Colors.amber.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.orange.shade500,
        name: 'Orange',
        shades: [
          Colors.orange.shade50,
          Colors.orange.shade100,
          Colors.orange.shade200,
          Colors.orange.shade300,
          Colors.orange.shade400,
          Colors.orange.shade500,
          Colors.orange.shade600,
          Colors.orange.shade700,
          Colors.orange.shade800,
          Colors.orange.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.deepOrange.shade500,
        name: 'Deep Orange',
        shades: [
          Colors.deepOrange.shade50,
          Colors.deepOrange.shade100,
          Colors.deepOrange.shade200,
          Colors.deepOrange.shade300,
          Colors.deepOrange.shade400,
          Colors.deepOrange.shade500,
          Colors.deepOrange.shade600,
          Colors.deepOrange.shade700,
          Colors.deepOrange.shade800,
          Colors.deepOrange.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.red.shade500,
        name: 'Red',
        shades: [
          Colors.red.shade50,
          Colors.red.shade100,
          Colors.red.shade200,
          Colors.red.shade300,
          Colors.red.shade400,
          Colors.red.shade500,
          Colors.red.shade600,
          Colors.red.shade700,
          Colors.red.shade800,
          Colors.red.shade900,
        ],
      ),
      FaabulColorShades(
        color: Colors.pink.shade500,
        name: 'Pink',
        shades: [
          Colors.pink.shade50,
          Colors.pink.shade100,
          Colors.pink.shade200,
          Colors.pink.shade300,
          Colors.pink.shade400,
          Colors.pink.shade500,
          Colors.pink.shade600,
          Colors.pink.shade700,
          Colors.pink.shade800,
          Colors.pink.shade900,
        ],
      ),
    ];
  }

  /// Name of the color
  final String? name;

  /// The color
  final Color color;

  /// Available shades of the color
  final List<Color>? shades;

  bool contains(Color? color) {
    if (color == null) return false;
    if (_Utilities.colorEquals(color, this.color)) return true;
    for (final shade in shades ?? []) {
      if (_Utilities.colorEquals(color, shade)) return true;
    }
    return false;
  }
}

class QuillToolbarSimpleColorPickerButton extends StatelessWidget {
  const QuillToolbarSimpleColorPickerButton({
    Key? key,
    required this.isBackground,
    required this.controller,
  }) : super(key: key);

  final bool isBackground;
  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return QuillToolbarColorButton(
      controller: controller,
      isBackground: isBackground,
      options: QuillToolbarColorButtonOptions(
        customOnPressedCallback: (_, __) => _showColorPicker(context),
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    final selectionStyle = controller.getSelectionStyle();
    final initialColor = isBackground
        ? _colorFromHex(selectionStyle.attributes['background']?.value)
        : _colorFromHex(selectionStyle.attributes['color']?.value);

    final selectedColor = MutableWrapper<Color?>(initialColor);
    await showSimpleColorPickerDialog(
      context: context,
      title: Text('Select a ${isBackground ? 'background' : 'text'} color'),
      selected: initialColor,
      allowUnselectButton: true,
      showColorTooltips: true,
      onChanged: (color) => selectedColor.value = color,
    );

    final hex =
        selectedColor.value == null ? null : _colorToHex(selectedColor.value!);
    controller.formatSelection(
      isBackground ? BackgroundAttribute(hex) : ColorAttribute(hex),
    );
  }
}

class MutableWrapper<T> {
  MutableWrapper(this.value);
  T value;
}
