import 'package:flutter/material.dart';

import '../models/course_models.dart';

const _blue = Color(0xFF425BC2);
const _green = Color(0xFF20D500);
const _border = Color(0xFFD4D4D4);

Future<Map<String, String>?> showSessionEditor(BuildContext context) {
  final title = TextEditingController();
  final subtitle = TextEditingController();
  final description = TextEditingController();

  return showDialog<Map<String, String>>(
    context: context,
    builder: (_) => _TextEditorDialog(
      title: 'Cadastrar sessão',
      fields: [
        ('Título', title, 'Ex.: C. Humanas'),
        ('Subtítulo', subtitle, 'Ex.: 500 anos de História'),
        ('Descrição', description, 'Explique o objetivo da sessão.'),
      ],
      onSubmit: () => {
        'title': title.text.trim(),
        'subtitle': subtitle.text.trim(),
        'description': description.text.trim(),
      },
    ),
  );
}

Future<Map<String, String>?> showModuleEditor(BuildContext context) {
  final title = TextEditingController();
  final description = TextEditingController();

  return showDialog<Map<String, String>>(
    context: context,
    builder: (_) => _TextEditorDialog(
      title: 'Cadastrar módulo',
      fields: [
        ('Título', title, 'Ex.: Módulo 8: Redemocratização'),
        ('Descrição', description, 'Resumo do conteúdo do módulo.'),
      ],
      onSubmit: () => {
        'title': title.text.trim(),
        'description': description.text.trim(),
      },
    ),
  );
}

class _TextEditorDialog extends StatefulWidget {
  final String title;
  final List<(String, TextEditingController, String)> fields;
  final Map<String, String> Function() onSubmit;

  const _TextEditorDialog({
    required this.title,
    required this.fields,
    required this.onSubmit,
  });

  @override
  State<_TextEditorDialog> createState() => _TextEditorDialogState();
}

class _TextEditorDialogState extends State<_TextEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(widget.title),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final field in widget.fields) ...[
                  TextFormField(
                    controller: field.$2,
                    maxLines: field.$1 == 'Descrição' ? 4 : 1,
                    decoration: InputDecoration(
                      labelText: field.$1,
                      hintText: field.$3,
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Preencha este campo.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                ],
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
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, widget.onSubmit());
          },
          icon: const Icon(Icons.check_rounded),
          label: const Text('Cadastrar'),
        ),
      ],
    );
  }
}

Future<CourseMaterial?> showMaterialEditor(BuildContext context) {
  return showDialog<CourseMaterial>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _MaterialEditorDialog(),
  );
}

class _MaterialEditorDialog extends StatefulWidget {
  const _MaterialEditorDialog();

  @override
  State<_MaterialEditorDialog> createState() => _MaterialEditorDialogState();
}

class _MaterialEditorDialogState extends State<_MaterialEditorDialog> {
  MaterialKind? _kind;
  int _step = 0;

  void _selectKind(MaterialKind kind) {
    setState(() {
      _kind = kind;
      _step = 1;
    });
  }

  void _backToKind() {
    setState(() => _step = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(.12, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
            return SlideTransition(position: offset, child: FadeTransition(
              opacity: animation,
              child: child,
            ));
          },
          child: _step == 0
              ? _MaterialKindStep(key: const ValueKey('kind'), onSelect: _selectKind)
              : _MaterialFormStep(
                  key: ValueKey(_kind),
                  kind: _kind!,
                  onBack: _backToKind,
                ),
        ),
      ),
    );
  }
}

class _MaterialKindStep extends StatelessWidget {
  final ValueChanged<MaterialKind> onSelect;

  const _MaterialKindStep({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Cadastrar material didático',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escolha o tipo de conteúdo que será adicionado ao módulo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              final children = [
                _KindCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Aula',
                  subtitle: 'Vídeo, áudio ou PDF',
                  onTap: () => onSelect(MaterialKind.video),
                ),
                _KindCard(
                  icon: Icons.assignment_rounded,
                  title: 'Atividade',
                  subtitle: 'Simulado com até 10 questões',
                  onTap: () => onSelect(MaterialKind.activity),
                ),
              ];
              return compact
                  ? Column(children: [
                      children[0],
                      const SizedBox(height: 12),
                      children[1],
                    ])
                  : Row(
                      children: [
                        Expanded(child: children[0]),
                        const SizedBox(width: 16),
                        Expanded(child: children[1]),
                      ],
                    );
            },
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

class _KindCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _KindCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 1.4),
          color: const Color(0xFFF9FBFF),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _blue.withValues(alpha: .10),
              child: Icon(icon, color: _blue, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialFormStep extends StatefulWidget {
  final MaterialKind kind;
  final VoidCallback onBack;

  const _MaterialFormStep({
    super.key,
    required this.kind,
    required this.onBack,
  });

  @override
  State<_MaterialFormStep> createState() => _MaterialFormStepState();
}

class _MaterialFormStepState extends State<_MaterialFormStep> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _file = TextEditingController();
  final _theme = TextEditingController();
  final _duration = TextEditingController();

  MaterialKind _fileKind = MaterialKind.video;
  final List<ActivityQuestion> _questions = [];
  ActivityQuestion? _selectedBankQuestion;

  @override
  void dispose() {
    for (final c in [_title, _description, _file, _theme, _duration]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get isActivity => widget.kind == MaterialKind.activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Voltar',
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    isActivity ? 'Cadastrar atividade' : 'Cadastrar aula',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                Chip(
                  avatar: Icon(isActivity ? Icons.assignment : Icons.play_lesson_outlined, size: 17),
                  label: Text(isActivity ? 'Atividade' : 'Aula'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: isActivity ? _activityForm() : _lessonForm(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(isActivity ? 'Cadastrar atividade' : 'Cadastrar aula'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _lessonForm() {
    return Column(
      children: [
        DropdownButtonFormField<MaterialKind>(
          initialValue: _fileKind,
          decoration: const InputDecoration(labelText: 'Tipo da aula'),
          items: const [
            DropdownMenuItem(value: MaterialKind.video, child: Text('Vídeo')),
            DropdownMenuItem(value: MaterialKind.audio, child: Text('Áudio')),
            DropdownMenuItem(value: MaterialKind.pdf, child: Text('PDF')),
          ],
          onChanged: (value) => setState(() => _fileKind = value!),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Título da aula'),
          validator: _required,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Descrição'),
          validator: _required,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _file,
          decoration: InputDecoration(
            labelText: 'Anexo do arquivo',
            hintText: 'URL ou caminho do arquivo',
            suffixIcon: IconButton(
              tooltip: 'Selecionar arquivo',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ponto preparado para conectar o file_picker no backend/app final.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.attach_file_rounded),
            ),
          ),
          validator: _required,
        ),
      ],
    );
  }

  Widget _activityForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _theme,
          decoration: const InputDecoration(labelText: 'Tema da atividade'),
          validator: _required,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _duration,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Tempo (minutos)',
            suffixText: 'min',
          ),
          validator: (value) {
            final number = int.tryParse((value ?? '').trim());
            if (number == null || number <= 0) return 'Informe um tempo válido.';
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Perguntas',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            Text('${_questions.length}/10'),
          ],
        ),
        const SizedBox(height: 8),
        _QuestionSearchArea(
          selectedQuestion: _selectedBankQuestion,
          onAdd: _addQuestion,
          onClear: () => setState(() => _selectedBankQuestion = null),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _questions.length >= 10 ? null : _showNewQuestion,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Cadastrar pergunta'),
        ),
        const SizedBox(height: 12),
        ..._questions.asMap().entries.map(
          (entry) => _QuestionTile(
            index: entry.key,
            question: entry.value,
            onRemove: () => setState(() => _questions.removeAt(entry.key)),
          ),
        ),
        if (_questions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Pesquise uma questão existente ou cadastre uma nova.',
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Preencha este campo.';
    return null;
  }

  void _addQuestion(ActivityQuestion question) {
    if (_questions.length >= 10) return;
    if (_questions.any((item) => item.id == question.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Essa questão já foi adicionada.')),
      );
      return;
    }
    setState(() {
      _questions.add(question);
      _selectedBankQuestion = null;
    });
  }

  Future<void> _showNewQuestion() async {
    final question = await showDialog<ActivityQuestion>(
      context: context,
      builder: (_) => const _QuestionEditorDialog(),
    );
    if (question != null) _addQuestion(question);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (isActivity) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicione pelo menos uma questão.')),
        );
        return;
      }

      Navigator.pop(
        context,
        CourseMaterial(
          id: 'material-${DateTime.now().microsecondsSinceEpoch}',
          kind: MaterialKind.activity,
          title: _theme.text.trim(),
          description: 'Atividade com ${_questions.length} questões.',
          activity: Activity(
            theme: _theme.text.trim(),
            durationMinutes: int.parse(_duration.text.trim()),
            questions: List.unmodifiable(_questions),
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      CourseMaterial(
        id: 'material-${DateTime.now().microsecondsSinceEpoch}',
        kind: _fileKind,
        title: _title.text.trim(),
        description: _description.text.trim(),
        fileName: _file.text.trim().split('/').last,
        fileUrl: _file.text.trim(),
      ),
    );
  }
}

class _QuestionSearchArea extends StatefulWidget {
  final ActivityQuestion? selectedQuestion;
  final ValueChanged<ActivityQuestion> onAdd;
  final VoidCallback onClear;

  const _QuestionSearchArea({
    required this.selectedQuestion,
    required this.onAdd,
    required this.onClear,
  });

  @override
  State<_QuestionSearchArea> createState() => _QuestionSearchAreaState();
}

class _QuestionSearchAreaState extends State<_QuestionSearchArea> {
  final _controller = TextEditingController();
  final _bank = const [
    ActivityQuestion(
      id: 'q1',
      title: 'Brasil Colônia',
      statement: 'Qual tratado dividiu as terras entre Portugal e Espanha?',
      difficulty: ActivityQuestionDifficulty.easy,
      options: ['Tordesilhas', 'Madri', 'Santo Ildefonso', 'Utrecht'],
      correctOptionIndex: 0,
    ),
    ActivityQuestion(
      id: 'q2',
      title: 'História do Brasil',
      statement: 'Em qual período ocorreu a Independência do Brasil?',
      difficulty: ActivityQuestionDifficulty.easy,
      options: ['1822', '1889', '1500', '1930'],
      correctOptionIndex: 0,
    ),
    ActivityQuestion(
      id: 'q3',
      title: 'Geografia',
      statement: 'Qual é a capital do Brasil?',
      difficulty: ActivityQuestionDifficulty.easy,
      options: ['São Paulo', 'Brasília', 'Salvador', 'Rio de Janeiro'],
      correctOptionIndex: 1,
    ),
  ];
  List<ActivityQuestion> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    final q = value.trim().toLowerCase();
    setState(() {
      _results = q.isEmpty
          ? []
          : _bank.where((item) =>
              item.title.toLowerCase().contains(q) ||
              item.statement.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: _search,
          decoration: const InputDecoration(
            labelText: 'Pesquisar questões existentes',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        if (_results.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: _results.map((question) => ListTile(
                dense: true,
                title: Text(question.title),
                subtitle: Text(question.statement, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  onPressed: () {
                    widget.onAdd(question);
                    _controller.clear();
                    setState(() => _results = []);
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, color: _blue),
                ),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final int index;
  final ActivityQuestion question;
  final VoidCallback onRemove;

  const _QuestionTile({
    required this.index,
    required this.question,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: _blue.withValues(alpha: .12),
            child: Text('${index + 1}', style: const TextStyle(color: _blue)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              question.statement,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 19),
          ),
        ],
      ),
    );
  }
}

class _QuestionEditorDialog extends StatefulWidget {
  const _QuestionEditorDialog();

  @override
  State<_QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<_QuestionEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _statement = TextEditingController();
  final List<TextEditingController> _answers = [TextEditingController(), TextEditingController()];
  ActivityQuestionDifficulty _difficulty = ActivityQuestionDifficulty.easy;
  int _correctIndex = 0;

  @override
  void dispose() {
    _title.dispose();
    _statement.dispose();
    for (final controller in _answers) controller.dispose();
    super.dispose();
  }

  void _addAnswer() {
    if (_answers.length >= 5) return;
    setState(() => _answers.add(TextEditingController()));
  }

  void _removeAnswer(int index) {
    if (_answers.length <= 2) return;
    setState(() {
      _answers[index].dispose();
      _answers.removeAt(index);
      if (_correctIndex >= _answers.length) _correctIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Cadastrar pergunta'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Informe o título.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _statement,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Pergunta'),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Informe a pergunta.' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ActivityQuestionDifficulty>(
                  initialValue: _difficulty,
                  decoration: const InputDecoration(labelText: 'Nível de dificuldade'),
                  items: ActivityQuestionDifficulty.values
                      .map((item) => DropdownMenuItem(value: item, child: Text(item.label)))
                      .toList(),
                  onChanged: (value) => setState(() => _difficulty = value!),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Respostas', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text('${_answers.length}/5'),
                    IconButton(
                      onPressed: _answers.length >= 5 ? null : _addAnswer,
                      icon: const Icon(Icons.add_circle_outline_rounded, color: _blue),
                    ),
                  ],
                ),
                ..._answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  final letter = String.fromCharCode(65 + index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: _correctIndex,
                          onChanged: (value) => setState(() => _correctIndex = value!),
                        ),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: _blue.withValues(alpha: .10),
                          child: Text(letter, style: const TextStyle(color: _blue, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(labelText: 'Resposta $letter'),
                            validator: (v) => (v ?? '').trim().isEmpty ? 'Preencha a resposta.' : null,
                          ),
                        ),
                        if (_answers.length > 2)
                          IconButton(
                            onPressed: () => _removeAnswer(index),
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                          ),
                      ],
                    ),
                  );
                }),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Marque a alternativa correta usando o botão ao lado da resposta.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              ActivityQuestion(
                id: 'question-${DateTime.now().microsecondsSinceEpoch}',
                title: _title.text.trim(),
                statement: _statement.text.trim(),
                difficulty: _difficulty,
                options: _answers.map((item) => item.text.trim()).toList(),
                correctOptionIndex: _correctIndex,
              ),
            );
          },
          icon: const Icon(Icons.check_rounded),
          label: const Text('Cadastrar pergunta'),
        ),
      ],
    );
  }
}
