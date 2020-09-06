import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SliverClip extends SingleChildRenderObjectWidget {
  const SliverClip({Key key, @required Widget child})
      : super(key: key, child: child);

  @override
  RenderSliverClip createRenderObject(BuildContext context) {
    return RenderSliverClip();
  }
}

class RenderSliverClip extends RenderProxySliver {
  @override
  void paint(PaintingContext context, Offset offset) {
    Rect rect;
    switch (constraints.axis) {
      case Axis.horizontal:
        rect = Rect.fromLTWH(geometry.paintOrigin + constraints.overlap, 0,
            geometry.paintExtent, constraints.crossAxisExtent);
        break;
      case Axis.vertical:
        rect = Rect.fromLTWH(0, geometry.paintOrigin + constraints.overlap,
            constraints.crossAxisExtent, geometry.paintExtent);
        break;
    }
    layer = context.pushClipRect(needsCompositing, offset, rect, super.paint,
        oldLayer: layer as ClipRectLayer);
  }
}
