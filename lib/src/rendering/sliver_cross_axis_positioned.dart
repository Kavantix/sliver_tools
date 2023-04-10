import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class _SliverCrossAxisPositionedParentData extends SliverPhysicalParentData {
  late double crossAxisPosition;
}

class SliverCrossAxisPositionedData {
  final double crossAxisPosition;
  final double crossAxisExtent;

  SliverCrossAxisPositionedData({
    required this.crossAxisPosition,
    required this.crossAxisExtent,
  });
}

mixin RenderSliverCrossAxisPositionedMixin
    on RenderSliver, RenderObjectWithChildMixin<RenderSliver> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _SliverCrossAxisPositionedParentData) {
      child.parentData = _SliverCrossAxisPositionedParentData();
    }
  }

  @override
  @nonVirtual
  @protected
  @visibleForTesting
  void performLayout() {
    final positionData = createCrossAxisPositionData(constraints);
    child!.layout(
      constraints.copyWith(crossAxisExtent: positionData.crossAxisExtent),
      parentUsesSize: true,
    );
    assert(
      child!.geometry != null,
      'Sliver child $child did not set its geometry',
    );

    geometry = child!.geometry;
    if (geometry!.scrollOffsetCorrection != null) return;
    final childParentData =
        child!.parentData as _SliverCrossAxisPositionedParentData;
    childParentData.crossAxisPosition = positionData.crossAxisPosition;
    switch (constraints.axis) {
      case Axis.vertical:
        childParentData.paintOffset =
            Offset(positionData.crossAxisPosition, 0.0);
        break;
      case Axis.horizontal:
        childParentData.paintOffset =
            Offset(0.0, positionData.crossAxisPosition);
        break;
    }
  }

  @protected
  SliverCrossAxisPositionedData createCrossAxisPositionData(
    SliverConstraints constraints,
  );

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    if (child == null) return false;
    final childParentData =
        child!.parentData as _SliverCrossAxisPositionedParentData;
    return result.addWithAxisOffset(
      paintOffset: childParentData.paintOffset,
      mainAxisOffset: 0,
      crossAxisOffset: childCrossAxisPosition(child!),
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
      hitTest: child!.hitTest,
    );
  }

  @override
  double childCrossAxisPosition(RenderSliver child) {
    final childParentData =
        child.parentData as _SliverCrossAxisPositionedParentData;
    return childParentData.crossAxisPosition;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child == this.child);
    final childParentData = child.parentData as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.geometry!.visible) {
      final childParentData = child!.parentData as SliverPhysicalParentData;
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }

  @override
  void debugPaint(PaintingContext context, Offset offset) {
    super.debugPaint(context, offset);
    assert(() {
      if (debugPaintSizeEnabled) {
        final parentSize = getAbsoluteSize();
        final outerRect = offset & parentSize;
        Size childSize;
        Rect? innerRect;
        if (child != null) {
          childSize = child!.getAbsoluteSize();
          final childParentData = child!.parentData as SliverPhysicalParentData;
          innerRect = (offset + childParentData.paintOffset) & childSize;
          assert(innerRect.top >= outerRect.top);
          assert(innerRect.left >= outerRect.left);
          assert(innerRect.right <= outerRect.right);
          assert(innerRect.bottom <= outerRect.bottom);
        }
        debugPaintPadding(context.canvas, outerRect, innerRect);
      }
      return true;
    }());
  }
}
