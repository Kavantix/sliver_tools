import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Constrains and centers the [child] sliver to a maximum cross axis extent
/// specified by [maxCrossAxisExtent].
class SliverCrossAxisConstrained extends SingleChildRenderObjectWidget {
  const SliverCrossAxisConstrained({
    @required this.maxCrossAxisExtent,
    Key key,
    Widget child,
  })  : assert(maxCrossAxisExtent != null),
        super(key: key, child: child);

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

class _SliverCrossAxisConstrainedParentData extends SliverPhysicalParentData {
  double crossAxisPosition;
}

class RenderSliverCrossAxisConstrained extends RenderSliver
    with RenderObjectWithChildMixin<RenderSliver> {
  RenderSliverCrossAxisConstrained({
    double maxCrossAxisExtent,
    RenderSliver child,
  }) : _maxCrossAxisExtent = maxCrossAxisExtent {
    this.child = child;
  }

  /// Max allowed limit of the cross axis
  double get maxCrossAxisExtent => _maxCrossAxisExtent;
  double _maxCrossAxisExtent;
  set maxCrossAxisExtent(double value) {
    assert(value != null);
    assert(value > 0);
    if (_maxCrossAxisExtent == value) return;
    _maxCrossAxisExtent = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _SliverCrossAxisConstrainedParentData)
      child.parentData = _SliverCrossAxisConstrainedParentData();
  }

  @override
  void performLayout() {
    child.layout(
      constraints.copyWith(
          crossAxisExtent:
              min(constraints.crossAxisExtent, _maxCrossAxisExtent)),
      parentUsesSize: true,
    );

    geometry = child.geometry;
    if (geometry.scrollOffsetCorrection != null) return;

    final childParentData =
        child.parentData as _SliverCrossAxisConstrainedParentData;
    final crossAxisPosition =
        (constraints.crossAxisExtent - child.constraints.crossAxisExtent) / 2;
    childParentData.crossAxisPosition = crossAxisPosition;
    switch (constraints.axis) {
      case Axis.vertical:
        childParentData.paintOffset = Offset(crossAxisPosition, 0.0);
        break;
      case Axis.horizontal:
        childParentData.paintOffset = Offset(0.0, crossAxisPosition);
        break;
    }
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {@required double mainAxisPosition, @required double crossAxisPosition}) {
    if (child == null) return false;
    final childParentData =
        child.parentData as _SliverCrossAxisConstrainedParentData;
    return child.hitTest(
      result,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition - childParentData.crossAxisPosition,
    );
  }

  @override
  double childCrossAxisPosition(RenderSliver child) {
    assert(child != null);
    final childParentData =
        child.parentData as _SliverCrossAxisConstrainedParentData;
    return childParentData.crossAxisPosition;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child != null);
    assert(child == this.child);
    final childParentData = child.parentData as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
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
        final parentSize = getAbsoluteSize();
        final outerRect = offset & parentSize;
        Size childSize;
        Rect innerRect;
        if (child != null) {
          childSize = child.getAbsoluteSize();
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
