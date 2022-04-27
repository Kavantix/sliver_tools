import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'helpers/unconstrained_scroll_physics.dart';

void main() => crossAxisConstrainedTests();

void crossAxisConstrainedTests() {
  Widget _createSut(
    double maxCrossAxisExtend, {
    double alignment = 0,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomScrollView(
        scrollBehavior: NoScrollbarScrollBehaviour(),
        scrollDirection: Axis.vertical,
        slivers: [
          SliverCrossAxisConstrained(
            maxCrossAxisExtent: maxCrossAxisExtend,
            alignment: alignment,
            child: const SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  group('SliverCrossAxisConstrained', () {
    late double maxCrossAxisExtent;
    late Widget sut;
    late Size windowSize;
    setUp(() {
      maxCrossAxisExtent = 300;
      sut = _createSut(
        maxCrossAxisExtent,
      );
    });

    group('Given window size is smaller then max extent', () {
      setUp(() {
        windowSize = const Size(200, 400);
      });
      testWidgets('It sizes sliver to available space', (tester) async {
        tester.binding.window.physicalSizeTestValue = windowSize;
        tester.binding.window.devicePixelRatioTestValue = 1;
        await tester.pumpWidget(sut);
        await tester.pumpAndSettle();

        final width = tester
            .renderObject(find.byType(SliverToBoxAdapter))
            .paintBounds
            .width;

        expect(width < maxCrossAxisExtent, true);
      });
    });

    group('Given window size is bigger then max extent', () {
      setUp(() {
        windowSize = const Size(1200, 400);
      });

      testWidgets('It sizes sliver to max extent', (tester) async {
        tester.binding.window.physicalSizeTestValue = windowSize;
        tester.binding.window.devicePixelRatioTestValue = 1;
        await tester.pumpWidget(sut);
        await tester.pumpAndSettle();

        final renderObject =
            tester.renderObject(find.byType(SliverToBoxAdapter));

        expect(renderObject.paintBounds.width, maxCrossAxisExtent);
      });
      testWidgets('it aligns correctly using the alignment parameter',
          (tester) async {
        tester.binding.window.physicalSizeTestValue = windowSize;
        tester.binding.window.devicePixelRatioTestValue = 1;
        await tester.pumpWidget(_createSut(maxCrossAxisExtent));

        final renderObject =
            tester.renderObject(find.byType(SliverToBoxAdapter));

        expect(renderObject.paintBounds.width, maxCrossAxisExtent);
        expect(
          (renderObject.parentData as SliverPhysicalParentData).paintOffset.dx,
          (1200 - maxCrossAxisExtent) / 2,
          reason: 'center alignment is off',
        );

        await tester.pumpWidget(_createSut(maxCrossAxisExtent, alignment: -1));
        expect(renderObject.paintBounds.width, maxCrossAxisExtent);
        expect(
          (renderObject.parentData as SliverPhysicalParentData).paintOffset.dx,
          0,
          reason: 'left alignment is off',
        );

        await tester.pumpWidget(_createSut(maxCrossAxisExtent, alignment: 1));
        expect(renderObject.paintBounds.width, maxCrossAxisExtent);
        expect(
          (renderObject.parentData as SliverPhysicalParentData).paintOffset.dx,
          (1200 - maxCrossAxisExtent),
          reason: 'right alignment is off',
        );
      });
    });
  });
}
