# sliver_tools

A set of useful sliver tools that are missing from the flutter framework.


Here is a taste what you can make using this package

![Demo](https://raw.githubusercontent.com/Kavantix/sliver_tools/master/gifs/demo2.gif)

The structure of this app:
```dart
class Section extends State {
  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          ...
        ),
        if (!infinite)
          SliverAnimatedPaintExtent(
            child: SliverList(...),
          )
        else
          SliverList(...),
      ],
    );
  }
}

class NewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        Section(infinite: false),
        Section(infinite: true),
      ],
    );
  }
}
```

## [MultiSliver](https://github.com/Kavantix/sliver_tools/blob/master/lib/src/multi_sliver.dart)

The `MultiSliver` widget allows for grouping of multiple slivers together such that they can be returned as a single widget.
For instance when one wants to wrap a few slivers with some padding or an inherited widget.


### Example
```dart
class WidgetThatReturnsASliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiSliver(
     pushPinnedChildren: false, // defaults to false
     children: <Widget>[
        SliverPersistentHeader(...),
        SliverList(...),
      ],
    );
  }
}
```

The `pushPinnedChildren` parameter allows for achieving a 'sticky header' effect by simply using pinned `SliverPersistentHeader` widgets (or any custom sliver that paints beyond its layoutExtent).



## [SliverAnimatedPaintExtent](https://github.com/Kavantix/sliver_tools/blob/master/lib/src/sliver_animated_paint_extent.dart)

The `SliverAnimatedPaintExtent` widget allows for having a smooth transition when a sliver changes the space it will occupy inside the viewport.
For instance when using a SliverList with a button below it that loads the next few items.


### Example
```dart
class WidgetThatReturnsASliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 150),
      child: SliverList(...),
    );
  }
}
```
