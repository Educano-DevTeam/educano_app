import 'package:flutter/material.dart';

class AppListItem extends StatelessWidget {
  final Widget? leading;
  final Widget? content;
  final Widget? trailing;

  final EdgeInsetsGeometry padding;

  final double leadingSpacing;
  final double trailingSpacing;

  final VoidCallback? onTap;

  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppListItem({
    super.key,
    this.leading,
    this.content,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
    this.leadingSpacing = 10,
    this.trailingSpacing = 6,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget item = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: leadingSpacing),
          ],

          if (content != null)
            Expanded(
              child: content!,
            ),

          if (trailing != null) ...[
            SizedBox(width: trailingSpacing),
            trailing!,
          ],
        ],
      ),
    );

    if (backgroundColor != null || borderRadius != null) {
      item = Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: item,
      );
    }

    if (onTap != null) {
      item = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: item,
        ),
      );
    }

    return item;
  }
}