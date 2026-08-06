import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import 'course_catalog_view.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

/// IBL18 – Atualização de Progresso e Trilha do Aluno
///
/// Estrutura em níveis (estilo Duolingo): cursos (cards) -> trilhas de
/// aprendizado -> módulos (com 1 lição + materiais didáticos), como se
/// fosse uma estrutura de pasta.
class StudentProgressView extends StatefulWidget {
  const StudentProgressView({super.key});

  @override
  State<StudentProgressView> createState() => _StudentProgressViewState();
}

class _StudentProgressViewState extends State<StudentProgressView> {
  String? _selectedCourseId;
  String? _selectedTrilhaId;

  final List<Map<String, dynamic>> _myCourses = [
    {
      'id': 'course-mat',
      'name': 'Matemática Básica',
      'icon': Icons.calculate_rounded,
      'color': EducanoColors.primaryBlue,
      'trilhas': [
        {
          'id': 'trilha-mat-fund',
          'title': 'Fundamentos',
          'description': 'Introdução aos conceitos básicos',
          'status': 'done',
          'modulos': [
            {
              'id': 'mod-mat-1',
              'title': 'Módulo 1: Operações Básicas',
              'status': 'done',
              'licao': {'title': 'Adição e Subtração', 'xp': 50, 'status': 'done'},
              'materiais': [
                {'name': 'Apostila em PDF', 'icon': Icons.picture_as_pdf_rounded},
                {'name': 'Slides da aula', 'icon': Icons.slideshow_rounded},
              ],
            },
            {
              'id': 'mod-mat-2',
              'title': 'Módulo 2: Frações',
              'status': 'done',
              'licao': {'title': 'Frações Equivalentes', 'xp': 60, 'status': 'done'},
              'materiais': [
                {'name': 'Apostila em PDF', 'icon': Icons.picture_as_pdf_rounded},
              ],
            },
          ],
        },
        {
          'id': 'trilha-mat-inter',
          'title': 'Módulo Intermediário',
          'description': 'Aprofundamento nos conteúdos principais',
          'status': 'current',
          'modulos': [
            {
              'id': 'mod-mat-3',
              'title': 'Módulo 3: Equações do 1º Grau',
              'status': 'current',
              'licao': {'title': 'Resolvendo Equações', 'xp': 80, 'status': 'current'},
              'materiais': [
                {'name': 'Vídeo-aula', 'icon': Icons.play_circle_rounded},
                {'name': 'Lista de exercícios', 'icon': Icons.assignment_rounded},
              ],
            },
            {
              'id': 'mod-mat-4',
              'title': 'Módulo 4: Equações do 2º Grau',
              'status': 'locked',
              'licao': {'title': 'Fórmula de Bhaskara', 'xp': 100, 'status': 'locked'},
              'materiais': [
                {'name': 'Apostila em PDF', 'icon': Icons.picture_as_pdf_rounded},
              ],
            },
          ],
        },
        {
          'id': 'trilha-mat-simulados',
          'title': 'Simulados',
          'description': 'Pratique com questões de vestibular',
          'status': 'locked',
          'modulos': [
            {
              'id': 'mod-mat-5',
              'title': 'Módulo 5: Simulado Geral',
              'status': 'locked',
              'licao': {'title': 'Prova Simulada', 'xp': 150, 'status': 'locked'},
              'materiais': [
                {'name': 'Caderno de questões', 'icon': Icons.quiz_rounded},
              ],
            },
          ],
        },
      ],
    },
    {
      'id': 'course-port',
      'name': 'Português Avançado',
      'icon': Icons.menu_book_rounded,
      'color': EducanoColors.successGreen,
      'trilhas': [
        {
          'id': 'trilha-port-gram',
          'title': 'Gramática',
          'description': 'Regras e estrutura da língua',
          'status': 'current',
          'modulos': [
            {
              'id': 'mod-port-1',
              'title': 'Módulo 1: Concordância Verbal',
              'status': 'done',
              'licao': {'title': 'Sujeito e Predicado', 'xp': 50, 'status': 'done'},
              'materiais': [
                {'name': 'Apostila em PDF', 'icon': Icons.picture_as_pdf_rounded},
              ],
            },
            {
              'id': 'mod-port-2',
              'title': 'Módulo 2: Crase',
              'status': 'current',
              'licao': {'title': 'Quando usar a crase', 'xp': 70, 'status': 'current'},
              'materiais': [
                {'name': 'Vídeo-aula', 'icon': Icons.play_circle_rounded},
              ],
            },
          ],
        },
        {
          'id': 'trilha-port-interp',
          'title': 'Interpretação de Texto',
          'description': 'Leitura crítica e compreensão',
          'status': 'locked',
          'modulos': [
            {
              'id': 'mod-port-3',
              'title': 'Módulo 3: Textos Argumentativos',
              'status': 'locked',
              'licao': {'title': 'Identificando Teses', 'xp': 80, 'status': 'locked'},
              'materiais': [
                {'name': 'Coletânea de textos', 'icon': Icons.picture_as_pdf_rounded},
              ],
            },
          ],
        },
      ],
    },
    {
      'id': 'course-bio',
      'name': 'Biologia Celular',
      'icon': Icons.biotech_rounded,
      'color': EducanoColors.accentYellow,
      'trilhas': [
        {
          'id': 'trilha-bio-cel',
          'title': 'A Célula',
          'description': 'Estrutura e funcionamento celular',
          'status': 'current',
          'modulos': [
            {
              'id': 'mod-bio-1',
              'title': 'Módulo 1: Membrana Plasmática',
              'status': 'done',
              'licao': {'title': 'Transporte Celular', 'xp': 50, 'status': 'done'},
              'materiais': [
                {'name': 'Apostila em PDF', 'icon': Icons.picture_as_pdf_rounded},
              ],
            },
            {
              'id': 'mod-bio-2',
              'title': 'Módulo 2: Organelas',
              'status': 'current',
              'licao': {'title': 'Mitocôndrias e Ribossomos', 'xp': 60, 'status': 'current'},
              'materiais': [
                {'name': 'Vídeo-aula', 'icon': Icons.play_circle_rounded},
                {'name': 'Slides da aula', 'icon': Icons.slideshow_rounded},
              ],
            },
          ],
        },
      ],
    },
    {
      'id': 'course-fis',
      'name': 'Física Quântica',
      'icon': Icons.science_rounded,
      'color': EducanoColors.lightBlue,
      'trilhas': [
        {
          'id': 'trilha-fis-intro',
          'title': 'Introdução',
          'description': 'Primeiros conceitos da física quântica',
          'status': 'current',
          'modulos': [
            {
              'id': 'mod-fis-1',
              'title': 'Módulo 1: Dualidade Onda-Partícula',
              'status': 'current',
              'licao': {'title': 'Experimento da Dupla Fenda', 'xp': 90, 'status': 'current'},
              'materiais': [
                {'name': 'Vídeo-aula', 'icon': Icons.play_circle_rounded},
              ],
            },
          ],
        },
      ],
    },
  ];

  Map<String, dynamic>? get _selectedCourse {
    if (_selectedCourseId == null) return null;
    return _myCourses.firstWhere((c) => c['id'] == _selectedCourseId);
  }

  Map<String, dynamic>? get _selectedTrilha {
    final course = _selectedCourse;
    if (course == null || _selectedTrilhaId == null) return null;
    final trilhas = course['trilhas'] as List<dynamic>;
    return trilhas.firstWhere((t) => t['id'] == _selectedTrilhaId)
        as Map<String, dynamic>;
  }

  void _openCatalog() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseCatalogView(
          enrolledCourseIds: _myCourses.map((c) => c['id'] as String).toList(),
          onEnroll: (course) {
            setState(() {
              _myCourses.add({
                'id': course['id'],
                'name': course['name'],
                'icon': course['icon'],
                'color': EducanoColors.primaryBlue,
                'trilhas': <Map<String, dynamic>>[],
              });
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedTrilhaId != null) {
      return _buildModulosLevel(context);
    }
    if (_selectedCourseId != null) {
      return _buildTrilhasLevel(context);
    }
    return _buildCoursesLevel(context);
  }

  // Nível 0 – grid de cursos do aluno
  Widget _buildCoursesLevel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: _spacingLarge),
          _buildOverallProgress(context),
          const SizedBox(height: _spacingLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meus Cursos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: _openCatalog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Adicionar curso'),
              ),
            ],
          ),
          const SizedBox(height: _spacingSmall),
          _buildCourseCardsGrid(),
        ],
      ),
    );
  }

  Widget _buildCourseCardsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 600
            ? 1
            : constraints.maxWidth < 1000
                ? 2
                : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: _spacingSmall,
            mainAxisSpacing: _spacingSmall,
            mainAxisExtent: 88,
          ),
          itemCount: _myCourses.length,
          itemBuilder: (context, index) => _buildCourseCard(_myCourses[index]),
        );
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final color = course['color'] as Color;
    final trilhas = course['trilhas'] as List<dynamic>;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: () => setState(() => _selectedCourseId = course['id'] as String),
        child: Container(
          padding: const EdgeInsets.all(_spacingSmall),
          decoration: BoxDecoration(
            color: EducanoColors.background,
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(course['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(width: _spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: EducanoColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${trilhas.length} trilhas de aprendizado',
                      style: const TextStyle(
                        color: EducanoColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: EducanoColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // Nível 1 – trilhas do curso selecionado
  Widget _buildTrilhasLevel(BuildContext context) {
    final course = _selectedCourse!;
    final trilhas = course['trilhas'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrillDownHeader(
            context,
            title: course['name'] as String,
            subtitle: 'Trilhas de aprendizado',
            onBack: () => setState(() => _selectedCourseId = null),
          ),
          const SizedBox(height: _spacingMedium),
          if (trilhas.isEmpty)
            const Text(
              'Nenhuma trilha cadastrada ainda para este curso.',
              style: TextStyle(color: EducanoColors.textSecondary),
            )
          else
            ...trilhas.map(
              (trilha) => _buildTrilhaFolderCard(trilha as Map<String, dynamic>),
            ),
        ],
      ),
    );
  }

  Widget _buildTrilhaFolderCard(Map<String, dynamic> trilha) {
    final status = trilha['status'] as String;
    final (color, icon) = _statusVisuals(status);
    final modulos = trilha['modulos'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: _spacingSmall),
      decoration: BoxDecoration(
        color: EducanoColors.background,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: () => setState(() => _selectedTrilhaId = trilha['id'] as String),
          child: Padding(
            padding: const EdgeInsets.all(_spacingSmall),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(Icons.folder_rounded, color: color, size: 20),
                ),
                const SizedBox(width: _spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trilha['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: EducanoColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${trilha['description']}  ·  ${modulos.length} módulos',
                        style: const TextStyle(
                          color: EducanoColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Nível 2 – módulos da trilha selecionada (lição + materiais)
  Widget _buildModulosLevel(BuildContext context) {
    final trilha = _selectedTrilha!;
    final modulos = trilha['modulos'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrillDownHeader(
            context,
            title: trilha['title'] as String,
            subtitle: 'Módulos',
            onBack: () => setState(() => _selectedTrilhaId = null),
          ),
          const SizedBox(height: _spacingMedium),
          ...modulos.map(
            (modulo) => _buildModuloExpansion(modulo as Map<String, dynamic>),
          ),
        ],
      ),
    );
  }

  Widget _buildModuloExpansion(Map<String, dynamic> modulo) {
    final status = modulo['status'] as String;
    final (color, icon) = _statusVisuals(status);
    final licao = modulo['licao'] as Map<String, dynamic>;
    final materiais = modulo['materiais'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: _spacingSmall),
      decoration: BoxDecoration(
        color: EducanoColors.background,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(Icons.folder_rounded, color: color, size: 18),
          ),
          title: Text(
            modulo['title'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: EducanoColors.textPrimary,
            ),
          ),
          trailing: Icon(icon, color: color, size: 20),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _spacingMedium,
                0,
                _spacingMedium,
                _spacingSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  _buildLicaoRow(licao),
                  const SizedBox(height: _spacingMinimum),
                  Text(
                    'Materiais didáticos',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: EducanoColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  ...materiais.map(
                    (material) => _buildMaterialRow(material as Map<String, dynamic>),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicaoRow(Map<String, dynamic> licao) {
    final status = licao['status'] as String;
    final (color, icon) = _statusVisuals(status);

    return Container(
      padding: const EdgeInsets.all(_spacingMinimum),
      margin: const EdgeInsets.symmetric(vertical: _spacingMinimum),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: _spacingMinimum),
          Expanded(
            child: Text(
              licao['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: EducanoColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: EducanoColors.accentYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${licao['xp']} XP',
              style: const TextStyle(
                color: EducanoColors.accentYellow,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(Map<String, dynamic> material) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abrir "${material['name']}" (em breve)'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(material['icon'] as IconData, color: EducanoColors.textSecondary, size: 18),
            const SizedBox(width: _spacingMinimum),
            Text(
              material['name'] as String,
              style: const TextStyle(color: EducanoColors.textPrimary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrillDownHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onBack,
  }) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: _spacingMinimum),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            Text(
              subtitle,
              style: const TextStyle(color: EducanoColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  (Color, IconData) _statusVisuals(String status) {
    switch (status) {
      case 'done':
        return (EducanoColors.successGreen, Icons.check_circle_rounded);
      case 'current':
        return (EducanoColors.primaryBlue, Icons.play_circle_filled_rounded);
      default:
        return (EducanoColors.textSecondary, Icons.lock_rounded);
    }
  }
}

Widget _buildHeader(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Meu Progresso',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: _spacingMinimum),
      Text(
        'Acompanhe seu avanço na trilha de aprendizado.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: EducanoColors.textSecondary,
            ),
      ),
    ],
  );
}

Widget _buildOverallProgress(BuildContext context) {
  const totalXp = 1240;
  const nextLevelXp = 2000;
  const level = 5;
  const progressPercent = totalXp / nextLevelXp;

  final stats = [
    {
      'label': 'Nível',
      'value': level.toString(),
      'icon': Icons.military_tech_rounded,
      'color': EducanoColors.accentYellow,
    },
    {
      'label': 'XP Total',
      'value': totalXp.toString(),
      'icon': Icons.bolt_rounded,
      'color': EducanoColors.primaryBlue,
    },
    {
      'label': 'Cursos Concluídos',
      'value': '3',
      'icon': Icons.check_circle_rounded,
      'color': EducanoColors.successGreen,
    },
    {
      'label': 'Sequência',
      'value': '7 dias',
      'icon': Icons.local_fire_department_rounded,
      'color': EducanoColors.error,
    },
  ];

  return Container(
    padding: const EdgeInsets.all(_spacingMedium),
    decoration: BoxDecoration(
      color: EducanoColors.background,
      borderRadius: BorderRadius.circular(_radius),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visão Geral',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 600 ? 2 : 4;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: _spacingSmall,
                mainAxisSpacing: _spacingSmall,
                mainAxisExtent: 136,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                return Container(
                  padding: const EdgeInsets.all(_spacingSmall),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat['value'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: stat['color'] as Color,
                        ),
                      ),
                      Text(
                        stat['label'] as String,
                        style: const TextStyle(
                          color: EducanoColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: _spacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'XP para o próximo nível',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$totalXp / $nextLevelXp XP',
              style: const TextStyle(
                color: EducanoColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: _spacingMinimum),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: EducanoColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(
              EducanoColors.primaryBlue,
            ),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: _spacingMinimum),
        Text(
          '${(progressPercent * 100).toStringAsFixed(0)}% concluído para o Nível ${level + 1}',
          style: const TextStyle(
            color: EducanoColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
