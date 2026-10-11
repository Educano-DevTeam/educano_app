import 'package:flutter/material.dart';

class AppList extends StatelessWidget {
  final int itemCount;

  final Widget Function(BuildContext context, int index) itemBuilder;

  final double? height;

  final double itemSpacing;

  final EdgeInsetsGeometry padding;

  final bool shrinkWrap;

  final ScrollPhysics? physics;

  final ScrollController? controller;

  const AppList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height,
    this.itemSpacing = 0,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    Widget list = ListView.separated(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics ??
          (height != null
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics()),
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) {
        return SizedBox(height: itemSpacing);
      },
      itemBuilder: itemBuilder,
    );

    // ------------------------------------------------------------
    // ALTURA OPCIONAL
    // ------------------------------------------------------------

    if (height != null) {
      list = SizedBox(
        height: height,
        width: double.infinity,
        child: list,
      );
    }

    return list;
  }
}