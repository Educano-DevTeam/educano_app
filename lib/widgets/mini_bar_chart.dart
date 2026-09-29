import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ChartPoint {
  final String label;
  final double atividades;
  final double simulados;
  const ChartPoint(this.label, this.atividades, this.simulados);
}

/// Gráfico de barras simples (sem dependências externas) que reproduz o
/// bloco "Evolução das notas" do protótipo: duas barras (Atividades em
/// vermelho e Simulados em azul) por mês.
class MiniBarChart extends StatelessWidget {
  final List<ChartPoint> data;
  final double maxValue;

  static const double _areaHeight = 110;

  const MiniBarChart({super.key, required this.data, this.maxValue = 900});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((point) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: _areaHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar(point.atividades, AppColors.red),
                      const SizedBox(width: 3),
                      _bar(point.simulados, AppColors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(point.label, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bar(double value, Color color) {
    final double h = _areaHeight * (value / maxValue).clamp(0.03, 1.0);
    return Container(
      width: 9,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
      ),
    );
  }
}
