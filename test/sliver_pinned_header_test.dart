import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sliver_tools/src/rendering/sliver_pinned_header.dart';

const constraints = SliverConstraints(
  overlap: 0,
  cacheOrigin: 0,
  scrollOffset: 0,
  axisDirection: AxisDirection.down,
  growthDirection: GrowthDirection.forward,
  crossAxisExtent: 600,
  crossAxisDirection: AxisDirection.right,
  userScrollDirection: ScrollDirection.idle,
  remainingPaintExtent: 800,
  remainingCacheExtent: 800,
  precedingScrollExtent: 0,
  viewportMainAxisExtent: 800,
);

const double childHeight = 234;
const double childWidth = 342;

void main() {
  group('SliverPinnedHeader', () {
    SliverPinnedHeader createWidget() {
      return const SliverPinnedHeader(
        child: SizedBox(height: childHeight, width: childWidth),
      );
    }

    RenderSliverPinnedHeader setup() {
      final widget = createWidget();
      return widget.createRenderObject(null)
        ..child = (widget.child as SizedBox).createRenderObject(null);
    }

    group('always', () {
      test('compensates overlap by moving its paint origin', () {
        double overlap = 0;
        final renderObject = setup();
        renderObject.layout(
          constraints.copyWith(
            overlap: overlap,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintOrigin, overlap);

        overlap = 40;
        renderObject.layout(
          constraints.copyWith(
            overlap: overlap,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintOrigin, overlap);

        overlap = -50;
        renderObject.layout(
          constraints.copyWith(
            overlap: overlap,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintOrigin, overlap);
      });

      test('updates its layoutOffset as if it is scrolling away', () {
        double scrollOffset = 0;
        final renderObject = setup();
        renderObject.layout(
          constraints.copyWith(
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(
          renderObject.geometry.layoutExtent,
          renderObject.geometry.maxPaintExtent - scrollOffset,
        );

        scrollOffset = 40;
        renderObject.layout(
          constraints.copyWith(
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(
          renderObject.geometry.layoutExtent,
          renderObject.geometry.maxPaintExtent - scrollOffset,
        );

        scrollOffset = childHeight + 2;
        renderObject.layout(
          constraints.copyWith(
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(
          renderObject.geometry.layoutExtent,
          0,
        );
      });

      test('sets its child\'s parentData paintOffset to 0,0', () {
        final renderObject = setup();
        renderObject.layout(constraints, parentUsesSize: true);
        final childParentData =
            renderObject.child.parentData as SliverPhysicalParentData;
        expect(childParentData.paintOffset, Offset.zero);
      });

      test('keeps extents within remainingPaintExtent', () {
        final renderObject = setup();
        renderObject.layout(
          constraints.copyWith(
            overlap: 10,
            remainingPaintExtent: 14,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintExtent, 4);
        expect(renderObject.geometry.layoutExtent, 4);
      });

      test('has mainAxisPosition of 0 even when pinned', () {
        double scrollOffset = 0;
        final renderObject = setup();
        renderObject.layout(
          constraints.copyWith(
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.childMainAxisPosition(renderObject.child), 0);

        scrollOffset = 40;
        renderObject.layout(
          constraints.copyWith(
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.childMainAxisPosition(renderObject.child), 0);

        scrollOffset = childHeight + 2;
        renderObject.layout(
          constraints.copyWith(
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.childMainAxisPosition(renderObject.child), 0);
      });
    });

    group('in a vertical viewport', () {
      test(
          'has scrollExtent, paintExtent, hitTestExtent, maxScrollObstructionExtent and maxPaintExtent equal to the height of the child',
          () {
        double scrollOffset = 0;
        final renderObject = setup();
        renderObject.layout(
          constraints.copyWith(
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintExtent, childHeight);

        scrollOffset = 40;
        renderObject.layout(
          constraints.copyWith(
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintExtent, childHeight);

        scrollOffset = 200;
        renderObject.layout(
          constraints.copyWith(
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintExtent, childHeight);
      });
    });

    group('in a horizontal viewport', () {
      test(
          'has scrollExtent, paintExtent, hitTestExtent, maxScrollObstructionExtent and maxPaintExtent equal to the width of the child',
          () {
        double scrollOffset = 0;
        final renderObject = setup();
        renderObject.layout(
          constraints.copyWith(
            axisDirection: AxisDirection.right,
            crossAxisDirection: AxisDirection.down,
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintExtent, childWidth);

        scrollOffset = 40;
        renderObject.layout(
          constraints.copyWith(
            axisDirection: AxisDirection.right,
            crossAxisDirection: AxisDirection.down,
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintExtent, childWidth);

        scrollOffset = 200;
        renderObject.layout(
          constraints.copyWith(
            axisDirection: AxisDirection.right,
            crossAxisDirection: AxisDirection.down,
            scrollOffset: scrollOffset,
          ),
          parentUsesSize: true,
        );
        expect(renderObject.geometry.paintExtent, childWidth);
      });
    });
  });
}
