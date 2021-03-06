import 'dart:math';

import 'package:flutter/rendering.dart';

import 'sliver_cross_axis_positioned.dart';

class RenderSliverCrossAxisConstrained extends RenderSliver
    with
        RenderObjectWithChildMixin<RenderSliver>,
        RenderSliverCrossAxisPositionedMixin {
  /// Max allowed limit of the cross axis
  double get maxCrossAxisExtent => _maxCrossAxisExtent!;
  double? _maxCrossAxisExtent;
  set maxCrossAxisExtent(double value) {
    assert(value > 0);
    if (_maxCrossAxisExtent != value) {
      _maxCrossAxisExtent = value;
      markNeedsLayout();
    }
  }

  @override
  SliverCrossAxisPositionedData createCrossAxisPositionData(
    SliverConstraints constraints,
  ) {
    final crossAxisExtent = min(
      constraints.crossAxisExtent,
      maxCrossAxisExtent,
    );
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
