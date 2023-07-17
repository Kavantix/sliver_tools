import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_tools/src/rendering/sliver_cross_axis_positioned.dart';

const double windowCrossAxisExtent = 800;
const constraints = SliverConstraints(
  overlap: 0,
  cacheOrigin: 0,
  scrollOffset: 0,
  axisDirection: AxisDirection.down,
  growthDirection: GrowthDirection.forward,
  crossAxisExtent: windowCrossAxisExtent,
  crossAxisDirection: AxisDirection.right,
  userScrollDirection: ScrollDirection.idle,
  remainingPaintExtent: 800,
  remainingCacheExtent: 800,
  precedingScrollExtent: 0,
  viewportMainAxisExtent: 800,
);

class _MockChild extends RenderSliver {
  @override
  void performLayout() {
    geometry = const SliverGeometry(
      paintExtent: 200,
      maxPaintExtent: 200,
      scrollExtent: 200,
    );
  }
}

class _MockPaintContext implements PaintingContext {
  final Offset expectedOffset;

  const _MockPaintContext(this.expectedOffset);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    expect(invocation.memberName, const Symbol('paintChild'));
    expect(invocation.positionalArguments[1] as Offset?, expectedOffset);
  }
}

class _MockCrossAxisPositionedSliver extends RenderSliver
    with
        RenderObjectWithChildMixin<RenderSliver>,
        RenderSliverCrossAxisPositionedMixin {
  final SliverCrossAxisPositionedData data;

  _MockCrossAxisPositionedSliver(this.data);

  @override
  SliverCrossAxisPositionedData createCrossAxisPositionData(
      SliverConstraints constraints) {
    return data;
  }
}

void main() => crossAxisPositionedTests();

void crossAxisPositionedTests() {
  RenderSliverCrossAxisPositionedMixin setup({
    double crossAxisPosition = 0,
    double crossAxisExtent = windowCrossAxisExtent,
  }) {
    return _MockCrossAxisPositionedSliver(
      SliverCrossAxisPositionedData(
        crossAxisPosition: crossAxisPosition,
        crossAxisExtent: crossAxisExtent,
      ),
    )..child = _MockChild();
  }

  group('RenderSliverCrossAxisPositionedMixin', () {
    test('passes updated constraints to child', () {
      var renderObject = setup();
      renderObject.layout(constraints, parentUsesSize: true);
      expect(renderObject.child!.constraints, constraints);

      const double crossAxisPosition = 214;
      const double crossAxisExtent =
          windowCrossAxisExtent - crossAxisPosition - 111;
      renderObject = setup(
        crossAxisPosition: crossAxisPosition,
        crossAxisExtent: crossAxisExtent,
      );
      renderObject.layout(constraints, parentUsesSize: true);
      expect(
        renderObject.child!.constraints,
        constraints.copyWith(crossAxisExtent: crossAxisExtent),
      );
    });

    test('directly passes the exact geometry of the child on', () {
      var renderObject = setup();
      renderObject.layout(constraints, parentUsesSize: true);
      expect(
        identical(renderObject.geometry, renderObject.child!.geometry),
        true,
        reason: 'geometry was not identical to the geometry of the child',
      );

      const double crossAxisPosition = 214;
      const double crossAxisExtent0 =
          windowCrossAxisExtent - crossAxisPosition - 111;
      renderObject = setup(
        crossAxisPosition: crossAxisPosition,
        crossAxisExtent: crossAxisExtent0,
      );
      renderObject.layout(constraints, parentUsesSize: true);
      expect(
        renderObject.child!.constraints,
        constraints.copyWith(crossAxisExtent: crossAxisExtent0),
      );
      expect(
        identical(renderObject.geometry, renderObject.child!.geometry),
        true,
        reason: 'geometry was not identical to the geometry of the child',
      );
    });

    test('correctly calls paint', () {
      var renderObject = setup();
      renderObject.layout(constraints, parentUsesSize: true);
      expect(renderObject.child!.constraints, constraints);
      renderObject.paint(
        const _MockPaintContext(Offset.zero),
        Offset.zero,
      );

      const double crossAxisPosition = 214;
      const double crossAxisExtent1 =
          windowCrossAxisExtent - crossAxisPosition - 111;
      renderObject = setup(
        crossAxisPosition: crossAxisPosition,
        crossAxisExtent: crossAxisExtent1,
      );
      renderObject.layout(constraints, parentUsesSize: true);
      expect(
        renderObject.child!.constraints,
        constraints.copyWith(crossAxisExtent: crossAxisExtent1),
      );
      renderObject.paint(
        const _MockPaintContext(Offset(crossAxisPosition, 0)),
        Offset.zero,
      );

      renderObject.layout(
        constraints.copyWith(
          axisDirection: AxisDirection.right,
          crossAxisDirection: AxisDirection.down,
        ),
        parentUsesSize: true,
      );
      expect(
        renderObject.child!.constraints,
        constraints.copyWith(
          axisDirection: AxisDirection.right,
          crossAxisDirection: AxisDirection.down,
          crossAxisExtent: crossAxisExtent1,
        ),
      );
      renderObject.paint(
        const _MockPaintContext(Offset(0, crossAxisPosition)),
        Offset.zero,
      );
    });
  });
}
