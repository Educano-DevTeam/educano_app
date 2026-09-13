import 'package:educano_app/core/constants/app_breakpoints.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const List<_CourseData> _courses = [
    _CourseData(
      title: 'Vestibular 2026 - Curso Preparatório',
      category: 'Multidisciplinar',
      hours: '75 Horas',
      description:
          'Prepare-se para o vestibular com o nosso curso completo. '
          'Oferecemos aulas focadas, material atualizado, simulados '
          'frequentes e suporte com professores...',
      progress: 1.0,
      progressLabel: 'Concluído',
      image: 'assets/home/course_vestibular.png',
    ),
    _CourseData(
      title: 'Introdução à Inteligência Artificial',
      category: 'Tecnologia',
      hours: '12 Horas',
      description:
          'Este curso apresenta os conceitos básicos de inteligência '
          'artificial de forma simples e direta. Você vai aprender '
          'como as ferramentas digitais funcionam...',
      progress: 0.35,
      progressLabel: '35%',
      image: 'assets/home/course_ia.png',
    ),
    _CourseData(
      title: 'Finanças Pessoais para Iniciantes',
      category: 'Educação Financeira',
      hours: '32 Horas',
      description:
          'Este curso prático ensina você a organizar seu orçamento, '
          'sair das dívidas e investir com segurança. Você vai aprender '
          'a controlar gastos do dia a dia, cria...',
      progress: 0.12,
      progressLabel: '12%',
      image: 'assets/home/course_financas.png',
    ),
    _CourseData(
      title: 'Design Profissional',
      category: 'Design',
      hours: '48 Horas',
      description:
          'Transforme sua carreira e domine as ferramentas mais buscadas '
          'do mercado com o curso de Design Profissional. Você vai '
          'aprender desde os conceit...',
      progress: 0.19,
      progressLabel: '19%',
      image: 'assets/home/course_design.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isMobile = width < AppBreakpoints.mobile;
        final bool isTablet =
            width >= AppBreakpoints.mobile && width < AppBreakpoints.expanded;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile
                ? 16
                : isTablet
                ? 20
                : 29,
            vertical: isMobile ? 16 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OverviewCard(isMobile: isMobile),

              const SizedBox(height: _spacingMedium),

              _CoursesCard(courses: _courses, isMobile: isMobile),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// VISÃO GERAL
// -----------------------------------------------------------------------------

class _OverviewCard extends StatelessWidget {
  final bool isMobile;

  const _OverviewCard({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      decoration: BoxDecoration(
        color: EducanoColors.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visão Geral',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF404040),
            ),
          ),

          const SizedBox(height: 14),

          _LevelCard(isMobile: isMobile),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LEVEL
// -----------------------------------------------------------------------------

class _LevelCard extends StatelessWidget {
  final bool isMobile;

  const _LevelCard({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 18,
        vertical: isMobile ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: EducanoColors.primaryBlue,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: isMobile ? _buildMobileLevel() : _buildDesktopLevel(),
      ),
    );
  }

  Widget _buildDesktopLevel() {
    return Row(
      children: [
        const SizedBox(
          width: 60,
          child: Icon(
            Icons.emoji_events_rounded,
            size: 56,
            color: EducanoColors.accentYellow,
          ),
        ),

        const SizedBox(width: 18),

        const SizedBox(
          width: 145,
          child: Text(
            'LEVEL 5',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: EducanoColors.primaryBlue,
            ),
          ),
        ),

        Expanded(
          child: _ProgressArea(
            progress: 0.625,
            label: '1250/2000 XP para o Level 6',
          ),
        ),

        const SizedBox(width: 14),

        const Text(
          '62%',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: EducanoColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 48,
              color: EducanoColors.accentYellow,
            ),
            const SizedBox(width: 14),
            const Text(
              'LEVEL 5',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: EducanoColors.primaryBlue,
              ),
            ),
            const Spacer(),
            const Text(
              '62%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: EducanoColors.primaryBlue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _ProgressArea(progress: 0.625, label: '1250/2000 XP para o Level 6'),
      ],
    );
  }
}

class _ProgressArea extends StatelessWidget {
  final double progress;
  final String label;

  const _ProgressArea({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 19,
            backgroundColor: const Color(0xFFD7D7D7),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF20D500)),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: EducanoColors.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// MEUS CURSOS
// -----------------------------------------------------------------------------

class _CoursesCard extends StatelessWidget {
  final List<_CourseData> courses;
  final bool isMobile;

  const _CoursesCard({required this.courses, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      decoration: BoxDecoration(
        color: EducanoColors.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meus Cursos',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF404040),
            ),
          ),

          const SizedBox(height: 14),

          ...courses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CourseCard(course: course, isMobile: isMobile),
            ),
          ),

          _SimuladosCard(isMobile: isMobile),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARD DE CURSO
// -----------------------------------------------------------------------------

class _CourseCard extends StatelessWidget {
  final _CourseData course;
  final bool isMobile;

  const _CourseCard({required this.course, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobile();
    }

    return _buildDesktop();
  }

  Widget _buildDesktop() {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {},
        child: Container(
          height: 138,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: 315,
                height: double.infinity,
                child: Image.asset(course.image, fit: BoxFit.cover),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    right: 16,
                    bottom: 10,
                  ),
                  child: _CourseInformation(course: course),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobile() {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {},
        child: Container(
          height: 123,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: 112,
                height: double.infinity,
                child: Image.asset(course.image, fit: BoxFit.cover),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 7, right: 8, bottom: 7),
                  child: _CourseInformation(course: course, isMobile: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INFORMAÇÕES DO CURSO
// -----------------------------------------------------------------------------

class _CourseInformation extends StatelessWidget {
  final _CourseData course;
  final bool isMobile;

  const _CourseInformation({required this.course, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                course.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF454545),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: EducanoColors.primaryBlue,
                ),
                const SizedBox(width: 5),
                Text(
                  course.hours,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ],
        ),

        Text(
          course.category,
          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
        ),

        const SizedBox(height: 7),

        Expanded(
          child: Text(
            course.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              height: 1.25,
              color: Color(0xFF4D4D4D),
            ),
          ),
        ),

        const Divider(height: 8, thickness: 1, color: Color(0xFFD5D5D5)),

        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: LinearProgressIndicator(
                  value: course.progress,
                  minHeight: 20,
                  backgroundColor: const Color(0xFFD7D7D7),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF20D500),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              course.progressLabel,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF494949),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SIMULADOS
// -----------------------------------------------------------------------------

class _SimuladosCard extends StatelessWidget {
  final bool isMobile;

  const _SimuladosCard({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {},
        child: Container(
          height: isMobile ? 123 : 138,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: isMobile ? 112 : 315,
                height: double.infinity,
                child: Image.asset(
                  'assets/home/simulados.png',
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 18),

              const Expanded(
                child: Text(
                  'Simulados',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF454545),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MODELO
// -----------------------------------------------------------------------------

class _CourseData {
  final String title;
  final String category;
  final String hours;
  final String description;
  final double progress;
  final String progressLabel;
  final String image;

  const _CourseData({
    required this.title,
    required this.category,
    required this.hours,
    required this.description,
    required this.progress,
    required this.progressLabel,
    required this.image,
  });
}
