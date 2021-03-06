import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'rendering/sliver_cross_axis_padded.dart';

/// Constrains and centers the [child] sliver to a maximum cross axis extent
/// specified by [paddingStart].
class SliverCrossAxisPadded extends SingleChildRenderObjectWidget {
  const SliverCrossAxisPadded({
    Key? key,
    this.paddingStart = 0.0,
    this.paddingEnd = 0.0,
    this.textDirection,
    required Widget child,
  }) : super(key: key, child: child);

  factory SliverCrossAxisPadded.symmetric({
    Key? key,
    required double padding,
    required Widget child,
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
  final TextDirection? textDirection;

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
