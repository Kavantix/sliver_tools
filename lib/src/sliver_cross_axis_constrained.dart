import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'rendering/sliver_cross_axis_constrained.dart';

/// Constrains and centers the [child] sliver to a maximum cross axis extent
/// specified by [maxCrossAxisExtent].
class SliverCrossAxisConstrained extends SingleChildRenderObjectWidget {
  const SliverCrossAxisConstrained({
    Key? key,
    required this.maxCrossAxisExtent,
    required Widget child,
  }) : super(key: key, child: child);

  /// Max allowed limit of the cross axis
  final double maxCrossAxisExtent;

  @override
  RenderSliverCrossAxisConstrained createRenderObject(BuildContext context) {
    final renderObject = RenderSliverCrossAxisConstrained();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverCrossAxisConstrained renderObject) {
    renderObject.maxCrossAxisExtent = maxCrossAxisExtent;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<double>('maxCrossAxisExtent', maxCrossAxisExtent));
  }
}
