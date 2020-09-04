import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/src/multi_sliver.dart';

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

    testWidgets('shows all child slivers', (tester) async {
      const box1Key = ValueKey('1');
      const box2Key = ValueKey('list');
      const groupKey = ValueKey('group');
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            slivers: [
              MultiSliver(
                key: groupKey,
                children: <Widget>[
                  SliverToBoxAdapter(
                    child: box(box1Key, '1', height: 150),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return box(index == 0 ? box2Key : null, '2', height: 300);
                    }, childCount: 2),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      expect(find.byKey(box1Key), findsOneWidget);
      expect(tester.getRect(find.byKey(box1Key)),
          const Rect.fromLTWH(0, 0, 800, 150));
      expect(tester.getRect(find.byKey(box2Key)),
          const Rect.fromLTWH(0, 150, 800, 300));
      expect(
          tester.renderObject(find.byKey(groupKey)), isA<RenderMultiSliver>());
      expect(
          (tester.renderObject(find.byKey(groupKey)) as RenderMultiSliver)
              .geometry
              .scrollExtent,
          750);
    });
  });
}
