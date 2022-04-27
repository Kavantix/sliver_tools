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

  /// How to align the sliver in the cross axis
  /// 0 means center -1 means to the left +1 means to the right
  double get alignment => _alignment!;
  double? _alignment;
  set alignment(double value) {
    assert(value >= -1.0);
    assert(value <= 1.0);
    if (_alignment != value) {
      _alignment = value;
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
      crossAxisPosition: (alignment + 1) *
          ((constraints.crossAxisExtent - crossAxisExtent) / 2),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<double>('maxCrossAxisExtent', maxCrossAxisExtent));
  }
}
