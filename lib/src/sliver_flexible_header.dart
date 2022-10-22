import 'package:flutter/widgets.dart';

import 'rendering/sliver_flexible_header.dart';

/// [SliverFlexibleHeader] behaves similarly to [SliverPinnedHeader] but through `floating`
/// parameter, triggers the feature to hide when scrolling down and show when scrolling up.
class SliverFlexibleHeader extends SingleChildRenderObjectWidget {
  const SliverFlexibleHeader({
    Key? key,
    required Widget child,
    this.floating = false,
  }) : super(key: key, child: child);

  final bool floating;

  @override
  RenderSliverFlexibleHeader createRenderObject(BuildContext context) {
    return RenderSliverFlexibleHeader(floating: floating);
  }
}
