import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import 'course_editor_view.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

const double _mobileBreakpoint = 900;

const Color _bronzeColor = Color(0xFFCD7F32);
const Color _silverColor = Color(0xFFB0B8C1);

/// Tela "Painel" do dashboard administrativo, replicada a partir do
/// design do Figma (frames "Tela Painel - Dashboard (Admins)" e
/// "Tela Painel - Dashboard (MOBILE)").
class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _mobileBreakpoint;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(_spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(context),
                  const SizedBox(height: _spacingLarge),
                  _buildStatCards(isMobile),
                  const SizedBox(height: _spacingLarge),
                  _buildOverviewSection(context, isMobile),
                  const SizedBox(height: _spacingLarge),
                  _buildBottomSection(context, isMobile),
                  const SizedBox(height: _spacingLarge + _spacingMedium),
                ],
              ),
            ),
            Positioned(
              bottom: _spacingSmall,
              right: _spacingSmall,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: EducanoColors.primaryBlue,
                child: const Icon(Icons.close_rounded, color: EducanoColors.textWhite),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildGreeting(BuildContext context) {
  return Text(
    'Bom dia, Miguel!',
    style: Theme.of(context).textTheme.headlineMedium,
  );
}

Widget _buildCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(_spacingMedium),
    decoration: BoxDecoration(
      color: EducanoColors.background,
      borderRadius: BorderRadius.circular(_radius),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    child: child,
  );
}

// ---------------------------------------------------------------------------
// Cards de estatística (Usuários / Plano Bronze / Plano Prata / Plano Ouro)
// ---------------------------------------------------------------------------

Widget _buildStatCards(bool isMobile) {
  final stats = [
    {
      'title': 'Usuários',
      'value': '+1.770',
      'valueColor': EducanoColors.textPrimary,
      'icon': Icons.person_rounded,
      'iconColor': EducanoColors.textSecondary,
      'trend': 'up',
      'trendValue': '15,5%',
      'subtitle': 'desde 1 de Jul de 2026',
    },
    {
      'title': 'Plano Bronze',
      'value': '236',
      'valueColor': EducanoColors.textPrimary,
      'icon': Icons.shield_rounded,
      'iconColor': _bronzeColor,
      'trend': 'flat',
      'trendValue': '15,5%',
      'subtitle': 'desde 1 de Jul de 2026',
    },
    {
      'title': 'Plano Prata',
      'value': '-19',
      'valueColor': EducanoColors.error,
      'icon': Icons.menu_book_rounded,
      'iconColor': _silverColor,
      'trend': 'down',
      'trendValue': '2,5%',
      'subtitle': 'desde 1 de Jul de 2026',
    },
    {
      'title': 'Plano Ouro',
      'value': '0',
      'valueColor': EducanoColors.textPrimary,
      'icon': Icons.school_rounded,
      'iconColor': EducanoColors.accentYellow,
      'trend': 'flat',
      'trendValue': '0,0%',
      'subtitle': 'nenhum usuário',
    },
  ];

  final cards = stats.map(_buildStatCard).toList();

  if (isMobile) {
    return Column(
      children: cards
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: _spacingSmall),
                child: c,
              ))
          .toList(),
    );
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (int i = 0; i < cards.length; i++) ...[
        if (i > 0) const SizedBox(width: _spacingSmall),
        Expanded(child: cards[i]),
      ],
    ],
  );
}

Widget _buildStatCard(Map<String, dynamic> stat) {
  return Container(
    padding: const EdgeInsets.all(_spacingSmall),
    decoration: BoxDecoration(
      color: EducanoColors.background,
      borderRadius: BorderRadius.circular(_radius),
      border: Border.all(color: EducanoColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stat['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: EducanoColors.textPrimary,
              ),
            ),
            Icon(stat['icon'] as IconData, color: stat['iconColor'] as Color, size: 20),
          ],
        ),
        const SizedBox(height: _spacingSmall),
        Row(
          children: [
            Text(
              stat['value'] as String,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: stat['valueColor'] as Color,
              ),
            ),
            const SizedBox(width: _spacingMinimum),
            _buildTrendBadge(stat['trend'] as String, stat['trendValue'] as String),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          stat['subtitle'] as String,
          style: const TextStyle(color: EducanoColors.textSecondary, fontSize: 12),
        ),
      ],
    ),
  );
}

Widget _buildTrendBadge(String trend, String value) {
  final Color color = switch (trend) {
    'up' => EducanoColors.successGreen,
    'down' => EducanoColors.error,
    _ => EducanoColors.textSecondary,
  };
  final IconData icon = switch (trend) {
    'up' => Icons.arrow_drop_up_rounded,
    'down' => Icons.arrow_drop_down_rounded,
    _ => Icons.remove_rounded,
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Total de Ganhos (gráfico de linhas) + Usuários (gráfico de rosca)
// ---------------------------------------------------------------------------

Widget _buildOverviewSection(BuildContext context, bool isMobile) {
  if (isMobile) {
    return Column(
      children: [
        _buildEarningsCard(context),
        const SizedBox(height: _spacingLarge),
        _buildUsersDonutCard(context),
      ],
    );
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 2, child: _buildEarningsCard(context)),
      const SizedBox(width: _spacingLarge),
      Expanded(child: _buildUsersDonutCard(context)),
    ],
  );
}

Widget _buildEarningsCard(BuildContext context) {
  final legend = [
    {'color': EducanoColors.primaryBlue, 'amount': 'R\$ 243.512,03'},
    {'color': _bronzeColor, 'amount': 'R\$ 174.203,72'},
    {'color': _silverColor, 'amount': 'R\$ 62.570,00'},
    {'color': EducanoColors.accentYellow, 'amount': 'R\$ 0,00'},
  ];

  return _buildCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total de Ganhos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: _spacingSmall),
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(painter: _LineChartPainter()),
        ),
        const SizedBox(height: _spacingSmall),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 500 ? 2 : 4;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: _spacingMinimum,
                mainAxisSpacing: _spacingMinimum,
                childAspectRatio: 2.6,
              ),
              itemCount: legend.length,
              itemBuilder: (context, index) {
                final item = legend[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: _spacingMinimum),
                  decoration: BoxDecoration(
                    border: Border.all(color: item['color'] as Color, width: 1.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: item['color'] as Color),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item['amount'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const Divider(height: _spacingMedium),
        Align(
          alignment: Alignment.centerRight,
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Total Geral: ',
                  style: TextStyle(color: EducanoColors.textSecondary, fontSize: 12),
                ),
                TextSpan(
                  text: 'R\$ 480.594,75',
                  style: const TextStyle(
                    color: EducanoColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildUsersDonutCard(BuildContext context) {
  final segments = [
    {'label': 'Básico', 'value': 53.0, 'color': EducanoColors.primaryBlue},
    {'label': 'Bronze', 'value': 35.0, 'color': _bronzeColor},
    {'label': 'Prata', 'value': 12.0, 'color': _silverColor},
    {'label': 'Ouro', 'value': 0.0, 'color': EducanoColors.accentYellow},
  ];

  return _buildCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Usuários', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: _spacingSmall),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(painter: _DonutChartPainter(segments)),
            ),
            const SizedBox(width: _spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: segments
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: s['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: _spacingMinimum),
                            Text(s['label'] as String, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: _spacingSmall),
        _buildCarouselSelector(),
      ],
    ),
  );
}

Widget _buildCarouselSelector() {
  return Row(
    children: [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.chevron_left_rounded, color: EducanoColors.textSecondary),
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: EducanoColors.searchBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: EducanoColors.border),
          ),
          child: const Center(child: Text('Planos')),
        ),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.chevron_right_rounded, color: EducanoColors.textSecondary),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Atividade Recente + Perguntas FAQ + Ações Rápidas
// ---------------------------------------------------------------------------

Widget _buildBottomSection(BuildContext context, bool isMobile) {
  if (isMobile) {
    return Column(
      children: [
        _buildActivityCard(context),
        const SizedBox(height: _spacingLarge),
        _buildFaqCard(context),
        const SizedBox(height: _spacingLarge),
        _buildQuickActionsCard(context),
      ],
    );
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 2, child: _buildActivityCard(context)),
      const SizedBox(width: _spacingLarge),
      Expanded(
        child: Column(
          children: [
            _buildFaqCard(context),
            const SizedBox(height: _spacingLarge),
            _buildQuickActionsCard(context),
          ],
        ),
      ),
    ],
  );
}

Widget _buildActivityCard(BuildContext context) {
  final activities = [
    {
      'title': 'Novo usuário cadastrado',
      'actor': 'Daniel de Oliveira',
      'description': 'foi cadastrado.',
      'icon': Icons.person_add_alt_rounded,
      'color': EducanoColors.successGreen,
      'time': '1h',
    },
    {
      'title': 'Edição de Curso',
      'actor': 'Daniel de Oliveira',
      'description': 'editou curso de Matemática, clique para ver as alterações.',
      'icon': Icons.edit_note_rounded,
      'color': EducanoColors.accentYellow,
      'time': '10:02',
    },
    {
      'title': 'Questão de concurso adicionada',
      'actor': 'Daniel de Oliveira',
      'description':
          'adicionou a questão "O Brasil ficou independente...", para o curso de Ciências Humanas.',
      'icon': Icons.quiz_rounded,
      'color': EducanoColors.successGreen,
      'time': 'há 5 horas',
    },
    {
      'title': 'Exclusão de Item',
      'actor': 'Daniel de Oliveira',
      'description': 'excluiu o item "XP em dobro" da loja.',
      'icon': Icons.delete_outline_rounded,
      'color': EducanoColors.error,
      'time': 'há 1 dia',
    },
  ];

  return _buildCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Atividade Recente', style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        ...activities.map(_buildActivityRow),
        const SizedBox(height: _spacingMinimum),
        Center(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded, color: EducanoColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActivityRow(Map<String, dynamic> activity) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: _spacingMinimum),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (activity['color'] as Color).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 18),
        ),
        const SizedBox(width: _spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: EducanoColors.textPrimary,
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${activity['actor']} ',
                      style: const TextStyle(
                        color: EducanoColors.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: activity['description'] as String,
                      style: const TextStyle(color: EducanoColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: _spacingMinimum),
        Text(
          activity['time'] as String,
          style: const TextStyle(color: EducanoColors.textSecondary, fontSize: 11),
        ),
      ],
    ),
  );
}

Widget _buildFaqCard(BuildContext context) {
  final questions = [
    {
      'name': 'Daniel de Oliveira',
      'question':
          'Estou tendo um problema com XP, sempre que faço uma atividade recebo 0xp. O que devo fazer?',
    },
    {
      'name': 'Manuela Souza',
      'question': 'Como devo fazer para ver meus simulados anteriores?',
    },
    {
      'name': 'Mateus Lima',
      'question':
          'Para os professores do Curso de Matemática: Qual a resposta da questão sobre Sigma?',
    },
    {
      'name': 'Luana Castanho',
      'question':
          'Estou tendo um problema com XP, sempre que faço uma atividade recebo 0xp. O que devo fazer?',
    },
    {
      'name': 'Rafael Cristiano',
      'question': 'Como posso me inscrever em um curso?',
    },
  ];

  return _buildCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Perguntas FAQ', style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        ...questions.map(_buildFaqRow),
        const SizedBox(height: _spacingMinimum),
        Center(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded, color: EducanoColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}

Widget _buildFaqRow(Map<String, dynamic> question) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: _spacingMinimum),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: EducanoColors.primaryBlue,
          child: Icon(Icons.person_rounded, color: EducanoColors.textWhite, size: 18),
        ),
        const SizedBox(width: _spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: EducanoColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              Text(
                question['question'] as String,
                style: const TextStyle(color: EducanoColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildQuickActionsCard(BuildContext context) {
  return _buildCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ações Rápidas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: _spacingSmall),
        _buildQuickActionButton(
          label: 'Cadastrar Usuário',
          icon: Icons.person_add_alt_1_rounded,
          color: EducanoColors.primaryBlue,
          onPressed: () => _showComingSoon(context),
        ),
        const SizedBox(height: _spacingMinimum),
        _buildQuickActionButton(
          label: 'Cadastrar Curso',
          icon: Icons.school_rounded,
          color: EducanoColors.successGreen,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CourseEditorView()),
          ),
        ),
        const SizedBox(height: _spacingMinimum),
        _buildQuickActionButton(
          label: 'Cadastrar Questão',
          icon: Icons.post_add_rounded,
          color: EducanoColors.accentYellow,
          onPressed: () => _showComingSoon(context),
        ),
        const SizedBox(height: _spacingMinimum),
        _buildQuickActionButton(
          label: 'Cadastrar Item',
          icon: Icons.storefront_rounded,
          color: EducanoColors.error,
          onPressed: () => _showComingSoon(context),
        ),
      ],
    ),
  );
}

Widget _buildQuickActionButton({
  required String label,
  required IconData icon,
  required Color color,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: EducanoColors.textWhite,
        padding: const EdgeInsets.symmetric(vertical: _spacingSmall),
      ),
    ),
  );
}

void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Em breve'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ---------------------------------------------------------------------------
// Gráficos (CustomPainter) — sem dependências externas
// ---------------------------------------------------------------------------

class _LineChartPainter extends CustomPainter {
  static const List<Map<String, Object>> _series = [
    {
      'color': EducanoColors.primaryBlue,
      'values': [0.55, 0.62, 0.58, 0.68, 0.72, 0.66, 0.78, 0.82],
    },
    {
      'color': _bronzeColor,
      'values': [0.30, 0.35, 0.28, 0.40, 0.46, 0.42, 0.55, 0.58],
    },
    {
      'color': _silverColor,
      'values': [0.18, 0.22, 0.15, 0.20, 0.24, 0.19, 0.16, 0.22],
    },
  ];

  static const List<String> _months = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago',
  ];

  static const List<String> _yLabels = ['200k', '150k', '100k', '50k'];

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 34.0;
    const bottomPadding = 18.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding;

    final gridPaint = Paint()
      ..color = EducanoColors.border
      ..strokeWidth = 1;

    for (int i = 0; i < _yLabels.length; i++) {
      final y = chartHeight * i / _yLabels.length;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);
      _drawText(canvas, _yLabels[i], Offset(0, y - 6));
    }

    for (int i = 0; i < _months.length; i++) {
      final x = leftPadding + chartWidth * i / (_months.length - 1);
      _drawText(canvas, _months[i], Offset(x - 8, chartHeight + 2));
    }

    for (final s in _series) {
      final values = s['values'] as List<double>;
      final color = s['color'] as Color;
      final path = Path();
      for (int i = 0; i < values.length; i++) {
        final x = leftPadding + chartWidth * i / (values.length - 1);
        final y = chartHeight - (chartHeight * values[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 10, color: EducanoColors.textSecondary),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> segments;

  _DonutChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    const strokeWidth = 20.0;

    final total = segments.fold<double>(0, (sum, s) => sum + (s['value'] as double));
    double startAngle = -math.pi / 2;

    for (final segment in segments) {
      final value = segment['value'] as double;
      if (value <= 0 || total <= 0) continue;

      final sweepAngle = (value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = segment['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      if (value / total >= 0.05) {
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius - strokeWidth / 2;
        final labelOffset = Offset(
          center.dx + labelRadius * math.cos(midAngle),
          center.dy + labelRadius * math.sin(midAngle),
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${value.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 11,
              color: EducanoColors.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(labelOffset.dx - textPainter.width / 2, labelOffset.dy - textPainter.height / 2),
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
