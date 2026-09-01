import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppLargeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Altura mínima do card.
  final double minHeight;

  final Color? color;
  final double borderRadius;

  const AppLargeCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.minHeight = 280,
    this.color,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: minHeight,
      ),
      margin: margin,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? EducanoColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}