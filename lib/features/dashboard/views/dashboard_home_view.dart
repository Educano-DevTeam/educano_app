import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/ui/app_card.dart';
import '../../../core/widgets/ui/app_large_card.dart';
import '../../../core/widgets/ui/app_list.dart';
import '../../../core/widgets/ui/app_list_item.dart';
import '../../../core/widgets/charts/revenue_chart.dart';
import '../../../core/utils/api_mappers.dart';
import '../../../services/api_client.dart';
import '../../../services/progress_service.dart';
import '../../../services/storage_service.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  Map<String, dynamic>? _summary;
  String _userName = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = await StorageService.instance.loadCurrentUser();
      final summary = await ProgressService.instance.dashboardSummary();
      if (!mounted) return;
      setState(() {
        _userName = user?.name.split(' ').first ?? '';
        _summary = summary;
        _error = null;
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_summary == null) {
      return Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  TextButton(onPressed: _load, child: const Text('Tentar novamente')),
                ],
              ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < AppBreakpoints.mobile;
        final isLarge = width >= AppBreakpoints.expanded;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 24,
            vertical: isSmall ? 8 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(context),
              SizedBox(height: isSmall ? 12 : 24),

              _buildStatistics(context),

              SizedBox(height: isSmall ? 12 : 24),

              _buildMainContent(context, isMobile: isSmall, isDesktop: isLarge),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(
    BuildContext context, {
    required bool isMobile,
    required bool isDesktop,
  }) {
    // ============================================================
    // MOBILE
    // ============================================================

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    // TABLET / TELA MÉDIA
    // ============================================================

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRevenueCard(context)),

              const SizedBox(width: 14),

              Expanded(child: _buildUsersCard(context)),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentActivity(context)),

              const SizedBox(width: 14),

              Expanded(child: _buildFaqCard(context)),
            ],
          ),
        ],
      );
    }

    // ============================================================
    // DESKTOP / EXPANDED
    // ============================================================

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildRevenueCard(context)),

            const SizedBox(width: 16),

            Expanded(child: _buildUsersCard(context)),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildRecentActivity(context)),

            const SizedBox(width: 16),

            Expanded(child: _buildFaqCard(context)),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SAUDAÇÃO
  // ============================================================

  Widget _buildGreeting(BuildContext context) {
    return Row(
      children: [
        Text(
          '${_greeting()}${_userName.isEmpty ? '' : ', $_userName'}!',
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Widget _buildStatistics(BuildContext context) {
    final summary = _summary!;
    final users = summary['usuarios'] as Map<String, dynamic>;
    final plans = (summary['planos'] as List).cast<Map<String, dynamic>>();
    final total = users['total'] as int;
    final newUsers = users['novosUltimos30Dias'] as int;
    const planStyles = [
      (Icons.school_rounded, Color(0xFF7DAB9E)),
      (Icons.workspace_premium_rounded, EducanoColors.primaryBlue),
      (Icons.diamond_rounded, EducanoColors.accentYellow),
    ];
    String percent(int value) =>
        total == 0 ? '0%' : '${(value * 100 / total).toStringAsFixed(1).replaceAll('.', ',')}%';

    final statistics = [
      _StatisticData(
        title: 'Usuários',
        value: '$total',
        variation: '▲ $newUsers',
        footer: 'novos nos últimos 30 dias',
        icon: Icons.person_rounded,
        color: EducanoColors.primaryBlue,
        variationColor: newUsers > 0 ? EducanoColors.successGreen : EducanoColors.textSecondary,
      ),
      for (var i = 0; i < plans.length && i < 3; i++)
        _StatisticData(
          title: 'Plano ${plans[i]['nome']}',
          value: '${plans[i]['total']}',
          variation: percent(plans[i]['total'] as int),
          footer: 'dos usuários',
          icon: planStyles[i].$1,
          color: planStyles[i].$2,
          variationColor: EducanoColors.textSecondary,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = _getGridColumns(
          width,
          mobile: 1,
          tablet: 2,
          desktop: 4,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: statistics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.15,
          ),
          itemBuilder: (context, index) {
            return _buildStatisticCard(
              context,
              statistics[index],
              mobile: width < AppBreakpoints.mobile,
            );
          },
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: EducanoColors.textPrimary,
                  ),
                ),
              ),

              Icon(item.icon, color: item.color, size: 20),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.value,
                style: TextStyle(
                  fontSize: mobile ? 30 : 26,
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
              fontSize: 12,
              color: EducanoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariation(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
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
        height: 360,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuários',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Expanded(child: _UsersDonutChart(summary: _summary!)),
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
    final events = (_summary!['eventosRecentes'] as List).cast<Map<String, dynamic>>();
    final activities = [
      for (final event in events)
        switch (event['tipo']) {
          'USUARIO' => ('Novo usuário cadastrado', event['descricao'] as String, ApiMappers.formatDate(event['data']), Icons.person_add_alt_rounded, EducanoColors.successGreen),
          'CURSO' => ('Curso cadastrado', event['descricao'] as String, ApiMappers.formatDate(event['data']), Icons.edit_note_rounded, EducanoColors.accentYellow),
          _ => ('Questão adicionada', event['descricao'] as String, ApiMappers.formatDate(event['data']), Icons.quiz_rounded, EducanoColors.primaryBlue),
        },
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      activity.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: EducanoColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                trailing: Text(
                  activity.$3,
                  style: const TextStyle(
                    fontSize: 10,
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
        'Estou tendo um problema com XP, sempre que faço uma atividade recebo 0xp. O que devo fazer?',
      ),
      ('Manuela Souza', 'Como devo fazer para ver meus simulados anteriores?'),
      (
        'Mateus Lima',
        'Para os professores do Curso de Matemática: Qual a resposta da questão sobre Sigma?',
      ),
      (
        'Luana Castanho',
        'Estou tendo um problema com XP, sempre que faço uma atividade recebo 0xp. O que devo fazer?',
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        question.$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
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
  final Map<String, dynamic> summary;

  const _UsersDonutChart({required this.summary});

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
                flex: 4,
                child: CustomPaint(
                  painter: _DonutPainter(data: data),
                  child: const SizedBox.expand(),
                ),
              ),

              // ====================================================
              // LEGENDA
              // ====================================================
              Expanded(
                flex: 5,
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

  static const _colors = [
    EducanoColors.primaryBlue,
    EducanoColors.successGreen,
    EducanoColors.accentYellow,
    Color(0xFFE94B0C),
    Colors.grey,
  ];

  List<_DonutData> _fromList(String key, String labelKey, {String? nested}) {
    final source = nested == null
        ? widget.summary[key] as List
        : (widget.summary[nested] as Map)[key] as List;
    final items = source.cast<Map<String, dynamic>>();
    return [
      for (var i = 0; i < items.length; i++)
        _DonutData(
          label: items[i][labelKey] as String,
          value: (items[i]['total'] as num).toDouble(),
          color: _colors[i % _colors.length],
        ),
    ];
  }

  List<_DonutData> _getData() {
    switch (_type) {
      case _DonutType.plans:
        return _fromList('planos', 'nome');
      case _DonutType.courses:
        return _fromList('inscricoesPorAluno', 'faixa', nested: 'cursos');
      case _DonutType.activity:
        return _fromList('atividade', 'faixa');
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              style: const TextStyle(
                fontSize: 11,
                color: EducanoColors.textPrimary,
              ),
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

int _getGridColumns(
  double width, {
  required int mobile,
  required int tablet,
  required int desktop,
}) {
  if (width < AppBreakpoints.compact) {
    return mobile;
  }

  if (width < AppBreakpoints.expanded) {
    return tablet;
  }

  return desktop;
}
