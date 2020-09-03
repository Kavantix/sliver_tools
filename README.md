# sliver_tools

A set of useful sliver tools that are missing from the flutter framework.

## multi_sliver

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
`TODO: insert Gif of a sticky header example`


## sliver_animated_paint_extent

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
