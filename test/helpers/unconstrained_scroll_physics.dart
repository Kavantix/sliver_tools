import 'package:flutter/widgets.dart';

class UnconstrainedScollPhysics extends ScrollPhysics {
  const UnconstrainedScollPhysics();

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return this;
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics _) => true;
}
