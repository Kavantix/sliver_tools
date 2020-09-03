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

  /// The child widget that will be rendered
  final Widget child;

  const SliverAnimatedPaintExtent({Key key, @required this.duration, @required this.child})
      : super(key: key);

  @override
  _SliverAnimatedPaintExtentState createState() => _SliverAnimatedPaintExtentState();
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
    );
  }
}

class _SliverAnimatedPaintExtent extends SingleChildRenderObjectWidget {
  final AnimationController controller;
  final Duration duration;

  const _SliverAnimatedPaintExtent({
    Key key,
    @required this.controller,
    @required this.duration,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderSliverAnimatedPaintExtent createRenderObject(BuildContext context) {
    return RenderSliverAnimatedPaintExtent()
      ..duration = duration
      ..controller = controller;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverAnimatedPaintExtent renderObject) {
    renderObject
      ..duration = duration
      ..controller = controller;
  }
}

/// The RenderObject that handles the animation for [SliverAnimatedPaintExtent]
class RenderSliverAnimatedPaintExtent extends RenderProxySliver {
  Duration duration;

  AnimationController _controller;
  AnimationController get controller => _controller;
  set controller(AnimationController controller) {
    if (controller != _controller) {
      _controller = controller;
      _controller?.removeListener(_update);
      controller.addListener(_update);
    }
  }

  void _update() {
    if (_lastValue == controller.value) return;
    markNeedsLayout();
  }

  Tween<double> _extentTween;
  double _lastValue = 0;

  void _restartAnimation() {
    _extentTween.begin = geometry.maxPaintExtent;
    _extentTween.end = child.geometry.maxPaintExtent;
    _controller.duration = duration;
    _lastValue = 0;
    _controller.forward(from: 0);
  }

  @override
  void performLayout() {
    _lastValue = controller.value;
    child.layout(constraints, parentUsesSize: true);
    final extent = _extentTween ??=
        Tween<double>(begin: child.geometry.maxPaintExtent, end: child.geometry.maxPaintExtent);
    if (child.geometry.maxPaintExtent != extent.end) {
      _restartAnimation();
    }
    final maxPaintExtent = extent.evaluate(controller);
    final paintExtent =
        max(0.0, min(child.geometry.paintExtent, maxPaintExtent - constraints.scrollOffset));
    final layoutExtent = min(child.geometry.layoutExtent, child.geometry.paintOrigin + paintExtent);
    final hitTestExtent =
        min(child.geometry.hitTestExtent, child.geometry.paintOrigin + paintExtent);
    geometry = SliverGeometry(
      paintOrigin: child.geometry.paintOrigin,
      scrollExtent: child.geometry.scrollExtent,
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
  bool get alwaysNeedsCompositing =>
      _controller?.isAnimating ?? false || super.alwaysNeedsCompositing;

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
        child.needsCompositing,
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
