import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/ui/app_card.dart';
import '../../../core/widgets/ui/app_large_card.dart';
import '../../../core/widgets/ui/app_button.dart';
import '../../../core/widgets/ui/app_small_button.dart';
import '../../../core/widgets/ui/app_fab_menu.dart';
import '../../../core/widgets/ui/app_list.dart';
import '../../../core/widgets/ui/app_list_item.dart';
import '../../../core/widgets/charts/revenue_chart.dart';

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
        final width = constraints.maxWidth;

        // ============================================================
        // CELULAR
        // ============================================================

        if (width < 600) {
          return Column(
            children: [
              for (int i = 0; i < statistics.length; i++) ...[
                _buildStatisticCard(context, statistics[i], mobile: true),

                if (i != statistics.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        // ============================================================
        // TABLET / TELA MÉDIA
        // ============================================================

        if (width < 1100) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: statistics.map((item) {
              return SizedBox(
                width: (width - 12) / 2,
                child: _buildStatisticCard(context, item, mobile: false),
              );
            }).toList(),
          );
        }

        // ============================================================
        // DESKTOP
        // ============================================================

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Icon(item.icon, color: item.color, size: 25),
            ],
          ),

          const SizedBox(height: 14),

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

              Flexible(
                child: _buildVariation(item.variation, item.variationColor),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            item.footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: EducanoColors.textSecondary,
            ),
          ),
        ],
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
    return const AppLargeCard(
      minHeight: 360,
      padding: EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: RevenueChart(),
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

          AppList(
            itemCount: activities.length,
            itemSpacing: 0,
            itemBuilder: (context, index) {
              final activity = activities[index];

              return AppListItem(
                padding: const EdgeInsets.symmetric(vertical: 5),

                leading: CircleAvatar(
                  radius: 17,
                  backgroundColor: activity.$5.withValues(alpha: 0.18),
                  child: Icon(activity.$4, color: activity.$5, size: 18),
                ),

                content: Column(
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

                trailing: Text(
                  activity.$3,
                  style: const TextStyle(
                    fontSize: 8,
                    color: EducanoColors.textSecondary,
                  ),
                ),
              );
            },
          ),
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

            AppList(
              height: 240,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];

                return AppListItem(
                  padding: const EdgeInsets.symmetric(vertical: 5),

                  leading: const CircleAvatar(
                    radius: 16,
                    backgroundColor: EducanoColors.secondaryBlue,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),

                  content: Column(
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
                );
              },
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
// GRÁFICO DE USUÁRIOS
// ================================================================

enum _DonutType { plans, courses, activity }

class _DonutData {
  final String label;
  final double value;
  final Color color;

  const _DonutData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _UsersDonutChart extends StatefulWidget {
  const _UsersDonutChart();

  @override
  State<_UsersDonutChart> createState() => _UsersDonutChartState();
}

class _UsersDonutChartState extends State<_UsersDonutChart> {
  int _currentType = 0;

  // ================================================================
  // TIPOS DE GRÁFICO
  // ================================================================

  static const _types = [
    _DonutType.plans,
    _DonutType.courses,
    _DonutType.activity,
  ];

  _DonutType get _type => _types[_currentType];

  void _previousType() {
    setState(() {
      _currentType = (_currentType - 1 + _types.length) % _types.length;
    });
  }

  void _nextType() {
    setState(() {
      _currentType = (_currentType + 1) % _types.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _getData();

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // ====================================================
              // DONUT
              // ====================================================
              Expanded(
                flex: 5,
                child: CustomPaint(
                  painter: _DonutPainter(data: data),
                  child: const SizedBox.expand(),
                ),
              ),

              // ====================================================
              // LEGENDA
              // ====================================================
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.map((item) {
                    return _LegendItem(
                      color: item.color,
                      label: item.label,
                      value: item.value,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        Row(
          children: [
            _buildArrowButton(
              icon: Icons.chevron_left_rounded,
              onPressed: _previousType,
            ),

            Expanded(
              child: Center(
                child: Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            _buildArrowButton(
              icon: Icons.chevron_right_rounded,
              onPressed: _nextType,
            ),
          ],
        ),
      ],
    );
  }

  String _getTitle() {
    switch (_type) {
      case _DonutType.plans:
        return 'Planos';

      case _DonutType.courses:
        return 'Cursos inscritos';

      case _DonutType.activity:
        return 'Frequência';
    }
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 28,
      height: 25,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: EducanoColors.border),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 18, color: EducanoColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // DADOS
  // ================================================================

  List<_DonutData> _getData() {
    switch (_type) {
      case _DonutType.plans:
        return const [
          _DonutData(
            label: 'Básico',
            value: 940,
            color: EducanoColors.primaryBlue,
          ),
          _DonutData(label: 'Bronze', value: 236, color: Color(0xFFE94B0C)),
          _DonutData(label: 'Prata', value: 594, color: Colors.grey),
          _DonutData(
            label: 'Ouro',
            value: 0,
            color: EducanoColors.accentYellow,
          ),
        ];

      case _DonutType.courses:
        return const [
          _DonutData(
            label: '1 curso',
            value: 480,
            color: EducanoColors.primaryBlue,
          ),
          _DonutData(
            label: '2–3 cursos',
            value: 720,
            color: EducanoColors.successGreen,
          ),
          _DonutData(
            label: '4–5 cursos',
            value: 420,
            color: EducanoColors.accentYellow,
          ),
          _DonutData(label: '6+ cursos', value: 150, color: Color(0xFFE94B0C)),
        ];

      case _DonutType.activity:
        return const [
          _DonutData(
            label: 'Ativos hoje',
            value: 780,
            color: EducanoColors.successGreen,
          ),
          _DonutData(
            label: '3–5 dias',
            value: 320,
            color: EducanoColors.primaryBlue,
          ),
          _DonutData(
            label: '6–14 dias',
            value: 280,
            color: EducanoColors.accentYellow,
          ),
          _DonutData(label: '15–30 dias', value: 210, color: Color(0xFFE94B0C)),
          _DonutData(label: '+30 dias', value: 150, color: Colors.grey),
        ];
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9),
            ),
          ),

          const SizedBox(width: 4),

          Text(
            value.toInt().toString(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: EducanoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_DonutData> data;

  const _DonutPainter({required this.data});

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

    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    if (total <= 0) return;

    double currentAngle = startAngle;

    for (final item in data) {
      if (item.value <= 0) continue;

      paint.color = item.color;

      final sweep = (item.value / total) * 2 * math.pi;

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
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
