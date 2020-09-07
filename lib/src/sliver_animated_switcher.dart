import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// [SliverAnimatedSwitcher] sets up an [AnimatedSwitcher] widget such that
/// it can be used as a sliver by using [SliverStack] and [SliverFadeTransition]
///
/// If you wish to use more option of [AnimatedSwitcher] than just the [duration]
/// you can use the [defaultLayoutBuilder] and [defaultTransitionBuilder] in a
/// regular [AnimatedSwitcher]
class SliverAnimatedSwitcher extends StatelessWidget {
  /// The child to pass to the [AnimatedSwitcher]
  final Widget child;

  /// The duration to pass to the [AnimatedSwitcher]
  final Duration duration;

  const SliverAnimatedSwitcher({
    Key key,
    @required this.child,
    @required this.duration,
  }) : super(key: key);

  static Widget defaultLayoutBuilder(
      Widget currentChild, List<Widget> previousChildren) {
    return SliverStack(
      children: <Widget>[
        ...previousChildren,
        currentChild,
      ],
    );
  }

  static Widget defaultTransitionBuilder(
          Widget child, Animation<double> animation) =>
      SliverFadeTransition(opacity: animation, sliver: child);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      layoutBuilder: defaultLayoutBuilder,
      transitionBuilder: defaultTransitionBuilder,
      child: child,
    );
  }
}
