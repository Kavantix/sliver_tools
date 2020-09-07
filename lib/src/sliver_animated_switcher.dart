// The MIT License (MIT)
//
// Copyright (c) 2020 Pieter van Loon
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
