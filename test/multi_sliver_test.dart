import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sliver_tools/src/rendering/multi_sliver.dart';

import 'helpers/pinned_header.dart';
import 'helpers/unconstrained_scroll_physics.dart';

void main() => multiSliverTests();

Widget box(Key? key, String title, {required double height}) {
  return Container(
    key: key,
    alignment: Alignment.center,
    height: height,
    width: double.infinity,
    child: Text(title),
  );
}

void multiSliverTests() {
  group('MultiSliver', () {
    const box1Key = ValueKey('1');
    const box2Key = ValueKey('2');
    const groupKey = ValueKey('group');
    const pinnedKey = ValueKey('pinned');
    const listKey = ValueKey('list');
    const childSize = 300.0;
    const pinnedSize = 150.0;

    Future<double> setupMultiSliver(
      WidgetTester tester, {
      int childCount = 2,
      bool includePinned = false,
      ScrollController? controller,
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            controller: controller,
            physics: const UnconstrainedScollPhysics(),
            slivers: [
              MultiSliver(
                key: groupKey,
                children: <Widget>[
                  if (includePinned)
                    const PinnedHeader(
                      size: pinnedSize,
                      boxKey: pinnedKey,
                    ),
                  box(box1Key, '1', height: 150),
                  SliverList(
                    key: listKey,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return box(
                          index == 0 ? box2Key : null,
                          '2',
                          height: childSize,
                        );
                      },
                      childCount: childCount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      expect(find.byKey(box1Key), findsOneWidget);
      return (includePinned ? pinnedSize : 0.0) + 150 + childCount * childSize;
    }

    testWidgets('shows all child slivers', (tester) async {
      final totalSize = await setupMultiSliver(tester);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(0, 0, 800, 150));
      expect(tester.getRect(find.byKey(box2Key)),
          const Rect.fromLTWH(0, 150, 800, 300));
      expect(
          tester.renderObject(find.byKey(groupKey)), isA<RenderMultiSliver>());
      final multiSliver =
          tester.renderObject(find.byKey(groupKey)) as RenderMultiSliver;
      expect(multiSliver.geometry!.scrollExtent, totalSize);
    });

    testWidgets('correctly sets maxPaintExtent and paintOrigin',
        (tester) async {
      double totalSize = await setupMultiSliver(tester);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(0, 0, 800, 150));
      expect(tester.getRect(find.byKey(box2Key)),
          const Rect.fromLTWH(0, 150, 800, 300));
      expect(
          tester.renderObject(find.byKey(groupKey)), isA<RenderMultiSliver>());
      final multiSliver =
          tester.renderObject(find.byKey(groupKey)) as RenderMultiSliver;
      expect(
        multiSliver.geometry!.maxPaintExtent,
        totalSize,
      );

      totalSize = await setupMultiSliver(tester, childCount: 20);
      expect(multiSliver.geometry!.maxPaintExtent, totalSize);
      expect(multiSliver.geometry!.paintOrigin, 0);
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(
        multiSliver.geometry!.maxPaintExtent,
        totalSize,
        reason: 'maxPaintExtent incorrect when scrolled past leading edge',
      );
      expect(
        multiSliver.geometry!.paintOrigin,
        0,
        reason: 'paintOrigin incorrect when scrolled past leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, 400));
      await tester.pump();
      expect(
        multiSliver.geometry!.maxPaintExtent,
        totalSize,
        reason: 'maxPaintExtent incorrect when overscrolling leading edge',
      );
      expect(
        multiSliver.geometry!.paintOrigin,
        0,
        reason: 'paintOrigin incorrect when overscrolling leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(multiSliver.geometry!.maxPaintExtent, totalSize);
      expect(multiSliver.geometry!.paintOrigin, 0);

      // test pinned
      totalSize =
          await setupMultiSliver(tester, childCount: 20, includePinned: true);
      expect(multiSliver.geometry!.maxPaintExtent, totalSize);
      expect(multiSliver.geometry!.paintOrigin, 0);
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(
        multiSliver.geometry!.maxPaintExtent,
        totalSize,
        reason:
            'maxPaintExtent incorrect with pinned when scrolled past leading edge',
      );
      expect(
        multiSliver.geometry!.paintOrigin,
        0,
        reason:
            'paintOrigin incorrect with pinned when overscrolling leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, 400));
      await tester.pump();
      expect(
        multiSliver.geometry!.maxPaintExtent,
        totalSize + 200,
        reason:
            'maxPaintExtent incorrect with pinned when overscrolling leading edge',
      );
      expect(
        multiSliver.geometry!.paintOrigin,
        -200,
        reason:
            'paintOrigin incorrect with pinned when overscrolling leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(multiSliver.geometry!.maxPaintExtent, totalSize);
      expect(multiSliver.geometry!.paintOrigin, 0);
    });

    testWidgets('correctly sets childScrollOffset', (tester) async {
      final controller = ScrollController();
      await setupMultiSliver(
        tester,
        controller: controller,
      );
      expect(
          tester.renderObject(find.byKey(groupKey)), isA<RenderMultiSliver>());
      final multiSliver =
          tester.renderObject(find.byKey(groupKey)) as RenderMultiSliver;
      final list = tester.renderObject(find.byKey(listKey)) as RenderSliver;
      expect(multiSliver.childScrollOffset(list), 150);
      controller.jumpTo(200);
      await tester.pump();
      expect(multiSliver.childScrollOffset(list), 150);
    });

    testWidgets('accepts RenderBox children', (tester) async {
      const boxKey = Key('box');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          slivers: [
            MultiSliver(
              children: [
                box(boxKey, 'Title', height: 200),
              ],
            ),
          ],
        ),
      ));
      expect(find.byKey(boxKey), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('correctly draws boxChild when scrolled off screen',
        (tester) async {
      const boxKey = Key('box');
      final controller = ScrollController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          physics: const UnconstrainedScollPhysics(),
          slivers: [
            MultiSliver(
              children: [
                box(boxKey, 'Title', height: 200),
              ],
            ),
          ],
        ),
      ));
      expect(find.byKey(boxKey), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      Rect boxRect() => tester.getRect(find.byKey(boxKey));
      final boxWidth = boxRect().width;
      expect(boxRect(), Rect.fromLTWH(0, 0, boxWidth, 200));
      controller.jumpTo(100);
      await tester.pump();
      expect(boxRect(), Rect.fromLTWH(0, -100, boxWidth, 200));
      controller.jumpTo(199);
      await tester.pump();
      expect(boxRect(), Rect.fromLTWH(0, -199, boxWidth, 200));
      controller.jumpTo(300);
      await tester.pump();
      expect(find.byKey(boxKey), findsNothing);
    });

    testWidgets('correctly draws boxChild when scrolled off screen',
        (tester) async {
      const boxKey = Key('box');
      final controller = ScrollController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          physics: const UnconstrainedScollPhysics(),
          slivers: [
            MultiSliver(
              children: [
                box(boxKey, 'Title', height: 200),
              ],
            ),
          ],
        ),
      ));
      expect(find.byKey(boxKey), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      final boxRenderObject = tester.renderObject(find.byKey(boxKey));
      Rect boxRect() => tester.getRect(find.byKey(boxKey));
      SliverGeometry boxGeometry() =>
          (boxRenderObject.parentData as MultiSliverParentData).geometry;
      final boxWidth = boxRect().width;
      expect(boxRect(), Rect.fromLTWH(0, 0, boxWidth, 200));
      expect(boxGeometry().hasVisualOverflow, false);
      controller.jumpTo(100);
      await tester.pump();
      expect(boxRect(), Rect.fromLTWH(0, -100, boxWidth, 200));
      expect(boxGeometry().hasVisualOverflow, true);
      controller.jumpTo(199);
      await tester.pump();
      expect(boxRect(), Rect.fromLTWH(0, -199, boxWidth, 200));
      expect(boxGeometry().hasVisualOverflow, true);
      controller.jumpTo(300);
      await tester.pump();
      expect(find.byKey(boxKey), findsNothing);
      expect(boxGeometry().hasVisualOverflow, false);
    });

    testWidgets('can hit boxchild', (tester) async {
      const boxKey = Key('box');
      final controller = ScrollController();
      var taps = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          physics: const UnconstrainedScollPhysics(),
          slivers: [
            MultiSliver(
              children: [
                const SliverToBoxAdapter(child: SizedBox(height: 400)),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => taps++,
                  child: box(boxKey, 'Title', height: 200),
                ),
              ],
            ),
          ],
        ),
      ));
      expect(taps, 0);
      final thebox = find.byKey(boxKey);
      await tester.tap(thebox);
      expect(taps, 1);
      controller.jumpTo(100);
      await tester.pump();
      controller.jumpTo(199);
      await tester.pump();
      controller.jumpTo(300);
      await tester.pump();
    });
  });
}
