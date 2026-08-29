import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/ui/app_card.dart';
import '../../../core/widgets/ui/app_large_card.dart';
import '../../../core/widgets/ui/app_button.dart';
import '../../../core/widgets/ui/app_small_button.dart';
import '../../../core/widgets/ui/app_fab_menu.dart';

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Stack(
          children: [
            // ======================================================
            // CONTEÚDO DA DASHBOARD
            // ======================================================
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: isMobile ? 8 : 24,
              ),

              child: isMobile
                  ? _buildMobileLayout(context)
                  : _buildWebLayout(context),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // WEB
  // ============================================================

  Widget _buildWebLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreeting(context),

        const SizedBox(height: 16),

        _buildStatistics(context),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====================================================
            // COLUNA PRINCIPAL
            // ====================================================
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  _buildRevenueCard(context),

                  const SizedBox(height: 16),

                  _buildRecentActivity(context),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // ====================================================
            // COLUNA LATERAL
            // ====================================================
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildUsersCard(context),

                  const SizedBox(height: 16),

                  _buildFaqCard(context),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreeting(context),

        const SizedBox(height: 12),

        _buildStatistics(context),

        const SizedBox(height: 12),

        _buildRevenueCard(context),

        const SizedBox(height: 12),

        _buildUsersCard(context),

        const SizedBox(height: 12),

        _buildRecentActivity(context),

        const SizedBox(height: 12),

        _buildFaqCard(context),
      ],
    );
  }

  // ============================================================
  // TAMANHO TELA
  // ============================================================

  int _getGridColumns(
    double width, {
    required int mobile,
    required int tablet,
    required int desktop,
  }) {
    if (width < AppBreakpoints.mobile) {
      return mobile;
    }

    if (width < AppBreakpoints.desktop) {
      return tablet;
    }

    return desktop;
  }

  // ============================================================
  // SAUDAÇÃO
  // ============================================================

  Widget _buildGreeting(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.arrow_back_rounded,
          color: EducanoColors.textSecondary,
          size: 30,
        ),

        const SizedBox(width: 8),

        Text(
          'Bom dia, Miguel!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: EducanoColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARDS DE ESTATÍSTICA
  // ============================================================

  Widget _buildStatistics(BuildContext context) {
    final statistics = [
      _StatisticData(
        title: 'Usuários',
        value: '+1.770',
        variation: '▲ 15,5%',
        footer: 'desde 1 de Jul de 2026',
        icon: Icons.person_rounded,
        color: EducanoColors.primaryBlue,
        variationColor: EducanoColors.successGreen,
      ),
      _StatisticData(
        title: 'Plano Bronze',
        value: '236',
        variation: '— 15,5%',
        footer: 'desde 1 de Jul de 2026',
        icon: Icons.shield_rounded,
        color: const Color(0xFFE94B0C),
        variationColor: EducanoColors.accentYellow,
      ),
      _StatisticData(
        title: 'Plano Prata',
        value: '-19',
        variation: '▼ 2,5%',
        footer: 'desde 1 de Jul de 2026',
        icon: Icons.menu_book_rounded,
        color: Colors.grey,
        variationColor: Colors.redAccent,
      ),
      _StatisticData(
        title: 'Plano Ouro',
        value: '0',
        variation: '— 0,0%',
        footer: 'nenhum usuário',
        icon: Icons.school_rounded,
        color: EducanoColors.accentYellow,
        variationColor: Colors.grey,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= AppBreakpoints.mobile;

        final columns = _getGridColumns(
          constraints.maxWidth,
          mobile: 1,
          tablet: 2,
          desktop: 4,
        );

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.45,
          ),

          itemCount: statistics.length,

          itemBuilder: (context, index) {
            // ...
          },
        );

        if (isMobile) {
          return Column(
            children: statistics
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildStatisticCard(context, item, mobile: true),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: statistics.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == statistics.length - 1 ? 0 : 12,
                ),
                child: _buildStatisticCard(context, item, mobile: false),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatisticCard(
    BuildContext context,
    _StatisticData item, {
    required bool mobile,
  }) {
    return AppCard(
      padding: EdgeInsets.all(mobile ? 16 : 14),
      child: SizedBox(
        height: mobile ? 105 : 112,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Icon(item.icon, color: item.color, size: 25),
              ],
            ),

            const Spacer(),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: mobile ? 38 : 34,
                    fontWeight: FontWeight.bold,
                    color: EducanoColors.textPrimary,
                  ),
                ),

                const SizedBox(width: 8),

                _buildVariation(item.variation, item.variationColor),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              item.footer,
              style: const TextStyle(
                fontSize: 11,
                color: EducanoColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariation(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // TOTAL DE GANHOS
  // ============================================================

  Widget _buildRevenueCard(BuildContext context) {
    return AppLargeCard(
      height: 310,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total de Ganhos',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),

          const Expanded(child: _RevenueChart()),

          const SizedBox(height: 8),

          _buildRevenueSummary(),

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: EducanoColors.border),
              ),
              child: const Text(
                'Total Geral:          R\$ 480.594,75',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSummary() {
    final items = [
      ('R\$ 243.512,03', EducanoColors.primaryBlue, Icons.person_rounded),
      ('R\$ 174.203,72', const Color(0xFFE94B0C), Icons.shield_rounded),
      ('R\$ 62.570,00', Colors.grey, Icons.menu_book_rounded),
      ('R\$ 0,00', EducanoColors.accentYellow, Icons.school_rounded),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AppSmallButton(
              text: item.$1,
              icon: item.$3,
              color: Colors.white,
              textColor: EducanoColors.textPrimary,
              onPressed: () {},
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // USUÁRIOS
  // ============================================================

  Widget _buildUsersCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: SizedBox(
        height: 255,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuários',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 4),

            const Expanded(child: _UsersDonutChart()),

            Row(
              children: [
                _buildArrowButton(Icons.chevron_left_rounded),

                const Expanded(
                  child: Center(
                    child: Text(
                      'Planos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                _buildArrowButton(Icons.chevron_right_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon) {
    return Container(
      width: 28,
      height: 25,
      decoration: BoxDecoration(
        border: Border.all(color: EducanoColors.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 18, color: EducanoColors.textSecondary),
    );
  }

  // ============================================================
  // ATIVIDADE RECENTE
  // ============================================================

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
      (
        'Novo usuário cadastrado',
        'Daniel de Oliveira foi cadastrado',
        'Hoje',
        Icons.person_add_alt_rounded,
        EducanoColors.successGreen,
      ),
      (
        'Edição de Curso',
        'Daniel de Oliveira editou curso de Matemática',
        '20/03',
        Icons.school_rounded,
        EducanoColors.accentYellow,
      ),
      (
        'Questão de concurso adicionada',
        'Daniel de Oliveira adicionou questão',
        'Há 6 Meses',
        Icons.article_rounded,
        EducanoColors.successGreen,
      ),
      (
        'Exclusão de Item',
        'Daniel de Oliveira excluiu um item',
        'Há 1 Ano',
        Icons.store_rounded,
        Colors.redAccent,
      ),
    ];

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atividade Recente',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const Divider(height: 12),

          ...activities.map((activity) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: activity.$5.withValues(alpha: 0.18),
                    child: Icon(activity.$4, color: activity.$5, size: 18),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.$1,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          activity.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            color: EducanoColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    activity.$3,
                    style: const TextStyle(
                      fontSize: 8,
                      color: EducanoColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // FAQ
  // ============================================================

  Widget _buildFaqCard(BuildContext context) {
    final questions = [
      (
        'Daniel de Oliveira',
        'Estou com um problema com XP, sempre que faço uma atividade recebo 0xp.',
      ),
      ('Manuela Souza', 'Como devo fazer para ver meus simulados anteriores?'),
      (
        'Mateus Lima',
        'Para os professores do Curso de Matemática: Qual a resposta da questão?',
      ),
      (
        'Luana Castanho',
        'Estou com um problema com XP, sempre que faço uma atividade recebo 0xp.',
      ),
      ('Rafael Cristiano', 'Como posso me inscrever em um curso?'),
    ];

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: SizedBox(
        height: 310,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perguntas FAQ',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const Divider(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: EducanoColors.secondaryBlue,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.$1,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                question.$2,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: EducanoColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Center(
              child: Text(
                '•••',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AÇÕES RÁPIDAS
  // ============================================================

  // Widget _buildQuickActions(BuildContext context) {
  //   return AppCard(
  //     padding: const EdgeInsets.all(10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Ações Rápidas',
  //           style: Theme.of(
  //             context,
  //           ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  //         ),

  //         const SizedBox(height: 8),

  //         _quickActionButton(
  //           'Cadastrar Usuário',
  //           Icons.person_add_alt_rounded,
  //           EducanoColors.primaryBlue,
  //         ),

  //         const SizedBox(height: 5),

  //         _quickActionButton(
  //           'Cadastrar Curso',
  //           Icons.school_rounded,
  //           EducanoColors.successGreen,
  //         ),

  //         const SizedBox(height: 5),

  //         _quickActionButton(
  //           'Cadastrar Questão',
  //           Icons.quiz_rounded,
  //           EducanoColors.accentYellow,
  //         ),

  //         const SizedBox(height: 5),

  //         _quickActionButton(
  //           'Cadastrar Item',
  //           Icons.store_rounded,
  //           const Color(0xFFE94B0C),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _quickActionButton(String text, IconData icon, Color color) {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: AppButton(
  //       text: text,
  //       icon: icon,
  //       color: color,
  //       textColor: Colors.white,
  //       height: 48,
  //       onPressed: () {},
  //     ),
  //   );
  // }

  // ============================================================
  // FAB
  // ============================================================

  Widget _buildFab(BuildContext context) {
    return AppFabMenu(
      actions: [
        AppFabAction(
          label: 'Cadastrar Usuário',
          icon: Icons.person_add_alt_rounded,
          color: EducanoColors.primaryBlue,
          onPressed: () {
            // Futuramente abrirá o cadastro de usuário.
          },
        ),

        AppFabAction(
          label: 'Cadastrar Curso',
          icon: Icons.school_rounded,
          color: EducanoColors.successGreen,
          onPressed: () {
            // Futuramente abrirá o cadastro de curso.
          },
        ),

        AppFabAction(
          label: 'Cadastrar Questão',
          icon: Icons.quiz_rounded,
          color: EducanoColors.accentYellow,
          onPressed: () {
            // Futuramente abrirá o cadastro de questão.
          },
        ),

        AppFabAction(
          label: 'Cadastrar Item',
          icon: Icons.store_rounded,
          color: const Color(0xFFE94B0C),
          onPressed: () {
            // Futuramente abrirá o cadastro de item.
          },
        ),
      ],
    );
  }
}

// ================================================================
// MODELO DOS CARDS
// ================================================================

class _StatisticData {
  final String title;
  final String value;
  final String variation;
  final String footer;
  final IconData icon;
  final Color color;
  final Color variationColor;

  const _StatisticData({
    required this.title,
    required this.value,
    required this.variation,
    required this.footer,
    required this.icon,
    required this.color,
    required this.variationColor,
  });
}

// ================================================================
// GRÁFICO DE GANHOS
// ================================================================

class _RevenueChart extends StatelessWidget {
  const _RevenueChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RevenueChartPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final bluePaint = Paint()
      ..color = EducanoColors.primaryBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final orangePaint = Paint()
      ..color = const Color(0xFFE94B0C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final greyPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const rows = 5;

    for (int i = 0; i <= rows; i++) {
      final y = size.height * i / rows;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final bluePoints = [
      Offset(0, size.height * .20),
      Offset(size.width * .10, size.height * .25),
      Offset(size.width * .20, size.height * .35),
      Offset(size.width * .30, size.height * .36),
      Offset(size.width * .40, size.height * .28),
      Offset(size.width * .50, size.height * .32),
      Offset(size.width * .60, size.height * .23),
      Offset(size.width * .70, size.height * .15),
      Offset(size.width * .80, size.height * .05),
      Offset(size.width * .90, size.height * .02),
    ];

    final orangePoints = [
      Offset(0, size.height * .38),
      Offset(size.width * .10, size.height * .55),
      Offset(size.width * .20, size.height * .45),
      Offset(size.width * .30, size.height * .65),
      Offset(size.width * .40, size.height * .55),
      Offset(size.width * .50, size.height * .78),
      Offset(size.width * .60, size.height * .50),
      Offset(size.width * .70, size.height * .47),
      Offset(size.width * .80, size.height * .22),
      Offset(size.width * .90, size.height * .12),
    ];

    final greyPoints = [
      Offset(0, size.height * .55),
      Offset(size.width * .10, size.height * .60),
      Offset(size.width * .20, size.height * .70),
      Offset(size.width * .30, size.height * .60),
      Offset(size.width * .40, size.height * .58),
      Offset(size.width * .50, size.height * .68),
      Offset(size.width * .60, size.height * .68),
      Offset(size.width * .70, size.height * .58),
      Offset(size.width * .80, size.height * .55),
      Offset(size.width * .90, size.height * .54),
    ];

    _drawLine(canvas, bluePoints, bluePaint);
    _drawLine(canvas, orangePoints, orangePaint);
    _drawLine(canvas, greyPoints, greyPaint);
  }

  void _drawLine(Canvas canvas, List<Offset> points, Paint paint) {
    final path = Path();

    path.moveTo(points.first.dx, points.first.dy);

    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ================================================================
// GRÁFICO DE USUÁRIOS
// ================================================================

class _UsersDonutChart extends StatelessWidget {
  const _UsersDonutChart();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: CustomPaint(
            painter: _DonutPainter(),
            child: const SizedBox.expand(),
          ),
        ),

        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _LegendItem(color: EducanoColors.primaryBlue, label: 'Básico'),
              _LegendItem(color: Color(0xFFE94B0C), label: 'Bronze'),
              _LegendItem(color: Colors.grey, label: 'Prata'),
              _LegendItem(color: EducanoColors.accentYellow, label: 'Ouro'),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.shortestSide * .32;

    final stroke = size.shortestSide * .13;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    const startAngle = -0.75;

    final values = [0.53, 0.35, 0.12];

    final colors = [
      EducanoColors.primaryBlue,
      const Color(0xFFE94B0C),
      Colors.grey,
    ];

    double currentAngle = startAngle;

    for (int i = 0; i < values.length; i++) {
      paint.color = colors[i];

      final sweep = values[i] * 2 * 3.14159265359;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweep,
        false,
        paint,
      );

      currentAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
