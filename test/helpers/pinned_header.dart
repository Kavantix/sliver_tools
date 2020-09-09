import 'package:flutter/widgets.dart';

class PinnedDelegate extends SliverPersistentHeaderDelegate {
  final double size;
  final Key boxKey;

  const PinnedDelegate({
    @required this.size,
    this.boxKey,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      key: boxKey,
      width: size,
      height: size,
    );
  }

  @override
  double get maxExtent => size;

  @override
  double get minExtent => size;

  @override
  bool shouldRebuild(covariant PinnedDelegate oldDelegate) {
    return oldDelegate.size != size || oldDelegate.boxKey != boxKey;
  }
}

class PinnedHeader extends StatelessWidget {
  final double size;
  final Key boxKey;

  const PinnedHeader({
    Key key,
    @required this.size,
    this.boxKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: PinnedDelegate(
        size: size,
        boxKey: boxKey,
      ),
    );
  }
}
