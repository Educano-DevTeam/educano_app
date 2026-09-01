import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../constants/app_breakpoints.dart';

/// ================================================================
/// GRÁFICO DE GANHOS
/// ================================================================
///
/// Componente completo do gráfico de ganhos.
///
/// Possui:
/// - eixo Y de 0 a 250k;
/// - scroll horizontal;
/// - meses de 2024 a 2026;
/// - separação visual entre anos;
/// - títulos 2024 / 2025 / 2026;
/// - linhas horizontais;
/// - linhas verticais pontilhadas;
/// - três linhas de dados;
/// - cards de resumo.
///
/// Uso:
///
/// const RevenueChart()
///
/// ================================================================

class RevenueChart extends StatefulWidget {
  const RevenueChart({super.key});

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  // ==============================================================
  // CONFIGURAÇÕES
  // ==============================================================

  static const double maxValue = 250000;
  static const double yStep = 50000;

  static const double monthWidth = 72;
  static const double chartHeight = 180;

  static const double cardMinWidth = 170;

  static const int monthsPerYear = 12;

  static const chartContentHeight =
      24 + // anos
      chartHeight + // gráfico
      4 + // espaçamento
      18 + // meses
      8; // scrollbar/padding

  final ScrollController _chartScrollController = ScrollController();

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final months = _buildMonths();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================================
            // TÍTULO
            // ==========================================================
            Text(
              'Total de Ganhos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            // ======================================================
            // GRÁFICO
            // ======================================================
            SizedBox(
              height: chartContentHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // EIXO Y
                  // =================================================
                  const SizedBox(
                    width: 38,
                    height: chartHeight + 24,
                    child: _RevenueYAxis(maxValue: maxValue, step: yStep),
                  ),

                  const SizedBox(width: 6),

                  // =================================================
                  // ÁREA SCROLLÁVEL
                  // =================================================
                  Expanded(
                    child: Scrollbar(
                      controller: _chartScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      interactive: true,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: SingleChildScrollView(
                        controller: _chartScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: months.length * monthWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 24,
                                child: _YearHeader(monthWidth: monthWidth),
                              ),

                              SizedBox(
                                height: chartHeight,
                                child: CustomPaint(
                                  painter: _RevenueChartPainter(
                                    monthWidth: monthWidth,
                                    maxValue: maxValue,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              SizedBox(
                                height: 18,
                                child: _MonthLabels(
                                  months: months,
                                  monthWidth: monthWidth,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ======================================================
            // CARDS
            // ======================================================
            const _RevenueSummaryCards(),

            const SizedBox(height: 8),

            // ==========================================================
            // TOTAL GERAL
            // ==========================================================
            const _RevenueTotalCard(),
          ],
        );
      },
    );
  }

  // ==============================================================
  // MESES
  // ==============================================================

  List<_ChartMonth> _buildMonths() {
    return const [
      // 2024
      _ChartMonth('Jan', 2024),
      _ChartMonth('Fev', 2024),
      _ChartMonth('Mar', 2024),
      _ChartMonth('Abr', 2024),
      _ChartMonth('Mai', 2024),
      _ChartMonth('Jun', 2024),
      _ChartMonth('Jul', 2024),
      _ChartMonth('Ago', 2024),
      _ChartMonth('Set', 2024),
      _ChartMonth('Out', 2024),
      _ChartMonth('Nov', 2024),
      _ChartMonth('Dez', 2024),

      // 2025
      _ChartMonth('Jan', 2025),
      _ChartMonth('Fev', 2025),
      _ChartMonth('Mar', 2025),
      _ChartMonth('Abr', 2025),
      _ChartMonth('Mai', 2025),
      _ChartMonth('Jun', 2025),
      _ChartMonth('Jul', 2025),
      _ChartMonth('Ago', 2025),
      _ChartMonth('Set', 2025),
      _ChartMonth('Out', 2025),
      _ChartMonth('Nov', 2025),
      _ChartMonth('Dez', 2025),

      // 2026
      _ChartMonth('Jan', 2026),
      _ChartMonth('Fev', 2026),
      _ChartMonth('Mar', 2026),
      _ChartMonth('Abr', 2026),
      _ChartMonth('Mai', 2026),
      _ChartMonth('Jun', 2026),
      _ChartMonth('Jul', 2026),
      _ChartMonth('Ago', 2026),
      _ChartMonth('Set', 2026),
      _ChartMonth('Out', 2026),
      _ChartMonth('Nov', 2026),
      _ChartMonth('Dez', 2026),
    ];
  }
}

// ==================================================================
// MODELO
// ==================================================================

class _ChartMonth {
  final String month;
  final int year;

  const _ChartMonth(this.month, this.year);
}

// ==================================================================
// EIXO Y
// ==================================================================

class _RevenueYAxis extends StatelessWidget {
  final double maxValue;
  final double step;

  const _RevenueYAxis({required this.maxValue, required this.step});

  @override
  Widget build(BuildContext context) {
    final labels = <String>[];

    for (double value = maxValue; value >= 0; value -= step) {
      labels.add('${(value / 1000).round()}k');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: labels.map((label) {
        return SizedBox(
          height: 12,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: EducanoColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ==================================================================
// CABEÇALHO DOS ANOS
// ==================================================================

class _YearHeader extends StatelessWidget {
  final double monthWidth;

  const _YearHeader({required this.monthWidth});

  @override
  Widget build(BuildContext context) {
    const years = ['2024', '2025', '2026'];

    return Stack(
      children: [
        for (int i = 0; i < years.length; i++)
          Positioned(
            left: i * monthWidth * 12,
            top: 0,
            width: monthWidth,
            height: 24,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                years[i],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: EducanoColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _YearLabel extends StatelessWidget {
  final String year;
  final double width;

  const _YearLabel({required this.year, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          year,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: EducanoColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// MESES
// ==================================================================

class _MonthLabels extends StatelessWidget {
  final List<_ChartMonth> months;
  final double monthWidth;

  const _MonthLabels({required this.months, required this.monthWidth});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: months.map((item) {
        return SizedBox(
          width: monthWidth,
          child: Center(
            child: Text(
              item.month,
              style: const TextStyle(
                fontSize: 9,
                color: EducanoColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ==================================================================
// PAINTER
// ==================================================================

class _RevenueChartPainter extends CustomPainter {
  final double monthWidth;
  final double maxValue;

  const _RevenueChartPainter({
    required this.monthWidth,
    required this.maxValue,
  });

  // ================================================================
  // DADOS
  // ================================================================
  //
  // Os valores estão em REAIS.
  //
  // Exemplo:
  // 42 = R$ 42.000
  // 150 = R$ 150.000
  //
  // Isso é convertido para reais no cálculo abaixo.
  // ================================================================

  static const blueValues = [
    42,
    58,
    75,
    62,
    90,
    110,
    98,
    135,
    150,
    172,
    165,
    190,

    180,
    195,
    172,
    205,
    198,
    220,
    210,
    225,
    215,
    230,
    218,
    238,

    230,
    242,
    225,
    248,
    235,
    242,
    238,
    245,
    232,
    240,
    235,
    248,
  ];

  static const orangeValues = [
    28,
    42,
    35,
    55,
    48,
    70,
    58,
    82,
    75,
    96,
    88,
    105,

    98,
    112,
    100,
    125,
    118,
    135,
    128,
    142,
    132,
    150,
    145,
    158,

    150,
    165,
    155,
    172,
    165,
    180,
    172,
    185,
    178,
    192,
    185,
    198,
  ];

  static const greyValues = [
    18,
    25,
    32,
    28,
    38,
    42,
    36,
    48,
    52,
    58,
    55,
    62,

    58,
    65,
    60,
    70,
    68,
    76,
    72,
    80,
    76,
    84,
    80,
    88,

    82,
    92,
    86,
    96,
    90,
    102,
    96,
    108,
    100,
    112,
    108,
    118,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // ============================================================
    // GRID HORIZONTAL
    // ============================================================

    final horizontalPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const horizontalLines = 5;

    for (int i = 0; i <= horizontalLines; i++) {
      final y = size.height * i / horizontalLines;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), horizontalPaint);
    }

    // ============================================================
    // DIVISÓRIAS DOS ANOS
    // ============================================================

    final yearDividerPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    _drawDashedVerticalLine(
      canvas,
      monthWidth / 2,
      size.height,
      yearDividerPaint,
    );

    for (int yearIndex = 1; yearIndex < 3; yearIndex++) {
      final x = yearIndex * 12 * monthWidth + monthWidth / 2;

      _drawDashedVerticalLine(canvas, x, size.height, yearDividerPaint);
    }

    _drawDashedVerticalLine(
      canvas,
      monthWidth * 12 + monthWidth / 2,
      size.height,
      yearDividerPaint,
    );

    _drawDashedVerticalLine(
      canvas,
      monthWidth * 24 + monthWidth / 2,
      size.height,
      yearDividerPaint,
    );

    // ============================================================
    // LINHAS
    // ============================================================

    _drawDataLine(
      canvas,
      values: blueValues,
      color: EducanoColors.primaryBlue,
      size: size,
    );

    _drawDataLine(
      canvas,
      values: orangeValues,
      color: const Color(0xFFE94B0C),
      size: size,
    );

    _drawDataLine(canvas, values: greyValues, color: Colors.grey, size: size);
  }

  // ==============================================================
  // LINHA PONTILHADA
  // ==============================================================

  void _drawDashedVerticalLine(
    Canvas canvas,
    double x,
    double height,
    Paint paint,
  ) {
    const dashLength = 4.0;
    const gapLength = 4.0;

    double y = 0;

    while (y < height) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, math.min(y + dashLength, height)),
        paint,
      );

      y += dashLength + gapLength;
    }
  }

  // ==============================================================
  // LINHA DOS DADOS
  // ==============================================================

  void _drawDataLine(
    Canvas canvas, {
    required List<num> values,
    required Color color,
    required Size size,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      // ----------------------------------------------------------
      // IMPORTANTE:
      //
      // Os valores estão em milhares.
      //
      // 42 -> R$ 42.000
      // 150 -> R$ 150.000
      // ----------------------------------------------------------

      final value = values[i] * 1000;

      // ----------------------------------------------------------
      // Converte o valor para a posição vertical.
      // ----------------------------------------------------------

      final normalized = value / maxValue;

      final y = size.height * (1 - normalized);

      // ----------------------------------------------------------
      // Cada ponto fica no centro do mês.
      // ----------------------------------------------------------

      final x = monthWidth / 2 + i * monthWidth;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) {
    return oldDelegate.monthWidth != monthWidth ||
        oldDelegate.maxValue != maxValue;
  }
}

// ==================================================================
// CARDS DE RESUMO
// ==================================================================

class _RevenueSummaryCards extends StatelessWidget {
  const _RevenueSummaryCards();

  static const double cardMinWidth = 160;
  static const double spacing = 8;

  @override
  Widget build(BuildContext context) {
    const items = [
      _RevenueSummaryData(
        label: 'Básico',
        value: 'R\$ 243.512,03',
        icon: Icons.person_rounded,
        color: EducanoColors.primaryBlue,
      ),
      _RevenueSummaryData(
        label: 'Bronze',
        value: 'R\$ 174.203,72',
        icon: Icons.shield_rounded,
        color: Color(0xFFE94B0C),
      ),
      _RevenueSummaryData(
        label: 'Prata',
        value: 'R\$ 62.570,00',
        icon: Icons.menu_book_rounded,
        color: Colors.grey,
      ),
      _RevenueSummaryData(
        label: 'Ouro',
        value: 'R\$ 0,00',
        icon: Icons.school_rounded,
        color: EducanoColors.accentYellow,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // ==========================================================
        // CALCULA QUANTOS CARDS CABEM NO ESPAÇO REAL
        // ==========================================================

        int columns = (width + spacing) ~/ (cardMinWidth + spacing);

        // Nunca teremos menos de 1 nem mais que a quantidade de cards.
        columns = columns.clamp(1, items.length);

        // ==========================================================
        // 1 CARD
        // ==========================================================

        if (columns == 1) {
          return Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _RevenueSummaryCard(item: items[i]),
                if (i != items.length - 1) const SizedBox(height: spacing),
              ],
            ],
          );
        }

        // ==========================================================
        // 2+ CARDS
        // ==========================================================

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: 48,
          ),
          itemBuilder: (context, index) {
            return _RevenueSummaryCard(item: items[index]);
          },
        );
      },
    );
  }
}

// ==================================================================
// MODELO
// ==================================================================

class _RevenueSummaryData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _RevenueSummaryData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// ==================================================================
// CARD INDIVIDUAL
// ==================================================================

class _RevenueSummaryCard extends StatelessWidget {
  final _RevenueSummaryData item;

  const _RevenueSummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      // ==========================================================
      // SOMENTE BORDA ESQUERDA + INFERIOR
      // ==========================================================
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),

        border: Border(
          left: BorderSide(color: item.color, width: 3),
          bottom: BorderSide(color: item.color, width: 2),
        ),
      ),

      child: Row(
        children: [
          // ========================================================
          // ÍCONE
          // ========================================================
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(item.icon, size: 16, color: item.color),
          ),

          const SizedBox(width: 8),

          // ========================================================
          // TEXTOS
          // ========================================================
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    color: EducanoColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: EducanoColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueTotalCard extends StatelessWidget {
  const _RevenueTotalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _RevenueSummaryCard(
        item: _RevenueSummaryData(
          label: 'Total Geral',
          value: 'R\$ 480.285,75',
          icon: Icons.account_balance_wallet_rounded,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }
}
