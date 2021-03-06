import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class RenderSliverClip extends RenderProxySliver {
  RenderSliverClip({
    required bool clipOverlap,
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
  Rect? get clipRect => _clipRect;
  Rect? _clipRect;

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
          geometry!.paintExtent - overlapCorrection,
        );
        break;
      case AxisDirection.right:
        rect = Rect.fromLTWH(
          geometry!.paintOrigin + overlapCorrection,
          0,
          geometry!.paintExtent - overlapCorrection,
          constraints.crossAxisExtent,
        );
        break;
      case AxisDirection.down:
        rect = Rect.fromLTWH(
          0,
          geometry!.paintOrigin + overlapCorrection,
          constraints.crossAxisExtent,
          geometry!.paintExtent - overlapCorrection,
        );
        break;
      case AxisDirection.left:
        rect = Rect.fromLTWH(
          0,
          0,
          geometry!.paintExtent - overlapCorrection,
          constraints.crossAxisExtent,
        );
        break;
    }
    return rect;
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    final double overlapCorrection = (clipOverlap ? constraints.overlap : 0);
    return child != null &&
        child!.geometry!.hitTestExtent > 0 &&
        mainAxisPosition > (geometry!.paintOrigin + overlapCorrection) &&
        mainAxisPosition <
            (geometry!.paintOrigin +
                overlapCorrection +
                (constraints.axis == Axis.vertical
                    ? clipRect!.height
                    : clipRect!.width)) &&
        child!.hitTest(
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
      clipRect!,
      super.paint,
      oldLayer: layer as ClipRectLayer?,
    );
  }
}
