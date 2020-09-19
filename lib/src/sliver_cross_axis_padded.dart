import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'rendering/sliver_cross_axis_positioned.dart';

/// Constrains and centers the [child] sliver to a maximum cross axis extent
/// specified by [paddingStart].
class SliverCrossAxisPadded extends SingleChildRenderObjectWidget {
  const SliverCrossAxisPadded({
    Key key,
    this.paddingStart = 0.0,
    this.paddingEnd = 0.0,
    this.textDirection,
    @required Widget child,
  })  : assert(paddingStart != null && paddingEnd != null),
        super(key: key, child: child);

  factory SliverCrossAxisPadded.symmetric({
    Key key,
    @required double padding,
    @required Widget child,
  }) =>
      SliverCrossAxisPadded(
        key: key,
        paddingStart: padding,
        paddingEnd: padding,
        child: child,
      );

  /// The padding for the start of the cross axis
  /// For a horizontal layout this means the top, vertical layout it depends on the [TextDirection]
  final double paddingStart;

  /// The padding for the end of the cross axis
  /// For a horizontal layout this means the bottom, vertical layout it depends on the [TextDirection]
  final double paddingEnd;

  /// The text direction with which to resolve the padding when axis is vertical.
  final TextDirection textDirection;

  @override
  RenderSliverCrossAxisPadded createRenderObject(BuildContext context) =>
      RenderSliverCrossAxisPadded()
        ..textDirection = textDirection ?? Directionality.of(context)
        ..paddingStart = paddingStart
        ..paddingEnd = paddingEnd;

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverCrossAxisPadded renderObject,
  ) {
    renderObject
      ..textDirection = textDirection ?? Directionality.of(context)
      ..paddingStart = paddingStart
      ..paddingEnd = paddingEnd;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<double>('maxCrossAxisExtent', paddingStart));
  }
}

class RenderSliverCrossAxisPadded extends RenderSliver
    with
        RenderObjectWithChildMixin<RenderSliver>,
        RenderSliverCrossAxisPositionedMixin {
  /// The text direction with which to resolve the padding when axis is vertical.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  /// The padding for the start of the cross axis
  /// For a horizontal layout this means the top, vertical layout it depends on the [TextDirection]
  double get paddingStart => _paddingStart;
  double _paddingStart;
  set paddingStart(double value) {
    assert(value != null);
    assert(value >= 0);
    if (_paddingStart == value) return;
    _paddingStart = value;
    markNeedsLayout();
  }

  /// The padding for the end of the cross axis
  /// For a horizontal layout this means the bottom, vertical layout it depends on the [TextDirection]
  double get paddingEnd => _paddingEnd;
  double _paddingEnd;
  set paddingEnd(double value) {
    assert(value != null);
    assert(value >= 0);
    if (_paddingEnd == value) return;
    _paddingEnd = value;
    markNeedsLayout();
  }

  @override
  SliverCrossAxisPositionedData createCrossAxisPositionData(
    SliverConstraints constraints,
  ) {
    assert(constraints.crossAxisExtent - _paddingStart - _paddingEnd > 0,
        'The total padding exceeds the crossAxisExtent of this sliver');
    final crossAxisExtent = max(
      0.0,
      constraints.crossAxisExtent - _paddingStart - paddingEnd,
    );
    double crossAxisPosition;
    switch (constraints.axis) {
      case Axis.vertical:
        crossAxisPosition =
            textDirection == TextDirection.ltr ? _paddingStart : _paddingEnd;
        break;
      case Axis.horizontal:
        crossAxisPosition = _paddingStart;
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
