import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sliver_tools/src/rendering/sliver_cross_axis_positioned.dart';

void main() {
  group('SliverCrossAxisPadded', () {
    group('SliverCrossAxisPositionData', () {
      const double crossAxisExtent = 800;
      const constraints = SliverConstraints(
        overlap: 0,
        cacheOrigin: 0,
        scrollOffset: 0,
        axisDirection: AxisDirection.down,
        growthDirection: GrowthDirection.forward,
        crossAxisExtent: crossAxisExtent,
        crossAxisDirection: AxisDirection.right,
        userScrollDirection: ScrollDirection.idle,
        remainingPaintExtent: 800,
        remainingCacheExtent: 800,
        precedingScrollExtent: 0,
        viewportMainAxisExtent: 800,
      );

      SliverCrossAxisPadded createWidget({
        double paddingStart = 0,
        double paddingEnd = 0,
        TextDirection textDirection = TextDirection.ltr,
      }) {
        return SliverCrossAxisPadded(
          child: const SizedBox.shrink(),
          textDirection: textDirection,
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
        );
      }

      RenderSliverCrossAxisPadded setup({
        double paddingStart = 0,
        double paddingEnd = 0,
        TextDirection textDirection = TextDirection.ltr,
      }) {
        final widget = createWidget(
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
          textDirection: textDirection,
        );
        return widget.createRenderObject(null);
      }

      SliverCrossAxisPositionedData positionedDataForUpdatedWidget({
        @required RenderSliverCrossAxisPadded renderObject,
        @required double paddingStart,
        @required double paddingEnd,
        @required TextDirection textDirection,
        SliverConstraints updatedConstraints,
      }) {
        createWidget(
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
          textDirection: textDirection,
        ).updateRenderObject(null, renderObject);
        return renderObject
            .createCrossAxisPositionData(updatedConstraints ?? constraints);
      }

      test('correctly set for 0 values', () {
        final renderObject = setup();
        final positionData =
            renderObject.createCrossAxisPositionData(constraints);
        expect(positionData.crossAxisExtent, crossAxisExtent);
        expect(positionData.crossAxisPosition, 0.0);
      });

      test('correctly set for non zero values', () {
        const double paddingStart = 123;
        const double paddingEnd = 243;
        final renderObject = setup(
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
        );
        final positionData =
            renderObject.createCrossAxisPositionData(constraints);
        expect(positionData.crossAxisExtent,
            crossAxisExtent - paddingStart - paddingEnd);
        expect(positionData.crossAxisPosition, paddingStart);
      });

      test('correctly set for non zero values with rtl textDirection', () {
        const double paddingStart = 223;
        const double paddingEnd = 322;
        final renderObject = setup(
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
          textDirection: TextDirection.rtl,
        );
        final positionData =
            renderObject.createCrossAxisPositionData(constraints);
        expect(positionData.crossAxisExtent,
            crossAxisExtent - paddingStart - paddingEnd);
        expect(positionData.crossAxisPosition, paddingEnd);
      });

      test('correctly updates values', () {
        double paddingStart = 223;
        double paddingEnd = 322;
        final renderObject = setup(
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
          textDirection: TextDirection.rtl,
        );
        var positionData =
            renderObject.createCrossAxisPositionData(constraints);
        expect(positionData.crossAxisExtent,
            crossAxisExtent - paddingStart - paddingEnd);
        expect(positionData.crossAxisPosition, paddingEnd);

        // textDirection swapped
        positionData = positionedDataForUpdatedWidget(
          renderObject: renderObject,
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
          textDirection: TextDirection.ltr,
        );
        expect(positionData.crossAxisExtent,
            crossAxisExtent - paddingStart - paddingEnd);
        expect(positionData.crossAxisPosition, paddingStart);

        // paddingStart increased
        paddingStart += 100;
        positionData = positionedDataForUpdatedWidget(
          renderObject: renderObject,
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
          textDirection: TextDirection.ltr,
        );
        expect(positionData.crossAxisExtent,
            crossAxisExtent - paddingStart - paddingEnd);
        expect(positionData.crossAxisPosition, paddingStart);

        // paddingEnd decreased
        paddingEnd -= 80;
        positionData = positionedDataForUpdatedWidget(
          renderObject: renderObject,
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
          textDirection: TextDirection.ltr,
        );
        expect(positionData.crossAxisExtent,
            crossAxisExtent - paddingStart - paddingEnd);
        expect(positionData.crossAxisPosition, paddingStart);
      });

      test('ignores textDirection when axis is horizontal', () {
        const double paddingStart = 223;
        const double paddingEnd = 322;
        final renderObject = setup(
          paddingStart: paddingStart,
          paddingEnd: paddingEnd,
          textDirection: TextDirection.rtl,
        );
        final positionData =
            renderObject.createCrossAxisPositionData(constraints.copyWith(
          axisDirection: AxisDirection.right,
          crossAxisDirection: AxisDirection.down,
        ));
        expect(positionData.crossAxisExtent,
            crossAxisExtent - paddingStart - paddingEnd);
        expect(positionData.crossAxisPosition, paddingStart);
      });

      test(
          'throws assertion error if total padding is more than crossAxisExtent',
          () {
        final renderObject = setup(
            paddingStart: crossAxisExtent / 2 + 1,
            paddingEnd: crossAxisExtent / 2);

        // Make sure errors caught by flutter bubble up
        FlutterError.onError = (error) => throw error.exception;
        expect(
          () => renderObject.layout(constraints, parentUsesSize: true),
          throwsAssertionError,
        );
      });
    });
  });
}
