import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;

const double _radius = 18;

/// Catálogo de cursos disponíveis para auto-inscrição do aluno.
/// Acessado a partir da Home (botão "Adicionar curso").
class CourseCatalogView extends StatefulWidget {
  final List<String> enrolledCourseIds;
  final ValueChanged<Map<String, dynamic>> onEnroll;

  const CourseCatalogView({
    super.key,
    required this.enrolledCourseIds,
    required this.onEnroll,
  });

  @override
  State<CourseCatalogView> createState() => _CourseCatalogViewState();
}

class _CourseCatalogViewState extends State<CourseCatalogView> {
  late final List<String> _enrolledIds;

  final List<Map<String, dynamic>> _catalogCourses = [
    {
      'id': 'course-mat',
      'name': 'Matemática Básica',
      'icon': Icons.calculate_rounded,
      'students': '540 mil alunos',
      'gradient': [EducanoColors.primaryBlue, EducanoColors.secondaryBlue],
    },
    {
      'id': 'course-port',
      'name': 'Português Avançado',
      'icon': Icons.menu_book_rounded,
      'students': '3,87 mi alunos',
      'gradient': [EducanoColors.darkGreen, EducanoColors.successGreen],
    },
    {
      'id': 'course-bio',
      'name': 'Biologia Celular',
      'icon': Icons.biotech_rounded,
      'students': '1,29 mi alunos',
      'gradient': [EducanoColors.accentYellow, EducanoColors.softGreen],
    },
    {
      'id': 'course-fis',
      'name': 'Física Quântica',
      'icon': Icons.science_rounded,
      'students': '510 mil alunos',
      'gradient': [EducanoColors.lightBlue, EducanoColors.primaryBlue],
    },
    {
      'id': 'course-hist',
      'name': 'História do Brasil',
      'icon': Icons.museum_rounded,
      'students': '238 mil alunos',
      'gradient': [EducanoColors.secondaryBlue, EducanoColors.lightBlue],
    },
  ];

  @override
  void initState() {
    super.initState();
    _enrolledIds = List.of(widget.enrolledCourseIds);
  }

  void _enroll(Map<String, dynamic> course) {
    setState(() => _enrolledIds.add(course['id'] as String));
    widget.onEnroll(course);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inscrito(a) em ${course['name']}!'),
        backgroundColor: EducanoColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EducanoColors.background,
      appBar: AppBar(
        title: const Text('Adicionar Curso'),
        backgroundColor: EducanoColors.background,
        elevation: 0,
        foregroundColor: EducanoColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(_spacingMedium),
        children: [
          Text(
            'Escolha um curso para começar a estudar.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: EducanoColors.textSecondary,
                ),
          ),
          const SizedBox(height: _spacingMedium),
          ..._catalogCourses.map(_buildCatalogCard),
        ],
      ),
    );
  }

  Widget _buildCatalogCard(Map<String, dynamic> course) {
    final bool enrolled = _enrolledIds.contains(course['id']);
    final colors = course['gradient'] as List<Color>;

    return Container(
      margin: const EdgeInsets.only(bottom: _spacingSmall),
      padding: const EdgeInsets.all(_spacingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(course['icon'] as IconData, color: EducanoColors.textWhite, size: 36),
          const SizedBox(width: _spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['name'] as String,
                  style: const TextStyle(
                    color: EducanoColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  course['students'] as String,
                  style: const TextStyle(
                    color: EducanoColors.textWhite,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: _spacingMinimum),
          enrolled
              ? const Icon(Icons.check_circle_rounded, color: EducanoColors.textWhite)
              : InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _enroll(course),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: EducanoColors.textWhite,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
