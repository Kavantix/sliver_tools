import 'dart:ui';

import 'package:flutter/material.dart';


/// A point within a sliver along its main axis.
///
/// `AlignmentSliver(0.0)` represents the center of the axis. The distance
/// from -1.0 to +1.0 is the distance from one side of the axis to the
/// other side of the axis. Therefore, 2.0 units are equivalent to the length
/// of the axis.
///
/// `AlignmentSliver(-1.0)` represents the start of the sliver.
///
/// `AlignmentSliver(1.0)` represents the end of the sliver.
///
/// `AlignmentSliver(3.0)` represents a point which extends beyond the end of
/// the sliver by the scrollExtent of the sliver.
///
/// `AlignmentSliver(-0.5)` represents a point that is half way between the
/// start and the center of the sliver.
///
/// `AlignmentSliver(value)` in a sliver with extent x describes the point
/// (value * x/2 + x/2) along its axisDirection.
///
/// [AlignmentSliver] uses visual coordinates, which means increasing [value]
/// moves the point from start to end. Which end of the sliver is set as the
/// start- and the endpoint is determined by the sliver and it's axisDirection.
///
/// See also:
/// 
///  * [SliverAlign] positions a child according to an [AlignmentSliver]
@immutable
class AlignmentSliver {
  /// Creates a sliver alignment.
  ///
  /// The [value] argument must not be null.
  const AlignmentSliver(this.value);

  /// The distance fraction in the main axis direction.
  ///
  /// A value of -1.0 corresponds to the starting edge. A value of 1.0
  /// corresponds to the ending edge. Values are not limited to that range;
  /// values less than -1.0 represent positions before of the left edge, and
  /// values greater than 1.0 represent positions after the right edge.
  final double value;
  
  /// The starting point of the main axis
  static const start = AlignmentSliver(-1.0);

  /// The center point of the main axis
  static const center = AlignmentSliver(0.0);

  /// The end point of the main axis
  static const end = AlignmentSliver(1.0);

  AlignmentSliver add(AlignmentSliver other) {
    return this + other;
  }

  /// Returns the difference between two [AlignmentSliver]s.
  AlignmentSliver operator -(AlignmentSliver other) {
    return AlignmentSliver(value - other.value);
  }

  /// Returns the sum of two [AlignmentSliver]s.
  AlignmentSliver operator +(AlignmentSliver other) {
    return AlignmentSliver(value + other.value);
  }

  /// Returns the negation of the given [AlignmentSliver].
  AlignmentSliver operator -() {
    return AlignmentSliver(-value);
  }

  /// Scales the [AlignmentSliver] value by the given factor.
  AlignmentSliver operator *(double other) {
    return AlignmentSliver(value * other);
  }

  /// Divides the [AlignmentSliver] value by the given factor.
  AlignmentSliver operator /(double other) {
    return AlignmentSliver(value / other);
  }

  /// Integer divides the [AlignmentSliver] value by the given factor.
  AlignmentSliver operator ~/(double other) {
    return AlignmentSliver((value ~/ other).toDouble());
  }

  /// Computes the remainder of `value` by the given factor.
  AlignmentSliver operator %(double other) {
    return AlignmentSliver(value % other);
  }

  /// Returns the offset that is this fraction in the direction of the given extent.
  Offset alongAxis(AxisDirection axisDirection, double extent) {
    final double axisCenter = extent / 2.0;
    final double position = axisCenter + value * axisCenter;
    switch(axisDirection) {
      case AxisDirection.up:
        return Offset(0.0, -position);
      case AxisDirection.down:
        return Offset(0.0, position);
      case AxisDirection.left:
        return Offset(-position, 0.0);
      case AxisDirection.right:
        return Offset(position, 0.0);
    }
  }

  /// Linearly interpolate between two [AlignmentSliver]s.
  ///
  /// If either is null, this function interpolates from [AlignmentSliver.center].
  ///
  /// {@macro dart.ui.shadow.lerp}
  static AlignmentSliver? lerp(AlignmentSliver? a, AlignmentSliver? b, double t) {
    if (a == null && b == null)
      return null;
    if (a == null)
      return AlignmentSliver(lerpDouble(0.0, b!.value, t)!);
    if (b == null)
      return AlignmentSliver(lerpDouble(a.value, 0.0, t)!);
    return AlignmentSliver(lerpDouble(a.value, b.value, t)!);
  }

  static String _stringify(double value) {
    if (value == -1.0)
      return 'AlignmentSliver.start';
    if (value == 0.0)
      return 'AlignmentSliver.center';
    if (value == 1.0)
      return 'AlignmentSliver.end';
    return 'AlignmentSliver(${value.toStringAsFixed(1)})';
  }

  @override
  String toString() => _stringify(value);

  @override
  bool operator ==(Object other) {
    return other is AlignmentSliver
        && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}