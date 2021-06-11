// Since the `_layoutChildSequence` method is based on the one of `RenderViewportBase`
// in the flutter project I also include their copyright:
//
// Copyright 2014 The Flutter Authors. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'dart:math';

import 'package:flutter/rendering.dart';

class MultiSliverParentData extends SliverPhysicalParentData
    with ContainerParentDataMixin<RenderObject> {
  late double mainAxisPosition;
  late SliverGeometry geometry;
  late SliverConstraints constraints;
  Offset? boxPaintOffset;
}

/// The RenderObject that handles laying out and painting the children of [MultiSliver]
class RenderMultiSliver extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderObject, MultiSliverParentData>,
        RenderSliverHelpers {
  RenderMultiSliver({
    required bool containing,
  }) : _containing = containing;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! MultiSliverParentData) {
      child.parentData = MultiSliverParentData();
    }
  }

  bool _containing;
  bool get containing => _containing;
  set containing(bool containing) {
    if (_containing != containing) {
      _containing = containing;
      markNeedsLayout();
    }
  }

  Iterable<RenderObject> get _children sync* {
    RenderObject? child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  Iterable<RenderObject> get _childrenInPaintOrder sync* {
    RenderObject? child = lastChild;
    while (child != null) {
      yield child;
      child = childBefore(child);
    }
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final correction = _layoutChildSequence(
      child: firstChild,
      scrollOffset: constraints.scrollOffset,
      overlap: constraints.overlap,
      remainingPaintExtent: constraints.remainingPaintExtent,
      mainAxisExtent: constraints.viewportMainAxisExtent,
      crossAxisExtent: constraints.crossAxisExtent,
      growthDirection: GrowthDirection.forward,
      advance: childAfter,
      remainingCacheExtent: constraints.remainingCacheExtent,
      cacheOrigin: constraints.cacheOrigin,
    );

    if (correction != null) {
      geometry = SliverGeometry(scrollOffsetCorrection: correction);
      return;
    }
  }

  /// Almost an exact copy of [RenderViewportBase]'s [layoutChildSequence]
  /// just added visualoverflow, maxScrollObstructionExtent and setting of the geometry
  double? _layoutChildSequence({
    required RenderObject? child,
    required double scrollOffset,
    required double overlap,
    required double remainingPaintExtent,
    required double mainAxisExtent,
    required double crossAxisExtent,
    required GrowthDirection growthDirection,
    required RenderObject? Function(RenderObject child) advance,
    required double remainingCacheExtent,
    required double cacheOrigin,
  }) {
    assert(scrollOffset.isFinite);
    assert(scrollOffset >= 0.0);
    const double initialLayoutOffset = 0.0;
    final ScrollDirection adjustedUserScrollDirection =
        applyGrowthDirectionToScrollDirection(
            constraints.userScrollDirection, growthDirection);
    double layoutOffset = initialLayoutOffset;
    double maxPaintOffset = min(0, overlap);
    double maxPaintExtent = 0;
    double maxHitTestExtent = 0;
    double scrollExtent = 0;
    double precedingScrollExtent = constraints.precedingScrollExtent;
    bool hasVisualOverflow = false;
    double maxScrollObstructionExtent = 0;
    bool visible = false;
    double? minPaintOrigin;

    while (child != null) {
      final double sliverScrollOffset =
          scrollOffset <= 0.0 ? 0.0 : scrollOffset;
      // If the scrollOffset is too small we adjust the paddedOrigin because it
      // doesn't make sense to ask a sliver for content before its scroll
      // offset.
      final double correctedCacheOrigin = max(cacheOrigin, -sliverScrollOffset);
      final double cacheExtentCorrection = cacheOrigin - correctedCacheOrigin;

      assert(sliverScrollOffset >= correctedCacheOrigin.abs());
      assert(correctedCacheOrigin <= 0.0);
      assert(sliverScrollOffset >= 0.0);
      assert(cacheExtentCorrection <= 0.0);

      final childParentData = layoutChild(
        SliverConstraints(
          axisDirection: constraints.axisDirection,
          growthDirection: growthDirection,
          userScrollDirection: adjustedUserScrollDirection,
          scrollOffset: sliverScrollOffset,
          precedingScrollExtent: precedingScrollExtent,
          overlap: max(overlap, maxPaintOffset) - layoutOffset,
          remainingPaintExtent: max(
              0.0, remainingPaintExtent - layoutOffset + initialLayoutOffset),
          crossAxisExtent: crossAxisExtent,
          crossAxisDirection: constraints.crossAxisDirection,
          viewportMainAxisExtent: mainAxisExtent,
          remainingCacheExtent:
              max(0.0, remainingCacheExtent + cacheExtentCorrection),
          cacheOrigin: correctedCacheOrigin,
        ),
        child,
        parentUsesSize: true,
      );

      assert(childParentData.geometry.debugAssertIsValid());

      // If there is a correction to apply, we'll have to start over.
      if (childParentData.geometry.scrollOffsetCorrection != null) {
        return childParentData.geometry.scrollOffsetCorrection;
      }

      // We use the child's paint origin in our coordinate system as the
      // layoutOffset we store in the child's parent data.
      final double effectiveLayoutOffset =
          layoutOffset + childParentData.geometry.paintOrigin;

      // `effectiveLayoutOffset` becomes meaningless once we moved past the trailing edge
      // because `child.geometry.layoutExtent` is zero. Using the still increasing
      // 'scrollOffset` to roughly position these invisible slivers in the right order.
      if (childParentData.geometry.visible || scrollOffset > 0) {
        _updateChildPaintOffset(child, effectiveLayoutOffset);
      } else {
        _updateChildPaintOffset(child, -scrollOffset + initialLayoutOffset);
      }

      minPaintOrigin = min(minPaintOrigin ?? double.infinity,
          childParentData.geometry.paintOrigin);
      maxPaintOffset = max(
          effectiveLayoutOffset + childParentData.geometry.paintExtent,
          maxPaintOffset);
      maxPaintExtent = max(
        maxPaintExtent,
        effectiveLayoutOffset +
            childParentData.geometry.maxPaintExtent +
            constraints.scrollOffset -
            childParentData.constraints.scrollOffset,
      );
      maxHitTestExtent = max(maxHitTestExtent,
          layoutOffset + childParentData.geometry.hitTestExtent);
      scrollOffset -= childParentData.geometry.scrollExtent;
      scrollExtent += childParentData.geometry.scrollExtent;
      precedingScrollExtent += childParentData.geometry.scrollExtent;
      layoutOffset += childParentData.geometry.layoutExtent;
      hasVisualOverflow =
          hasVisualOverflow || childParentData.geometry.hasVisualOverflow;
      maxScrollObstructionExtent =
          childParentData.geometry.maxScrollObstructionExtent;
      visible = visible || childParentData.geometry.visible;
      if (childParentData.geometry.cacheExtent != 0.0) {
        remainingCacheExtent -=
            childParentData.geometry.cacheExtent - cacheExtentCorrection;
        cacheOrigin = min(
            correctedCacheOrigin + childParentData.geometry.cacheExtent, 0.0);
      }

      // updateOutOfBandData(growthDirection, child.geometry);

      // move on to the next child
      child = advance(child);
    }

    for (final child in _children) {
      final parentData = child.parentData as MultiSliverParentData;
      _updateChildPaintOffset(
          child, parentData.mainAxisPosition - minPaintOrigin!);
    }

    if (containing) {
      final allowedBounds = max(0.0, scrollExtent - constraints.scrollOffset);
      if (maxPaintOffset > allowedBounds) {
        _containPinnedSlivers(maxPaintOffset, allowedBounds, constraints.axis);
        maxPaintOffset = allowedBounds;
        layoutOffset = allowedBounds;
        maxScrollObstructionExtent =
            min(allowedBounds, maxScrollObstructionExtent);
      }
      hasVisualOverflow = true;
    }
    minPaintOrigin ??= 0;
    final paintExtent = max(
      0.0,
      min(
        maxPaintOffset - minPaintOrigin,
        constraints.remainingPaintExtent - minPaintOrigin,
      ),
    );
    double totalPaintExtent = (minPaintOrigin + paintExtent)
        .clamp(0.0, constraints.remainingPaintExtent)
        .toDouble();
    assert(() {
      const fraction = 0.000001;
      // Round the remainingPaintExtent to prevent the warning that is otherwise possible
      final remainingPaintExtent =
          (constraints.remainingPaintExtent / fraction).floorToDouble() *
              fraction;
      totalPaintExtent = totalPaintExtent.clamp(0.0, remainingPaintExtent);
      return true;
    }());
    final layoutExtent =
        max(0.0, min(layoutOffset, totalPaintExtent - minPaintOrigin));
    geometry = SliverGeometry(
      paintOrigin: minPaintOrigin,
      scrollExtent: scrollExtent,
      paintExtent: totalPaintExtent - minPaintOrigin,
      maxPaintExtent: maxPaintExtent - minPaintOrigin,
      layoutExtent: layoutExtent,
      cacheExtent: constraints.remainingCacheExtent - remainingCacheExtent,
      hasVisualOverflow: hasVisualOverflow,
      maxScrollObstructionExtent: maxScrollObstructionExtent,
      visible: visible && paintExtent > 0,
    );

    return null;
  }

  MultiSliverParentData layoutChild(
      SliverConstraints constraints, RenderObject child,
      {bool parentUsesSize = false}) {
    final childParentData = child.parentData as MultiSliverParentData;
    childParentData.constraints = constraints;
    if (child is RenderSliver) {
      child.layout(constraints, parentUsesSize: parentUsesSize);
      childParentData.geometry = child.geometry!;
    } else if (child is RenderBox) {
      child.layout(constraints.asBoxConstraints(),
          parentUsesSize: parentUsesSize);
      final double childExtent;
      switch (constraints.axis) {
        case Axis.horizontal:
          childExtent = child.size.width;
          break;
        case Axis.vertical:
          childExtent = child.size.height;
          break;
      }
      final double paintedChildSize =
          calculatePaintOffset(constraints, from: 0.0, to: childExtent);
      final double cacheExtent =
          calculateCacheOffset(constraints, from: 0.0, to: childExtent);

      assert(paintedChildSize.isFinite);
      assert(paintedChildSize >= 0.0);
      childParentData.geometry = SliverGeometry(
        scrollExtent: childExtent,
        paintExtent: paintedChildSize,
        cacheExtent: cacheExtent,
        maxPaintExtent: childExtent,
        hitTestExtent: paintedChildSize,
        hasVisualOverflow: paintedChildSize > 0 &&
            (childExtent > constraints.remainingPaintExtent ||
                constraints.scrollOffset > 0.0),
      );
      setBoxChildParentData(child, constraints, childParentData.geometry);
    } else {
      throw ArgumentError(
          'MultiSliver can only handle RenderSliver and RenderBox children');
    }
    return childParentData;
  }

  void setBoxChildParentData(
      RenderBox child, SliverConstraints constraints, SliverGeometry geometry) {
    final MultiSliverParentData childParentData =
        child.parentData! as MultiSliverParentData;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        childParentData.boxPaintOffset = Offset(
            0.0,
            -(geometry.scrollExtent -
                (geometry.paintExtent + constraints.scrollOffset)));
        break;
      case AxisDirection.right:
        childParentData.boxPaintOffset = Offset(-constraints.scrollOffset, 0.0);
        break;
      case AxisDirection.down:
        childParentData.boxPaintOffset = Offset(0.0, -constraints.scrollOffset);
        break;
      case AxisDirection.left:
        childParentData.boxPaintOffset = Offset(
            -(geometry.scrollExtent -
                (geometry.paintExtent + constraints.scrollOffset)),
            0.0);
        break;
    }
  }

  void _containPinnedSlivers(
      double usedBounds, double allowedBounds, Axis axis) {
    final diff = usedBounds - allowedBounds;
    for (final child in _children) {
      final childParentData = child.parentData as MultiSliverParentData;
      if (!childParentData.geometry.visible) continue;
      switch (axis) {
        case Axis.horizontal:
          childParentData.paintOffset =
              childParentData.paintOffset - Offset(diff, 0);
          break;
        case Axis.vertical:
          childParentData.paintOffset =
              childParentData.paintOffset - Offset(0, diff);
          break;
      }
    }
  }

  void _updateChildPaintOffset(RenderObject child, double layoutOffset) {
    final childParentData = child.parentData as MultiSliverParentData;
    childParentData.mainAxisPosition = layoutOffset;
    switch (constraints.axis) {
      case Axis.horizontal:
        childParentData.paintOffset = Offset(layoutOffset, 0);
        break;
      case Axis.vertical:
        childParentData.paintOffset = Offset(0, layoutOffset);
        break;
    }
    if (childParentData.boxPaintOffset != null) {
      childParentData.paintOffset += childParentData.boxPaintOffset!;
    }
  }

  double _computeChildMainAxisPosition(RenderObject child) {
    final childParentData = child.parentData as MultiSliverParentData;
    switch (constraints.axis) {
      case Axis.vertical:
        return childParentData.paintOffset.dy;
      case Axis.horizontal:
        return childParentData.paintOffset.dx;
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    for (final child in _children.where(
        (c) => (c.parentData as MultiSliverParentData).geometry.visible)) {
      if (child is RenderSliver) {
        final childMainAxisPosition = _computeChildMainAxisPosition(child);
        final hit = child.hitTest(
          result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition,
          crossAxisPosition: crossAxisPosition,
        );
        if (hit) return true;
      } else if (child is RenderBox) {
        final hit = hitTestBoxChild(
          BoxHitTestResult.wrap(result),
          child,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition,
        );
        if (hit) return true;
      }
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final child in _childrenInPaintOrder) {
      final childParentData = child.parentData as MultiSliverParentData;
      final childGeometry = childParentData.geometry;
      if (childGeometry.visible) {
        final childPaintOffset = childParentData.paintOffset;
        switch (applyGrowthDirectionToAxisDirection(
            constraints.axisDirection, constraints.growthDirection)) {
          case AxisDirection.down:
          case AxisDirection.right:
            context.paintChild(child, offset + childPaintOffset);
            break;
          case AxisDirection.up:
            context.paintChild(
              child,
              offset +
                  Offset(0, geometry!.paintExtent - childGeometry.paintExtent) -
                  childPaintOffset,
            );
            break;
          case AxisDirection.left:
            context.paintChild(
              child,
              offset +
                  Offset(geometry!.paintExtent - childGeometry.paintExtent, 0) -
                  childPaintOffset,
            );
            break;
        }
      }
    }
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    final childParentData = child.parentData as MultiSliverParentData;
    final childGeometry = childParentData.geometry;
    final childPaintOffset = childParentData.paintOffset;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.down:
      case AxisDirection.right:
        transform.translate(
          childPaintOffset.dx,
          childPaintOffset.dy,
        );
        break;
      case AxisDirection.up:
        transform.translate(
          childPaintOffset.dx,
          geometry!.paintExtent -
              childGeometry.paintExtent -
              childPaintOffset.dy,
        );
        break;
      case AxisDirection.left:
        transform.translate(
          geometry!.paintExtent -
              childGeometry.paintExtent -
              childPaintOffset.dx,
          childPaintOffset.dy,
        );
        break;
    }
  }

  @override
  double childScrollOffset(covariant RenderObject child) {
    return child.sliverConstraints!.precedingScrollExtent -
        constraints.precedingScrollExtent;
  }

  @override
  double childMainAxisPosition(covariant RenderObject child) {
    return _computeChildMainAxisPosition(child);
  }
}

extension on RenderObject {
  SliverConstraints? get sliverConstraints =>
      (parentData as MultiSliverParentData).constraints;
}
