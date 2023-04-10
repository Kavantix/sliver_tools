# 0.2.10

Fixed issue with hit testing of [SliverCrossAxisConstrained].

# 0.2.9

* Fixed #70 by using a specific hit test method with thanks to @knopp
* Fixed an edge case where `SliverClipRect` could have a null dereference with thanks to @siqwin

# 0.2.8

- Fixed #56 by accounting for maxScrollObstructionExtent with thanks to @manu-sncf
- Added some asserts to validate layout of children

# 0.2.7

Fixed issue when using a `center` key in the CustomScrollView when using `MultiSliver`.

# 0.2.6

Added `alignment` property to [SliverCrossAxisConstrained].

# 0.2.5

Fixed issue where the `maxPaintExtent` was not calculated correctly in some rare cases.

# 0.2.4

Fixed formatting for pub analysis.

# 0.2.3

Fixed dev_dependency for pub analysis.

# 0.2.2

Fixed issue where small content of a `MultiSliver` would cause an exception when
the overlap it got was larger.

# 0.2.1

This version essentially makes the `SliverToBoxAdapter` widget obsolete.
MultiSliver now accepts `RenderBox` children directly!🎉

- Accept box children of MultiSliver.
- Fixed floating point rounding error that happens in debug mode.

# 0.2.0

BREAKING:
- Migrated to nullsafety
- All render objects are now part of the private api.
  *If you want to depend on them as public API, please open an issue.*

# 0.1.10

Further improved `childScrollOffset` of [MultiSliver].
[MultiSliver] now correctly passes the incoming `precedingScrollExtent` to the children.

# 0.1.9

Fixed edge cases for `applyPaintTransform` and `childScrollOffset` of [MultiSliver].

# 0.1.8

Improved hit testing of positioned children in [SliverStack].

# 0.1.7

Fixed issue where hit testing of positioned children in [SliverStack] failed.

# 0.1.6

Fixed issue where hit testing of a pinned [SliverPinnedHeader] failed.

# 0.1.5

Added [SliverPinnedHeader]

# 0.1.4+1

Fixes small layoutExtent issue in [MultiSliver]

# 0.1.4

Added [SliverCrossAxisPadded]

# 0.1.3

Added [SliverCrossAxisConstrained] with thanks to @remonh87

# 0.1.2+3

- Improved handling of reverse scroll direction
- Added `insetOnOverlap` parameter to [SliverStack]

# 0.1.2+2

Fixed a small analysis issue

# 0.1.2

Added the following widgets:
- [SliverStack]
- [SliverClip]
- [SliverAnimatedSwitcher]

# 0.1.1

Updated readme and changelog links

# 0.1.0

Initial release including:
- [MultiSliver]
- [SliverAnimatedPaintExtent]

[MultiSliver]: https://github.com/Kavantix/sliver_tools/blob/master/lib/src/multi_sliver.dart
[SliverAnimatedPaintExtent]: https://github.com/Kavantix/sliver_tools/blob/master/lib/src/sliver_animated_paint_extent.dart
[SliverStack]: https://github.com/Kavantix/sliver_tools/blob/master/lib/src/sliver_stack.dart
[SliverClip]: https://github.com/Kavantix/sliver_tools/blob/master/lib/src/sliver_clip.dart
[SliverAnimatedSwitcher]: https://github.com/Kavantix/sliver_tools/blob/master/lib/src/sliver_animated_switcher.dart
[SliverCrossAxisConstrained]: https://github.com/Kavantix/sliver_tools/blob/master/lib/src/sliver_cross_axis_constrained.dart
[SliverCrossAxisPadded]: https://github.com/Kavantix/sliver_tools/blob/master/lib/src/sliver_cross_axis_padded.dart
[SliverPinnedHeader]: https://github.com/Kavantix/sliver_tools/blob/master/lib/src/sliver_pinned_header.dart
