import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'sliver_stack.dart';

/// ------------------ NOTICE ---------------------
/// This widget is not finished and thus subject to change
/// -----------------------------------------------
class SliverTabView extends StatelessWidget {
  const SliverTabView({
    Key? key,
    required this.children,
    required this.horizontalController,
    this.precedingPinnedExtent = 0.0,
  }) : super(key: key);

  final List<Widget> children;
  final TabController horizontalController;
  final double precedingPinnedExtent;

  @override
  Widget build(BuildContext context) {
    return SliverStack(
      children: [
        SliverPositioned.fill(
          child: TabBarView(
            physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
            controller: horizontalController,
            children: [
              for (var i = 0; i < children.length; i++) Container(),
            ],
          ),
        ),
        _SliverTranslucentHitTester(
          child: _SliverTabView(
            horizontalController: horizontalController,
            precedingPinnedExtent: precedingPinnedExtent,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SliverTranslucentHitTester extends SingleChildRenderObjectWidget {
  const _SliverTranslucentHitTester({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  _RenderSliverTranslucentHitTester createRenderObject(BuildContext context) {
    return _RenderSliverTranslucentHitTester();
  }
}

class _RenderSliverTranslucentHitTester extends RenderProxySliver {
  @override
  bool hitTest(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    super.hitTest(
      result,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
    );
    // Always return false so it acts like transluesent hit testing
    return false;
  }
}

class _SliverTabView extends MultiChildRenderObjectWidget {
  _SliverTabView({
    Key? key,
    required List<Widget> children,
    required this.horizontalController,
    required this.precedingPinnedExtent,
  }) : super(key: key, children: children);

  final TabController horizontalController;
  final double precedingPinnedExtent;

  @override
  RenderSliverTabView createRenderObject(BuildContext context) {
    final renderObject = RenderSliverTabView();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverTabView renderObject) {
    renderObject
      ..horizontalController = horizontalController
      ..precedingPinnedExtent = precedingPinnedExtent;
  }
}

class SliverTabViewParentData extends ParentData
    with ContainerParentDataMixin<RenderSliver> {
  double crossAxisPosition = 0;
  double scrollOffset = 0;
  double overlap = 0;

  double mainAxisOffset(double paintOrigin) => paintOrigin + overlap;

  Offset offset(AxisDirection direction, double paintOrigin) {
    switch (direction) {
      case AxisDirection.up:
        // scrollOffset = crossAxisPosition;
        return Offset(crossAxisPosition, 0);
      case AxisDirection.right:
        // TODO: Handle this case.
        break;
      case AxisDirection.down:
        // scrollOffset = crossAxisPosition;
        return Offset(crossAxisPosition, mainAxisOffset(paintOrigin));
      case AxisDirection.left:
        // TODO: Handle this case.
        break;
    }
    throw FallThroughError();
  }
}

class RenderSliverTabView extends RenderSliver
    with ContainerRenderObjectMixin<RenderSliver, SliverTabViewParentData> {
  TabController get horizontalController => _horizontalController!;
  TabController? _horizontalController;
  set horizontalController(TabController value) {
    if (value != _horizontalController) {
      _horizontalController?.animation?.removeListener(_scrollUpdated);
      _horizontalController = value;
      _horizontalController?.animation?.addListener(_scrollUpdated);
      markNeedsLayout();
    }
  }

  double get precedingPinnedExtent => _precedingPinnedExtent!;
  double? _precedingPinnedExtent;
  set precedingPinnedExtent(double value) {
    if (_precedingPinnedExtent != value) {
      _precedingPinnedExtent = value;
      markNeedsLayout();
    }
  }

  void _scrollUpdated() {
    markNeedsLayout();
  }

  Iterable<RenderSliver> get childrenInPaintOrder sync* {
    var child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  Iterable<RenderSliver> get childrenInHitTestOrder sync* {
    var child = lastChild;
    while (child != null) {
      yield child;
      child = childBefore(child);
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SliverTabViewParentData)
      child.parentData = SliverTabViewParentData();
  }

  double _lastScrollOffset = 0;
  int _currentIndex = -1;

  @override
  void performLayout() {
    double crossAxisPosition =
        -horizontalController.animation!.value * constraints.crossAxisExtent;

    int index = 0;
    late RenderSliver currentChild;
    for (final child in childrenInPaintOrder) {
      final childParentData = child.parentData as SliverTabViewParentData;

      if (index == horizontalController.index) {
        if (_currentIndex != index) {
          _currentIndex = index;
          final diff = constraints.scrollOffset -
              childParentData.scrollOffset +
              childParentData.overlap;
          if (diff != 0.0) {
            geometry = SliverGeometry(scrollOffsetCorrection: -diff);
            childParentData.overlap = 0;
            _lastScrollOffset = childParentData.scrollOffset;
            return;
          }
        } else {
          childParentData.scrollOffset +=
              constraints.scrollOffset - _lastScrollOffset;
        }
        currentChild = child;
      } else if (childParentData.scrollOffset == 0) {
        childParentData.overlap = constraints.overlap;
      }
      child.layout(
        constraints.copyWith(
          scrollOffset: max(0.0, childParentData.scrollOffset),
          cacheOrigin: 0, // TODO: Maybe fix this??
        ),
        parentUsesSize: true,
      );
      childParentData.crossAxisPosition = crossAxisPosition;
      crossAxisPosition += constraints.crossAxisExtent;
      index++;
    }
    if (constraints.preceedingPaintExtent > precedingPinnedExtent) {
      for (final child in childrenInPaintOrder) {
        if (child == currentChild) continue;
        final childParentData = child.parentData as SliverTabViewParentData;
        childParentData.scrollOffset = 0;
      }
    }

    _lastScrollOffset = constraints.scrollOffset;

    geometry = SliverGeometry(
      maxPaintExtent: max(constraints.remainingPaintExtent,
          currentChild.geometry!.maxPaintExtent),
      scrollExtent: max(constraints.viewportMainAxisExtent,
          currentChild.geometry!.scrollExtent),
      paintExtent: constraints.remainingPaintExtent,
      layoutExtent: constraints.remainingPaintExtent,
      hasVisualOverflow: true, // TODO: logic
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final direction = applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection);
    for (final child in childrenInPaintOrder) {
      final childParentData = child.parentData as SliverTabViewParentData;
      context.paintChild(
        child,
        offset + childParentData.offset(direction, child.geometry!.paintOrigin),
      );
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    for (final child in childrenInHitTestOrder) {
      final childParentData = child.parentData as SliverTabViewParentData;
      final hit = child.hitTest(SliverHitTestResult.wrap(result),
          mainAxisPosition: mainAxisPosition -
              childParentData.mainAxisOffset(child.geometry!.paintOrigin),
          crossAxisPosition:
              crossAxisPosition + childParentData.crossAxisPosition);
      if (hit) return true;
    }
    return false;
  }

  @override
  void applyPaintTransform(covariant RenderSliver child, Matrix4 transform) {
    final direction = applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection);
    final childParentData = child.parentData as SliverTabViewParentData;
    transform.translate(
        childParentData.offset(direction, child.geometry!.paintOrigin).dx);
  }
}

extension on SliverConstraints {
  double get preceedingPaintExtent => scrollOffset <= 0
      ? viewportMainAxisExtent - remainingPaintExtent
      : -scrollOffset;
}
