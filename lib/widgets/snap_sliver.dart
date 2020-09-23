// import 'package:flutter/foundation.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';

// class SnapSliverController {
//   void Function(bool) onSnapChanged;
// }

// class SnapSliver extends StatefulWidget {
//   const SnapSliver(
//       {Key key,
//       this.child,
//       this.pinned = false,
//       this.floating = true,
//       this.maxHeight = 56,
//       this.minHeight = 56,
//       this.onSnapChanged})
//       : super(key: key);

//   final Widget child;
//   final bool pinned;
//   final bool floating;
//   final double minHeight;
//   final double maxHeight;
//   final void Function(bool) onSnapChanged;
//   @override
//   _SnapSliverState createState() => _SnapSliverState();
// }

// class _SnapSliverState extends State<SnapSliver> with TickerProviderStateMixin {
//   FloatingHeaderSnapConfiguration _snapConfiguration;

//   void _updateSnapConfiguration() {
//     _snapConfiguration = FloatingHeaderSnapConfiguration(
//       vsync: this,
//       curve: Curves.easeOut,
//       duration: const Duration(milliseconds: 200),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _updateSnapConfiguration();
//   }

//   @override
//   void didUpdateWidget(SnapSliver oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     _updateSnapConfiguration();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MediaQuery.removePadding(
//       context: context,
//       removeBottom: true,
//       child: SliverPersistentHeader(
//         floating: widget.floating,
//         pinned: widget.pinned,
//         delegate: _SnapSliverDelegate(
//           child: widget.child,
//           snapConfiguration: _snapConfiguration,
//           minHeight: widget.minHeight,
//           maxHeight: widget.maxHeight,
//           floating: widget.floating,
//           onSnapChanged: widget.onSnapChanged,
//         ),
//       ),
//     );
//   }
// }

// class _SnapSliverDelegate extends SliverPersistentHeaderDelegate {
//   _SnapSliverDelegate(
//       {@required this.child,
//       @required this.floating,
//       this.minHeight = 56,
//       this.maxHeight = 56,
//       @required this.snapConfiguration,
//       this.onSnapChanged});

//   final Widget child;
//   final double minHeight;
//   final double maxHeight;
//   final bool floating;
//   final void Function(bool) onSnapChanged;
//   @override
//   double get minExtent => minHeight;

//   @override
//   double get maxExtent => maxHeight;

//   @override
//   final FloatingHeaderSnapConfiguration snapConfiguration;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     // final Widget appBar = FlexibleSpaceBar.createSettings(
//     //   minExtent: minExtent,
//     //   maxExtent: maxExtent,
//     //   currentExtent: math.max(minExtent, maxExtent - shrinkOffset),
//     //   toolbarOpacity: toolbarOpacity,
//     //   child: child
//     // );
//     return floating
//         ? _FloatingSliver(
//             child: child,
//             onSnapChanged: onSnapChanged,
//           )
//         : child;
//   }

//   @override
//   bool shouldRebuild(covariant _SnapSliverDelegate oldDelegate) {
//     return child != oldDelegate.child;
//   }
// }

// class _FloatingSliver extends StatefulWidget {
//   const _FloatingSliver({Key key, this.child, this.onSnapChanged})
//       : super(key: key);

//   final Widget child;
//   final void Function(bool) onSnapChanged;
//   @override
//   _FloatingSliverState createState() => _FloatingSliverState();
// }

// class _FloatingSliverState extends State<_FloatingSliver> {
//   ScrollPosition _position;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (_position != null) {
//       _position.isScrollingNotifier.removeListener(_isScrollingListener);
//     }
//     _position = Scrollable.of(context)?.position;
//     if (_position != null) {
//       _position.isScrollingNotifier.addListener(_isScrollingListener);
//     }
//   }

//   @override
//   void dispose() {
//     if (_position != null) {
//       _position.isScrollingNotifier.removeListener(_isScrollingListener);
//     }
//     super.dispose();
//   }

//   RenderSliverFloatingPersistentHeader _headerRenderer() {
//     return context
//         .findAncestorRenderObjectOfType<RenderSliverFloatingPersistentHeader>();
//   }

//   void _isScrollingListener() {
//     if (_position == null) return;

// // _position.
//     // When a scroll stops, then maybe snap the appbar into view.
//     // Similarly, when a scroll starts, then maybe stop the snap animation.
//     final header = _headerRenderer();
//     widget.onSnapChanged(header.geometry.layoutExtent == 0.0);
//     // debugPrint("header.scrollExtent, ${header.geometry.scrollExtent}");
//     // debugPrint("header.hasVisualOverflow, ${header.geometry.hasVisualOverflow}");
//     // debugPrint("header.hitTestExtent, ${header.geometry.hitTestExtent}");

//     if (_position.isScrollingNotifier.value) {
//       header?.maybeStopSnapAnimation(_position.userScrollDirection);
//     } else {
//       header?.maybeStartSnapAnimation(_position.userScrollDirection);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print(_position == null);
//     return widget.child;
//   }
// }
