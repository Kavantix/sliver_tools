import 'package:flutter/material.dart';
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
    color: const Color(0xFF000000),
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
            scrollBehavior: NoScrollbarScrollBehaviour(),
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

    testWidgets('rounding error does not occur', (tester) async {
      final controller = ScrollController();
      await setupMultiSliver(
        tester,
        controller: controller,
        childCount: 20,
      );
      expect(
          tester.renderObject(find.byKey(groupKey)), isA<RenderMultiSliver>());
      final multiSliver =
          tester.renderObject(find.byKey(groupKey)) as RenderMultiSliver;
      final list = tester.renderObject(find.byKey(listKey)) as RenderSliver;
      expect(multiSliver.childScrollOffset(list), 150);
      controller.jumpTo(-44.5333330000001);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts RenderBox children', (tester) async {
      const boxKey = Key('box');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          scrollBehavior: NoScrollbarScrollBehaviour(),
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
          scrollBehavior: NoScrollbarScrollBehaviour(),
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

    testWidgets(
        'correctly sets hasVisualOverflow of boxChild when scrolled off screen',
        (tester) async {
      const boxKey = Key('box');
      final controller = ScrollController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          scrollBehavior: NoScrollbarScrollBehaviour(),
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

    testWidgets('can hit sliver child', (tester) async {
      const boxKey = Key('box');
      final controller = ScrollController();
      var taps = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          scrollBehavior: NoScrollbarScrollBehaviour(),
          controller: controller,
          physics: const UnconstrainedScollPhysics(),
          slivers: [
            MultiSliver(
              children: [
                box(UniqueKey(), 'Title', height: 100),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 100),
                      GestureDetector(
                        onTap: () => taps++,
                        child: Container(
                          key: boxKey,
                          color: const Color(0xFF000000),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
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
      await tester.tap(thebox);
      expect(taps, 2);
    });

    testWidgets('can hit box child', (tester) async {
      const boxKey = Key('box');
      final controller = ScrollController();
      var taps = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          scrollBehavior: NoScrollbarScrollBehaviour(),
          controller: controller,
          physics: const UnconstrainedScollPhysics(),
          slivers: [
            MultiSliver(
              children: [
                const SliverToBoxAdapter(child: SizedBox(height: 400)),
                GestureDetector(
                  onTap: () => taps++,
                  child: box(boxKey, 'Title', height: 1),
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
    });

    testWidgets('sliver child hit test position is correct', (tester) async {
      const boxKey = Key('box');
      final controller = ScrollController();
      TapDownDetails? tapDownDetails;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          scrollBehavior: NoScrollbarScrollBehaviour(),
          controller: controller,
          physics: const UnconstrainedScollPhysics(),
          slivers: [
            MultiSliver(
              children: [
                const SliverToBoxAdapter(child: SizedBox(height: 400)),
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTapDown: (details) {
                      tapDownDetails = details;
                    },
                    child: box(boxKey, 'Title', height: 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ));
      expect(tapDownDetails, isNull);
      final thebox = find.byKey(boxKey);
      await tester.tap(thebox);
      expect(tapDownDetails?.globalPosition, const Offset(400, 400.5));
      expect(tapDownDetails?.localPosition, const Offset(400, 0.5));
    });

    testWidgets('box child does not get hit when tapping outside',
        (tester) async {
      const boxKey = Key('box');
      final controller = ScrollController();
      var taps = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          scrollBehavior: NoScrollbarScrollBehaviour(),
          controller: controller,
          physics: const UnconstrainedScollPhysics(),
          slivers: [
            MultiSliver(
              children: [
                GestureDetector(
                  onTap: () => taps++,
                  child: box(UniqueKey(), 'Title', height: 200),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    key: boxKey,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ));
      expect(taps, 0);
      final thebox = find.byKey(boxKey);
      await tester.tap(thebox, warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('paintExtent is not larger than maxPaintExtent',
        (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          scrollBehavior: NoScrollbarScrollBehaviour(),
          controller: controller,
          physics: const UnconstrainedScollPhysics(),
          slivers: [
            const SliverPinnedHeader(child: SizedBox(height: 56)),
            const MultiSliver(children: [
              // This height being smaller than the pinned height caused an exception before 0.2.2
              SizedBox(height: 30),
            ]),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    const SizedBox(height: 50, width: double.infinity),
                childCount: 20,
              ),
            ),
          ],
        ),
      ));
      controller.jumpTo(60);
      await tester.pump();
      // Throws exception if it fails
    });

    testWidgets('correctly handles slivers before the centerKey',
        (tester) async {
      final bottom = List<int>.generate(10, (i) => i + 1);
      const Key centerKey = ValueKey('second-sliver-list');
      final controller = ScrollController();
      int taps = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          scrollBehavior: NoScrollbarScrollBehaviour(),
          physics: const UnconstrainedScollPhysics(),
          center: centerKey,
          slivers: <Widget>[
            MultiSliver(
              children: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => taps += 1,
                      child: const SizedBox(
                        height: 30,
                        key: ValueKey('Item 0'),
                      ),
                    ),
                    const SizedBox(height: 20, key: ValueKey('Item -1')),
                    const SizedBox(height: 20, key: ValueKey('Item -2')),
                  ]),
                ),
                const SizedBox(height: 20, key: ValueKey('Item -3')),
                const SizedBox(height: 20, key: ValueKey('Item -4')),
              ],
            ),
            MultiSliver(
              key: centerKey,
              children: [
                for (final index in bottom)
                  SizedBox(height: 20, key: ValueKey('Item $index')),
              ],
            ),
          ],
        ),
      ));
      controller.jumpTo(-110.0);
      await tester.pumpAndSettle();
      expect(find.byType(SizedBox), findsNWidgets(5 + bottom.length));
      expect(
        tester.getRect(find.byKey(const ValueKey('Item 0'))).bottom,
        110,
      );
      final RenderBox renderObject2 =
          tester.renderObject(find.byKey(const ValueKey('Item -2')));
      expect(
        renderObject2.localToGlobal(Offset.zero).dy,
        40,
      );
      final RenderBox renderObject1 =
          tester.renderObject(find.byKey(const ValueKey('Item -1')));
      expect(
        renderObject1.localToGlobal(Offset.zero).dy,
        60,
      );
      final RenderBox renderObject0 =
          tester.renderObject(find.byKey(const ValueKey('Item 0')));
      expect(
        renderObject0.localToGlobal(Offset.zero).dy,
        80,
      );
      final RenderBox renderObject3 =
          tester.renderObject(find.byKey(const ValueKey('Item -3')));
      expect(
        renderObject3.localToGlobal(Offset.zero).dy,
        20,
      );
      final RenderBox renderObject4 =
          tester.renderObject(find.byKey(const ValueKey('Item -4')));
      expect(
        renderObject4.localToGlobal(Offset.zero).dy,
        0,
      );
      expect(taps, 0);
      await tester.tapAt(const Offset(0, 80 + 15));
      expect(taps, 1);
      controller.jumpTo(-100);
      await tester.pumpAndSettle();
      expect(
        renderObject2.localToGlobal(Offset.zero).dy,
        30,
      );
      expect(
        renderObject4.localToGlobal(Offset.zero).dy,
        -10,
      );
    });
  });

  testWidgets(
      'maxScrollObstructionExtent should be the sum of all maxScrollObstructionExtent children',
      (tester) async {
    final multiSliverKey = GlobalKey();

    const headerHeight = 46.0;
    const nbPinned = 2;

    const totalPinnedHeight = nbPinned * headerHeight;

    await tester.pumpWidget(
      Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            slivers: <Widget>[
              MultiSliver(
                key: multiSliverKey,
                children: [
                  for (int i = 0; i < nbPinned; i++)
                    SliverPinnedHeader(
                        child: SizedBox(
                            height: headerHeight, child: Text('Pinned $i'))),
                ],
              ),
              const SliverToBoxAdapter(child: Text('Content'))
            ],
          )),
    );

    final multiSliverFinder = find.byKey(multiSliverKey);

    expect(multiSliverFinder, findsOneWidget);

    final RenderSliver renderMultiSliver =
        tester.renderObject(multiSliverFinder);

    expect(renderMultiSliver.geometry!.maxScrollObstructionExtent,
        totalPinnedHeight);
  });
}
