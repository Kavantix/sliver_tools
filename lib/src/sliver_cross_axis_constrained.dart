import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'rendering/sliver_cross_axis_positioned.dart';

/// Constrains and centers the [child] sliver to a maximum cross axis extent
/// specified by [maxCrossAxisExtent].
class SliverCrossAxisConstrained extends SingleChildRenderObjectWidget {
  const SliverCrossAxisConstrained({
    @required this.maxCrossAxisExtent,
    Key key,
    Widget child,
  })  : assert(maxCrossAxisExtent != null),
        super(key: key, child: child);

  /// Max allowed limit of the cross axis
  final double maxCrossAxisExtent;

  @override
  RenderSliverCrossAxisConstrained createRenderObject(BuildContext context) =>
      RenderSliverCrossAxisConstrained(maxCrossAxisExtent: maxCrossAxisExtent);

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

class RenderSliverCrossAxisConstrained extends RenderSliver
    with
        RenderObjectWithChildMixin<RenderSliver>,
        RenderSliverCrossAxisPositionedMixin {
  RenderSliverCrossAxisConstrained({
    double maxCrossAxisExtent,
    RenderSliver child,
  }) : _maxCrossAxisExtent = maxCrossAxisExtent {
    this.child = child;
  }

  /// Max allowed limit of the cross axis
  double get maxCrossAxisExtent => _maxCrossAxisExtent;
  double _maxCrossAxisExtent;
  set maxCrossAxisExtent(double value) {
    assert(value != null);
    assert(value > 0);
    if (_maxCrossAxisExtent == value) return;
    _maxCrossAxisExtent = value;
    markNeedsLayout();
  }

  @override
  SliverCrossAxisPositionedData createCrossAxisPositionData(
    SliverConstraints constraints,
  ) {
    final crossAxisExtent =
        min(constraints.crossAxisExtent, _maxCrossAxisExtent);
    return SliverCrossAxisPositionedData(
      crossAxisExtent: crossAxisExtent,
      crossAxisPosition: (constraints.crossAxisExtent - crossAxisExtent) / 2,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<double>('maxCrossAxisExtent', maxCrossAxisExtent));
  }
}
