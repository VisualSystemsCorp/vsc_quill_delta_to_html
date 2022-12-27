import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';
import 'package:vsc_quill_delta_to_html/src/funcs_html.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/group_types.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/grouper.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/list_nester.dart';
import 'package:vsc_quill_delta_to_html/src/grouper/table_grouper.dart';
import 'package:vsc_quill_delta_to_html/src/value_types.dart';

import 'insert_ops_converter.dart';
import 'op_attribute_sanitizer.dart';
import 'op_to_html_converter.dart';

class ConverterOptions {
  ConverterOptions({
    this.orderedListTag,
    this.bulletListTag,
    this.multiLineBlockquote,
    this.multiLineHeader,
    this.multiLineCodeblock,
    this.multiLineParagraph,
    this.multiLineCustomBlock,
    OpAttributeSanitizerOptions? sanitizerOptions,
    OpConverterOptions? converterOptions,
  }) {
    this.sanitizerOptions = sanitizerOptions ?? OpAttributeSanitizerOptions();
    this.converterOptions = converterOptions ?? OpConverterOptions();
    _initCommon();
  }

  ConverterOptions.forEmail() {
    sanitizerOptions = OpAttributeSanitizerOptions();
    converterOptions = OpConverterOptions(
        inlineStylesFlag: true,
        customCssStyles: (op) {
          if (op.isImage()) {
            // Fit images within restricted parent width.
            return ['max-width: 100%', 'object-fit: contain'];
          }
          if (op.isBlockquote()) {
            return ['border-left: 4px solid #ccc', 'padding-left: 16px'];
          }
          return null;
        });
    _initCommon();
  }

  void _initCommon() {
    orderedListTag ??= 'ol';
    bulletListTag ??= 'ul';
    multiLineBlockquote ??= true;
    multiLineHeader ??= true;
    multiLineCodeblock ??= true;
    multiLineParagraph ??= true;
    multiLineCustomBlock ??= true;
  }

  String? orderedListTag;
  String? bulletListTag;
  bool? multiLineBlockquote;
  bool? multiLineHeader;
  bool? multiLineCodeblock;
  bool? multiLineParagraph;
  bool? multiLineCustomBlock;
  late OpAttributeSanitizerOptions sanitizerOptions;
  late OpConverterOptions converterOptions;
}

const brTag = '<br/>';

/// Converts [Quill's Delta](https://quilljs.com/docs/delta/) format to HTML (insert ops only) with properly nested lists.
/// It has full support for Quill operations - including images, videos, formulas, tables, and mentions. Conversion
/// can be performed in vanilla Dart (i.e., server-side or CLI) or in Flutter.
///
/// This is a complete port of the popular [quill-delta-to-html](https://www.npmjs.com/package/quill-delta-to-html)
/// Typescript/Javascript package to Dart.
///
/// This converter can convert to HTML for a number of purposes, not the least of which is for generating
/// HTML-based emails. It makes a great pairing with [Flutter Quill](https://pub.dev/packages/flutter_quill).
///
/// Documentation can be found [here](https://github.com/VisualSystemsCorp/vsc_quill_delta_to_html).
class QuillDeltaToHtmlConverter {
  QuillDeltaToHtmlConverter(this._rawDeltaOps, [ConverterOptions? options]) {
    _options = options ?? ConverterOptions();
    _converterOptions = _options.converterOptions;
    _converterOptions.linkTarget ??= '_blank';
  }

  late ConverterOptions _options;
  final List<Map<String, dynamic>> _rawDeltaOps;
  late OpConverterOptions _converterOptions;

  // render callbacks
  String? Function(GroupType groupType, TDataGroup data)? _beforeRenderCallback;
  set beforeRender(
          String? Function(GroupType groupType, TDataGroup data)? callback) =>
      _beforeRenderCallback = callback;

  String? Function(GroupType groupType, String htmlString)?
      _afterRenderCallback;
  set afterRender(
          String? Function(GroupType groupType, String htmlString)? callback) =>
      _afterRenderCallback = callback;

  String Function(DeltaInsertOp customOp, DeltaInsertOp? contextOp)?
      _renderCustomWithCallback;
  set renderCustomWith(
          String Function(DeltaInsertOp customOp, DeltaInsertOp? contextOp)?
              callback) =>
      _renderCustomWithCallback = callback;

  @visibleForTesting
  String getListTag(DeltaInsertOp op) {
    if (op.isOrderedList()) return _options.orderedListTag.toString();
    if (op.isBulletList()) return _options.bulletListTag.toString();
    if (op.isCheckedList()) return _options.bulletListTag.toString();
    if (op.isUncheckedList()) return _options.bulletListTag.toString();
    return '';
  }

  List<TDataGroup> getGroupedOps() {
    var deltaOps =
        InsertOpsConverter.convert(_rawDeltaOps, _options.sanitizerOptions);

    var pairedOps = Grouper.pairOpsWithTheirBlock(deltaOps);

    var groupedSameStyleBlocks = Grouper.groupConsecutiveSameStyleBlocks(
      pairedOps,
      blockquotes: _options.multiLineBlockquote ?? false,
      header: _options.multiLineHeader ?? false,
      codeBlocks: _options.multiLineCodeblock ?? false,
      customBlocks: _options.multiLineCustomBlock ?? false,
    );

    var groupedOps =
        Grouper.reduceConsecutiveSameStyleBlocksToOne(groupedSameStyleBlocks);

    groupedOps = TableGrouper().group(groupedOps);
    return ListNester().nest(groupedOps);
  }

  /// Convert the Delta ops provided at construction to an HTML string.
  String convert() {
    final groups = getGroupedOps();
    return groups.map((group) {
      if (group is ListGroup) {
        return _renderWithCallbacks(
            GroupType.list, group, () => _renderList(group));
      }
      if (group is TableGroup) {
        return _renderWithCallbacks(
            GroupType.table, group, () => _renderTable(group));
      }
      if (group is BlockGroup) {
        return _renderWithCallbacks(
            GroupType.block, group, () => renderBlock(group.op, group.ops));
      }
      if (group is BlotBlock) {
        return _renderCustom(group.op, null);
      }
      if (group is VideoItem) {
        return _renderWithCallbacks(GroupType.video, group, () {
          var converter = OpToHtmlConverter(group.op, _converterOptions);
          return converter.getHtml();
        });
      }

      // InlineGroup
      return _renderWithCallbacks(GroupType.inlineGroup, group,
          () => renderInlines((group as InlineGroup).ops, true));
    }).join('');
  }

  _renderWithCallbacks(
    GroupType groupType,
    TDataGroup group,
    String Function() myRenderFn,
  ) {
    var html = _beforeRenderCallback?.call(groupType, group) ?? '';

    if (html.isEmpty) {
      html = myRenderFn();
    }

    html = _afterRenderCallback?.call(groupType, html) ?? html;

    return html;
  }

  String _renderList(ListGroup list) {
    final firstItem = list.items[0];
    return makeStartTag(getListTag(firstItem.item.op)) +
        list.items.map((li) => _renderListItem(li)).join('') +
        makeEndTag(getListTag(firstItem.item.op));
  }

  String _renderListItem(ListItem li) {
    //if (!isOuterMost) {
    li.item.op.attributes.indent = 0;
    //}
    final converter = OpToHtmlConverter(li.item.op, _converterOptions);
    final parts = converter.getHtmlParts();
    final liElementsHtml = renderInlines(li.item.ops, false);
    return parts.openingTag +
        liElementsHtml +
        (li.innerList != null ? _renderList(li.innerList!) : '') +
        parts.closingTag;
  }

  String _renderTable(TableGroup table) {
    return makeStartTag('table') +
        makeStartTag('tbody') +
        table.rows.map((row) => _renderTableRow(row)).join('') +
        makeEndTag('tbody') +
        makeEndTag('table');
  }

  String _renderTableRow(TableRow row) {
    return makeStartTag('tr') +
        row.cells.map((cell) => _renderTableCell(cell)).join('') +
        makeEndTag('tr');
  }

  String _renderTableCell(TableCell cell) {
    final converter = OpToHtmlConverter(cell.item.op, _converterOptions);
    final parts = converter.getHtmlParts();
    final cellElementsHtml = renderInlines(cell.item.ops, false);
    return makeStartTag('td', [
          TagKeyValue(
            key: 'data-row',
            value: cell.item.op.attributes.table,
          ),
        ]) +
        parts.openingTag +
        cellElementsHtml +
        parts.closingTag +
        makeEndTag('td');
  }

  @visibleForTesting
  String renderBlock(DeltaInsertOp bop, List<DeltaInsertOp> ops) {
    final converter = OpToHtmlConverter(bop, _converterOptions);
    final htmlParts = converter.getHtmlParts();

    if (bop.isCodeBlock()) {
      return htmlParts.openingTag +
          encodeHtml(ops
              .map((iop) => iop.isCustomEmbed()
                  ? _renderCustom(iop, bop)
                  : iop.insert.value)
              .join('')) +
          htmlParts.closingTag;
    }

    final inlines = ops.map((op) => _renderInline(op, bop)).join('');
    return htmlParts.openingTag +
        (inlines.isEmpty ? brTag : inlines) +
        htmlParts.closingTag;
  }

  @visibleForTesting
  String renderInlines(List<DeltaInsertOp> ops, [bool isInlineGroup = true]) {
    final opsLen = ops.length - 1;
    final html = ops.mapIndexed((i, op) {
      if (i > 0 && i == opsLen && op.isJustNewline()) {
        return '';
      }
      return _renderInline(op, null);
    }).join('');
    if (!isInlineGroup) {
      return html;
    }

    final startParaTag = makeStartTag(_converterOptions.paragraphTag);
    final endParaTag = makeEndTag(_converterOptions.paragraphTag);
    if (html == brTag || _options.multiLineParagraph == true) {
      return startParaTag + html + endParaTag;
    }

    return startParaTag +
        html
            .split(brTag)
            .map((v) => v.isEmpty ? brTag : v)
            .join(endParaTag + startParaTag) +
        endParaTag;
  }

  String _renderInline(DeltaInsertOp op, DeltaInsertOp? contextOp) {
    if (op.isCustomEmbed()) {
      return _renderCustom(op, contextOp);
    }

    final converter = OpToHtmlConverter(op, _converterOptions);
    return converter.getHtml().replaceAll('\n', brTag);
  }

  String _renderCustom(DeltaInsertOp op, DeltaInsertOp? contextOp) {
    return _renderCustomWithCallback?.call(op, contextOp) ?? '';
  }
}
