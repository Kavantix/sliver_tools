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

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// [SliverClip] clips its sliver child from its paintOrigin to its paintExtent.
/// Also clips off any overlap if [clipOverlap] is `true`
class SliverClip extends SingleChildRenderObjectWidget {
  const SliverClip({
    Key key,
    @required Widget child,
    this.clipOverlap = true,
  }) : super(key: key, child: child);

  /// Whether or not any overlap with previous slivers should be clipped
  /// default value is `true`
  final bool clipOverlap;

  @override
  RenderSliverClip createRenderObject(BuildContext context) {
    return RenderSliverClip(clipOverlap: clipOverlap);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverClip renderObject) {
    renderObject.clipOverlap = clipOverlap;
  }
}

class RenderSliverClip extends RenderProxySliver {
  RenderSliverClip({
    @required bool clipOverlap,
  }) : _clipOverlap = clipOverlap;

  bool _clipOverlap;

  /// Whether or not any overlap with previous slivers should be clipped
  /// default value is `true`
  bool get clipOverlap => _clipOverlap;
  set clipOverlap(bool value) {
    if (_clipOverlap != value) {
      _clipOverlap = value;
      markNeedsPaint();
    }
  }

  @visibleForTesting
  Rect get clipRect => _clipRect;
  Rect _clipRect;

  Rect calculateClipRect() {
    final axisDirection = applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection);
    Rect rect;
    final double overlapCorrection = (clipOverlap ? constraints.overlap : 0);
    switch (axisDirection) {
      case AxisDirection.up:
        rect = Rect.fromLTWH(
          0,
          0,
          constraints.crossAxisExtent,
          geometry.paintExtent - overlapCorrection,
        );
        break;
      case AxisDirection.right:
        rect = Rect.fromLTWH(
          geometry.paintOrigin + overlapCorrection,
          0,
          geometry.paintExtent - overlapCorrection,
          constraints.crossAxisExtent,
        );
        break;
      case AxisDirection.down:
        rect = Rect.fromLTWH(
          0,
          geometry.paintOrigin + overlapCorrection,
          constraints.crossAxisExtent,
          geometry.paintExtent - overlapCorrection,
        );
        break;
      case AxisDirection.left:
        rect = Rect.fromLTWH(
          0,
          0,
          geometry.paintExtent - overlapCorrection,
          constraints.crossAxisExtent,
        );
        break;
    }
    return rect;
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {double mainAxisPosition, double crossAxisPosition}) {
    final double overlapCorrection = (clipOverlap ? constraints.overlap : 0);
    return child != null &&
        child.geometry.hitTestExtent > 0 &&
        mainAxisPosition > (geometry.paintOrigin + overlapCorrection) &&
        mainAxisPosition <
            (geometry.paintOrigin +
                overlapCorrection +
                (constraints.axis == Axis.vertical
                    ? clipRect.height
                    : clipRect.width)) &&
        child.hitTest(
          result,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition,
        );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _clipRect = calculateClipRect();
    layer = context.pushClipRect(
      needsCompositing,
      offset,
      clipRect,
      super.paint,
      oldLayer: layer as ClipRectLayer,
    );
  }
}
