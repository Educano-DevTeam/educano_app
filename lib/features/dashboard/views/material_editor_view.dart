import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/theme.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;

const double _radius = 18;

/// Largura máxima do formulário, para os campos não esticarem na tela toda.
const double _formMaxWidth = 720;

/// Tipos de material didático que podem ser cadastrados em um módulo.
enum MaterialKind {
  pdf(
    label: 'PDF',
    icon: Icons.picture_as_pdf_rounded,
    color: EducanoColors.error,
    formats: '.pdf',
    maxSize: '50 MB',
    example: 'Apostila em PDF',
  ),
  video(
    label: 'Vídeo',
    icon: Icons.play_circle_rounded,
    color: EducanoColors.primaryBlue,
    formats: '.mp4, .mov',
    maxSize: '500 MB',
    example: 'Vídeo-aula',
  ),
  audio(
    label: 'Áudio',
    icon: Icons.headphones_rounded,
    color: EducanoColors.accentYellow,
    formats: '.mp3, .wav',
    maxSize: '100 MB',
    example: 'Podcast da aula',
  );

  final String label;
  final IconData icon;
  final Color color;
  final String formats;
  final String maxSize;
  final String example;

  const MaterialKind({
    required this.label,
    required this.icon,
    required this.color,
    required this.formats,
    required this.maxSize,
    required this.example,
  });
}

/// Material Didático – cadastro de um material (PDF, vídeo ou áudio) em um
/// módulo do curso. Aberto a partir da página de edição do curso.
class MaterialEditorView extends StatefulWidget {
  final String courseName;
  final String trilhaTitle;
  final String moduloTitle;
  final Map<String, dynamic>? material;

  const MaterialEditorView({
    super.key,
    required this.courseName,
    required this.trilhaTitle,
    required this.moduloTitle,
    this.material,
  });

  @override
  State<MaterialEditorView> createState() => _MaterialEditorViewState();
}

class _MaterialEditorViewState extends State<MaterialEditorView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late MaterialKind _kind;

  String? _fileName;
  String? _fileSize;
  String? _duration;
  bool _showFileError = false;

  bool get _isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    final material = widget.material;
    _nameController =
        TextEditingController(text: material?['name'] as String? ?? '');
    _descriptionController = TextEditingController(
      text: material?['description'] as String? ?? '',
    );
    _kind = material?['type'] as MaterialKind? ?? MaterialKind.pdf;
    _fileName = material?['fileName'] as String?;
    _fileSize = material?['fileSize'] as String?;
    _duration = material?['duration'] as String?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectKind(MaterialKind kind) {
    if (kind == _kind) return;
    setState(() {
      _kind = kind;
      // O arquivo escolhido deixa de valer quando o tipo muda.
      _fileName = null;
      _fileSize = null;
      _duration = null;
    });
  }

  /// Upload simulado: ainda não há backend para receber o arquivo, então
  /// só preenche um arquivo de exemplo do tipo escolhido.
  void _selectFile() {
    final (fileName, fileSize, duration) = switch (_kind) {
      MaterialKind.pdf => ('apostila.pdf', '2,4 MB', null),
      MaterialKind.video => ('video-aula.mp4', '48,7 MB', '12:34'),
      MaterialKind.audio => ('podcast.mp3', '6,1 MB', '08:15'),
    };

    setState(() {
      _fileName = fileName;
      _fileSize = fileSize;
      _duration = duration;
      _showFileError = false;
    });
  }

  void _removeFile() {
    setState(() {
      _fileName = null;
      _fileSize = null;
      _duration = null;
    });
  }

  void _save() {
    final isFormValid = _formKey.currentState!.validate();
    final hasFile = _fileName != null;
    if (!hasFile) setState(() => _showFileError = true);
    if (!isFormValid || !hasFile) return;

    Navigator.pop(context, <String, dynamic>{
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'type': _kind,
      // Mesmo campo usado pelos materiais da tela Meu Progresso do aluno.
      'icon': _kind.icon,
      'fileName': _fileName,
      'fileSize': _fileSize,
      if (_duration != null) 'duration': _duration,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Material atualizado!' : 'Material adicionado!'),
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
        title: Text(_isEditing ? 'Editar Material' : 'Novo Material'),
        backgroundColor: EducanoColors.background,
        elevation: 0,
        foregroundColor: EducanoColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < AppBreakpoints.compact;
            final pagePadding = isCompact ? _spacingSmall : _spacingMedium;

            return ListView(
              padding: EdgeInsets.all(pagePadding),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLocation(),
                        const SizedBox(height: _spacingMedium),
                        _buildSectionCard(
                          title: 'Tipo de material',
                          isCompact: isCompact,
                          children: [_buildKindSelector()],
                        ),
                        const SizedBox(height: _spacingMedium),
                        _buildSectionCard(
                          title: 'Arquivo',
                          isCompact: isCompact,
                          children: [_buildUploadArea()],
                        ),
                        const SizedBox(height: _spacingMedium),
                        _buildSectionCard(
                          title: 'Informações do Material',
                          isCompact: isCompact,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Título do material',
                                hintText: 'Ex.: ${_kind.example}',
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                      ? 'Informe o título do material'
                                      : null,
                            ),
                            const SizedBox(height: _spacingSmall),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Descrição (opcional)',
                                alignLabelWithHint: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: _spacingMedium),
                        _buildSectionCard(
                          title: 'Prévia para o aluno',
                          isCompact: isCompact,
                          children: [_buildStudentPreview()],
                        ),
                        const SizedBox(height: _spacingMedium),
                        ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_rounded),
                          label: Text(
                            _isEditing ? 'Salvar alterações' : 'Adicionar material',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: _spacingSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Onde o material vai ficar: curso › trilha › módulo.
  Widget _buildLocation() {
    return Container(
      padding: const EdgeInsets.all(_spacingSmall),
      decoration: BoxDecoration(
        color: EducanoColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_rounded, color: EducanoColors.primaryBlue),
          const SizedBox(width: _spacingMinimum),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.moduloTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: EducanoColors.textPrimary,
                  ),
                ),
                Text(
                  '${widget.courseName}  ·  ${widget.trilhaTitle}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: EducanoColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKindSelector() {
    return Row(
      children: [
        for (final kind in MaterialKind.values) ...[
          if (kind != MaterialKind.values.first)
            const SizedBox(width: _spacingMinimum),
          Expanded(child: _buildKindOption(kind)),
        ],
      ],
    );
  }

  Widget _buildKindOption(MaterialKind kind) {
    final selected = kind == _kind;

    return Semantics(
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _selectKind(kind),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: _spacingMinimum,
              vertical: _spacingSmall,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? kind.color.withValues(alpha: 0.1)
                  : EducanoColors.searchBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? kind.color : EducanoColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  kind.icon,
                  size: 28,
                  color: selected ? kind.color : EducanoColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  kind.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? EducanoColors.textPrimary
                        : EducanoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    if (_fileName != null) return _buildSelectedFile();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(_spacingSmall),
          decoration: BoxDecoration(
            color: EducanoColors.searchBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _showFileError
                  ? EducanoColors.error
                  : EducanoColors.lightBlue,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.cloud_upload_rounded,
                size: 40,
                color: EducanoColors.primaryBlue,
              ),
              const SizedBox(height: _spacingMinimum),
              const Text(
                'Nenhum arquivo selecionado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: EducanoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Formatos aceitos: ${_kind.formats}  ·  até ${_kind.maxSize}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: EducanoColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: _spacingSmall),
              OutlinedButton.icon(
                onPressed: _selectFile,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Selecionar arquivo'),
              ),
            ],
          ),
        ),
        if (_showFileError)
          const Padding(
            padding: EdgeInsets.only(top: _spacingMinimum, left: 12),
            child: Text(
              'Selecione o arquivo do material',
              style: TextStyle(color: EducanoColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedFile() {
    final details = [_fileSize, _duration].whereType<String>().join('  ·  ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kind.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _kind.color.withValues(alpha: 0.15),
            child: Icon(_kind.icon, color: _kind.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: EducanoColors.textPrimary,
                  ),
                ),
                Text(
                  details,
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
          IconButton(
            tooltip: 'Remover arquivo',
            onPressed: _removeFile,
            icon: const Icon(Icons.close_rounded),
            color: EducanoColors.error,
          ),
        ],
      ),
    );
  }

  /// Mesma linha de material que o aluno vê dentro do módulo em Meu Progresso.
  Widget _buildStudentPreview() {
    final name = _nameController.text.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _spacingSmall,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: EducanoColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EducanoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Materiais didáticos',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: EducanoColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(_kind.icon, color: EducanoColors.textSecondary, size: 18),
              const SizedBox(width: _spacingMinimum),
              Expanded(
                child: Text(
                  name.isEmpty ? 'Título do material' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: name.isEmpty
                        ? EducanoColors.textSecondary
                        : EducanoColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
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
