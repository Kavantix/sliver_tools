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

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// [SliverAnimatedPaintExtent] allows for smoothly animating maxPaintExtent changes
class SliverAnimatedPaintExtent extends StatefulWidget {
  /// The duration that the animation will take
  final Duration duration;

  /// The curve for the animation
  final Curve curve;

  /// The child widget that will be rendered
  final Widget child;

  const SliverAnimatedPaintExtent({
    Key key,
    @required this.duration,
    @required this.child,
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  _SliverAnimatedPaintExtentState createState() =>
      _SliverAnimatedPaintExtentState();
}

class _SliverAnimatedPaintExtentState extends State<SliverAnimatedPaintExtent>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SliverAnimatedPaintExtent(
      controller: _controller,
      duration: widget.duration,
      child: widget.child,
      curve: widget.curve,
    );
  }
}

class _SliverAnimatedPaintExtent extends SingleChildRenderObjectWidget {
  /// The controller in charge of the animation
  final AnimationController controller;

  /// The duration that the animation will take
  final Duration duration;

  /// The curve for the animation
  final Curve curve;

  const _SliverAnimatedPaintExtent({
    Key key,
    @required this.controller,
    @required this.duration,
    @required this.curve,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderSliverAnimatedPaintExtent createRenderObject(BuildContext context) {
    return RenderSliverAnimatedPaintExtent()
      ..duration = duration
      ..controller = controller
      ..curve = curve;
  }

  @override
  void updateRenderObject(BuildContext context,
      covariant RenderSliverAnimatedPaintExtent renderObject) {
    renderObject
      ..duration = duration
      ..controller = controller
      ..curve = curve;
  }
}

/// The RenderObject that handles the animation for [SliverAnimatedPaintExtent]
class RenderSliverAnimatedPaintExtent extends RenderProxySliver {
  /// The duration that the animation will take
  Duration duration;

  /// The curve for the animation
  Curve curve;

  AnimationController _controller;

  /// The controller in charge of the animation
  AnimationController get controller => _controller;
  set controller(AnimationController value) {
    if (value != _controller) {
      _controller?.removeListener(_update);
      _controller = value;
      _controller.addListener(_update);
    }
  }

  void _update() {
    if (_lastValue == controller.value) return;
    markNeedsLayout();
  }

  Tween<double> _paintExtentTween;
  Tween<double> _scrollExtentTween;
  double _lastValue = 0;

  void _restartAnimation() {
    _paintExtentTween.begin = geometry.maxPaintExtent;
    _paintExtentTween.end = child.geometry.maxPaintExtent;
    _scrollExtentTween.begin = geometry.scrollExtent;
    _scrollExtentTween.end = child.geometry.scrollExtent;
    _lastValue = 0;
    _controller.value = 0;
    _controller.animateTo(1, duration: duration, curve: curve);
  }

  @override
  void performLayout() {
    _lastValue = controller.value;
    child.layout(constraints, parentUsesSize: true);
    final extentTween = _paintExtentTween ??= Tween<double>(
        begin: child.geometry.maxPaintExtent,
        end: child.geometry.maxPaintExtent);
    final scrollExtentTween = _scrollExtentTween ??= Tween<double>(
        begin: child.geometry.scrollExtent, end: child.geometry.scrollExtent);
    if (child.geometry.maxPaintExtent != extentTween.end ||
        child.geometry.scrollExtent != scrollExtentTween.end) {
      _restartAnimation();
    }
    final maxPaintExtent = extentTween.evaluate(controller);
    final scrollExtent = scrollExtentTween.evaluate(controller);
    double paintExtent;
    double layoutExtent;
    if (extentTween.begin > extentTween.end) {
      paintExtent = max(
          0.0,
          max(child.geometry.paintExtent,
              maxPaintExtent - constraints.scrollOffset));
      paintExtent = min(paintExtent,
          constraints.remainingPaintExtent - child.geometry.paintOrigin);
      layoutExtent = max(child.geometry.layoutExtent,
          child.geometry.paintOrigin + paintExtent);
    } else {
      paintExtent = max(
          0.0,
          min(child.geometry.paintExtent,
              maxPaintExtent - constraints.scrollOffset));
      layoutExtent = min(child.geometry.layoutExtent,
          child.geometry.paintOrigin + paintExtent);
    }
    final hitTestExtent = min(
        child.geometry.hitTestExtent, child.geometry.paintOrigin + paintExtent);
    geometry = SliverGeometry(
      paintOrigin: child.geometry.paintOrigin,
      scrollExtent: scrollExtent,
      paintExtent: paintExtent,
      layoutExtent: layoutExtent,
      maxPaintExtent: maxPaintExtent,
      cacheExtent: child.geometry.cacheExtent,
      maxScrollObstructionExtent: child.geometry.maxScrollObstructionExtent,
      visible: child.geometry.visible,
      hitTestExtent: hitTestExtent,
      hasVisualOverflow: child.geometry.hasVisualOverflow,
      scrollOffsetCorrection: child.geometry.scrollOffsetCorrection,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      layer = null;
      return;
    }
    Offset bottomRight;
    switch (constraints.axis) {
      case Axis.horizontal:
        bottomRight = Offset(geometry.paintExtent, constraints.crossAxisExtent);
        break;
      case Axis.vertical:
        bottomRight = Offset(constraints.crossAxisExtent, geometry.paintExtent);
        break;
    }
    if (_controller.isAnimating) {
      layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromPoints(Offset.zero, bottomRight),
        (context, offset) => super.paint(context, offset),
        oldLayer: layer as ClipRectLayer,
      );
    } else {
      layer = null;
      super.paint(context, offset);
    }
  }
}
