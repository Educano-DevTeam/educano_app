import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/course.dart';
import '../widgets/app_shell.dart';
import '../widgets/section_card.dart';
import '../widgets/mini_bar_chart.dart';
import '../widgets/hover_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const List<Course> _courses = [
    Course(initials: 'MB', color: AppColors.navy, name: 'Matemática Básica', progressLabel: '3 trilhas • 45% concluído'),
    Course(initials: 'PA', color: AppColors.green, name: 'Português Avançado', progressLabel: '2 trilhas • 62% concluído'),
    Course(initials: 'FQ', color: AppColors.orange, name: 'Física Quântica', progressLabel: '1 trilha • 20% concluído'),
    Course(initials: 'BC', color: AppColors.red, name: 'Biologia Celular', progressLabel: '1 trilha • 80% concluído'),
  ];

  static const List<ChartPoint> _chartData = [
    ChartPoint('Fev', 320, 260),
    ChartPoint('Mar', 480, 210),
    ChartPoint('Abr', 610, 520),
    ChartPoint('Mai', 300, 250),
    ChartPoint('Jun', 540, 470),
    ChartPoint('Jul', 700, 640),
    ChartPoint('Ago', 860, 760),
  ];

  int? _selectedCourse;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/perfil',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meu Perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gerencie suas informações e confira seu progresso.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const _ProfileHeaderCard(),
            const SizedBox(height: 16),
            const _PlanBanner(),
            const SizedBox(height: 20),
            const SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Evolução das notas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      Spacer(),
                      Text('2026', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _LegendDot(color: AppColors.red, label: 'Atividades'),
                      SizedBox(width: 16),
                      _LegendDot(color: AppColors.primary, label: 'Simulados'),
                    ],
                  ),
                  SizedBox(height: 16),
                  MiniBarChart(data: _chartData),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Meus Cursos',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      Spacer(),
                      Text('4 em andamento', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < _courses.length; i++)
                    _CourseRow(
                      course: _courses[i],
                      selected: _selectedCourse == i,
                      onTap: () => setState(
                        () => _selectedCourse = _selectedCourse == i ? null : i,
                      ),
                    ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Ver todos os cursos  ›',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 92,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
              Positioned(
                left: 20,
                bottom: -30,
                child: Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool narrow = constraints.maxWidth < 460;

                const Widget nameBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Daniel Lima',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('daniel.lima@gmail.com',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  ],
                );

                final Widget buttons = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HoverOutlineButton(
                      label: 'Editar Perfil',
                      leadingIcon: Icons.edit_outlined,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    HoverOutlineButton(
                      label: 'Compartilhar',
                      leadingIcon: Icons.ios_share,
                      onPressed: () {},
                    ),
                  ],
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    narrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [nameBlock, const SizedBox(height: 12), buttons],
                          )
                        : Row(children: [Expanded(child: nameBlock), buttons]),
                    const SizedBox(height: 20),
                    const _StatsRow(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    const List<List<String>> items = [
      ['5', 'Nível'],
      ['1.240', 'XP'],
      ['7 dias', 'Sequência'],
      ['3', 'Concluídos'],
    ];

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0)
            Container(
              width: 1,
              height: 30,
              color: AppColors.cardBorder,
              margin: const EdgeInsets.symmetric(horizontal: 14),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(items[i][0],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              Text(items[i][1], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ],
    );
  }
}

class _PlanBanner extends StatelessWidget {
  const _PlanBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.workspace_premium, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plano Básico',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary)),
                Text('Grátis - Tenha acesso a mais recursos disponíveis.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          HoverButton(
            label: 'Ver planos',
            trailingIcon: Icons.chevron_right,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _CourseRow extends StatefulWidget {
  final Course course;
  final bool selected;
  final VoidCallback onTap;

  const _CourseRow({
    required this.course,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CourseRow> createState() => _CourseRowState();
}

class _CourseRowState extends State<_CourseRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    Color bg;
    if (widget.selected) {
      bg = AppColors.primary.withValues(alpha: 0.12);
    } else if (_hovered) {
      bg = AppColors.scaffoldBg;
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: course.color, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  course.initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary)),
                    Text(course.progressLabel,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: widget.selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}