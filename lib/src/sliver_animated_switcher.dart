import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SliverAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SliverAnimatedSwitcher(
      {Key key, @required this.child, @required this.duration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      layoutBuilder: (currentChild, previousChildren) {
        return SliverStack(
          children: <Widget>[
            ...previousChildren,
            currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) =>
          SliverFadeTransition(opacity: animation, sliver: child),
      child: child,
    );
  }
}
