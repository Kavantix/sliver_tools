import 'dart:math';

import 'package:flutter/rendering.dart';

import 'sliver_cross_axis_positioned.dart';

class RenderSliverCrossAxisPadded extends RenderSliver
    with
        RenderObjectWithChildMixin<RenderSliver>,
        RenderSliverCrossAxisPositionedMixin {
  /// The text direction with which to resolve the padding when axis is vertical.
  TextDirection get textDirection => _textDirection!;
  TextDirection? _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  /// The padding for the start of the cross axis
  /// For a horizontal layout this means the top, vertical layout it depends on the [TextDirection]
  double get paddingStart => _paddingStart!;
  double? _paddingStart;
  set paddingStart(double value) {
    assert(value >= 0);
    if (_paddingStart == value) return;
    _paddingStart = value;
    markNeedsLayout();
  }

  /// The padding for the end of the cross axis
  /// For a horizontal layout this means the bottom, vertical layout it depends on the [TextDirection]
  double get paddingEnd => _paddingEnd!;
  double? _paddingEnd;
  set paddingEnd(double value) {
    assert(value >= 0);
    if (_paddingEnd == value) return;
    _paddingEnd = value;
    markNeedsLayout();
  }

  @override
  SliverCrossAxisPositionedData createCrossAxisPositionData(
    SliverConstraints constraints,
  ) {
    assert(constraints.crossAxisExtent - paddingStart - paddingEnd > 0,
        'The total padding exceeds the crossAxisExtent of this sliver');
    final crossAxisExtent = max(
      0.0,
      constraints.crossAxisExtent - paddingStart - paddingEnd,
    );
    double crossAxisPosition;
    switch (constraints.axis) {
      case Axis.vertical:
        crossAxisPosition =
            textDirection == TextDirection.ltr ? paddingStart : paddingEnd;
        break;
      case Axis.horizontal:
        crossAxisPosition = paddingStart;
        break;
    }
    return SliverCrossAxisPositionedData(
      crossAxisExtent: crossAxisExtent,
      crossAxisPosition: crossAxisPosition,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<double>('paddingStart', paddingStart))
      ..add(DiagnosticsProperty<double>('paddingEnd', paddingEnd))
      ..add(DiagnosticsProperty<TextDirection>('textDirection', textDirection));
  }
}
