import 'package:flutter/material.dart';

class BouncingScrollWrapper extends StatelessWidget {
  final Widget child;

  const BouncingScrollWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  static Widget builder(BuildContext context, Widget child) {
    return BouncingScrollWrapper(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _BouncingScrollBehavior(),
      child: child,
    );
  }
}

class _BouncingScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
