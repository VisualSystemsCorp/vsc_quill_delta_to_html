import 'package:collection/collection.dart';
import 'package:vsc_quill_delta_to_html/src/delta_insert_op.dart';
import 'package:vsc_quill_delta_to_html/src/helpers/array.dart';

import 'group_types.dart';

class Grouper {
  static List<TDataGroup> pairOpsWithTheirBlock(List<DeltaInsertOp> ops) {
    final result = <TDataGroup>[];

    bool canBeInBlock(DeltaInsertOp op) {
      return !(op.isJustNewline() ||
          op.isCustomEmbedBlock() ||
          op.isVideo() ||
          op.isContainerBlock());
    }

    bool isInlineData(DeltaInsertOp op) => op.isInline();

    var lastInd = ops.length - 1;
    for (var i = lastInd; i >= 0; i--) {
      final op = ops[i];

      if (op.isVideo()) {
        result.add(VideoItem(op));
      } else if (op.isCustomEmbedBlock()) {
        result.add(BlotBlock(op));
      } else if (op.isContainerBlock()) {
        final opsSlice = sliceFromReverseWhile(ops, i - 1, canBeInBlock);
        result.add(BlockGroup(op, opsSlice.elements));
        i = opsSlice.sliceStartsAt > -1 ? opsSlice.sliceStartsAt : i;
      } else {
        final opsSlice = sliceFromReverseWhile(ops, i - 1, isInlineData);
        result.add(InlineGroup(opsSlice.elements..add(op)));
        i = opsSlice.sliceStartsAt > -1 ? opsSlice.sliceStartsAt : i;
      }
    }
    return result.reversed.toList();
  }

  static List<dynamic /*TDataGroup | BlockGroup[]*/ >
      groupConsecutiveSameStyleBlocks(
    List<TDataGroup> groups, {
    // blocksOf:
    bool header = true,
    bool codeBlocks = true,
    bool blockquotes = true,
    bool customBlocks = true,
  }) {
    return groupConsecutiveElementsWhile(groups, (g, gPrev) {
      if (g is! BlockGroup || gPrev is! BlockGroup) {
        return false;
      }

      return ((codeBlocks && Grouper.areBothCodeblocksWithSameLang(g, gPrev)) ||
          (blockquotes && Grouper.areBothBlockquotesWithSameAdi(g, gPrev)) ||
          (header && Grouper.areBothSameHeadersWithSameAdi(g, gPrev)) ||
          (customBlocks && Grouper.areBothCustomBlockWithSameAttr(g, gPrev)));
    });
  }

  // Moves all ops of same style consecutive blocks to the ops of first block
  // and discards the rest.
  static List<TDataGroup> reduceConsecutiveSameStyleBlocksToOne(
      List<dynamic /*TDataGroup | BlockGroup[]*/ > groups) {
    var newLineOp = DeltaInsertOp.createNewLineOp();
    final result = groups.map((elm) {
      if (elm is! List) {
        if (elm is BlockGroup && elm.ops.isEmpty) {
          elm.ops.add(newLineOp);
        }
        return elm as TDataGroup;
      }

      final elmList = List.castFrom<dynamic, BlockGroup>(elm);
      var groupsLastInd = elmList.length - 1;
      elmList[0].ops = flatten(
        elmList.mapIndexed((i, g) {
          if (g.ops.isEmpty) {
            return [newLineOp];
          }
          return List.from(g.ops)..addAll(i < groupsLastInd ? [newLineOp] : []);
        }),
      );

      return elmList[0];
    }).toList();

    return result;
  }

  static bool areBothCodeblocksWithSameLang(BlockGroup g1, BlockGroup gOther) {
    return (g1.op.isCodeBlock() &&
        gOther.op.isCodeBlock() &&
        g1.op.hasSameLangAs(gOther.op));
  }

  static bool areBothSameHeadersWithSameAdi(BlockGroup g1, BlockGroup gOther) {
    return g1.op.isSameHeaderAs(gOther.op) && g1.op.hasSameAdiAs(gOther.op);
  }

  static bool areBothBlockquotesWithSameAdi(BlockGroup g, BlockGroup gOther) {
    return (g.op.isBlockquote() &&
        gOther.op.isBlockquote() &&
        g.op.hasSameAdiAs(gOther.op));
  }

  static bool areBothCustomBlockWithSameAttr(BlockGroup g, BlockGroup gOther) {
    return (g.op.isCustomTextBlock() &&
        gOther.op.isCustomTextBlock() &&
        g.op.hasSameAttr(gOther.op));
  }
}
