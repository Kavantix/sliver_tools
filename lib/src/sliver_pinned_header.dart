import 'package:flutter/widgets.dart';

import 'rendering/sliver_pinned_header.dart';

/// Used by [SliverPinnedHeader.builder] widget.
typedef OverlappedWidgetBuilder = Widget Function(BuildContext context, bool overlapped);

/// [SliverPinnedHeader] keeps its child pinned to the leading edge of the viewport.
/// There are two options for constructing a [SliverPinnedHeader] :
///  1. The default constructor takes an explicit [Widget] child.
///  2.  The [SliverPinnedHeader.builder] constructor takes an [OverlappedWidgetBuilder]
///  which indicates when the [CustomScrollView] is overlapped.
class SliverPinnedHeader extends SingleChildRenderObjectWidget {
  const SliverPinnedHeader({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  static Widget builder(OverlappedWidgetBuilder builder) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        return SliverPinnedHeader(
          child: builder(context, constraints.overlap > 0.0),
        );
      },
    );
  }

  @override
  RenderSliverPinnedHeader createRenderObject(BuildContext context) {
    return RenderSliverPinnedHeader();
  }
}
