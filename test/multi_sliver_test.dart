import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'helpers/pinned_header.dart';

class _UnconstrainedScollPhysics extends ScrollPhysics {
  const _UnconstrainedScollPhysics();

  @override
  ScrollPhysics applyTo(ScrollPhysics ancestor) {
    return this;
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics _) => true;
}

void main() {
  group('MultiSliver', () {
    Widget box(Key key, String title, {@required double height}) {
      return Container(
        key: key,
        alignment: Alignment.center,
        height: height,
        width: double.infinity,
        child: Text(title),
      );
    }

    const box1Key = ValueKey('1');
    const box2Key = ValueKey('list');
    const groupKey = ValueKey('group');
    const pinnedKey = ValueKey('pinned');
    const childSize = 300.0;
    const pinnedSize = 150.0;

    Future<double> setupMultiSliver(
      WidgetTester tester, {
      int childCount = 2,
      bool includePinned = false,
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            physics: const _UnconstrainedScollPhysics(),
            slivers: [
              MultiSliver(
                key: groupKey,
                children: <Widget>[
                  if (includePinned)
                    const PinnedHeader(
                      size: pinnedSize,
                      boxKey: pinnedKey,
                    ),
                  SliverToBoxAdapter(
                    child: box(box1Key, '1', height: 150),
                  ),
                  SliverList(
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
      expect(multiSliver.geometry.scrollExtent, totalSize);
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
        multiSliver.geometry.maxPaintExtent,
        totalSize,
      );

      totalSize = await setupMultiSliver(tester, childCount: 20);
      expect(multiSliver.geometry.maxPaintExtent, totalSize);
      expect(multiSliver.geometry.paintOrigin, 0);
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(
        multiSliver.geometry.maxPaintExtent,
        totalSize,
        reason: 'maxPaintExtent incorrect when scrolled past leading edge',
      );
      expect(
        multiSliver.geometry.paintOrigin,
        0,
        reason: 'paintOrigin incorrect when scrolled past leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, 400));
      await tester.pump();
      expect(
        multiSliver.geometry.maxPaintExtent,
        totalSize,
        reason: 'maxPaintExtent incorrect when overscrolling leading edge',
      );
      expect(
        multiSliver.geometry.paintOrigin,
        0,
        reason: 'paintOrigin incorrect when overscrolling leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(multiSliver.geometry.maxPaintExtent, totalSize);
      expect(multiSliver.geometry.paintOrigin, 0);

      // test pinned
      totalSize =
          await setupMultiSliver(tester, childCount: 20, includePinned: true);
      expect(multiSliver.geometry.maxPaintExtent, totalSize);
      expect(multiSliver.geometry.paintOrigin, 0);
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(
        multiSliver.geometry.maxPaintExtent,
        totalSize,
        reason:
            'maxPaintExtent incorrect with pinned when scrolled past leading edge',
      );
      expect(
        multiSliver.geometry.paintOrigin,
        0,
        reason:
            'paintOrigin incorrect with pinned when overscrolling leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, 400));
      await tester.pump();
      expect(
        multiSliver.geometry.maxPaintExtent,
        totalSize + 200,
        reason:
            'maxPaintExtent incorrect with pinned when overscrolling leading edge',
      );
      expect(
        multiSliver.geometry.paintOrigin,
        -200,
        reason:
            'paintOrigin incorrect with pinned when overscrolling leading edge',
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -200));
      await tester.pump();
      expect(multiSliver.geometry.maxPaintExtent, totalSize);
      expect(multiSliver.geometry.paintOrigin, 0);
    });
  });
}
