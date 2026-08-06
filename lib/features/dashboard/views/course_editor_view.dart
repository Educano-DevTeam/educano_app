import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;

const double _radius = 18;

/// Página completa de criação/edição de um curso.
/// Aberta a partir da Listagem de Cursos (admin/parceiro/professor).
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
  late String _category;
  late String _status;

  final List<String> _categories = ['Exatas', 'Humanas', 'Biológicas'];
  final List<String> _statuses = ['Ativo', 'Inativo', 'Rascunho'];

  bool get _isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.course?['name'] as String? ?? '');
    _descriptionController = TextEditingController(
      text: widget.course?['description'] as String? ?? '',
    );
    _category = widget.course?['category'] as String? ?? _categories.first;
    _status = widget.course?['status'] as String? ?? 'Rascunho';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, {
      'name': _nameController.text,
      'category': _category,
      'status': _status,
      'description': _descriptionController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Curso atualizado!' : 'Curso criado!'),
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
        title: Text(_isEditing ? 'Editar Curso' : 'Novo Curso'),
        backgroundColor: EducanoColors.background,
        elevation: 0,
        foregroundColor: EducanoColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(_spacingMedium),
          children: [
            _buildSectionCard(
              title: 'Informações do Curso',
              children: [
                TextFormField(
                  controller: _nameController,
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
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _spacingMedium),
            _buildSectionCard(
              title: 'Trilhas e Materiais',
              children: [
                const Text(
                  'Organize as trilhas de aprendizado, módulos, lições e '
                  'materiais didáticos deste curso.',
                  style: TextStyle(color: EducanoColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: _spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.account_tree_rounded),
                    label: const Text('Gerenciar trilhas (em breve)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _spacingMedium),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Salvar curso'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: _spacingSmall),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(_spacingMedium),
      decoration: BoxDecoration(
        color: EducanoColors.surface,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: _spacingMinimum),
          ...children,
        ],
      ),
    );
  }
}
