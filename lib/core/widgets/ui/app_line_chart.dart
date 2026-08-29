import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppLineChart extends StatelessWidget {
  final List<double> values;

  const AppLineChart({
    super.key,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(values),
      child: const SizedBox(
        width: double.infinity,
        height: 250,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;

  _LineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final paint = Paint()
      ..color = EducanoColors.primaryBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final maxValue = values.reduce(
      (a, b) => a > b ? a : b,
    );

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;

      final y = maxValue == 0
          ? size.height
          : size.height - (values[i] / maxValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}