import 'package:flutter/widgets.dart';

import 'sliver_stack.dart';

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

  /// The reverse duration to pass to the [AnimatedSwitcher]
  final Duration? reverseDuration;

  /// The switch in curve to pass to the [AnimatedSwitcher]
  final Curve switchInCurve;

  /// The switch out curve to pass to the [AnimatedSwitcher]
  final Curve switchOutCurve;

  const SliverAnimatedSwitcher({
    Key? key,
    required this.child,
    required this.duration,
    this.reverseDuration,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
  }) : super(key: key);

  static Widget defaultLayoutBuilder(
      Widget? currentChild, List<Widget> previousChildren) {
    return SliverStack(
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
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
      reverseDuration: reverseDuration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      layoutBuilder: defaultLayoutBuilder,
      transitionBuilder: defaultTransitionBuilder,
      child: child,
    );
  }
}
