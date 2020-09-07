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

  @override
  void paint(PaintingContext context, Offset offset) {
    Rect rect;
    switch (constraints.axis) {
      case Axis.horizontal:
        rect = Rect.fromLTWH(
          geometry.paintOrigin + (clipOverlap ? constraints.overlap : 0),
          0,
          geometry.paintExtent,
          constraints.crossAxisExtent,
        );
        break;
      case Axis.vertical:
        rect = Rect.fromLTWH(
          0,
          geometry.paintOrigin + (clipOverlap ? constraints.overlap : 0),
          constraints.crossAxisExtent,
          geometry.paintExtent,
        );
        break;
    }
    layer = context.pushClipRect(
      needsCompositing,
      offset,
      rect,
      super.paint,
      oldLayer: layer as ClipRectLayer,
    );
  }
}
