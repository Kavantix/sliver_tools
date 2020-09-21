import 'package:flutter/widgets.dart';

import 'rendering/sliver_pinned_header.dart';

/// [SliverPinnedHeader] keeps its child pinned to the leading edge of the viewport.
class SliverPinnedHeader extends SingleChildRenderObjectWidget {
  const SliverPinnedHeader({
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderSliverPinnedHeader createRenderObject(BuildContext context) {
    return RenderSliverPinnedHeader();
  }
}
