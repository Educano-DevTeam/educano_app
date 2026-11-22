import 'package:educano_app/core/widgets/ui/app_small_button.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/models/app_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../services/api_client.dart';
import '../../../services/courses_service.dart';
import '../../../services/storage_service.dart';
import '../../dashboard/views/dashboard_courses_view.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

// IBL06 – Listagem e Relatório de Cursos Cadastrados
// IBL07 – Inscrição de usuário em Curso (ação inline via dialog)
class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todas';

  List<Map<String, dynamic>> _courses = [];
  bool _loading = true;
  String? _error;
  AppUser? _user;

  bool get _isStaff => _user?.isStaff ?? false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _user ??= await StorageService.instance.loadCurrentUser();
      final results = await Future.wait([
        CoursesService.instance.list(),
        CoursesService.instance.myCourses(),
      ]);
      final result = results[0] as CourseListResult;
      final enrolledIds = (results[1] as List<Map<String, dynamic>>)
          .where((course) => course['inscritoEm'] != null)
          .map((course) => course['id'] as String)
          .toSet();
      if (!mounted) return;
      setState(() {
        _courses = result.courses
            .map(
              (course) => {
                ...course,
                'isEnrolled': enrolledIds.contains(course['id']),
              },
            )
            .toList();
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

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error
            ? EducanoColors.error
            : EducanoColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openCourse(Map<String, dynamic> course) {
    Navigator.pushNamed(context, AppRoutes.course, arguments: course['id']);
  }

  /// Inscrição do próprio aluno, com escolha da turma.
  Future<void> _selfEnroll(Map<String, dynamic> course) async {
    try {
      final message = await CoursesService.instance.enroll(
        course['id'] as String,
      );
      if (!mounted) return;
      _snack(message);
      await _loadCourses();
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    }
  }

  List<String> get _categoryOptions => [
    'Todas',
    ..._courses.map((c) => c['category'] as String).toSet(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCourses {
    return _courses.where((course) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (course['name'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (course['category'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesCategory =
          _selectedCategory == 'Todas' ||
          course['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showCourseSummaryDialog(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
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
          if (course['isEnrolled'] == true)
            AppSmallButton(
              onPressed: () {
                Navigator.pop(context);
                _openCourse(course);
              },
              icon: Icons.visibility_outlined,
              label: 'Abrir curso',
            )
          else
            AppSmallButton(
              onPressed: () {
                Navigator.pop(context);
                _selfEnroll(course);
              },
              icon: Icons.how_to_reg_rounded,
              label: 'Me inscrever',
            ),
          if (course['canEdit'] == true)
            AppSmallButton(
              onPressed: () async {
                Navigator.pop(context);
                final saved = await openDashboardCourseEditor(
                  this.context,
                  courseId: course['id'] as String,
                );
                if (saved) await _loadCourses();
              },
              icon: Icons.edit_rounded,
              label: '',
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

  Future<void> _openCourseEditor(BuildContext context) async {
    final saved = await openDashboardCourseEditor(context);
    if (saved) await _loadCourses();
  }

  Future<void> _showEnrollDialog(
    BuildContext context, {
    String? courseName,
  }) async {
    final active = _courses.where((c) => c['status'] == 'Ativo').toList();
    if (active.isEmpty) return;
    final message = await showDialog<String>(
      context: context,
      builder: (_) => EnrollUserDialog(
        courses: active,
        initialCourseName: active.any((c) => c['name'] == courseName)
            ? courseName
            : null,
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
          _isStaff ? 'Cursos Cadastrados' : 'Catálogo de Cursos',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: _spacingMinimum),
        Text(
          _isStaff
              ? 'Encontre seus cursos para editar informações e materiais.'
              : 'Inscreva-se nos cursos disponíveis e continue seus estudos.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: EducanoColors.textSecondary),
        ),
      ],
    );
  }

  /// Barra de ações acima da busca (frame do Figma: botão primário à
  /// esquerda, ações secundárias na sequência).
  Widget _buildActions(BuildContext context) {
    // Cadastro de cursos e inscrição de outros usuários são da equipe.
    if (!_isStaff) return const SizedBox.shrink();
    return Wrap(
      spacing: _spacingMinimum,
      runSpacing: _spacingMinimum,
      children: [
        AppSmallButton(
          onPressed: () => _openCourseEditor(context),
          icon: Icons.add_rounded,
          label: 'Novo Curso',
        ),
        OutlinedButton.icon(
          onPressed: () => _showEnrollDialog(context),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Inscrever Usuário'),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
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

        // Mobile: busca em cima e categoria abaixo.
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField,
              const SizedBox(height: _spacingSmall),
              categoryFilter(width: double.infinity),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
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
      return const Padding(
        padding: EdgeInsets.all(_spacingLarge),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: EducanoColors.error),
            ),
          ),
          TextButton(
            onPressed: _loadCourses,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    return Column(
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
    );
  }

  Widget _buildCourseItem(BuildContext context, Map<String, dynamic> course) {
    final statusColor = switch (course['status'] as String) {
      'Ativo' => EducanoColors.successGreen,
      'Inativo' => EducanoColors.error,
      _ => EducanoColors.accentYellow,
    };
    final capacity = course['capacity'] as int? ?? 0;
    final progress = capacity == 0
        ? 0.0
        : (course['enrolled'] as int) / capacity;

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
                final isNarrow = constraints.maxWidth < AppBreakpoints.compact;

                final enrolled = course['isEnrolled'] == true;
                final imageUrl = course['imageUrl'] as String? ?? '';
                final icon = course['icon'] as IconData;
                final color = course['color'] as Color;
                final enrollButton = AppSmallButton(
                  onPressed: () =>
                      enrolled ? _openCourse(course) : _selfEnroll(course),
                  label: enrolled ? 'Acessar' : 'Me inscrever',
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: imageUrl.isEmpty
                              ? Icon(icon, color: color)
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  webHtmlElementStrategy:
                                      WebHtmlElementStrategy.fallback,
                                  errorBuilder: (_, _, _) =>
                                      Icon(icon, color: color),
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
