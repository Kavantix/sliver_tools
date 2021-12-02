import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'rendering/sliver_stack.dart';

/// A [Stack] widget that can be used as a sliver
///
/// Its children can either be slivers or box children that are positioned
/// using [SliverPositioned] with at least one of its values not null
/// This means that only the sliver children have an effect on the size of
/// of this sliver and the box children are meant to follow the slivers
///
/// See also:
///
/// * [SliverIndexedStack], a variant of [SliverStack] where only the child
///   at a given index is dipslayed.
class SliverStack extends MultiChildRenderObjectWidget {
  SliverStack({
    Key? key,
    required List<Widget> children,
    this.textDirection,
    this.positionedAlignment = Alignment.center,
    this.insetOnOverlap = false,
  }) : super(key: key, children: children);

  /// The alignment to use on any positioned children that are only partially
  /// positioned
  ///
  /// Defaults to [Alignment.center]
  final AlignmentGeometry positionedAlignment;

  /// The text direction with which to resolve [positionedAlignment].
  ///
  /// Defaults to the ambient [Directionality].
  final TextDirection? textDirection;

  /// Whether the positioned children should be inset (made smaller) when the sliver has overlap.
  ///
  /// This is very useful and most likely what you want when using a pinned [SliverPersistentHeader]
  /// as child of the stack
  ///
  /// Defaults to false
  final bool insetOnOverlap;

  @override
  RenderSliverStack createRenderObject(BuildContext context) {
    final renderObject = RenderSliverStack();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverStack renderObject) {
    renderObject
      ..positionedAlignment = positionedAlignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..insetOnOverlap = insetOnOverlap;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AlignmentGeometry>(
      'positionedAlignment',
      positionedAlignment,
      defaultValue: Alignment.center,
    ));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection));
    properties.add(FlagProperty(
      'insetOnOverlap',
      value: insetOnOverlap,
      defaultValue: false,
    ));
  }
}

/// A widget that controls where a box child of a [SliverStack] is positioned.
///
/// A [SliverPositioned] widget must be a descendant of a [SliverStack], and the path from
/// the [SliverPositioned] widget to its enclosing [SliverStack] must contain only
/// [StatelessWidget]s or [StatefulWidget]s (not other kinds of widgets, like
/// [RenderObjectWidget]s).
class SliverPositioned extends ParentDataWidget<SliverStackParentData> {
  /// Creates a widget that controls where a child of a [Stack] is positioned.
  ///
  /// Only two out of the three horizontal values ([left], [right],
  /// [width]), and only two out of the three vertical values ([top],
  /// [bottom], [height]), can be set. In each case, at least one of
  /// the three must be null.
  ///
  /// See also:
  ///
  ///  * [Positioned.directional], which specifies the widget's horizontal
  ///    position using `start` and `end` rather than `left` and `right`.
  ///  * [PositionedDirectional], which is similar to [Positioned.directional]
  ///    but adapts to the ambient [Directionality].
  const SliverPositioned({
    Key? key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    required Widget child,
  })  : assert(left == null || right == null || width == null),
        assert(top == null || bottom == null || height == null),
        super(key: key, child: child);

  /// Creates a Positioned object with the values from the given [Rect].
  ///
  /// This sets the [left], [top], [width], and [height] properties
  /// from the given [Rect]. The [right] and [bottom] properties are
  /// set to null.
  SliverPositioned.fromRect({
    Key? key,
    required Rect rect,
    required Widget child,
  })  : left = rect.left,
        top = rect.top,
        width = rect.width,
        height = rect.height,
        right = null,
        bottom = null,
        super(key: key, child: child);

  /// Creates a Positioned object with the values from the given [RelativeRect].
  ///
  /// This sets the [left], [top], [right], and [bottom] properties from the
  /// given [RelativeRect]. The [height] and [width] properties are set to null.
  SliverPositioned.fromRelativeRect({
    Key? key,
    required RelativeRect rect,
    required Widget child,
  })  : left = rect.left,
        top = rect.top,
        right = rect.right,
        bottom = rect.bottom,
        width = null,
        height = null,
        super(key: key, child: child);

  /// Creates a Positioned object with [left], [top], [right], and [bottom] set
  /// to 0.0 unless a value for them is passed.
  const SliverPositioned.fill({
    Key? key,
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    required Widget child,
  })  : width = null,
        height = null,
        super(key: key, child: child);

  /// Creates a widget that controls where a child of a [Stack] is positioned.
  ///
  /// Only two out of the three horizontal values (`start`, `end`,
  /// [width]), and only two out of the three vertical values ([top],
  /// [bottom], [height]), can be set. In each case, at least one of
  /// the three must be null.
  ///
  /// If `textDirection` is [TextDirection.rtl], then the `start` argument is
  /// used for the [right] property and the `end` argument is used for the
  /// [left] property. Otherwise, if `textDirection` is [TextDirection.ltr],
  /// then the `start` argument is used for the [left] property and the `end`
  /// argument is used for the [right] property.
  ///
  /// The `textDirection` argument must not be null.
  ///
  /// See also:
  ///
  ///  * [PositionedDirectional], which adapts to the ambient [Directionality].
  factory SliverPositioned.directional({
    Key? key,
    required TextDirection textDirection,
    double? start,
    double? top,
    double? end,
    double? bottom,
    double? width,
    double? height,
    required Widget child,
  }) {
    double? left;
    double? right;
    switch (textDirection) {
      case TextDirection.rtl:
        left = end;
        right = start;
        break;
      case TextDirection.ltr:
        left = start;
        right = end;
        break;
    }
    return SliverPositioned(
      key: key,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  /// The distance that the child's left edge is inset from the left of the stack.
  ///
  /// Only two out of the three horizontal values ([left], [right], [width]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// horizontally.
  final double? left;

  /// The distance that the child's top edge is inset from the top of the stack.
  ///
  /// Only two out of the three vertical values ([top], [bottom], [height]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// vertically.
  final double? top;

  /// The distance that the child's right edge is inset from the right of the stack.
  ///
  /// Only two out of the three horizontal values ([left], [right], [width]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// horizontally.
  final double? right;

  /// The distance that the child's bottom edge is inset from the bottom of the stack.
  ///
  /// Only two out of the three vertical values ([top], [bottom], [height]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// vertically.
  final double? bottom;

  /// The child's width.
  ///
  /// Only two out of the three horizontal values ([left], [right], [width]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// horizontally.
  final double? width;

  /// The child's height.
  ///
  /// Only two out of the three vertical values ([top], [bottom], [height]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// vertically.
  final double? height;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is SliverStackParentData);
    final parentData = renderObject.parentData as SliverStackParentData;
    bool needsLayout = false;

    if (parentData.left != left) {
      parentData.left = left;
      needsLayout = true;
    }

    if (parentData.top != top) {
      parentData.top = top;
      needsLayout = true;
    }

    if (parentData.right != right) {
      parentData.right = right;
      needsLayout = true;
    }

    if (parentData.bottom != bottom) {
      parentData.bottom = bottom;
      needsLayout = true;
    }

    if (parentData.width != width) {
      parentData.width = width;
      needsLayout = true;
    }

    if (parentData.height != height) {
      parentData.height = height;
      needsLayout = true;
    }

    if (needsLayout) {
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('left', left, defaultValue: null));
    properties.add(DoubleProperty('top', top, defaultValue: null));
    properties.add(DoubleProperty('right', right, defaultValue: null));
    properties.add(DoubleProperty('bottom', bottom, defaultValue: null));
    properties.add(DoubleProperty('width', width, defaultValue: null));
    properties.add(DoubleProperty('height', height, defaultValue: null));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SliverStack;
}

/// A [SliverStack] that shows a single child from a list of children.
///
/// The displayed child is the one with the given [index]. The stack is
/// always as big as the largest child.
/// This also means that all children are always layed out meaning there
/// is a performance impact for every child.
///
/// If value is null, then nothing is displayed.
///
/// See also:
///
/// * [SliverStack], for more details about how the SliverStack works
class SliverIndexedStack extends MultiChildRenderObjectWidget {
  SliverIndexedStack({
    Key? key,
    required List<Widget> children,
    this.index = 0,
    this.textDirection,
    this.positionedAlignment = Alignment.center,
    this.insetOnOverlap = false,
  })  : assert(index == null || (index >= 0 && index < children.length),
            'Index should be a valid index into the list of children'),
        super(key: key, children: children);

  /// The index of the child to show.
  final int? index;

  /// The alignment to use on any positioned children that are only partially
  /// positioned
  ///
  /// Defaults to [Alignment.center]
  final AlignmentGeometry positionedAlignment;

  /// The text direction with which to resolve [positionedAlignment].
  ///
  /// Defaults to the ambient [Directionality].
  final TextDirection? textDirection;

  /// Whether the positioned children should be inset (made smaller) when the sliver has overlap.
  ///
  /// This is very useful and most likely what you want when using a pinned [SliverPersistentHeader]
  /// as child of the stack
  ///
  /// Defaults to false
  final bool insetOnOverlap;

  @override
  RenderSliverIndexedStack createRenderObject(BuildContext context) {
    final renderObject = RenderSliverIndexedStack();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverIndexedStack renderObject) {
    renderObject
      ..positionedAlignment = positionedAlignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..insetOnOverlap = insetOnOverlap
      ..index = index;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
  }
}
