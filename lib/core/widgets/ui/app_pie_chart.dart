import 'dart:math';

import 'package:flutter/material.dart';

class AppPieChartItem {
  final double value;
  final Color color;

  const AppPieChartItem({
    required this.value,
    required this.color,
  });
}

class AppPieChart extends StatelessWidget {
  final List<AppPieChartItem> items;

  const AppPieChart({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PieChartPainter(items),
      child: const SizedBox(
        width: 220,
        height: 220,
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<AppPieChartItem> items;

  _PieChartPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    if (total == 0) return;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = min(size.width, size.height) / 2;

    double startAngle = -pi / 2;

    for (final item in items) {
      final sweepAngle =
          item.value / total * 2 * pi;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}