import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class _SimpleSliverStackParentData extends StackParentData {
  final void Function(Offset value) onOffsetUpdated;

  _SimpleSliverStackParentData(this.onOffsetUpdated);
  @override
  set offset(Offset _offset) {
    super.offset = _offset;
    onOffsetUpdated(_offset);
  }
}

class SliverStackParentData extends ParentData
    with ContainerParentDataMixin<RenderObject> {
  /// The distance by which the child's top edge is inset from the top of the stack.
  double? top;

  /// The distance by which the child's right edge is inset from the right of the stack.
  double? right;

  /// The distance by which the child's bottom edge is inset from the bottom of the stack.
  double? bottom;

  /// The distance by which the child's left edge is inset from the left of the stack.
  double? left;

  /// The child's width.
  ///
  /// Ignored if both left and right are non-null.
  double? width;

  /// The child's height.
  ///
  /// Ignored if both top and bottom are non-null.
  double? height;

  /// Get or set the current values in terms of a RelativeRect object.
  RelativeRect get rect => RelativeRect.fromLTRB(left!, top!, right!, bottom!);
  set rect(RelativeRect value) {
    top = value.top;
    right = value.right;
    bottom = value.bottom;
    left = value.left;
  }

  Offset paintOffset = Offset.zero;

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
  AlignmentGeometry get positionedAlignment => _positionedAlignment!;
  AlignmentGeometry? _positionedAlignment;
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
  TextDirection get textDirection => _textDirection!;
  TextDirection? _textDirection;
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
  bool get insetOnOverlap => _insetOnOverlap!;
  bool? _insetOnOverlap;
  set insetOnOverlap(bool value) {
    if (_insetOnOverlap != value) {
      _insetOnOverlap = value;
      markNeedsLayout();
    }
  }

  Alignment? _alignment;

  Iterable<RenderObject> get _children sync* {
    RenderObject? child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  Iterable<RenderObject> get _childrenInHitTestOrder sync* {
    RenderObject? child = lastChild;
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
    double? minPaintOrigin;
    for (final child in _children.whereType<RenderSliver>()) {
      final parentData = child.parentData as SliverStackParentData;
      child.layout(constraints, parentUsesSize: true);
      final childGeometry = child.geometry!;
      if (childGeometry.scrollOffsetCorrection != null) {
        geometry = SliverGeometry(
            scrollOffsetCorrection: childGeometry.scrollOffsetCorrection);
        return;
      }
      minPaintOrigin = min(
        minPaintOrigin ?? double.infinity,
        childGeometry.paintOrigin,
      );
      maxScrollExtent = max(maxScrollExtent, childGeometry.scrollExtent);
      maxPaintExtent = max(maxPaintExtent, childGeometry.paintExtent);
      maxMaxPaintExtent = max(maxMaxPaintExtent, childGeometry.maxPaintExtent);
      maxLayoutExtent = max(maxLayoutExtent, childGeometry.layoutExtent);
      maxHitTestExtent = max(maxHitTestExtent, childGeometry.hitTestExtent);
      maxScrollObstructionExtent = max(
        maxScrollObstructionExtent,
        childGeometry.maxScrollObstructionExtent,
      );
      maxCacheExtent = max(maxCacheExtent, childGeometry.cacheExtent);
      hasVisualOverflow = hasVisualOverflow ||
          childGeometry.hasVisualOverflow ||
          childGeometry.paintOrigin < 0;
      parentData.mainAxisPosition = 0;
    }
    geometry = SliverGeometry(
      paintOrigin: minPaintOrigin ?? 0,
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
            geometry!.paintExtent -
                parentData.mainAxisPosition -
                child.geometry!.paintExtent,
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
            geometry!.paintExtent -
                parentData.mainAxisPosition -
                child.geometry!.paintExtent,
            0,
          );
          break;
      }
    }

    final size = constraints.axis == Axis.vertical
        ? Size(
            constraints.crossAxisExtent,
            max(geometry!.maxPaintExtent - overlapAndScroll,
                geometry!.paintExtent - overlap),
          )
        : Size(
            max(geometry!.maxPaintExtent - overlapAndScroll,
                geometry!.paintExtent - overlap),
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
            -geometry!.maxPaintExtent +
                min(geometry!.maxPaintExtent,
                    geometry!.paintExtent + constraints.scrollOffset) +
                parentData.paintOffset.dy,
          );
          parentData.mainAxisPosition = geometry!.paintExtent -
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
              -geometry!.maxPaintExtent +
                  min(geometry!.maxPaintExtent,
                      geometry!.paintExtent + constraints.scrollOffset) +
                  parentData.paintOffset.dx,
              parentData.paintOffset.dy);
          parentData.mainAxisPosition = geometry!.paintExtent -
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
    if (!geometry!.visible) return;
    for (final child in _children) {
      if (child is RenderSliver && child.geometry!.visible ||
          child is RenderBox) {
        final parentData = child.parentData as SliverStackParentData;
        context.paintChild(child, offset + parentData.paintOffset);
      }
    }
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    if (child is RenderSliver && child.geometry!.visible ||
        child is RenderBox) {
      final parentData = child.parentData as SliverStackParentData;
      transform.translate(parentData.paintOffset.dx, parentData.paintOffset.dy);
    }
  }

  double _computeChildMainAxisPosition(
      RenderObject child, double parentMainAxisPosition) {
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
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    final boxResult = BoxHitTestResult.wrap(result);
    for (final child in _childrenInHitTestOrder) {
      if (child is RenderSliver && child.geometry!.visible) {
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

class RenderSliverIndexedStack extends RenderSliverStack {
  int? get index => _index;
  int? _index;
  set index(int? value) {
    if (_index != value) {
      _index = value;
      markNeedsLayout();
    }
  }

  RenderObject? _findCurrentChild() {
    final index = this.index;
    if (index == null) return null;
    final children = _children.take(index + 1).toList();
    if (children.length >= index) return null;
    return children[index];
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    _findCurrentChild()?.visitChildrenForSemantics(visitor);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = _findCurrentChild();
    if (child == null) return;
    if (child is RenderSliver && child.geometry!.visible ||
        child is RenderBox) {
      final parentData = child.parentData as SliverStackParentData;
      context.paintChild(child, offset + parentData.paintOffset);
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    final child = _findCurrentChild();
    if (child == null) return false;
    if (child is RenderSliver && child.geometry!.visible) {
      return child.hitTest(
        result,
        mainAxisPosition:
            _computeChildMainAxisPosition(child, mainAxisPosition),
        crossAxisPosition: crossAxisPosition,
      );
    } else if (child is RenderBox) {
      final boxResult = BoxHitTestResult.wrap(result);
      return hitTestBoxChild(boxResult, child,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition);
    } else {
      return false;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
  }
}
