import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/data/dashboard_events.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/api_mappers.dart';
import '../../../services/api_client.dart';
import '../../../services/questions_service.dart';
import '../../course/models/course_models.dart';
import '../../course/widgets/course_editor_dialogs.dart';
import '../widgets/dashboard_list_components.dart';

// IBL12/IBL13 – Cadastro e consulta paginada de questões.
class DashboardQuestionsView extends StatefulWidget {
  const DashboardQuestionsView({super.key});
  @override State<DashboardQuestionsView> createState() => _DashboardQuestionsViewState();
}

class _DashboardQuestionsViewState extends State<DashboardQuestionsView> {
  final _service = QuestionsService.instance;
  final _search = TextEditingController();
  String _difficulty = 'Todas';
  String _theme = 'Todos';
  List<String> _themes = [];
  List<ActivityQuestion> _questions = [];
  int _page = 1, _totalPages = 1, _total = 0;
  int _requestVersion = 0;
  bool _loading = true; String? _error; Timer? _debounce;
  @override void initState() { super.initState(); DashboardEvents.changes.addListener(_reload); _reload(); _loadThemes(); }
  @override void dispose() { DashboardEvents.changes.removeListener(_reload); _debounce?.cancel(); _search.dispose(); super.dispose(); }
  void _reload() => _load(1);
  Future<void> _loadThemes() async {
    try {
      final themes = await _service.themes();
      if (mounted) {
        setState(() {
          _themes = themes;
          if (_theme != 'Todos' && !_themes.contains(_theme)) {
            _theme = 'Todos';
          }
        });
      }
    } on ApiException {
      // A lista continua funcional mesmo se não for possível carregar os filtros.
    }
  }
  Future<void> _load(int page) async {
    final requestVersion = ++_requestVersion;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _service.list(
        page: page,
        search: _search.text.trim(),
        difficulty: _difficulty == 'Todas'
            ? null
            : ApiMappers.difficultyFromLabel(_difficulty),
        theme: _theme == 'Todos' ? null : _theme,
      );
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _questions = result.questions;
        _page = result.page;
        _totalPages = result.totalPages;
        _total = result.total;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }
  String _displayTheme(String theme) => theme.isEmpty
      ? theme
      : '${theme[0].toUpperCase()}${theme.substring(1).toLowerCase()}';
  void _onSearch(String _) { _debounce?.cancel(); _debounce = Timer(const Duration(milliseconds: 400), _reload); }
  void _snack(String message, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? EducanoColors.error : EducanoColors.successGreen, behavior: SnackBarBehavior.floating));
  Future<void> _addQuestion() async {
    await createQuestionFromDashboard(context);
    if (mounted) _loadThemes();
  }
  Future<void> _edit(ActivityQuestion q) async { final saved = await showActivityQuestionDialog(context, question: q); if (saved != null && mounted) { _snack('Questão atualizada.'); _load(_page); _loadThemes(); } }
  Future<void> _delete(ActivityQuestion q) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Excluir questão'), content: Text('Excluir "${q.title}"? Ela também sai das atividades em que foi usada.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: EducanoColors.error), onPressed: () => Navigator.pop(context, true), child: const Text('Excluir'))]));
    if (ok != true) return;
    try { await _service.delete(q.id); if (!mounted) return; _snack('Questão excluída.'); _load(_page); } on ApiException catch (e) { _snack(e.message, error: true); }
  }
  void _details(ActivityQuestion question) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(question.title)),
            IconButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _edit(question);
              },
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _delete(question);
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.statement),
                const SizedBox(height: 12),
                ...question.options.asMap().entries.map(
                  (entry) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: entry.key == question.correctOptionIndex
                            ? EducanoColors.primaryBlue
                            : Colors.grey.shade300,
                        width: entry.key == question.correctOptionIndex ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${String.fromCharCode(65 + entry.key)}. ${entry.value}',
                    ),
                  ),
                ),
                Text(
                  'Dificuldade: ${question.difficulty.label}'
                  '${question.topic.isEmpty ? '' : '  •  Tema: ${_displayTheme(question.topic)}'}',
                ),
                if (question.authorName != null)
                  Text(
                    'Professor responsável: ${question.authorName}',
                    style: const TextStyle(
                      color: EducanoColors.textSecondary,
                    ),
                  ),
                if (question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Gabarito comentado',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(question.explanation),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _filters() => LayoutBuilder(
    builder: (context, constraints) {
      final search = TextField(
        controller: _search,
        onChanged: _onSearch,
        decoration: const InputDecoration(
          hintText: 'Buscar por título ou enunciado...',
          prefixIcon: Icon(Icons.search_rounded),
        ),
      );
      final difficulty = DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: _difficulty,
        decoration: const InputDecoration(labelText: 'Dificuldade'),
        items: [
          'Todas',
          ...ActivityQuestionDifficulty.values.map((value) => value.label),
        ]
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() => _difficulty = value);
          _reload();
        },
      );
      final theme = DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: _theme,
        decoration: const InputDecoration(labelText: 'Tema'),
        items: [
          const DropdownMenuItem(value: 'Todos', child: Text('Todos')),
          ..._themes.map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(_displayTheme(value), overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _theme = value;
          });
          _reload();
        },
      );

      if (constraints.maxWidth < 900) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            search,
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: theme),
              const SizedBox(width: 16),
              Expanded(child: difficulty),
            ]),
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: search),
          const SizedBox(width: 16),
          SizedBox(width: 200, child: theme),
          const SizedBox(width: 16),
          SizedBox(width: 180, child: difficulty),
        ],
      );
    },
  );
  Widget _pagination() => Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(onPressed: _page > 1 && !_loading ? () => _load(_page - 1) : null, icon: const Icon(Icons.chevron_left_rounded)), Text('Página $_page de ${_totalPages == 0 ? 1 : _totalPages}'), IconButton(onPressed: _page < _totalPages && !_loading ? () => _load(_page + 1) : null, icon: const Icon(Icons.chevron_right_rounded))]));
  @override Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Questoes', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text('Gerencie as questoes cadastradas.', style: Theme.of(context).textTheme.bodyLarge), const SizedBox(height: 24), Wrap(spacing: 8, runSpacing: 8, children: [ElevatedButton.icon(onPressed: _addQuestion, icon: const Icon(Icons.add_rounded), label: const Text('Nova Questao'))]), const SizedBox(height: 16), _filters(), const SizedBox(height: 24),
    DashboardListCard(title: 'Lista de Questoes', count: _total, children: [
      if (_error != null) Padding(padding: const EdgeInsets.all(24), child: Row(children: [Expanded(child: Text(_error!, style: const TextStyle(color: EducanoColors.error))), TextButton(onPressed: _reload, child: const Text('Tentar novamente'))])),
      if (_loading) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
      else if (_error == null && _questions.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Nenhuma questão encontrada.'))
      else ..._questions.map((q) => DashboardListRow(onTap: () => _details(q), leading: const Icon(Icons.quiz_outlined), title: q.title, subtitle: '${q.difficulty.label}  •  ${q.options.length} alternativas  •  correta: ${q.correctOptionIndex >= 0 ? q.options[q.correctOptionIndex] : '—'}', trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => _edit(q), icon: const Icon(Icons.edit_rounded)), IconButton(onPressed: () => _delete(q), icon: const Icon(Icons.delete_outline_rounded, color: Colors.red))]))),
      if (_totalPages > 1) _pagination(),
    ])]));
}

/// Cadastra uma questão (usado pela tela e pelo botão flutuante do dashboard).
Future<void> createQuestionFromDashboard(BuildContext context) async {
  final saved = await showActivityQuestionDialog(context);
  if (saved == null || !context.mounted) return;
  DashboardEvents.notifyChanged();
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Questão cadastrada.'), backgroundColor: EducanoColors.successGreen, behavior: SnackBarBehavior.floating));
}
