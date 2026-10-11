import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const AppBarChart({super.key, required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(values: values, labels: labels),
      child: const SizedBox(width: double.infinity, height: 250),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  _BarChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = EducanoColors.primaryBlue
      ..style = PaintingStyle.fill;

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // final barWidth = size.width / values.length * .5;

    for (int i = 0; i < values.length; i++) {
      // final height = maxValue == 0 ? 0 : (values[i] / maxValue) * size.height;

      final x = (size.width / values.length) * i;
      final barWidth = (size.width / values.length * 0.8).toDouble();
      final height = ((values[i] / maxValue) * size.height).toDouble();

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + barWidth * .5,
            size.height - height,
            barWidth,
            height,
          ),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
