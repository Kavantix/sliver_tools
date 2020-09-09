import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/src/sliver_stack.dart';
import 'helpers/pinned_header.dart';

class _UnconstrainedScollPhysics extends ScrollPhysics {
  const _UnconstrainedScollPhysics();
  ScrollPhysics applyTo(ScrollPhysics ancestor) {
    return this;
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics _) => true;
}

void main() {
  group('SliverStack', () {
    Widget box(Key key, {double size}) {
      return Container(
        key: key,
        height: size,
        width: size,
      );
    }

    const box1Key = ValueKey('box 1');
    const boxInListKey = ValueKey('box in list');
    const stackKey = ValueKey('stack');
    const positionedKey = ValueKey('positioned');
    const pinnedKey = ValueKey('pinned');
    const childSize = 300.0;
    const pinnedSize = 150.0;

    Future<double> setupStack(
      WidgetTester tester, {
      bool reverse = false,
      Axis scrollDirection = Axis.vertical,
      bool ignoreOverlap = false,
      bool includePinned = false,
      int childCount = 2,
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            physics: const _UnconstrainedScollPhysics(),
            dragStartBehavior: DragStartBehavior.start,
            reverse: reverse,
            scrollDirection: scrollDirection,
            slivers: [
              if (includePinned)
                const PinnedHeader(
                  size: pinnedSize,
                  boxKey: pinnedKey,
                ),
              SliverStack(
                key: stackKey,
                insetOnOverlap: !ignoreOverlap,
                children: <Widget>[
                  SliverPositioned.fill(
                    child: box(positionedKey),
                  ),
                  SliverToBoxAdapter(
                    child: box(box1Key, size: 150),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return box(
                          index == 0 ? boxInListKey : null,
                          size: childSize,
                        );
                      },
                      childCount: childCount,
                    ),
                  ),
                ],
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 800, width: 800),
              ),
            ],
          ),
        ),
      );
      expect(find.byKey(positionedKey), findsOneWidget);
      expect(find.byKey(box1Key), findsOneWidget);
      expect(find.byKey(boxInListKey), findsOneWidget);
      expect(find.byKey(stackKey), findsOneWidget);
      return childCount * childSize;
    }

    void expectAllExtents(RenderSliver sliver, double expected) {
      expect(
        sliver.geometry.scrollExtent,
        expected,
        reason: 'scrollExtent is incorrect',
      );
      expect(
        sliver.geometry.paintExtent,
        min(sliver.constraints.remainingPaintExtent, expected),
        reason: 'paintExtent is incorrect',
      );
      expect(
        sliver.geometry.maxPaintExtent,
        expected,
        reason: 'maxPaintExtent is incorrect',
      );
      expect(
        sliver.geometry.layoutExtent,
        min(sliver.constraints.remainingPaintExtent, expected),
        reason: 'layoutExtent is incorrect',
      );
      expect(
        sliver.geometry.hitTestExtent,
        min(sliver.constraints.remainingPaintExtent, expected),
        reason: 'hitTestExtent is incorrect',
      );
    }

    testWidgets('shows all child slivers', (tester) async {
      await setupStack(tester);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(0, 0, 800, 150));
      expect(tester.getRect(find.byKey(boxInListKey)),
          const Rect.fromLTWH(0, 0, 800, 300));
      expect(
          tester.renderObject(find.byKey(stackKey)), isA<RenderSliverStack>());
      final stackSliver =
          tester.renderObject(find.byKey(stackKey)) as RenderSliverStack;
      expectAllExtents(stackSliver, 600);
    });

    testWidgets('positions all child slivers correctly when horizontal',
        (tester) async {
      await setupStack(tester, scrollDirection: Axis.horizontal);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(0, 0, 150, 600));
      expect(tester.getRect(find.byKey(boxInListKey)),
          const Rect.fromLTWH(0, 0, 300, 600));
      expect(
          tester.renderObject(find.byKey(stackKey)), isA<RenderSliverStack>());
      final stackSliver =
          tester.renderObject(find.byKey(stackKey)) as RenderSliverStack;
      expectAllExtents(stackSliver, 600);
    });

    testWidgets('positions all child slivers correctly when in reverse',
        (tester) async {
      await setupStack(tester, reverse: true);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(0, 450, 800, 150));
      expect(tester.getRect(find.byKey(boxInListKey)),
          const Rect.fromLTWH(0, 300, 800, 300));
      expect(
          tester.renderObject(find.byKey(stackKey)), isA<RenderSliverStack>());
      final stackSliver =
          tester.renderObject(find.byKey(stackKey)) as RenderSliverStack;
      expectAllExtents(stackSliver, 600);
    });

    testWidgets(
        'positions all child slivers correctly when horizontal in reverse',
        (tester) async {
      await setupStack(tester, scrollDirection: Axis.horizontal, reverse: true);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(650, 0, 150, 600));
      expect(tester.getRect(find.byKey(boxInListKey)),
          const Rect.fromLTWH(500, 0, 300, 600));
      expect(
          tester.renderObject(find.byKey(stackKey)), isA<RenderSliverStack>());
      final stackSliver =
          tester.renderObject(find.byKey(stackKey)) as RenderSliverStack;
      expectAllExtents(stackSliver, 600);
    });

    Future<void> checkAllScrolledPositions(
      WidgetTester tester, {
      @required Size size,
      @required Offset pinnedOffset,
    }) async {
      expect(
        tester.getRect(find.byKey(positionedKey)),
        pinnedOffset & size,
        reason: 'position incorrect when not scrolled',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(
        tester.getRect(find.byKey(positionedKey)),
        pinnedOffset & Size(size.width, size.height - 200),
        reason: 'position incorrect when scrolked past leading',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, 400));
      await tester.pump();
      expect(
        tester.getRect(find.byKey(positionedKey)),
        (const Offset(0, 200) + pinnedOffset) & size,
        reason: 'position incorrect when overscrolling leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(
        tester.getRect(find.byKey(positionedKey)),
        pinnedOffset & size,
        reason: 'position incorrect when no longer scrolled',
      );
    }

    testWidgets('sizes positioned.fill to maximum size of slivers',
        (tester) async {
      double totalSize;

      totalSize = await setupStack(tester, includePinned: true);
      await checkAllScrolledPositions(
        tester,
        size: Size(800, totalSize),
        pinnedOffset: const Offset(0, pinnedSize),
      );

      totalSize = await setupStack(tester, includePinned: true, childCount: 20);
      await checkAllScrolledPositions(
        tester,
        size: Size(800, totalSize),
        pinnedOffset: const Offset(0, pinnedSize),
      );
    });

    Future<void> checkAllScrolledPositionsWithoutOverlap(
      WidgetTester tester, {
      Size size,
    }) async {
      expect(
        tester.getRect(find.byKey(positionedKey)),
        Offset.zero & size,
        reason: 'position incorrect when not scrolled',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(
        tester.getRect(find.byKey(positionedKey)),
        const Offset(0, -200) & size,
        reason: 'position incorrect when scrolled past leading',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, 400));
      await tester.pump();
      expect(
        tester.getRect(find.byKey(positionedKey)),
        const Offset(0, 200) & size,
        reason: 'position incorrect when overscrolling leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(
        tester.getRect(find.byKey(positionedKey)),
        Offset.zero & size,
        reason: 'position incorrect when no longer scrolled',
      );
    }

    testWidgets(
        'sizes positioned.fill to maximum size of slivers when ignoring overlap',
        (tester) async {
      double totalSize;

      totalSize = await setupStack(tester, ignoreOverlap: true);
      await checkAllScrolledPositionsWithoutOverlap(
        tester,
        size: Size(800, totalSize),
      );

      totalSize = await setupStack(tester, ignoreOverlap: true, childCount: 20);
      await checkAllScrolledPositionsWithoutOverlap(
        tester,
        size: Size(800, totalSize),
      );
    });

    // testWidgets('shows all positioned children', (tester) async {
    //   await setupStack(tester);
    //   expect(tester.getRect(find.byKey(positionedKey)),
    //       const Rect.fromLTWH(0, 150, 800, 600));
    //   expect(
    //       tester.renderObject(find.byKey(stackKey)), isA<RenderSliverStack>());
    //   final stackSliver =
    //       tester.renderObject(find.byKey(stackKey)) as RenderSliverStack;
    //   expectAllExtents(stackSliver, 600);

    //   await tester.dragFrom(const Offset(400, 300), const Offset(0, -100));
    //   await tester.pumpAndSettle();
    //   expect(tester.getRect(find.byKey(positionedKey)),
    //       const Rect.fromLTWH(0, 150, 800, 500));
    //   expect(stackSliver.geometry.scrollExtent, 600);
    //   expect(stackSliver.geometry.paintExtent, 550);
    //   expect(stackSliver.geometry.layoutExtent, 550);
    //   await tester.dragFrom(const Offset(400, 300), const Offset(0, 200));
    //   await tester.pump();
    //   expect(tester.getRect(find.byKey(positionedKey)),
    //       const Rect.fromLTWH(0, 150, 800, 700));
    //   expect(stackSliver.geometry.scrollExtent, 600);
    //   expect(stackSliver.geometry.paintExtent, 350);
    //   expect(stackSliver.geometry.layoutExtent, 350);
    // });

    // testWidgets('shows all positioned children when ignoring overlap',
    //     (tester) async {
    //   await setupStack(tester, ignoreOverlap: true);
    //   expect(tester.getRect(find.byKey(positionedKey)),
    //       const Rect.fromLTWH(0, 150, 800, 600));
    //   expect(
    //       tester.renderObject(find.byKey(stackKey)), isA<RenderSliverStack>());
    //   final stackSliver =
    //       tester.renderObject(find.byKey(stackKey)) as RenderSliverStack;
    //   expectAllExtents(stackSliver, 600);

    //   await tester.dragFrom(const Offset(400, 300), const Offset(0, -300));
    //   await tester.pumpAndSettle();
    //   expect(tester.getRect(find.byKey(positionedKey)),
    //       const Rect.fromLTWH(0, -150, 800, 600));
    //   expect(stackSliver.geometry.scrollExtent, 600);
    //   expect(stackSliver.geometry.paintExtent, 450);
    //   expect(stackSliver.geometry.layoutExtent, 450);
    //   await tester.dragFrom(const Offset(400, 300), const Offset(0, 400));
    //   await tester.pump();
    //   expect(tester.getRect(find.byKey(positionedKey)),
    //       const Rect.fromLTWH(0, 250, 800, 600));
    //   expect(stackSliver.geometry.scrollExtent, 600);
    //   expect(stackSliver.geometry.paintExtent, 350);
    //   expect(stackSliver.geometry.layoutExtent, 350);
    // });
  });
}
