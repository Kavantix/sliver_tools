import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../types/sliver_alignment.dart';

class RenderSliverAlign extends RenderSliver with RenderObjectWithChildMixin<RenderSliver> {
  RenderSliverAlign({
    SliverAlignment alignment = SliverAlignment.center,
    double? mainAxisFactor,
  }) : _alignment = alignment,
       _mainAxisFactor = mainAxisFactor;

  /// How to align the child.
  ///
  /// The value of the alignment controls the child's position relative to its
  /// scrollExtent and axisDirection. A value of -1.0 means that the leading
  /// edge of the child is positioned at the leading edge of the parent whereas
  /// a value of 1.0 means that the trailing edge of the child is aligned with
  /// the traling edge of the parent. Other values interpolate (and extrapolate)
  /// linearly. For example, a value of 0.0 means that the center of the child
  /// is aligned with the center of the parent.
  SliverAlignment get alignment => _alignment;
  SliverAlignment _alignment;
  set alignment(SliverAlignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  /// If non-null, sets its scrollExtent to the child's scrollExtent multiplied
  /// by this factor.
  ///
  /// Can be both greater and less than 1.0 but must be positive.
  double? get mainAxisFactor => _mainAxisFactor;
  double? _mainAxisFactor;
  set mainAxisFactor(double? value) {
    assert(value == null || value >= 0.0);
    if (value == _mainAxisFactor) return;
    _mainAxisFactor = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData)
      child.parentData = SliverPhysicalParentData();
  }

  /// Sets the [SliverPhysicalParentData.paintOffset] for the given child
  /// according to the [SliverConstraints.axisDirection] and
  /// [SliverConstraints.growthDirection] and the given geometry.
  @protected
  void setChildParentData(RenderSliver child, SliverConstraints constraints, SliverGeometry geometry) {
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    final direction = applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection);
    final relativeOffset = alignment.alongAxis(
      direction,
      geometry.scrollExtent - child.geometry!.scrollExtent,
    );
    childParentData.paintOffset = relativeOffset;
  }

  @override
  bool hitTestChildren(SliverHitTestResult result, {required double mainAxisPosition, required double crossAxisPosition}) {
    return child != null
      && child!.geometry!.hitTestExtent > 0
      && child!.hitTest(
        result,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child!.layout(constraints, parentUsesSize: true);
    final SliverGeometry childLayoutGeometry = child!.geometry!;

    final double scrollExtent = _mainAxisFactor != null
      ? childLayoutGeometry.scrollExtent * _mainAxisFactor!
      : childLayoutGeometry.scrollExtent;
    final double scrollExtentDelta = childLayoutGeometry.scrollExtent - scrollExtent;
    final double maxPaintExtent = math.max(0.0, childLayoutGeometry.maxPaintExtent - scrollExtentDelta);
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: maxPaintExtent);
    final double cacheExtent = calculateCacheOffset(constraints, from: 0.0, to: maxPaintExtent);

    geometry = SliverGeometry(
      scrollExtent: scrollExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: maxPaintExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: scrollExtent > constraints.remainingPaintExtent || constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      final SliverPhysicalParentData childParentData = child!.parentData! as SliverPhysicalParentData;
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child == this.child);
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SliverAlignment>('alignment', alignment));
    properties.add(DoubleProperty('mainAxisFactor', mainAxisFactor, defaultValue: null));
  }

}