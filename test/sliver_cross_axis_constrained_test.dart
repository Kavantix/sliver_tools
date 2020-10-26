import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_tools/sliver_tools.dart';

void main() {
  Widget _createSut(Widget sliver, double maxCrossAxisExtend) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomScrollView(
        slivers: [
          SliverCrossAxisConstrained(
            maxCrossAxisExtent: maxCrossAxisExtend,
            child: sliver,
          ),
        ],
      ),
    );
  }

  group('SliverCrossAxisConstrained', () {
    double maxCrossAxisExtent;
    Widget sut;
    Size windowSize;
    setUp(() {
      maxCrossAxisExtent = 300;
      sut = _createSut(
        const SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            height: 100,
          ),
        ),
        maxCrossAxisExtent,
      );
    });

    group('Given window size is smaller then max extent', () {
      setUp(() {
        windowSize = const Size(200, 400);
      });
      testWidgets('It sizes sliver to available space', (tester) async {
        tester.binding.window.physicalSizeTestValue = windowSize;
        await tester.pumpWidget(sut);
        await tester.pumpAndSettle();

        final width = await tester
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

      testWidgets('It sizes sliver tto max extent', (tester) async {
        tester.binding.window.physicalSizeTestValue = windowSize;
        await tester.pumpWidget(sut);
        await tester.pumpAndSettle();

        final renderObject =
            await tester.renderObject(find.byType(SliverToBoxAdapter));

        expect(renderObject.paintBounds.width, maxCrossAxisExtent);
      });
    });
  });
}
