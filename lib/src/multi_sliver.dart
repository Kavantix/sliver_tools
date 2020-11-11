// The MIT License (MIT)
//
// Copyright (c) 2020 Pieter van Loon
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// [MultiSliver] allows for returning multiple slivers from a single build method
class MultiSliver extends MultiChildRenderObjectWidget {
  MultiSliver({
    Key key,
    @required List<Widget> children,
    this.pushPinnedChildren = false,
  }) : super(key: key, children: children);

  /// If true any children that paint beyond the layoutExtent of the entire [MultiSliver] will
  /// be pushed off towards the leading edge of the [Viewport]
  final bool pushPinnedChildren;

  @override
  RenderMultiSliver createRenderObject(BuildContext context) =>
      RenderMultiSliver(
        containing: pushPinnedChildren,
      );

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderMultiSliver renderObject) {
    renderObject.containing = pushPinnedChildren;
  }
}

class MultiSliverParentData extends SliverPhysicalContainerParentData {
  double mainAxisPosition;
}

/// The RenderObject that handles laying out and painting the children of [MultiSliver]
class RenderMultiSliver extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderSliver,
            SliverPhysicalContainerParentData> {
  RenderMultiSliver({
    @required bool containing,
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

  Iterable<RenderSliver> get _children sync* {
    RenderSliver child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  Iterable<RenderSliver> get _childrenInPaintOrder sync* {
    RenderSliver child = lastChild;
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
      layoutOffset: 0.0,
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
  double _layoutChildSequence({
    @required RenderSliver child,
    @required double scrollOffset,
    @required double overlap,
    @required double layoutOffset,
    @required double remainingPaintExtent,
    @required double mainAxisExtent,
    @required double crossAxisExtent,
    @required GrowthDirection growthDirection,
    @required RenderSliver Function(RenderSliver child) advance,
    @required double remainingCacheExtent,
    @required double cacheOrigin,
  }) {
    assert(scrollOffset.isFinite);
    assert(scrollOffset >= 0.0);
    final double initialLayoutOffset = layoutOffset;
    final ScrollDirection adjustedUserScrollDirection =
        applyGrowthDirectionToScrollDirection(
            constraints.userScrollDirection, growthDirection);
    assert(adjustedUserScrollDirection != null);
    double maxPaintOffset = layoutOffset + overlap;
    double maxPaintExtent = 0;
    double maxHitTestExtent = 0;
    double precedingScrollExtent = 0;
    bool hasVisualOverflow = false;
    double maxScrollObstructionExtent = 0;
    bool visible = false;
    double minPaintOrigin;

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

      child.layout(
          SliverConstraints(
            axisDirection: constraints.axisDirection,
            growthDirection: growthDirection,
            userScrollDirection: adjustedUserScrollDirection,
            scrollOffset: sliverScrollOffset,
            precedingScrollExtent: precedingScrollExtent,
            overlap: maxPaintOffset - layoutOffset,
            remainingPaintExtent: max(
                0.0, remainingPaintExtent - layoutOffset + initialLayoutOffset),
            crossAxisExtent: crossAxisExtent,
            crossAxisDirection: constraints.crossAxisDirection,
            viewportMainAxisExtent: mainAxisExtent,
            remainingCacheExtent:
                max(0.0, remainingCacheExtent + cacheExtentCorrection),
            cacheOrigin: correctedCacheOrigin,
          ),
          parentUsesSize: true);

      assert(child.geometry.debugAssertIsValid());

      // If there is a correction to apply, we'll have to start over.
      if (child.geometry.scrollOffsetCorrection != null) {
        return child.geometry.scrollOffsetCorrection;
      }

      // We use the child's paint origin in our coordinate system as the
      // layoutOffset we store in the child's parent data.
      final double effectiveLayoutOffset =
          layoutOffset + child.geometry.paintOrigin;

      // `effectiveLayoutOffset` becomes meaningless once we moved past the trailing edge
      // because `child.geometry.layoutExtent` is zero. Using the still increasing
      // 'scrollOffset` to roughly position these invisible slivers in the right order.
      if (child.geometry.visible || scrollOffset > 0) {
        _updateChildPaintOffset(child, effectiveLayoutOffset);
      } else {
        _updateChildPaintOffset(child, -scrollOffset + initialLayoutOffset);
      }

      minPaintOrigin =
          min(minPaintOrigin ?? double.infinity, child.geometry.paintOrigin);
      maxPaintOffset = max(
          effectiveLayoutOffset + child.geometry.paintExtent, maxPaintOffset);
      maxPaintExtent = max(
        maxPaintExtent,
        layoutOffset +
            child.geometry.maxPaintExtent +
            constraints.scrollOffset -
            child.constraints.scrollOffset,
      );
      maxHitTestExtent =
          max(maxHitTestExtent, layoutOffset + child.geometry.hitTestExtent);
      scrollOffset -= child.geometry.scrollExtent;
      precedingScrollExtent += child.geometry.scrollExtent;
      layoutOffset += child.geometry.layoutExtent;
      hasVisualOverflow = hasVisualOverflow || child.geometry.hasVisualOverflow;
      maxScrollObstructionExtent = child.geometry.maxScrollObstructionExtent;
      visible = visible || child.geometry.visible;
      if (child.geometry.cacheExtent != 0.0) {
        remainingCacheExtent -=
            child.geometry.cacheExtent - cacheExtentCorrection;
        cacheOrigin =
            min(correctedCacheOrigin + child.geometry.cacheExtent, 0.0);
      }

      // updateOutOfBandData(growthDirection, child.geometry);

      // move on to the next child
      child = advance(child);
    }

    for (final child in _children) {
      final parentData = child.parentData as MultiSliverParentData;
      switch (constraints.axis) {
        case Axis.horizontal:
          parentData.paintOffset =
              Offset(parentData.mainAxisPosition - minPaintOrigin, 0);
          break;
        case Axis.vertical:
          parentData.paintOffset =
              Offset(0, parentData.mainAxisPosition - minPaintOrigin);
          break;
      }
    }

    if (containing) {
      final allowedBounds =
          max(0.0, precedingScrollExtent - constraints.scrollOffset);
      if (maxPaintOffset > allowedBounds) {
        _containPinnedSlivers(maxPaintOffset, allowedBounds, constraints.axis);
        maxPaintOffset = allowedBounds;
        layoutOffset = allowedBounds;
        maxScrollObstructionExtent =
            min(allowedBounds, maxScrollObstructionExtent);
      }
      hasVisualOverflow = true;
    }
    final paintExtent = max(
        0.0,
        min(maxPaintOffset - minPaintOrigin,
            constraints.remainingPaintExtent - minPaintOrigin));
    final totalPaintExtent = (minPaintOrigin + paintExtent)
        .clamp(0.0, constraints.remainingPaintExtent)
        .toDouble();
    final layoutExtent =
        max(0.0, min(layoutOffset, totalPaintExtent - minPaintOrigin));
    geometry = SliverGeometry(
      paintOrigin: minPaintOrigin,
      scrollExtent: precedingScrollExtent,
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

  void _containPinnedSlivers(
      double usedBounds, double allowedBounds, Axis axis) {
    final diff = usedBounds - allowedBounds;
    for (final child in _children) {
      if (!child.geometry.visible) continue;
      final childParentData =
          child.parentData as SliverPhysicalContainerParentData;
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

  void _updateChildPaintOffset(RenderSliver child, double layoutOffset) {
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
  }

  double _computeChildMainAxisPosition(
      RenderSliver child, double parentMainAxisPosition) {
    assert(child != null);
    assert(child.constraints != null);
    final childParentData = child.parentData as SliverPhysicalParentData;
    switch (constraints.axis) {
      case Axis.vertical:
        return parentMainAxisPosition - childParentData.paintOffset.dy;
      case Axis.horizontal:
        return parentMainAxisPosition - childParentData.paintOffset.dx;
    }
    throw FallThroughError();
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    @required double mainAxisPosition,
    @required double crossAxisPosition,
  }) {
    assert(mainAxisPosition != null);
    assert(crossAxisPosition != null);
    for (final child in _children.where((c) => c.geometry.visible)) {
      final hit = child.hitTest(
        result,
        mainAxisPosition:
            _computeChildMainAxisPosition(child, mainAxisPosition),
        crossAxisPosition: crossAxisPosition,
      );
      if (hit) return true;
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final child in _childrenInPaintOrder) {
      final parentData = child.parentData as SliverPhysicalContainerParentData;
      if (child.geometry.visible) {
        switch (applyGrowthDirectionToAxisDirection(
            constraints.axisDirection, constraints.growthDirection)) {
          case AxisDirection.down:
          case AxisDirection.right:
            context.paintChild(child, offset + parentData.paintOffset);
            break;
          case AxisDirection.up:
            context.paintChild(
              child,
              offset +
                  Offset(0, geometry.paintExtent - child.geometry.paintExtent) -
                  parentData.paintOffset,
            );
            break;
          case AxisDirection.left:
            context.paintChild(
              child,
              offset +
                  Offset(geometry.paintExtent - child.geometry.paintExtent, 0) -
                  parentData.paintOffset,
            );
            break;
        }
      }
    }
  }

  @override
  void applyPaintTransform(covariant RenderSliver child, Matrix4 transform) {
    assert(child != null);
    final childParentData = child.parentData as SliverPhysicalParentData;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.down:
      case AxisDirection.right:
        transform.translate(
          childParentData.paintOffset.dx,
          childParentData.paintOffset.dy,
        );
        break;
      case AxisDirection.up:
        transform.translate(
          childParentData.paintOffset.dx,
          geometry.paintExtent -
              child.geometry.paintExtent -
              childParentData.paintOffset.dy,
        );
        break;
      case AxisDirection.left:
        transform.translate(
          geometry.paintExtent -
              child.geometry.paintExtent -
              childParentData.paintOffset.dx,
          childParentData.paintOffset.dy,
        );
        break;
    }
  }

  @override
  double childScrollOffset(covariant RenderSliver child) {
    final parentData = child.parentData as SliverPhysicalContainerParentData;
    switch (constraints.axis) {
      case Axis.horizontal:
        return parentData.paintOffset.dx + constraints.scrollOffset;
      case Axis.vertical:
        return parentData.paintOffset.dy + constraints.scrollOffset;
    }
    throw FallThroughError();
  }

  @override
  double childMainAxisPosition(covariant RenderSliver child) {
    return _computeChildMainAxisPosition(child, constraints.scrollOffset);
  }
}
