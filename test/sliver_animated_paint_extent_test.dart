import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/src/sliver_animated_paint_extent.dart';

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
    }) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          slivers: [
            SliverAnimatedPaintExtent(
              key: key,
              duration: animationDuration,
              child: SliverToBoxAdapter(
                child: box(boxHeight),
              ),
            ),
          ],
        ),
      );
    }

    testWidgets('shows its child', (tester) async {
      const key = ValueKey('animated_paint_extent');
      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: 150,
        animationDuration: const Duration(milliseconds: 150),
      ));
      expect(find.byKey(key), findsOneWidget);
      expect(tester.renderObject(find.byKey(key)), isA<RenderSliverAnimatedPaintExtent>());
      final renderObject =
          (tester.renderObject(find.byKey(key)) as RenderSliverAnimatedPaintExtent);
      expect(renderObject.geometry.layoutExtent, 150);
      expect(renderObject.geometry.paintExtent, 150);
      expect(renderObject.geometry.scrollExtent, 150);
    });

    testWidgets('animates child size increase', (tester) async {
      const key = ValueKey('animated_paint_extent');
      const duration = Duration(milliseconds: 150);

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: 150,
        animationDuration: duration,
      ));
      final renderObject =
          (tester.renderObject(find.byKey(key)) as RenderSliverAnimatedPaintExtent);
      expect(renderObject.geometry.layoutExtent, 150);
      expect(renderObject.geometry.paintExtent, 150);
      expect(renderObject.geometry.scrollExtent, 150);

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: 300,
        animationDuration: duration,
      ));
      expect(renderObject.geometry.layoutExtent, 150);
      expect(renderObject.geometry.paintExtent, 150);
      expect(renderObject.geometry.scrollExtent, 150);
      await tester.pump(const Duration(milliseconds: 75));
      expect(renderObject.geometry.paintExtent, 225);
      expect(renderObject.geometry.layoutExtent, 225);
      expect(renderObject.geometry.scrollExtent, 225);
      await tester.pump(const Duration(milliseconds: 75));
      expect(renderObject.geometry.layoutExtent, 300);
      expect(renderObject.geometry.paintExtent, 300);
      expect(renderObject.geometry.scrollExtent, 300);
    });

    testWidgets('animates child size decrease', (tester) async {
      const key = ValueKey('animated_paint_extent');
      const duration = Duration(milliseconds: 200);

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: 300,
        animationDuration: duration,
      ));
      final renderObject =
          (tester.renderObject(find.byKey(key)) as RenderSliverAnimatedPaintExtent);
      expect(renderObject.geometry.layoutExtent, 300);
      expect(renderObject.geometry.paintExtent, 300);
      expect(renderObject.geometry.scrollExtent, 300);

      await tester.pumpWidget(animatedPaintExtent(
        key: key,
        boxHeight: 150,
        animationDuration: duration,
      ));
      expect(renderObject.geometry.layoutExtent, 300);
      expect(renderObject.geometry.paintExtent, 300);
      expect(renderObject.geometry.scrollExtent, 300);
      await tester.pump(const Duration(milliseconds: 100));
      expect(renderObject.geometry.paintExtent, 225);
      expect(renderObject.geometry.layoutExtent, 225);
      expect(renderObject.geometry.scrollExtent, 225);
      await tester.pump(const Duration(milliseconds: 100));
      expect(renderObject.geometry.paintExtent, 150);
      expect(renderObject.geometry.layoutExtent, 150);
      expect(renderObject.geometry.scrollExtent, 150);
    });
  });
}
