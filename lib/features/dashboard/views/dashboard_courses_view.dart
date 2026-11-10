import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/data/dashboard_events.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../services/api_client.dart';
import '../../../services/courses_service.dart';
import 'course_editor_view.dart';
import '../widgets/dashboard_list_components.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

// IBL06 – Listagem e Relatório de Cursos Cadastrados
// IBL07 – Inscrição de usuário em Curso (ação inline via dialog)
class DashboardCoursesView extends StatefulWidget {
  const DashboardCoursesView({super.key});

  @override
  State<DashboardCoursesView> createState() => _DashboardCoursesViewState();
}

class _DashboardCoursesViewState extends State<DashboardCoursesView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Todos';
  String _selectedCategory = 'Todas';

  List<Map<String, dynamic>> _courses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    DashboardEvents.changes.addListener(_loadCourses);
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await CoursesService.instance.list();
      if (!mounted) return;
      setState(() {
        _courses = result.courses;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  List<String> get _categoryOptions => [
        'Todas',
        ..._courses.map((c) => c['category'] as String).toSet(),
      ];

  @override
  void dispose() {
    DashboardEvents.changes.removeListener(_loadCourses);
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCourses {
    return _courses.where((course) {
      final matchesSearch = _searchQuery.isEmpty ||
          (course['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (course['category'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _selectedStatus == 'Todos' || course['status'] == _selectedStatus;
      final matchesCategory = _selectedCategory == 'Todas' ||
          course['category'] == _selectedCategory;
      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();
  }

  void _showCourseSummaryDialog(BuildContext context, Map<String, dynamic> course) {
    final statusColor = switch (course['status'] as String) {
      'Ativo' => EducanoColors.successGreen,
      'Inativo' => EducanoColors.error,
      _ => EducanoColors.accentYellow,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.menu_book_rounded,
              color: EducanoColors.primaryBlue,
            ),
            const SizedBox(width: _spacingMinimum),
            Expanded(
              child: Text(
                course['name'] as String,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['description'] as String? ?? 'Descrição não disponível.',
                style: const TextStyle(color: EducanoColors.textSecondary),
              ),
              const SizedBox(height: _spacingSmall),
              _buildSummaryRow('Categoria', course['category'] as String),
              _buildSummaryRow('Criado em', course['createdAt'] as String),
              _buildSummaryRow(
                'Capacidade',
                '${course['enrolled']}/${course['capacity'] ?? '∞'} vagas preenchidas',
              ),
              _buildSummaryRow('Conteúdo', _contentSummary(course)),
              const SizedBox(height: 4),
              _buildStatusBadge(course['status'] as String, statusColor),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (course['canEdit'] == true)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _deleteCourse(course);
              },
              icon: const Icon(Icons.delete_outline_rounded, color: EducanoColors.error),
              label: const Text('Excluir', style: TextStyle(color: EducanoColors.error)),
            ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.course, arguments: course['id']);
            },
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Abrir curso'),
          ),
          if (course['canEdit'] == true)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openCourseEditor(course: course);
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Editar curso'),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: EducanoColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: EducanoColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _contentSummary(Map<String, dynamic> course) {
    final summary = course['contentSummary'] as Map<String, dynamic>?;
    if (summary != null && course['trilhas'] == null) {
      return [
        _plural(summary['trilhas'] as int, 'trilha', 'trilhas'),
        _plural(summary['modulos'] as int, 'módulo', 'módulos'),
        _plural(summary['materiais'] as int, 'material', 'materiais'),
      ].join('  ·  ');
    }
    final trilhas = course['trilhas'] as List<dynamic>? ?? const [];
    final modulos = trilhas
        .expand((t) => (t as Map<String, dynamic>)['modulos'] as List<dynamic>)
        .toList();
    final materiais = modulos.fold<int>(
      0,
      (sum, m) => sum + ((m as Map<String, dynamic>)['materiais'] as List).length,
    );
    return [
      _plural(trilhas.length, 'trilha', 'trilhas'),
      _plural(modulos.length, 'módulo', 'módulos'),
      _plural(materiais, 'material', 'materiais'),
    ].join('  ·  ');
  }

  /// Abre a página de criação (sem [course]) ou edição do curso. O editor
  /// salva na API; a listagem é recarregada depois.
  Future<void> _openCourseEditor({Map<String, dynamic>? course}) =>
      openDashboardCourseEditor(context, courseId: course?['id'] as String?);

  Future<void> _deleteCourse(Map<String, dynamic> course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir curso'),
        content: Text(
          'Excluir "${course['name']}"? Trilhas, materiais, inscrições e o '
          'progresso dos alunos também serão removidos.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: EducanoColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await CoursesService.instance.delete(course['id'] as String);
      if (!mounted) return;
      _snack('Curso excluído.');
      await _loadCourses();
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    }
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? EducanoColors.error : EducanoColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Relatório dos cursos filtrados em CSV, para copiar e colar numa planilha.
  void _exportCourses() {
    String cell(Object? value) => '"${'${value ?? ''}'.replaceAll('"', '""')}"';
    final rows = [
      ['Nome', 'Categoria', 'Status', 'Inscritos', 'Capacidade', 'Criado em', 'Conteúdo'],
      for (final c in _filteredCourses)
        [c['name'], c['category'], c['status'], c['enrolled'], c['capacity'] ?? 'Sem limite', c['createdAt'], _contentSummary(c)],
    ];
    final csv = rows.map((row) => row.map(cell).join(';')).join('\n');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Relatório de cursos (${rows.length - 1})'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(child: SelectableText(csv, style: const TextStyle(fontSize: 12))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: csv));
              if (context.mounted) Navigator.pop(context);
              _snack('CSV copiado para a área de transferência.');
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copiar CSV'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEnrollDialog(BuildContext context, {String? courseName}) async {
    final activeCourses = _courses.where((c) => c['status'] == 'Ativo').toList();
    if (activeCourses.isEmpty) {
      _snack('Não há cursos ativos para inscrição.', error: true);
      return;
    }
    final message = await showDialog<String>(
      context: context,
      builder: (_) => EnrollUserDialog(
        courses: activeCourses,
        initialCourseName: activeCourses.any((c) => c['name'] == courseName) ? courseName : null,
      ),
    );

    if (message == null || !context.mounted) return;
    _snack(message);
    await _loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: _spacingLarge),
          _buildStats(),
          const SizedBox(height: _spacingLarge),
          _buildActions(context),
          const SizedBox(height: _spacingSmall),
          _buildSearchAndFilters(),
          const SizedBox(height: _spacingMedium),
          _buildCoursesList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Cursos Cadastrados',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: _spacingMinimum),
        Text(
          'Encontre seus cursos para editar informações e materiais.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: EducanoColors.textSecondary,
              ),
        ),
      ],
    );
  }

  /// Barra de ações acima da busca (frame do Figma: botão primário à
  /// esquerda, ações secundárias na sequência).
  Widget _buildActions(BuildContext context) {
    return Wrap(
      spacing: _spacingMinimum,
      runSpacing: _spacingMinimum,
      children: [
        ElevatedButton.icon(
          onPressed: () => _openCourseEditor(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Novo Curso'),
        ),
        OutlinedButton.icon(
          onPressed: () => _showEnrollDialog(context),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Inscrever Usuário'),
        ),
        OutlinedButton.icon(
          onPressed: _courses.isEmpty ? null : _exportCourses,
          icon: const Icon(Icons.download_rounded),
          label: const Text('Exportar'),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final totalInscritos = _courses.fold<int>(
      0,
      (sum, c) => sum + (c['enrolled'] as int),
    );
    final stats = [
      {
        'label': 'Total de Cursos',
        'value': _courses.length.toString(),
        'icon': Icons.menu_book_rounded,
        'color': EducanoColors.primaryBlue,
      },
      {
        'label': 'Cursos Ativos',
        'value':
            _courses.where((c) => c['status'] == 'Ativo').length.toString(),
        'icon': Icons.check_circle_rounded,
        'color': EducanoColors.successGreen,
      },
      {
        'label': 'Vagas Preenchidas',
        'value': totalInscritos.toString(),
        'icon': Icons.people_alt_rounded,
        'color': EducanoColors.accentYellow,
      },
      {
        'label': 'Em Rascunho',
        'value': _courses
            .where((c) => c['status'] == 'Rascunho')
            .length
            .toString(),
        'icon': Icons.edit_note_rounded,
        'color': EducanoColors.lightBlue,
      },
    ];

    return DashboardSummaryGrid(items: stats.map((s) => DashboardSummaryData(label: s['label'] as String, value: s['value'] as String, icon: s['icon'] as IconData, color: s['color'] as Color)).toList());
    /* return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppBreakpoints.medium;
        final columns = isCompact ? 2 : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: _spacingSmall,
            mainAxisSpacing: _spacingSmall,
            mainAxisExtent: 112,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: EdgeInsets.all(isCompact ? 12.0 : _spacingSmall),
              decoration: BoxDecoration(
                color: EducanoColors.background,
                borderRadius: BorderRadius.circular(_radius),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: isCompact ? 16 : 20,
                    backgroundColor:
                        (stat['color'] as Color).withValues(alpha: 0.15),
                    child: Icon(
                      stat['icon'] as IconData,
                      size: isCompact ? 18 : 24,
                      color: stat['color'] as Color,
                    ),
                  ),
                  SizedBox(width: isCompact ? _spacingMinimum : _spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stat['label'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: EducanoColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          stat['value'] as String,
                          style: TextStyle(
                            fontSize: isCompact ? 20 : 22,
                            fontWeight: FontWeight.bold,
                            color: EducanoColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ); */
  }

  Widget _buildSearchAndFilters() {
    Widget statusFilter({double? width}) => _buildFilterDropdown(
          width: width,
          value: _selectedStatus,
          options: const ['Todos', 'Ativo', 'Inativo', 'Rascunho'],
          onChanged: (value) => setState(() => _selectedStatus = value!),
        );
    Widget categoryFilter({double? width}) => _buildFilterDropdown(
          width: width,
          value: _selectedCategory,
          options: _categoryOptions,
          onChanged: (value) => setState(() => _selectedCategory = value!),
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.medium;
        final searchField = TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Buscar por nome ou categoria...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        );

        // Mobile: busca em cima e os dois filtros dividindo a linha de baixo.
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField,
              const SizedBox(height: _spacingSmall),
              Row(
                children: [
                  Expanded(child: statusFilter()),
                  const SizedBox(width: _spacingSmall),
                  Expanded(child: categoryFilter()),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: _spacingSmall),
            statusFilter(width: 170),
            const SizedBox(width: _spacingSmall),
            categoryFilter(width: 170),
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    double? width,
  }) {
    return Container(
      width: width,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: _spacingSmall),
      decoration: BoxDecoration(
        color: EducanoColors.searchBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EducanoColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCoursesList(BuildContext context) {
    final courses = _filteredCourses;
    if (_loading) {
      return const DashboardListCard(title: 'Lista de Cursos', children: [Padding(padding: EdgeInsets.all(_spacingLarge), child: Center(child: CircularProgressIndicator()))]);
    }
    if (_error != null) {
      return DashboardListCard(title: 'Lista de Cursos', children: [Padding(padding: const EdgeInsets.all(_spacingLarge), child: Row(children: [Expanded(child: Text(_error!, style: const TextStyle(color: EducanoColors.error))), TextButton(onPressed: _loadCourses, child: const Text('Tentar novamente'))]))]);
    }
    return DashboardListCard(title: 'Lista de Cursos', count: courses.length, children: courses.isEmpty ? [const Padding(padding: EdgeInsets.all(_spacingLarge), child: Center(child: Text('Nenhum curso encontrado.')))] : courses.map((course) => _buildCourseItem(context, course)).toList());
    /* return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lista de Cursos (${courses.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: _spacingSmall),
        if (courses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(_spacingLarge),
            decoration: BoxDecoration(
              color: EducanoColors.background,
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: EducanoColors.textSecondary,
                ),
                SizedBox(height: _spacingSmall),
                Text(
                  'Nenhum curso encontrado.',
                  style: TextStyle(color: EducanoColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ...courses.map((course) => _buildCourseItem(context, course)),
      ],
    ); */
  }

  Widget _buildCourseItem(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
    final statusColor = switch (course['status'] as String) {
      'Ativo' => EducanoColors.successGreen,
      'Inativo' => EducanoColors.error,
      _ => EducanoColors.accentYellow,
    };
    final capacity = course['capacity'] as int? ?? 0;
    final progress = capacity == 0 ? 0.0 : (course['enrolled'] as int) / capacity;
    final courseColor = course['color'] as Color? ?? EducanoColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: _spacingSmall),
      decoration: BoxDecoration(
        color: EducanoColors.background,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: () => _showCourseSummaryDialog(context, course),
          child: Padding(
            padding: const EdgeInsets.all(_spacingSmall),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow =
                    constraints.maxWidth < AppBreakpoints.compact;

                final enrollButton = ElevatedButton(
                  onPressed: course['status'] != 'Ativo' ? null : () => _showEnrollDialog(
                    context,
                    courseName: course['name'] as String,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _spacingSmall,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Inscrever',
                    style: TextStyle(fontSize: 13),
                  ),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: courseColor.withValues(alpha: 0.12),
                          foregroundImage: (course['imageUrl'] as String? ?? '').isEmpty
                              ? null
                              : NetworkImage(course['imageUrl'] as String),
                          child: Icon(
                            course['icon'] as IconData? ??
                                Icons.menu_book_rounded,
                            color: courseColor,
                          ),
                        ),
                        const SizedBox(width: _spacingSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['name'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: EducanoColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${course['category']}  ·  Criado em '
                                '${course['createdAt']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: EducanoColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isNarrow) ...[
                          const SizedBox(width: _spacingSmall),
                          _buildStatusBadge(
                            course['status'] as String,
                            statusColor,
                          ),
                          const SizedBox(width: _spacingSmall),
                          Text(
                            '${course['enrolled']}/${course['capacity'] ?? '∞'}',
                            style: const TextStyle(
                              color: EducanoColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: _spacingSmall),
                          enrollButton,
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: EducanoColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: _spacingMinimum),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: EducanoColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          EducanoColors.primaryBlue,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% de capacidade '
                      'preenchida',
                      style: const TextStyle(
                        color: EducanoColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    // Mobile: status, vagas e ação vão para uma linha própria.
                    if (isNarrow) ...[
                      const SizedBox(height: _spacingSmall),
                      Row(
                        children: [
                          _buildStatusBadge(
                            course['status'] as String,
                            statusColor,
                          ),
                          const SizedBox(width: _spacingMinimum),
                          Expanded(
                            child: Text(
                              '${course['enrolled']}/${course['capacity'] ?? '∞'} '
                              'vagas',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: EducanoColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          enrollButton,
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _plural(int count, String singular, String plural) =>
    '$count ${count == 1 ? singular : plural}';

// IBL07 – Formulário de Inscrição de usuário em Curso
/// Inscrição de um aluno (pelo e-mail) em um curso. Retorna a mensagem de
/// sucesso ou null se cancelado.
class EnrollUserDialog extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final String? initialCourseName;

  const EnrollUserDialog({
    super.key,
    required this.courses,
    this.initialCourseName,
  });

  @override
  State<EnrollUserDialog> createState() => _EnrollUserDialogState();
}

class _EnrollUserDialogState extends State<EnrollUserDialog> {
  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late String _selectedCourse;
  String _selectedTurma = 'EAD';
  bool _saving = false;
  String? _error;

  final List<String> _turmas = ['Manhã', 'Tarde', 'Noite', 'EAD'];

  @override
  void initState() {
    super.initState();
    _selectedCourse =
        widget.initialCourseName ?? widget.courses.first['name'] as String;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final course =
        widget.courses.firstWhere((c) => c['name'] == _selectedCourse);

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final studentName = await CoursesService.instance.enrollUser(
        course['id'] as String,
        email: _emailController.text,
        turma: _selectedTurma,
      );
      if (!mounted) return;
      Navigator.pop(
        context,
        '$studentName inscrito(a) em $_selectedCourse (turma $_selectedTurma).',
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            color: EducanoColors.primaryBlue,
          ),
          SizedBox(width: _spacingMinimum),
          Expanded(child: Text('Inscrever Usuário em Curso')),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedCourse,
                decoration: const InputDecoration(labelText: 'Curso'),
                items: widget.courses
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['name'] as String,
                        child: Text(
                          c['name'] as String,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCourse = value!),
              ),
              if (_error != null) ...[
                const SizedBox(height: _spacingSmall),
                Text(_error!, style: const TextStyle(color: EducanoColors.error)),
              ],
              const SizedBox(height: _spacingSmall),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail do aluno',
                  helperText: 'O aluno precisa ter uma conta ativa.',
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Informe o e-mail do aluno';
                  if (!_emailRegex.hasMatch(trimmed)) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: _spacingSmall),
              DropdownButtonFormField<String>(
                initialValue: _selectedTurma,
                decoration: const InputDecoration(labelText: 'Turma'),
                items: _turmas
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedTurma = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _submit,
          icon: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check_rounded),
          label: const Text('Inscrever aluno'),
        ),
      ],
    );
  }
}

/// Abre o editor de curso (novo ou existente, pelo [courseId]) e retorna
/// true quando o curso foi salvo na API.
Future<bool> openDashboardCourseEditor(BuildContext context, {String? courseId}) async {
  Map<String, dynamic>? course;

  if (courseId != null) {
    try {
      course = CoursesService.editorMap(await CoursesService.instance.detail(courseId));
    } on ApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: EducanoColors.error),
        );
      }
      return false;
    }
  }

  if (!context.mounted) return false;
  final saved = await Navigator.push<Map<String, dynamic>>(
    context,
    MaterialPageRoute(builder: (_) => CourseEditorView(course: course)),
  );
  if (saved != null) DashboardEvents.notifyChanged();
  return saved != null;
}
