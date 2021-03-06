import 'package:flutter/widgets.dart';

import 'rendering/sliver_clip.dart';

/// [SliverClip] clips its sliver child from its paintOrigin to its paintExtent.
/// Also clips off any overlap if [clipOverlap] is `true`
class SliverClip extends SingleChildRenderObjectWidget {
  const SliverClip({
    Key? key,
    required Widget child,
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
