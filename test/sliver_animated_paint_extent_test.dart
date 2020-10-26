import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_tools/sliver_tools.dart';

void main() {
  group('SliverAnimatedPaintExtent', () {
    Widget box(double height) {
      return SizedBox(
        height: height,
        width: double.infinity,
      );
    }

    Widget animatedPaintExtent({
      @required Key key,
      @required double boxHeight,
      @required Duration animationDuration,
      Curve curve = Curves.linear,
    }) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          slivers: [
            SliverAnimatedPaintExtent(
              key: key,
              duration: animationDuration,
              curve: curve,
              child: SliverToBoxAdapter(
                child: box(boxHeight),
              ),
            ),
          ],
        ),
      );
    }

    const double startHeight = 150;
    const double endHeight = 300;

    testWidgets('shows its child', (tester) async {
      const key = ValueKey('animated_paint_extent');
      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: startHeight,
        animationDuration: const Duration(milliseconds: 150),
      ));
      expect(find.byKey(key), findsOneWidget);
      expect(tester.renderObject(find.byKey(key)),
          isA<RenderSliverAnimatedPaintExtent>());
      final renderObject = (tester.renderObject(find.byKey(key))
          as RenderSliverAnimatedPaintExtent);
      expect(renderObject.geometry.layoutExtent, startHeight);
      expect(renderObject.geometry.paintExtent, startHeight);
      expect(renderObject.geometry.scrollExtent, startHeight);
    });

    testWidgets('animates child size increase', (tester) async {
      const key = ValueKey('animated_paint_extent');
      const duration = Duration(milliseconds: 150);
      const middleHeight = startHeight + (endHeight - startHeight) / 2;

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: startHeight,
        animationDuration: duration,
      ));
      final renderObject = (tester.renderObject(find.byKey(key))
          as RenderSliverAnimatedPaintExtent);
      expect(renderObject.geometry.layoutExtent, startHeight);
      expect(renderObject.geometry.paintExtent, startHeight);
      expect(renderObject.geometry.scrollExtent, startHeight);

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: endHeight,
        animationDuration: duration,
      ));
      expect(renderObject.geometry.layoutExtent, startHeight);
      expect(renderObject.geometry.paintExtent, startHeight);
      expect(renderObject.geometry.scrollExtent, startHeight);
      await tester.pump(const Duration(milliseconds: 75));
      expect(renderObject.geometry.paintExtent, middleHeight);
      expect(renderObject.geometry.layoutExtent, middleHeight);
      expect(renderObject.geometry.scrollExtent, middleHeight);
      await tester.pump(const Duration(milliseconds: 75));
      expect(renderObject.geometry.layoutExtent, endHeight);
      expect(renderObject.geometry.paintExtent, endHeight);
      expect(renderObject.geometry.scrollExtent, endHeight);
    });

    testWidgets('animates child size decrease', (tester) async {
      const key = ValueKey('animated_paint_extent');
      const duration = Duration(milliseconds: 200);
      const middleHeight = startHeight + (endHeight - startHeight) / 2;

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: endHeight,
        animationDuration: duration,
      ));
      final renderObject = (tester.renderObject(find.byKey(key))
          as RenderSliverAnimatedPaintExtent);
      expect(renderObject.geometry.layoutExtent, endHeight);
      expect(renderObject.geometry.paintExtent, endHeight);
      expect(renderObject.geometry.scrollExtent, endHeight);

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: startHeight,
        animationDuration: duration,
      ));
      expect(renderObject.geometry.layoutExtent, endHeight);
      expect(renderObject.geometry.paintExtent, endHeight);
      expect(renderObject.geometry.scrollExtent, endHeight);
      await tester.pump(const Duration(milliseconds: 100));
      expect(renderObject.geometry.paintExtent, middleHeight);
      expect(renderObject.geometry.layoutExtent, middleHeight);
      expect(renderObject.geometry.scrollExtent, middleHeight);
      await tester.pump(const Duration(milliseconds: 100));
      expect(renderObject.geometry.paintExtent, startHeight);
      expect(renderObject.geometry.layoutExtent, startHeight);
      expect(renderObject.geometry.scrollExtent, startHeight);
    });

    testWidgets('animates child size increase with curve', (tester) async {
      const key = ValueKey('animated_paint_extent');
      const duration = Duration(milliseconds: 150);
      const curve = Curves.easeOut;
      final middleHeight =
          startHeight + curve.transform(0.5) * (endHeight - startHeight);

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: startHeight,
        animationDuration: duration,
        curve: curve,
      ));
      final renderObject = (tester.renderObject(find.byKey(key))
          as RenderSliverAnimatedPaintExtent);
      expect(renderObject.geometry.layoutExtent, startHeight);
      expect(renderObject.geometry.paintExtent, startHeight);
      expect(renderObject.geometry.scrollExtent, startHeight);

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: endHeight,
        animationDuration: duration,
        curve: curve,
      ));
      expect(renderObject.geometry.layoutExtent, startHeight);
      expect(renderObject.geometry.paintExtent, startHeight);
      expect(renderObject.geometry.scrollExtent, startHeight);
      await tester.pump(const Duration(milliseconds: 75));
      expect(renderObject.geometry.paintExtent, middleHeight);
      expect(renderObject.geometry.layoutExtent, middleHeight);
      expect(renderObject.geometry.scrollExtent, middleHeight);
      await tester.pump(const Duration(milliseconds: 75));
      expect(renderObject.geometry.layoutExtent, endHeight);
      expect(renderObject.geometry.paintExtent, endHeight);
      expect(renderObject.geometry.scrollExtent, endHeight);
    });
  });
}
