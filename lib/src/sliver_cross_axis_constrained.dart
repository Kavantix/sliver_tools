import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Constraints and centers the child [sliver] to a maximum cross axis extent
///  specified by [maxCrossAxisExtent].
class SliverCrossAxisConstrained extends SingleChildRenderObjectWidget {
  const SliverCrossAxisConstrained({
    @required this.maxCrossAxisExtent,
    Key key,
    Widget sliver,
  })  : assert(maxCrossAxisExtent != null),
        super(key: key, child: sliver);

  /// Max allowed limit of the cross axis
  final double maxCrossAxisExtent;

  @override
  RenderSliverCrossAxisConstrained createRenderObject(BuildContext context) =>
      RenderSliverCrossAxisConstrained(maxCrossAxisExtent: maxCrossAxisExtent);

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverCrossAxisConstrained renderObject) {
    renderObject.maxCrossAxisExtent = maxCrossAxisExtent;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<double>('maxCrossAxisExtent', maxCrossAxisExtent));
  }
}

class RenderSliverCrossAxisConstrained extends RenderSliver
    with RenderObjectWithChildMixin<RenderSliver> {
  double _maxCrossAxisExtent;

  RenderSliverCrossAxisConstrained(
      {double maxCrossAxisExtent, RenderSliver child})
      : _maxCrossAxisExtent = maxCrossAxisExtent {
    this.child = child;
  }

  set maxCrossAxisExtent(double value) {
    assert(value != null);
    assert(value > 0);
    if (_maxCrossAxisExtent == value) return;
    _maxCrossAxisExtent = value;
    markNeedsLayout();
  }

  double get maxCrossAxisExtent => _maxCrossAxisExtent;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData)
      child.parentData = SliverPhysicalParentData();
  }

  @override
  void performLayout() {
    child.layout(
        constraints.copyWith(
            crossAxisExtent:
                min(constraints.crossAxisExtent, _maxCrossAxisExtent)),
        parentUsesSize: true);

    final childLayoutGeometry = child.geometry;
    if (childLayoutGeometry.scrollOffsetCorrection != null) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: childLayoutGeometry.scrollOffsetCorrection,
      );
      return;
    }

    geometry = SliverGeometry(
      scrollExtent: childLayoutGeometry.scrollExtent,
      paintExtent: childLayoutGeometry.paintExtent,
      layoutExtent: childLayoutGeometry.layoutExtent,
      cacheExtent: childLayoutGeometry.cacheExtent,
      maxPaintExtent: childLayoutGeometry.maxPaintExtent,
      hitTestExtent: childLayoutGeometry.hitTestExtent,
      hasVisualOverflow: childLayoutGeometry.hasVisualOverflow,
    );

    final childParentData = child.parentData as SliverPhysicalParentData;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
      case AxisDirection.down:
        childParentData.paintOffset =
            Offset(childCrossAxisPosition(child), 0.0);
        break;
      case AxisDirection.right:
      case AxisDirection.left:
        childParentData.paintOffset =
            Offset(0.0, childCrossAxisPosition(child));
        break;
    }
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {@required double mainAxisPosition, @required double crossAxisPosition}) {
    if (child != null && child.geometry.hitTestExtent > 0.0)
      return child.hitTest(result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition(child),
          crossAxisPosition: crossAxisPosition - childCrossAxisPosition(child));
    return false;
  }

  @override
  double childMainAxisPosition(RenderSliver child) => 0;

  @override
  double childCrossAxisPosition(RenderSliver child) {
    assert(child != null);
    assert(child == this.child);
    assert(constraints != null);
    assert(constraints.crossAxisExtent != null);
    assert(child.constraints.crossAxisExtent != null);
    return (constraints.crossAxisExtent - child.constraints.crossAxisExtent) /
        2;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child != null);
    assert(child == this.child);
    final childParentData = child.parentData as SliverPhysicalParentData;
    childParentData
        .applyPaintTransform(transform); // ignore: cascade_invocations
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child.geometry.visible) {
      final childParentData = child.parentData as SliverPhysicalParentData;
      context.paintChild(child, offset + childParentData.paintOffset);
    }
  }

  @override
  void debugPaint(PaintingContext context, Offset offset) {
    super.debugPaint(context, offset);
    assert(() {
      if (debugPaintSizeEnabled) {
        final parentSize = getAbsoluteSizeRelativeToOrigin();
        final outerRect = offset & parentSize;
        Size childSize;
        Rect innerRect;
        if (child != null) {
          childSize = child.getAbsoluteSizeRelativeToOrigin();
          final childParentData = child.parentData as SliverPhysicalParentData;
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<double>('maxCrossAxisExtent', maxCrossAxisExtent));
  }
}
