import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/theme.dart';
import 'material_editor_view.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;

const double _radius = 18;

/// Página completa de criação/edição de um curso.
/// Aberta a partir da Listagem de Cursos (admin/parceiro/professor).
///
/// Além dos dados do curso, organiza o conteúdo na mesma estrutura que o
/// aluno vê em Meu Progresso: trilhas -> módulos (1 lição + materiais).
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
  late String _category;
  late String _status;
  late IconData _icon;
  late Color _color;
  late final List<Map<String, dynamic>> _trilhas;

  /// Trilha criada por último, que já aparece aberta na lista.
  String? _newTrilhaId;

  final List<String> _categories = ['Exatas', 'Humanas', 'Biológicas'];
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

  int get _enrolled => widget.course?['enrolled'] as int? ?? 0;

  String get _courseName {
    final name = _nameController.text.trim();
    return name.isEmpty ? 'Novo curso' : name;
  }

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    _nameController =
        TextEditingController(text: course?['name'] as String? ?? '');
    _descriptionController = TextEditingController(
      text: course?['description'] as String? ?? '',
    );
    _capacityController = TextEditingController(
      text: course?['capacity']?.toString() ?? '',
    );
    _category = course?['category'] as String? ?? _categories.first;
    _status = course?['status'] as String? ?? 'Rascunho';
    _icon = course?['icon'] as IconData? ?? Icons.menu_book_rounded;
    _color = course?['color'] as Color? ?? EducanoColors.primaryBlue;
    _trilhas = _copyTrilhas(course?['trilhas']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, <String, dynamic>{
      'name': _nameController.text.trim(),
      'category': _category,
      'status': _status,
      'description': _descriptionController.text.trim(),
      'enrolled': _enrolled,
      'capacity': int.parse(_capacityController.text.trim()),
      'createdAt': widget.course?['createdAt'] ?? _formatDate(DateTime.now()),
      'icon': _icon,
      'color': _color,
      'trilhas': _trilhas,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Curso atualizado!' : 'Curso criado!'),
        backgroundColor: EducanoColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      message: 'Tem certeza que deseja remover "${trilha['title']}"? '
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
        'licao': <String, dynamic>{
          'title': result['licaoTitle'],
          'xp': result['xp'],
        },
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
      builder: (_) => _ModuloDialog(
        number: modulos.indexOf(modulo) + 1,
        modulo: modulo,
      ),
    );
    if (result == null) return;

    setState(() {
      modulo['title'] = result['title'];
      modulo['licao'] = <String, dynamic>{
        ...modulo['licao'] as Map<String, dynamic>,
        'title': result['licaoTitle'],
        'xp': result['xp'],
      };
    });
  }

  Future<void> _removeModulo(
    Map<String, dynamic> trilha,
    Map<String, dynamic> modulo,
  ) async {
    final confirmed = await _confirmRemoval(
      title: 'Remover Módulo',
      message: 'Tem certeza que deseja remover "${modulo['title']}"? '
          'A lição e os materiais dele também serão removidos.',
    );
    if (!confirmed) return;

    setState(() => (trilha['modulos'] as List<dynamic>).remove(modulo));
  }

  Future<void> _openMaterialEditor(
    Map<String, dynamic> trilha,
    Map<String, dynamic> modulo, {
    Map<String, dynamic>? material,
  }) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => MaterialEditorView(
          courseName: _courseName,
          trilhaTitle: trilha['title'] as String,
          moduloTitle: modulo['title'] as String,
          material: material,
        ),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      final materiais = modulo['materiais'] as List<dynamic>;
      if (material == null) {
        materiais.add(result);
      } else {
        materiais[materiais.indexOf(material)] = result;
      }
    });
  }

  Future<void> _removeMaterial(
    Map<String, dynamic> modulo,
    Map<String, dynamic> material,
  ) async {
    final confirmed = await _confirmRemoval(
      title: 'Remover Material',
      message: 'Tem certeza que deseja remover "${material['name']}" do módulo?',
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
            style: ElevatedButton.styleFrom(backgroundColor: EducanoColors.error),
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
            final contentCard = _buildContentCard(isCompact);
            final saveButton = SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
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
                      contentCard,
                      const SizedBox(height: _spacingMedium),
                      saveButton,
                    ],
                  );

            return ListView(
              padding: EdgeInsets.all(isCompact ? _spacingSmall : _spacingMedium),
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
          decoration: const InputDecoration(labelText: 'Status'),
          items: _statuses
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (value) => setState(() => _status = value!),
        ),
        const SizedBox(height: _spacingSmall),
        TextFormField(
          controller: _capacityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Capacidade (vagas)',
            prefixIcon: const Icon(Icons.people_alt_rounded),
            helperText: _isEditing ? '$_enrolled alunos já inscritos' : null,
          ),
          validator: (value) {
            final capacity = int.tryParse(value?.trim() ?? '');
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
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _color.withValues(alpha: 0.15),
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
          const Icon(Icons.chevron_right_rounded, color: EducanoColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildIconOption(Map<String, dynamic> option) {
    final icon = option['icon'] as IconData;
    final selected = icon == _icon;

    return Tooltip(
      message: option['label'] as String,
      child: Semantics(
        selected: selected,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => setState(() => _icon = icon),
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
                color: selected ? EducanoColors.textPrimary : Colors.transparent,
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
      (sum, m) => sum + ((m as Map<String, dynamic>)['materiais'] as List).length,
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
    final licao = modulo['licao'] as Map<String, dynamic>;
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
          _buildLicaoRow(licao),
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
                style: TextStyle(color: EducanoColors.textSecondary, fontSize: 13),
              ),
            )
          else
            ...materiais.map(
              (m) => _buildMaterialRow(trilha, modulo, m as Map<String, dynamic>),
            ),
          TextButton.icon(
            onPressed: () => _openMaterialEditor(trilha, modulo),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Adicionar material'),
          ),
        ],
      ),
    );
  }

  Widget _buildLicaoRow(Map<String, dynamic> licao) {
    return Container(
      padding: const EdgeInsets.all(_spacingMinimum),
      margin: const EdgeInsets.symmetric(vertical: _spacingMinimum),
      decoration: BoxDecoration(
        color: EducanoColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_rounded, color: EducanoColors.primaryBlue, size: 18),
          const SizedBox(width: _spacingMinimum),
          Expanded(
            child: Text(
              licao['title'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: EducanoColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: _spacingMinimum),
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

  Widget _buildMaterialRow(
    Map<String, dynamic> trilha,
    Map<String, dynamic> modulo,
    Map<String, dynamic> material,
  ) {
    final kind = material['type'] as MaterialKind? ?? MaterialKind.pdf;
    final details = [
      kind.label,
      material['fileName'],
      material['fileSize'],
      material['duration'],
    ].whereType<String>().join('  ·  ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: kind.color.withValues(alpha: 0.15),
            child: Icon(kind.icon, color: kind.color, size: 16),
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
            tooltip: 'Editar material',
            visualDensity: VisualDensity.compact,
            onPressed: () =>
                _openMaterialEditor(trilha, modulo, material: material),
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
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              'licao': <String, dynamic>{
                ...modulo['licao'] as Map<String, dynamic>,
              },
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
    _titleController =
        TextEditingController(text: widget.trilha?['title'] as String? ?? '');
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
            child: Text(widget.trilha == null ? 'Nova Trilha' : 'Editar Trilha'),
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
  late final TextEditingController _licaoController;
  late final TextEditingController _xpController;

  @override
  void initState() {
    super.initState();
    final licao = widget.modulo?['licao'] as Map<String, dynamic>?;
    _titleController =
        TextEditingController(text: widget.modulo?['title'] as String? ?? '');
    _licaoController =
        TextEditingController(text: licao?['title'] as String? ?? '');
    _xpController = TextEditingController(text: '${licao?['xp'] ?? 50}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _licaoController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, <String, dynamic>{
      'title': _titleController.text.trim(),
      'licaoTitle': _licaoController.text.trim(),
      'xp': int.parse(_xpController.text.trim()),
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
          const Icon(Icons.folder_open_rounded, color: EducanoColors.primaryBlue),
          const SizedBox(width: _spacingMinimum),
          Expanded(
            child: Text(widget.modulo == null ? 'Novo Módulo' : 'Editar Módulo'),
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
                  controller: _licaoController,
                  decoration: const InputDecoration(
                    labelText: 'Título da lição',
                    hintText: 'Ex.: Frações Equivalentes',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Informe o título da lição'
                      : null,
                ),
                const SizedBox(height: _spacingSmall),
                TextFormField(
                  controller: _xpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'XP da lição',
                    prefixIcon: Icon(Icons.bolt_rounded),
                  ),
                  validator: (value) {
                    final xp = int.tryParse(value?.trim() ?? '');
                    return (xp == null || xp <= 0) ? 'Informe um XP válido' : null;
                  },
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
