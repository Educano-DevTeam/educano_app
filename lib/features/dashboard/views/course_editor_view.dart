import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/api_mappers.dart';
import '../../course/models/course_models.dart' as course_models;
import '../../course/widgets/course_editor_dialogs.dart';
import 'material_editor_view.dart' as editor;
import '../../../services/api_client.dart';
import '../../../services/courses_service.dart';
import '../../../services/storage_service.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;

const double _radius = 18;

/// Página completa de criação/edição de um curso.
/// Aberta a partir da Listagem de Cursos (admin/parceiro/professor).
///
/// Além dos dados do curso, organiza o conteúdo na mesma estrutura que o
/// aluno vê em Meu Progresso: trilhas -> módulos -> materiais.
class CourseEditorView extends StatefulWidget {
  final Map<String, dynamic>? course;

  const CourseEditorView({super.key, this.course});

  @override
  State<CourseEditorView> createState() => _CourseEditorViewState();
}

class _CourseEditorViewState extends State<CourseEditorView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _capacityController;
  late final TextEditingController _workloadController;
  late final TextEditingController _priceController;
  late String _category;
  late String _status;
  late IconData _icon;
  late Color _color;
  late final List<Map<String, dynamic>> _trilhas;
  late List<Map<String, dynamic>> _persistedTrilhas;

  /// Trilha criada por último, que já aparece aberta na lista.
  String? _newTrilhaId;

  final List<String> _categories = ApiMappers.courseCategories.values.toList();
  bool _saving = false;
  String? _savedCourseId;
  List<Map<String, dynamic>> _selectedTeachers = [];
  String? _courseOwnerId;
  String? _currentUserId;

  /// Somente administradores ativam ou desativam cursos.
  bool _isAdmin = false;

  /// Capa em imagem é mantida enquanto nenhum ícone for escolhido.
  bool _iconChanged = false;
  Uint8List? _coverBytes;
  String? _coverFileName;
  final List<String> _statuses = ['Ativo', 'Inativo', 'Rascunho'];

  // Mesmos ícones e cores dos cards de curso do aluno.
  final List<Map<String, dynamic>> _iconOptions = [
    {'label': 'Livro', 'icon': Icons.menu_book_rounded},
    {'label': 'Matemática', 'icon': Icons.calculate_rounded},
    {'label': 'Biologia', 'icon': Icons.biotech_rounded},
    {'label': 'Ciências', 'icon': Icons.science_rounded},
    {'label': 'História', 'icon': Icons.museum_rounded},
    {'label': 'Geografia', 'icon': Icons.public_rounded},
    {'label': 'Idiomas', 'icon': Icons.translate_rounded},
    {'label': 'Artes', 'icon': Icons.palette_rounded},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'label': 'Azul', 'color': EducanoColors.primaryBlue},
    {'label': 'Verde', 'color': EducanoColors.successGreen},
    {'label': 'Amarelo', 'color': EducanoColors.accentYellow},
    {'label': 'Azul Claro', 'color': EducanoColors.lightBlue},
    {'label': 'Verde Escuro', 'color': EducanoColors.darkGreen},
    {'label': 'Vermelho', 'color': EducanoColors.error},
  ];

  bool get _isEditing => widget.course != null;
  String? get _courseId => widget.course?['id'] as String? ?? _savedCourseId;

  String get _imageUrl => widget.course?['imageUrl'] as String? ?? '';

  bool get _showsImage =>
      _coverBytes != null || (_imageUrl.isNotEmpty && !_iconChanged);

  int get _enrolled => widget.course?['enrolled'] as int? ?? 0;

  String get _courseName {
    final name = _nameController.text.trim();
    return name.isEmpty ? 'Novo curso' : name;
  }

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    _nameController = TextEditingController(
      text: course?['name'] as String? ?? '',
    );
    _descriptionController = TextEditingController(
      text: course?['description'] as String? ?? '',
    );
    _capacityController = TextEditingController(
      text: course?['capacity']?.toString() ?? '',
    );
    _workloadController = TextEditingController(
      text: course?['workload']?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: course?['price']?.toString() ?? '0',
    );
    _category = course?['category'] as String? ?? _categories.first;
    // Categorias cadastradas antes ficam disponíveis no seletor.
    if (!_categories.contains(_category)) _categories.add(_category);
    _status = course?['status'] as String? ?? 'Rascunho';
    _icon = course?['icon'] as IconData? ?? Icons.menu_book_rounded;
    _color = course?['color'] as Color? ?? EducanoColors.primaryBlue;
    _trilhas = _copyTrilhas(course?['trilhas']);
    _persistedTrilhas = _copyTrilhas(course?['trilhas']);
    _courseOwnerId = course?['ownerId'] as String?;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.instance.loadCurrentUser();
    if (mounted) {
      setState(() {
        _isAdmin = user?.isAdmin ?? false;
        _currentUserId = user?.id;
      });
    }
    if (user != null && user.id == _courseOwnerId && _courseId != null) {
      await _loadTeachers(_courseId!);
    }
  }

  bool get _isCourseOwner =>
      _courseOwnerId != null && _courseOwnerId == _currentUserId;

  Future<void> _pickCover() async {
    final picked = await FilePicker.pickFiles(type: FileType.image);
    if (picked.isEmpty) return;
    final file = picked.first;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _coverBytes = bytes;
      _coverFileName = file.name;
      _iconChanged = true;
    });
  }

  Future<void> _loadTeachers(String courseId) async {
    try {
      final linked = await CoursesService.instance.linkedTeachers(courseId);
      if (mounted) setState(() => _selectedTeachers = linked);
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _chooseTeachers() async {
    final courseId = _courseId;
    if (courseId == null) return;
    try {
      final available = await CoursesService.instance.availableTeachers(
        courseId,
      );
      if (!mounted) return;
      final selected = List<Map<String, dynamic>>.from(_selectedTeachers);
      final search = TextEditingController();
      final saved = await showDialog<List<Map<String, dynamic>>>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, refresh) {
            final query = search.text.trim().toLowerCase();
            final matches = available.where((person) {
              final name = (person['nome'] as String? ?? '').toLowerCase();
              final email = (person['email'] as String? ?? '').toLowerCase();
              final isSelected = selected.any(
                (item) => item['id'] == person['id'],
              );
              return !isSelected &&
                  (query.isEmpty ||
                      name.contains(query) ||
                      email.contains(query));
            }).toList();
            return AlertDialog(
              title: const Text('Professores do curso'),
              content: SizedBox(
                width: 480,
                height: 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: search,
                      onChanged: (_) => refresh(() {}),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Pesquisar professor',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${matches.length} professores encontrados'),
                    if (selected.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${selected.length} selecionados',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 128),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: selected.length,
                          itemExtent: 64,
                          itemBuilder: (_, index) {
                            final person = selected[index];
                            return ListTile(
                              dense: true,
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline_rounded),
                              ),
                              title: Text(person['nome'] as String? ?? ''),
                              subtitle: Text(person['email'] as String? ?? ''),
                              trailing: IconButton(
                                tooltip: 'Remover professor',
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () =>
                                    refresh(() => selected.removeAt(index)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const Divider(),
                    if (matches.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('Nenhum professor encontrado.'),
                        ),
                      )
                    else
                      SizedBox(
                        height: 192,
                        child: ListView.builder(
                          itemCount: matches.length,
                          itemExtent: 64,
                          itemBuilder: (_, index) {
                            final person = matches[index];
                            return ListTile(
                              dense: true,
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline_rounded),
                              ),
                              title: Text(person['nome'] as String? ?? ''),
                              subtitle: Text(person['email'] as String? ?? ''),
                              trailing: const Icon(Icons.add_circle_outline),
                              onTap: () => refresh(() => selected.add(person)),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, selected),
                  child: const Text('Salvar seleção'),
                ),
              ],
            );
          },
        ),
      );
      search.dispose();
      if (saved == null) return;
      final oldIds = _selectedTeachers
          .map((person) => person['id'] as String)
          .toSet();
      final newIds = saved.map((person) => person['id'] as String).toSet();
      for (final id in newIds.difference(oldIds)) {
        await CoursesService.instance.linkTeacher(courseId, id);
      }
      for (final id in oldIds.difference(newIds)) {
        await CoursesService.instance.unlinkTeacher(courseId, id);
      }
      if (mounted) setState(() => _selectedTeachers = saved);
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: EducanoColors.error,
          ),
        );
    }
  }

  Widget _buildTeachersCard(bool isCompact) {
    if (_courseId == null || !_isCourseOwner) return const SizedBox.shrink();
    return _buildSectionCard(
      title: 'Professores vinculados',
      isCompact: isCompact,
      children: [
        if (_selectedTeachers.isEmpty)
          const Text(
            'Nenhum professor selecionado.',
            style: TextStyle(color: EducanoColors.textSecondary),
          ),
        ..._selectedTeachers.map(
          (person) => ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(person['nome'] as String? ?? ''),
            subtitle: Text(person['email'] as String? ?? ''),
            trailing: IconButton(
              tooltip: 'Desvincular',
              onPressed: () async {
                try {
                  await CoursesService.instance.unlinkTeacher(
                    _courseId!,
                    person['id'] as String,
                  );
                  if (mounted)
                    setState(
                      () => _selectedTeachers.removeWhere(
                        (item) => item['id'] == person['id'],
                      ),
                    );
                } on ApiException catch (error) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.message)));
                }
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _chooseTeachers,
          icon: const Icon(Icons.group_add_outlined),
          label: const Text('Selecionar professores'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _workloadController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final course = <String, dynamic>{
      'id': _courseId,
      'name': _nameController.text.trim(),
      'category': _category,
      'status': _status,
      'originalStatus': widget.course?['status'],
      'description': _descriptionController.text.trim(),
      'enrolled': _enrolled,
      'capacity': int.tryParse(_capacityController.text.trim()),
      'workload': int.tryParse(_workloadController.text.trim()),
      'price':
          double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ??
          0,
      'coverBytes': _coverBytes,
      'coverFileName': _coverFileName,
      'idCapa': widget.course?['idCapa'],
      'iconChanged': _iconChanged,
      'createdAt': widget.course?['createdAt'] ?? _formatDate(DateTime.now()),
      'icon': _icon,
      'color': _color,
      'trilhas': _trilhas,
      'originalTrilhas': _persistedTrilhas,
      'ownerId': _courseOwnerId,
    };

    final creating = _courseId == null;
    setState(() => _saving = true);
    try {
      final saved = await CoursesService.instance.saveFromEditor(course);
      if (!mounted) return;
      _persistedTrilhas = _copyTrilhas(_trilhas);
      if (creating) {
        _savedCourseId = saved['id'] as String;
        _courseOwnerId = _currentUserId;
        await _loadTeachers(_savedCourseId!);
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Curso criado. Agora você pode vincular os professores e salvar novamente.',
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Curso atualizado!' : 'Curso criado!'),
          backgroundColor: EducanoColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, saved);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: EducanoColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Trilhas, módulos e materiais
  // ---------------------------------------------------------------------------

  Future<void> _addTrilha() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _TrilhaDialog(),
    );
    if (result == null) return;

    final id = 'trilha-${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _trilhas.add({
        'id': id,
        'title': result['title'],
        'description': result['description'],
        'modulos': <Map<String, dynamic>>[],
      });
      _newTrilhaId = id;
    });
  }

  Future<void> _editTrilha(Map<String, dynamic> trilha) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _TrilhaDialog(trilha: trilha),
    );
    if (result == null) return;

    setState(() {
      trilha['title'] = result['title'];
      trilha['description'] = result['description'];
    });
  }

  Future<void> _removeTrilha(Map<String, dynamic> trilha) async {
    final modulos = (trilha['modulos'] as List<dynamic>).length;
    final confirmed = await _confirmRemoval(
      title: 'Remover Trilha',
      message:
          'Tem certeza que deseja remover "${trilha['title']}"? '
          '${_plural(modulos, 'módulo', 'módulos')} e seus materiais também '
          'serão removidos.',
    );
    if (!confirmed) return;

    setState(() => _trilhas.remove(trilha));
  }

  Future<void> _addModulo(Map<String, dynamic> trilha) async {
    final modulos = trilha['modulos'] as List<dynamic>;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _ModuloDialog(number: modulos.length + 1),
    );
    if (result == null) return;

    setState(() {
      modulos.add(<String, dynamic>{
        'id': 'mod-${DateTime.now().microsecondsSinceEpoch}',
        'title': result['title'],
        'description': result['description'],
        'materiais': <Map<String, dynamic>>[],
      });
    });
  }

  Future<void> _editModulo(
    Map<String, dynamic> trilha,
    Map<String, dynamic> modulo,
  ) async {
    final modulos = trilha['modulos'] as List<dynamic>;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) =>
          _ModuloDialog(number: modulos.indexOf(modulo) + 1, modulo: modulo),
    );
    if (result == null) return;

    setState(() {
      modulo['title'] = result['title'];
      modulo['description'] = result['description'];
    });
  }

  Future<void> _removeModulo(
    Map<String, dynamic> trilha,
    Map<String, dynamic> modulo,
  ) async {
    final confirmed = await _confirmRemoval(
      title: 'Remover Módulo',
      message:
          'Tem certeza que deseja remover "${modulo['title']}"? '
          'Os materiais dele também serão removidos.',
    );
    if (!confirmed) return;

    setState(() => (trilha['modulos'] as List<dynamic>).remove(modulo));
  }

  Future<void> _openMaterialEditor(
    Map<String, dynamic> modulo, {
    Map<String, dynamic>? material,
  }) async {
    course_models.CourseMaterial? initial;
    if (material != null && material['tipo'] == 'ATIVIDADE') {
      final currentActivity = material['activity'] as course_models.Activity?;
      final id = material['id'] as String;
      final base = course_models.CourseMaterial(
        id: id,
        kind: course_models.MaterialKind.activity,
        title: material['name'] as String? ?? 'Atividade',
        description: material['description'] as String? ?? '',
        activity: currentActivity,
      );
      try {
        initial = currentActivity != null
            ? base
            : await CoursesService.instance.activityForEdit(base);
      } on ApiException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.message)));
        }
        return;
      }
    } else if (material != null) {
      final kind = material['type'] as editor.MaterialKind?;
      initial = course_models.CourseMaterial(
        id: material['id'] as String,
        kind: switch (kind) {
          editor.MaterialKind.video => course_models.MaterialKind.video,
          editor.MaterialKind.audio => course_models.MaterialKind.audio,
          _ => course_models.MaterialKind.pdf,
        },
        title: material['name'] as String? ?? '',
        description: material['description'] as String? ?? '',
        fileName: material['fileName'] as String?,
        fileUrl: material['fileUrl'] as String?,
        pageCount: material['quantidadePaginas'] as int?,
        durationSeconds: ApiMappers.parseDuration(
          material['duration'] as String?,
        ),
      );
    }
    if (!mounted) return;
    final result = await showMaterialEditor(context, material: initial);
    if (result == null || !mounted) return;

    final mapped = <String, dynamic>{
      'id': result.id,
      'name': result.title,
      'description': result.description,
      'fileName': result.fileName,
      'fileUrl': result.fileUrl,
      'fileBytes': result.fileBytes,
      'fileSize': ApiMappers.fileSize(result.fileSizeBytes),
      'duration': ApiMappers.duration(result.durationSeconds),
      'quantidadePaginas': result.pageCount,
      if (result.kind == course_models.MaterialKind.activity) ...{
        'tipo': 'ATIVIDADE',
        'activity': result.activity,
        'idsQuestoes': result.activity?.questionIds ?? const <String>[],
        'totalQuestoes': result.activity?.questionIds.length ?? 0,
      } else ...{
        'type': switch (result.kind) {
          course_models.MaterialKind.video => editor.MaterialKind.video,
          course_models.MaterialKind.audio => editor.MaterialKind.audio,
          _ => editor.MaterialKind.pdf,
        },
      },
    };
    setState(() {
      final materiais = modulo['materiais'] as List<dynamic>;
      if (material == null) {
        materiais.add(mapped);
      } else {
        materiais[materiais.indexOf(material)] = mapped;
      }
    });
  }

  Future<void> _removeMaterial(
    Map<String, dynamic> modulo,
    Map<String, dynamic> material,
  ) async {
    final confirmed = await _confirmRemoval(
      title: 'Remover Material',
      message:
          'Tem certeza que deseja remover "${material['name']}" do módulo?',
    );
    if (!confirmed) return;

    setState(() => (modulo['materiais'] as List<dynamic>).remove(material));
  }

  Future<bool> _confirmRemoval({
    required String title,
    required String message,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: EducanoColors.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EducanoColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Curso' : 'Novo Curso'),
        backgroundColor: EducanoColors.background,
        elevation: 0,
        foregroundColor: EducanoColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < AppBreakpoints.compact;
            final isWide = constraints.maxWidth >= AppBreakpoints.medium;

            final infoCard = _buildInfoCard(isCompact);
            final appearanceCard = _buildAppearanceCard(isCompact);
            final teachersCard = _buildTeachersCard(isCompact);
            final contentCard = _buildContentCard(isCompact);
            final saveButton = SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text('Salvar curso'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: _spacingSmall),
                ),
              ),
            );

            // Desktop: dados do curso à esquerda e conteúdo à direita.
            final Widget content = isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            infoCard,
                            const SizedBox(height: _spacingMedium),
                            appearanceCard,
                            const SizedBox(height: _spacingMedium),
                            teachersCard,
                            const SizedBox(height: _spacingMedium),
                            saveButton,
                          ],
                        ),
                      ),
                      const SizedBox(width: _spacingMedium),
                      Expanded(flex: 3, child: contentCard),
                    ],
                  )
                : Column(
                    children: [
                      infoCard,
                      const SizedBox(height: _spacingMedium),
                      appearanceCard,
                      const SizedBox(height: _spacingMedium),
                      teachersCard,
                      const SizedBox(height: _spacingMedium),
                      contentCard,
                      const SizedBox(height: _spacingMedium),
                      saveButton,
                    ],
                  );

            return ListView(
              padding: EdgeInsets.all(
                isCompact ? _spacingSmall : _spacingMedium,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.contentMaxWidth,
                    ),
                    child: content,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isCompact) {
    return _buildSectionCard(
      title: 'Informações do Curso',
      isCompact: isCompact,
      children: [
        TextFormField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Nome do curso'),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Informe o nome do curso'
              : null,
        ),
        const SizedBox(height: _spacingSmall),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Categoria'),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) => setState(() => _category = value!),
        ),
        const SizedBox(height: _spacingSmall),
        DropdownButtonFormField<String>(
          initialValue: _status,
          decoration: InputDecoration(
            labelText: 'Status',
            helperText: _isAdmin
                ? null
                : 'O curso fica como rascunho até ter nome, categoria, '
                      'descrição e capa. Um administrador faz a ativação.',
            helperMaxLines: 2,
          ),
          items: _statuses
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: _isAdmin
              ? (value) => setState(() => _status = value!)
              : null,
        ),
        const SizedBox(height: _spacingSmall),
        TextFormField(
          controller: _capacityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Capacidade (vagas)',
            prefixIcon: const Icon(Icons.people_alt_rounded),
            helperText: _isEditing
                ? '$_enrolled alunos já inscritos · vazio = sem limite'
                : 'Deixe vazio para não limitar as vagas',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final capacity = int.tryParse(value.trim());
            if (capacity == null || capacity <= 0) {
              return 'Informe um número de vagas válido';
            }
            if (capacity < _enrolled) {
              return 'O curso já tem $_enrolled alunos inscritos';
            }
            return null;
          },
        ),
        const SizedBox(height: _spacingSmall),
        TextFormField(
          controller: _workloadController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Carga horária (horas)',
            suffixText: 'h',
          ),
          validator: (value) => int.tryParse((value ?? '').trim()) == null
              ? 'Informe a carga horária em horas.'
              : null,
        ),
        const SizedBox(height: _spacingSmall),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Preço',
            prefixText: 'R\$ ',
          ),
          validator: (value) {
            final price = double.tryParse((value ?? '').replaceAll(',', '.'));
            return price == null || price < 0
                ? 'Informe um preço válido.'
                : null;
          },
        ),
        const SizedBox(height: _spacingSmall),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  /// Ícone e cor do card que o aluno vê em Meu Progresso, com a prévia.
  Widget _buildAppearanceCard(bool isCompact) {
    return _buildSectionCard(
      title: 'Aparência do Card',
      isCompact: isCompact,
      children: [
        _buildCardPreview(),
        const SizedBox(height: _spacingSmall),
        OutlinedButton.icon(
          onPressed: _pickCover,
          icon: const Icon(Icons.image_outlined),
          label: Text(_coverFileName ?? 'Enviar arquivo da capa'),
        ),
        const SizedBox(height: _spacingSmall),
        const Text('Ícone', style: _fieldLabelStyle),
        const SizedBox(height: _spacingMinimum),
        // Material transparente para o efeito de toque aparecer sobre o card.
        Material(
          type: MaterialType.transparency,
          child: Wrap(
            spacing: _spacingMinimum,
            runSpacing: _spacingMinimum,
            children: _iconOptions.map(_buildIconOption).toList(),
          ),
        ),
        const SizedBox(height: _spacingSmall),
        const Text('Cor', style: _fieldLabelStyle),
        const SizedBox(height: _spacingMinimum),
        Material(
          type: MaterialType.transparency,
          child: Wrap(
            spacing: _spacingMinimum,
            runSpacing: _spacingMinimum,
            children: _colorOptions.map(_buildColorOption).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCardPreview() {
    return Container(
      padding: const EdgeInsets.all(_spacingSmall),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _color.withValues(alpha: 0.15),
            foregroundImage: _coverBytes != null
                ? MemoryImage(_coverBytes!)
                : (_showsImage ? NetworkImage(_imageUrl) : null),
            child: Icon(_icon, color: _color, size: 24),
          ),
          const SizedBox(width: _spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: EducanoColors.textPrimary,
                  ),
                ),
                Text(
                  '${_trilhas.length} trilhas de aprendizado',
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
          const Icon(
            Icons.chevron_right_rounded,
            color: EducanoColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildIconOption(Map<String, dynamic> option) {
    final icon = option['icon'] as IconData;
    final selected = !_showsImage && icon == _icon;

    return Tooltip(
      message: option['label'] as String,
      child: Semantics(
        selected: selected,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => setState(() {
            _coverBytes = null;
            _coverFileName = null;
            _icon = icon;
            _iconChanged = true;
          }),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? _color.withValues(alpha: 0.15)
                  : EducanoColors.searchBackground,
              border: Border.all(
                color: selected ? _color : EducanoColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: selected ? _color : EducanoColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Map<String, dynamic> option) {
    final color = option['color'] as Color;
    final selected = color == _color;

    return Tooltip(
      message: option['label'] as String,
      child: Semantics(
        selected: selected,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => setState(() => _color = color),
          child: Ink(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: selected
                    ? EducanoColors.textPrimary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: selected
                ? const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: EducanoColors.textWhite,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(bool isCompact) {
    return _buildSectionCard(
      title: 'Trilhas e Materiais',
      isCompact: isCompact,
      children: [
        const Text(
          'Organize as trilhas de aprendizado, módulos, lições e '
          'materiais didáticos deste curso.',
          style: TextStyle(color: EducanoColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: _spacingSmall),
        if (_trilhas.isEmpty)
          _buildEmptyContent()
        else
          ..._trilhas.map(_buildTrilhaTile),
        const SizedBox(height: _spacingMinimum),
        OutlinedButton.icon(
          onPressed: _addTrilha,
          icon: const Icon(Icons.create_new_folder_rounded),
          label: const Text('Nova trilha'),
        ),
      ],
    );
  }

  Widget _buildEmptyContent() {
    return Container(
      padding: const EdgeInsets.all(_spacingMedium),
      decoration: BoxDecoration(
        color: EducanoColors.searchBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.account_tree_rounded,
            size: 40,
            color: EducanoColors.textSecondary,
          ),
          SizedBox(height: _spacingMinimum),
          Text(
            'Nenhuma trilha cadastrada ainda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: EducanoColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Crie a primeira trilha para adicionar módulos e materiais.',
            textAlign: TextAlign.center,
            style: TextStyle(color: EducanoColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Trilha como "pasta" expansível, igual à estrutura de Meu Progresso.
  Widget _buildTrilhaTile(Map<String, dynamic> trilha) {
    final modulos = trilha['modulos'] as List<dynamic>;
    final materiais = modulos.fold<int>(
      0,
      (sum, m) =>
          sum + ((m as Map<String, dynamic>)['materiais'] as List).length,
    );
    final description = trilha['description'] as String? ?? '';
    final summary = [
      if (description.isNotEmpty) description,
      _plural(modulos.length, 'módulo', 'módulos'),
      _plural(materiais, 'material', 'materiais'),
    ].join('  ·  ');

    return Container(
      key: ValueKey(trilha['id']),
      margin: const EdgeInsets.only(bottom: _spacingSmall),
      decoration: BoxDecoration(
        color: EducanoColors.searchBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EducanoColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        // O ExpansionTile usa ListTile, que precisa de um Material mais
        // próximo que o Container decorado deste card.
        child: Material(
          type: MaterialType.transparency,
          child: ExpansionTile(
            shape: const Border(),
            initiallyExpanded: trilha['id'] == _newTrilhaId,
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: _color.withValues(alpha: 0.15),
              child: Icon(Icons.folder_rounded, color: _color, size: 18),
            ),
            title: Text(
              trilha['title'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: EducanoColors.textPrimary,
              ),
            ),
            subtitle: Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: EducanoColors.textSecondary,
                fontSize: 12,
              ),
            ),
            children: [
              if (modulos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: _spacingMinimum),
                  child: Text(
                    'Nenhum módulo nesta trilha ainda.',
                    style: TextStyle(
                      color: EducanoColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                ...modulos.map(
                  (m) => _buildModuloCard(trilha, m as Map<String, dynamic>),
                ),
              Wrap(
                spacing: _spacingMinimum,
                children: [
                  TextButton.icon(
                    onPressed: () => _addModulo(trilha),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Novo módulo'),
                  ),
                  TextButton.icon(
                    onPressed: () => _editTrilha(trilha),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Editar trilha'),
                  ),
                  TextButton.icon(
                    onPressed: () => _removeTrilha(trilha),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remover trilha'),
                    style: TextButton.styleFrom(
                      foregroundColor: EducanoColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuloCard(
    Map<String, dynamic> trilha,
    Map<String, dynamic> modulo,
  ) {
    final materiais = modulo['materiais'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: _spacingMinimum),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EducanoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EducanoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_open_rounded, color: _color, size: 20),
              const SizedBox(width: _spacingMinimum),
              Expanded(
                child: Text(
                  modulo['title'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: EducanoColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Editar módulo',
                visualDensity: VisualDensity.compact,
                onPressed: () => _editModulo(trilha, modulo),
                icon: const Icon(Icons.edit_rounded, size: 18),
              ),
              IconButton(
                tooltip: 'Remover módulo',
                visualDensity: VisualDensity.compact,
                onPressed: () => _removeModulo(trilha, modulo),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: EducanoColors.error,
              ),
            ],
          ),
          if ((modulo['description'] as String? ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: _spacingSmall),
              child: Text(
                modulo['description'] as String,
                style: const TextStyle(
                  color: EducanoColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          const Text(
            'Materiais didáticos',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: EducanoColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (materiais.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Nenhum material adicionado.',
                style: TextStyle(
                  color: EducanoColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...materiais.map(
              (m) => _buildMaterialRow(modulo, m as Map<String, dynamic>),
            ),
          TextButton.icon(
            onPressed: () => _openMaterialEditor(modulo),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Adicionar material'),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(
    Map<String, dynamic> modulo,
    Map<String, dynamic> material,
  ) {
    // Atividades e aulas podem ser editadas pelo mesmo modal.
    final isActivity = material['tipo'] == 'ATIVIDADE';
    final kind =
        material['type'] as editor.MaterialKind? ?? editor.MaterialKind.pdf;
    final details =
        (isActivity
                ? ['Atividade', '${material['totalQuestoes'] ?? 0} questões']
                : [
                    kind.label,
                    material['fileName'],
                    material['fileSize'],
                    material['duration'],
                  ])
            .whereType<String>()
            .where((text) => text.isNotEmpty)
            .join('  ·  ');
    final color = isActivity ? EducanoColors.successGreen : kind.color;
    final icon = isActivity ? Icons.assignment_rounded : kind.icon;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: _spacingMinimum),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['name'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: EducanoColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: EducanoColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: isActivity ? 'Editar atividade' : 'Editar material',
            visualDensity: VisualDensity.compact,
            onPressed: () => _openMaterialEditor(modulo, material: material),
            icon: const Icon(Icons.edit_rounded, size: 18),
          ),
          IconButton(
            tooltip: 'Remover material',
            visualDensity: VisualDensity.compact,
            onPressed: () => _removeMaterial(modulo, material),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: EducanoColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? _spacingSmall : _spacingMedium),
      decoration: BoxDecoration(
        color: EducanoColors.surface,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

const TextStyle _fieldLabelStyle = TextStyle(
  fontWeight: FontWeight.w600,
  color: EducanoColors.textSecondary,
  fontSize: 13,
);

String _plural(int count, String singular, String plural) =>
    '$count ${count == 1 ? singular : plural}';

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

/// Cópia profunda das trilhas, para que voltar sem salvar não altere o curso
/// que está na listagem.
List<Map<String, dynamic>> _copyTrilhas(Object? trilhas) {
  return [
    for (final trilha in trilhas as List<dynamic>? ?? const [])
      <String, dynamic>{
        ...trilha as Map<String, dynamic>,
        'modulos': <Map<String, dynamic>>[
          for (final modulo in trilha['modulos'] as List<dynamic>)
            <String, dynamic>{
              ...modulo as Map<String, dynamic>,
              'materiais': <Map<String, dynamic>>[
                for (final material in modulo['materiais'] as List<dynamic>)
                  <String, dynamic>{...material as Map<String, dynamic>},
              ],
            },
        ],
      },
  ];
}

/// Formulário de criação/edição de uma trilha de aprendizado.
class _TrilhaDialog extends StatefulWidget {
  final Map<String, dynamic>? trilha;

  const _TrilhaDialog({this.trilha});

  @override
  State<_TrilhaDialog> createState() => _TrilhaDialogState();
}

class _TrilhaDialogState extends State<_TrilhaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.trilha?['title'] as String? ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.trilha?['description'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      title: Row(
        children: [
          const Icon(Icons.folder_rounded, color: EducanoColors.primaryBlue),
          const SizedBox(width: _spacingMinimum),
          Expanded(
            child: Text(
              widget.trilha == null ? 'Nova Trilha' : 'Editar Trilha',
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Título da trilha',
                  hintText: 'Ex.: Fundamentos',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Informe o título da trilha'
                    : null,
              ),
              const SizedBox(height: _spacingSmall),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Ex.: Introdução aos conceitos básicos',
                ),
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
          onPressed: _submit,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}

/// Formulário de criação/edição de um módulo e da lição dele.
class _ModuloDialog extends StatefulWidget {
  final int number;
  final Map<String, dynamic>? modulo;

  const _ModuloDialog({required this.number, this.modulo});

  @override
  State<_ModuloDialog> createState() => _ModuloDialogState();
}

class _ModuloDialogState extends State<_ModuloDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.modulo?['title'] as String? ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.modulo?['description'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.folder_open_rounded,
            color: EducanoColors.primaryBlue,
          ),
          const SizedBox(width: _spacingMinimum),
          Expanded(
            child: Text(
              widget.modulo == null ? 'Novo Módulo' : 'Editar Módulo',
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Título do módulo',
                    hintText: 'Ex.: Módulo ${widget.number}: Frações',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Informe o título do módulo'
                      : null,
                ),
                const SizedBox(height: _spacingSmall),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Resumo do conteúdo do módulo.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}
