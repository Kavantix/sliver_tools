import 'package:flutter/widgets.dart';

import 'types/sliver_alignment.dart';
import 'rendering/sliver_align.dart';

/// A widget which sizes itself relative to its child's scrollExtent (i.e. main
/// axis size) and positions its child according to an [SliverAlignment].
/// 
/// {@tool snippet}
/// The following example creates a list where each list-tile has a nested,
/// collapsable list of slivers
/// 
/// ```dart
/// MultiSliver(
///   children: for (var item in list) MultiSliver(
///     children: [
///       ListTileHeader(),
///       AnimatedBuilder(
///         animation: _heightFactor,
///         builder: (context, child) => SliverClip(
///           child: SliverAlign(
///           alignment: SliverAlignment.center,
///           mainAxisFactor: _heightFactor.value,
///           child: child,
///         ),
///         child: MultiSliver(
///           children: ... // NestedList
///         ),
///       ],
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
class SliverAlign extends SingleChildRenderObjectWidget {
  /// Creates an alignment widget.
  ///
  /// The alignment defaults to [SliverAlignment.center].
  const SliverAlign({
    Key? key,
    this.alignment = SliverAlignment.center,
    this.mainAxisFactor,
    Widget? child,
  }) : super(key: key, child: child);

  /// How to align the child.
  ///
  /// The value of the alignment controls the child's position relative to its
  /// scrollExtent and axisDirection. A value of -1.0 means that the leading
  /// edge of the child is positioned at the leading edge of the parent whereas
  /// a value of 1.0 means that the trailing edge of the child is aligned with
  /// the traling edge of the parent. Other values interpolate (and extrapolate)
  /// linearly. For example, a value of 0.0 means that the center of the child
  /// is aligned with the center of the parent.
  final SliverAlignment alignment;

  /// If non-null, sets its scrollExtent to the child's scrollExtent multiplied
  /// by this factor.
  ///
  /// Can be both greater and less than 1.0 but must be non-negative.
  final double? mainAxisFactor;

  @override
  RenderSliverAlign createRenderObject(BuildContext context) {
    return RenderSliverAlign(
      alignment: alignment,
      mainAxisFactor: mainAxisFactor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverAlign renderObject) {
    renderObject
      ..alignment = alignment
      ..mainAxisFactor = mainAxisFactor;
  }
}