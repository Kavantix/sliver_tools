import 'dart:math';

import 'package:flutter/rendering.dart';

class RenderSliverFlexibleHeader extends RenderSliverSingleBoxAdapter {
  RenderSliverFlexibleHeader({this.floating = false});

  final bool floating;

  double _lastActualScrollOffset = 0;
  double _effectiveScrollOffset = 0;
  double _childPosition = 0;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double maxExtent = childExtent;
    final double paintExtent = maxExtent - _effectiveScrollOffset;
    final double layoutExtent = maxExtent - constraints.scrollOffset;

    if ((constraints.scrollOffset < _lastActualScrollOffset ||
        _effectiveScrollOffset < maxExtent)) {
      double delta = _lastActualScrollOffset - constraints.scrollOffset;
      final bool allowFloatingExpansion =
          constraints.userScrollDirection == ScrollDirection.forward;
      if (allowFloatingExpansion) {
        _effectiveScrollOffset = min(_effectiveScrollOffset, maxExtent);
      } else {
        delta = min(delta, 0);
      }
      _effectiveScrollOffset =
          (_effectiveScrollOffset - delta).clamp(0.0, constraints.scrollOffset);
    } else {
      _effectiveScrollOffset = constraints.scrollOffset;
    }

    final paintedChildExtent = min(
      childExtent,
      constraints.remainingPaintExtent - constraints.overlap,
    );
    geometry = SliverGeometry(
      paintExtent:
          floating ? paintExtent.clamp(0.0, constraints.remainingPaintExtent) : paintedChildExtent,
      maxPaintExtent: maxExtent,
      paintOrigin: floating ? min(constraints.overlap, 0) : constraints.overlap,
      scrollExtent: maxExtent,
      layoutExtent: floating
          ? min(
              paintExtent.clamp(0.0, constraints.remainingPaintExtent),
              layoutExtent.clamp(0.0, constraints.remainingPaintExtent),
            )
          : max(0.0, paintedChildExtent - constraints.scrollOffset),
      hasVisualOverflow: floating ? true : paintedChildExtent < childExtent,
    );
    _childPosition = min(0, paintExtent - childExtent);
    _lastActualScrollOffset = constraints.scrollOffset;
  }

  double get childExtent {
    if (child == null) {
      return 0;
    }
    assert(child!.hasSize);
    switch (constraints.axis) {
      case Axis.vertical:
        return child!.size.height;
      case Axis.horizontal:
        return child!.size.width;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection,
        constraints.growthDirection,
      )) {
        case AxisDirection.up:
          offset += Offset(
            0,
            geometry!.paintExtent - childMainAxisPosition(child!) - childExtent,
          );
          break;
        case AxisDirection.down:
          offset += Offset(0, childMainAxisPosition(child!));
          break;
        case AxisDirection.left:
          offset += Offset(
            geometry!.paintExtent - childMainAxisPosition(child!) - childExtent,
            0,
          );
          break;
        case AxisDirection.right:
          offset += Offset(childMainAxisPosition(child!), 0);
          break;
      }
      context.paintChild(child!, offset);
    }
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    assert(child == this.child);
    return floating ? _childPosition : 0;
  }
}
