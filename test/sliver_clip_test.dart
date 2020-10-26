import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'helpers/pinned_header.dart';

void main() {
  group('SliverClip', () {
    Widget box(Key key, {double size}) {
      return Container(
        key: key,
        alignment: Alignment.center,
        height: size,
        width: size,
      );
    }

    const box1Key = ValueKey('box 1');
    const boxInListKey = ValueKey('box in list');
    const clipKey = ValueKey('clip');

    Future<void> setupClip(WidgetTester tester,
        {bool reverse = false, Axis scrollDirection = Axis.vertical}) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            reverse: reverse,
            scrollDirection: scrollDirection,
            slivers: [
              const PinnedHeader(
                size: 150,
                boxKey: box1Key,
              ),
              SliverClip(
                key: clipKey,
                child: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return box(
                        index == 0 ? boxInListKey : null,
                        size: 300,
                      );
                    },
                    childCount: 2,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 800, width: 800),
              ),
            ],
          ),
        ),
      );
      expect(find.byKey(box1Key), findsOneWidget);
      expect(find.byKey(boxInListKey), findsOneWidget);
      expect(find.byKey(clipKey), findsOneWidget);
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

    testWidgets('positions and clips correctly', (tester) async {
      await setupClip(tester);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(0, 0, 800, 150));
      expect(tester.getRect(find.byKey(boxInListKey)),
          const Rect.fromLTWH(0, 150, 800, 300));
      expect(tester.renderObject(find.byKey(clipKey)), isA<RenderSliverClip>());
      final clipSliver =
          tester.renderObject(find.byKey(clipKey)) as RenderSliverClip;
      expectAllExtents(clipSliver, 600);

      expect(
        clipSliver.clipRect,
        const Rect.fromLTWH(0, 0, 800, 450),
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -100));
      await tester.pump();
      expect(
        clipSliver.clipRect,
        const Rect.fromLTWH(0, 100, 800, 450),
      );
    });

    testWidgets('positions and clips correctly horizontal', (tester) async {
      await setupClip(tester, scrollDirection: Axis.horizontal);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(0, 0, 150, 600));
      expect(tester.getRect(find.byKey(boxInListKey)),
          const Rect.fromLTWH(150, 0, 300, 600));
      expect(tester.renderObject(find.byKey(clipKey)), isA<RenderSliverClip>());
      final clipSliver =
          tester.renderObject(find.byKey(clipKey)) as RenderSliverClip;
      expectAllExtents(clipSliver, 600);

      expect(
        clipSliver.clipRect,
        const Rect.fromLTWH(0, 0, 600, 600),
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(-100, 0));
      await tester.pump();
      expect(
        clipSliver.clipRect,
        const Rect.fromLTWH(100, 0, 500, 600),
      );
    });

    testWidgets('positions and clips correctly when in reverse',
        (tester) async {
      await setupClip(tester, reverse: true);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(0, 450, 800, 150));
      expect(tester.getRect(find.byKey(boxInListKey)),
          const Rect.fromLTWH(0, 150, 800, 300));
      expect(tester.renderObject(find.byKey(clipKey)), isA<RenderSliverClip>());
      final clipSliver =
          tester.renderObject(find.byKey(clipKey)) as RenderSliverClip;
      expectAllExtents(clipSliver, 600);

      expect(
        clipSliver.clipRect,
        const Rect.fromLTWH(0, 0, 800, 450),
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, 100));
      await tester.pump();
      expect(
        clipSliver.clipRect,
        const Rect.fromLTWH(0, 0, 800, 450),
      );
    });

    testWidgets('positions and clips correctly when horizontal in reverse',
        (tester) async {
      await setupClip(tester, scrollDirection: Axis.horizontal, reverse: true);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(650, 0, 150, 600));
      expect(tester.getRect(find.byKey(boxInListKey)),
          const Rect.fromLTWH(350, 0, 300, 600));
      expect(tester.renderObject(find.byKey(clipKey)), isA<RenderSliverClip>());
      final clipSliver =
          tester.renderObject(find.byKey(clipKey)) as RenderSliverClip;
      expectAllExtents(clipSliver, 600);

      expect(
        clipSliver.clipRect,
        const Rect.fromLTWH(0, 0, 600, 600),
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(100, 0));
      await tester.pump();
      expect(
        clipSliver.clipRect,
        const Rect.fromLTWH(0, 0, 500, 600),
      );
    });
  });
}
