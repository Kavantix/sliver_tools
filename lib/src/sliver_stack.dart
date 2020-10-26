// The MIT License (MIT)
//
// Copyright (c) 2020 Pieter van Loon
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A [Stack] widget that can be used as a sliver
///
/// Its children can either be slivers or box children that are positioned
/// using [SliverPositioned] with at least one of its values not null
/// This means that only the sliver children have an effect on the size of
/// of this sliver and the box children are meant to follow the slivers
class SliverStack extends MultiChildRenderObjectWidget {
  SliverStack({
    Key key,
    @required List<Widget> children,
    this.positionedAlignment = Alignment.center,
    this.textDirection,
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
  final TextDirection textDirection;

  /// Whether the positioned children should be inset (made smaller) when the sliver has overlap.
  ///
  /// This is very useful and most likely what you want when using a pinned [SliverPersistentHeader]
  /// as child of the stack
  ///
  /// Defaults to false
  final bool insetOnOverlap;

  @override
  RenderSliverStack createRenderObject(BuildContext context) {
    return RenderSliverStack()
      ..positionedAlignment = positionedAlignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..insetOnOverlap = insetOnOverlap;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverStack renderObject) {
    renderObject
      ..positionedAlignment = positionedAlignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..insetOnOverlap = insetOnOverlap;
  }
}

class _SimpleSliverStackParentData extends StackParentData {
  final void Function(Offset value) onOffsetUpdated;

  _SimpleSliverStackParentData(this.onOffsetUpdated);
  @override
  set offset(Offset _offset) {
    super.offset = _offset;
    onOffsetUpdated(_offset);
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
    Key key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    @required Widget child,
  })  : assert(left == null || right == null || width == null),
        assert(top == null || bottom == null || height == null),
        super(key: key, child: child);

  /// Creates a Positioned object with the values from the given [Rect].
  ///
  /// This sets the [left], [top], [width], and [height] properties
  /// from the given [Rect]. The [right] and [bottom] properties are
  /// set to null.
  SliverPositioned.fromRect({
    Key key,
    Rect rect,
    @required Widget child,
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
    Key key,
    RelativeRect rect,
    @required Widget child,
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
    Key key,
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    @required Widget child,
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
    Key key,
    @required TextDirection textDirection,
    double start,
    double top,
    double end,
    double bottom,
    double width,
    double height,
    @required Widget child,
  }) {
    assert(textDirection != null);
    double left;
    double right;
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
  final double left;

  /// The distance that the child's top edge is inset from the top of the stack.
  ///
  /// Only two out of the three vertical values ([top], [bottom], [height]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// vertically.
  final double top;

  /// The distance that the child's right edge is inset from the right of the stack.
  ///
  /// Only two out of the three horizontal values ([left], [right], [width]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// horizontally.
  final double right;

  /// The distance that the child's bottom edge is inset from the bottom of the stack.
  ///
  /// Only two out of the three vertical values ([top], [bottom], [height]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// vertically.
  final double bottom;

  /// The child's width.
  ///
  /// Only two out of the three horizontal values ([left], [right], [width]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// horizontally.
  final double width;

  /// The child's height.
  ///
  /// Only two out of the three vertical values ([top], [bottom], [height]) can be
  /// set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// vertically.
  final double height;

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
      final AbstractNode targetParent = renderObject.parent;
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

class SliverStackParentData extends ParentData
    with ContainerParentDataMixin<RenderObject> {
  /// The distance by which the child's top edge is inset from the top of the stack.
  double top;

  /// The distance by which the child's right edge is inset from the right of the stack.
  double right;

  /// The distance by which the child's bottom edge is inset from the bottom of the stack.
  double bottom;

  /// The distance by which the child's left edge is inset from the left of the stack.
  double left;

  /// The child's width.
  ///
  /// Ignored if both left and right are non-null.
  double width;

  /// The child's height.
  ///
  /// Ignored if both top and bottom are non-null.
  double height;

  /// Get or set the current values in terms of a RelativeRect object.
  RelativeRect get rect => RelativeRect.fromLTRB(left, top, right, bottom);
  set rect(RelativeRect value) {
    top = value.top;
    right = value.right;
    bottom = value.bottom;
    left = value.left;
  }

  Offset paintOffset;

  double mainAxisPosition = 0;
  double crossAxisPosition = 0;

  /// Whether this child is considered positioned.
  ///
  /// A child is positioned if any of the top, right, bottom, or left properties
  /// are non-null. Positioned children do not factor into determining the size
  /// of the stack but are instead placed relative to the non-positioned
  /// children in the stack.
  bool get isPositioned =>
      top != null ||
      right != null ||
      bottom != null ||
      left != null ||
      width != null ||
      height != null;

  @override
  String toString() {
    final List<String> values = <String>[
      if (top != null) 'top=${debugFormatDouble(top)}',
      if (right != null) 'right=${debugFormatDouble(right)}',
      if (bottom != null) 'bottom=${debugFormatDouble(bottom)}',
      if (left != null) 'left=${debugFormatDouble(left)}',
      if (width != null) 'width=${debugFormatDouble(width)}',
      if (height != null) 'height=${debugFormatDouble(height)}',
    ];
    if (values.isEmpty) values.add('not positioned');
    values.add(super.toString());
    return values.join('; ');
  }

  _SimpleSliverStackParentData get simpleStackParentData =>
      _SimpleSliverStackParentData((value) => paintOffset = value)
        ..top = top
        ..right = right
        ..bottom = bottom
        ..left = left
        ..width = width
        ..height = height
        ..offset = paintOffset;
}

class RenderSliverStack extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>>,
        RenderSliverHelpers {
  /// The alignment to use on any positioned children that are only partially
  /// positioned
  /// Defaults to [Alignment.center]
  AlignmentGeometry get positionedAlignment => _positionedAlignment;
  AlignmentGeometry _positionedAlignment;
  set positionedAlignment(AlignmentGeometry value) {
    if (_positionedAlignment != value) {
      _positionedAlignment = value;
      markNeedsLayout();
    }
  }

  /// The text direction with which to resolve [alignment].
  ///
  /// This may be changed to null, but only after the [alignment] has been changed
  /// to a value that does not depend on the direction.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      _alignment = null;
      markNeedsLayout();
    }
  }

  /// Whether the positioned children should be inset (made smaller) when the sliver has overlap.
  ///
  /// This is very useful and most likely what you want when using a pinned [SliverPersistentHeader]
  /// as child of the stack
  ///
  /// Defaults to false
  bool get insetOnOverlap => _insetOnOverlap;
  bool _insetOnOverlap;
  set insetOnOverlap(bool value) {
    if (_insetOnOverlap != value) {
      _insetOnOverlap = value;
      markNeedsLayout();
    }
  }

  Alignment _alignment;

  Iterable<RenderObject> get _children sync* {
    RenderObject child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  Iterable<RenderObject> get _childrenInHitTestOrder sync* {
    RenderObject child = lastChild;
    while (child != null) {
      yield child;
      child = childBefore(child);
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = SliverStackParentData();
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final axisDirection = applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection);
    final double overlapAndScroll = insetOnOverlap
        ? max(0.0, constraints.overlap + constraints.scrollOffset)
        : 0;
    final overlap = insetOnOverlap ? max(0.0, constraints.overlap) : 0;

    bool hasVisualOverflow = false;
    double maxScrollExtent = 0;
    double maxPaintExtent = 0;
    double maxMaxPaintExtent = 0;
    double maxLayoutExtent = 0;
    double maxHitTestExtent = 0;
    double maxScrollObstructionExtent = 0;
    double maxCacheExtent = 0;
    double minPaintOrigin;
    for (final child in _children.whereType<RenderSliver>()) {
      final parentData = child.parentData as SliverStackParentData;
      child.layout(constraints, parentUsesSize: true);
      if (child.geometry.scrollOffsetCorrection != null) {
        geometry = SliverGeometry(
            scrollOffsetCorrection: child.geometry.scrollOffsetCorrection);
        return;
      }
      minPaintOrigin =
          min(minPaintOrigin ?? double.infinity, child.geometry.paintOrigin);
      maxScrollExtent = max(maxScrollExtent, child.geometry.scrollExtent);
      maxPaintExtent = max(maxPaintExtent, child.geometry.paintExtent);
      maxMaxPaintExtent = max(maxMaxPaintExtent, child.geometry.maxPaintExtent);
      maxLayoutExtent = max(maxLayoutExtent, child.geometry.layoutExtent);
      maxHitTestExtent = max(maxHitTestExtent, child.geometry.hitTestExtent);
      maxScrollObstructionExtent = max(maxScrollObstructionExtent,
          child.geometry.maxScrollObstructionExtent);
      maxCacheExtent = max(maxCacheExtent, child.geometry.cacheExtent);
      hasVisualOverflow = hasVisualOverflow ||
          child.geometry.hasVisualOverflow ||
          child.geometry.paintOrigin < 0;
      parentData.mainAxisPosition = 0;
    }
    geometry = SliverGeometry(
      paintOrigin: minPaintOrigin,
      scrollExtent: maxScrollExtent,
      paintExtent: maxPaintExtent,
      maxPaintExtent: maxMaxPaintExtent,
      layoutExtent: maxLayoutExtent,
      hitTestExtent: maxHitTestExtent,
      maxScrollObstructionExtent: maxScrollObstructionExtent,
      cacheExtent: maxCacheExtent,
      hasVisualOverflow: hasVisualOverflow,
    );
    for (final child in _children.whereType<RenderSliver>()) {
      final parentData = child.parentData as SliverStackParentData;
      switch (axisDirection) {
        case AxisDirection.up:
          parentData.paintOffset = Offset(
            0,
            geometry.paintExtent -
                parentData.mainAxisPosition -
                child.geometry.paintExtent,
          );
          break;
        case AxisDirection.right:
          parentData.paintOffset = Offset(parentData.mainAxisPosition, 0);
          break;
        case AxisDirection.down:
          parentData.paintOffset = Offset(0, parentData.mainAxisPosition);
          break;
        case AxisDirection.left:
          parentData.paintOffset = Offset(
            geometry.paintExtent -
                parentData.mainAxisPosition -
                child.geometry.paintExtent,
            0,
          );
          break;
      }
    }

    final size = constraints.axis == Axis.vertical
        ? Size(
            constraints.crossAxisExtent,
            max(geometry.maxPaintExtent - overlapAndScroll,
                geometry.paintExtent - overlap),
          )
        : Size(
            max(geometry.maxPaintExtent - overlapAndScroll,
                geometry.paintExtent - overlap),
            constraints.crossAxisExtent,
          );
    for (final child in _children.whereType<RenderBox>()) {
      final parentData = child.parentData as SliverStackParentData;
      assert(parentData.isPositioned,
          'All non sliver children of SliverStack should be positioned');
      if (!parentData.isPositioned) return;
      child.parentData = parentData.simpleStackParentData;
      final overflows = RenderStack.layoutPositionedChild(
        child,
        child.parentData as StackParentData,
        size,
        _alignment ??= positionedAlignment.resolve(textDirection),
      );
      child.parentData = parentData;
      final paintOffset = constraints.scrollOffset - overlapAndScroll;
      switch (axisDirection) {
        case AxisDirection.up:
          parentData.paintOffset = Offset(
            parentData.paintOffset.dx,
            -geometry.maxPaintExtent +
                min(geometry.maxPaintExtent,
                    geometry.paintExtent + constraints.scrollOffset) +
                parentData.paintOffset.dy,
          );
          parentData.mainAxisPosition = geometry.paintExtent -
              parentData.paintOffset.dy -
              child.size.height;
          parentData.crossAxisPosition = parentData.paintOffset.dx;
          break;
        case AxisDirection.right:
          parentData.paintOffset =
              parentData.paintOffset - Offset(paintOffset, 0);
          parentData.mainAxisPosition = parentData.paintOffset.dx;
          parentData.crossAxisPosition = parentData.paintOffset.dy;
          break;
        case AxisDirection.down:
          parentData.paintOffset =
              parentData.paintOffset - Offset(0, paintOffset);
          parentData.mainAxisPosition = parentData.paintOffset.dy;
          parentData.crossAxisPosition = parentData.paintOffset.dx;
          break;
        case AxisDirection.left:
          parentData.paintOffset = Offset(
              -geometry.maxPaintExtent +
                  min(geometry.maxPaintExtent,
                      geometry.paintExtent + constraints.scrollOffset) +
                  parentData.paintOffset.dx,
              parentData.paintOffset.dy);
          parentData.mainAxisPosition = geometry.paintExtent -
              parentData.paintOffset.dx -
              child.size.width;
          parentData.crossAxisPosition = parentData.paintOffset.dy;
          break;
      }
      hasVisualOverflow = hasVisualOverflow || overflows;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!geometry.visible) return;
    for (final child in _children) {
      if (child is RenderSliver && child.geometry.visible ||
          child is RenderBox) {
        final parentData = child.parentData as SliverStackParentData;
        context.paintChild(child, offset + parentData.paintOffset);
      }
    }
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    if (child is RenderSliver && child.geometry.visible || child is RenderBox) {
      final parentData = child.parentData as SliverStackParentData;
      transform.translate(parentData.paintOffset.dx, parentData.paintOffset.dy);
    }
  }

  double _computeChildMainAxisPosition(
      RenderObject child, double parentMainAxisPosition) {
    assert(child != null);
    final childParentData = child.parentData as SliverStackParentData;
    return parentMainAxisPosition - childParentData.mainAxisPosition;
  }

  @override
  double childMainAxisPosition(covariant RenderObject child) {
    final childParentData = child.parentData as SliverStackParentData;
    return childParentData.mainAxisPosition;
  }

  @override
  double childCrossAxisPosition(covariant RenderObject child) {
    final childParentData = child.parentData as SliverStackParentData;
    return childParentData.crossAxisPosition;
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    @required double mainAxisPosition,
    @required double crossAxisPosition,
  }) {
    assert(mainAxisPosition != null);
    assert(crossAxisPosition != null);
    final boxResult = BoxHitTestResult.wrap(result);
    for (final child in _childrenInHitTestOrder) {
      if (child is RenderSliver && child.geometry.visible) {
        final hit = child.hitTest(
          result,
          mainAxisPosition:
              _computeChildMainAxisPosition(child, mainAxisPosition),
          crossAxisPosition: crossAxisPosition,
        );
        if (hit) return true;
      } else if (child is RenderBox) {
        hitTestBoxChild(boxResult, child,
            mainAxisPosition: mainAxisPosition,
            crossAxisPosition: crossAxisPosition);
      }
    }
    return false;
  }
}
