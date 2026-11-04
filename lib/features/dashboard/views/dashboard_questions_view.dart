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

// IBL12/IBL13 – Cadastro, consulta paginada e relatório de questões.
class DashboardQuestionsView extends StatefulWidget {
  const DashboardQuestionsView({super.key});
  @override State<DashboardQuestionsView> createState() => _DashboardQuestionsViewState();
}

class _DashboardQuestionsViewState extends State<DashboardQuestionsView> {
  final _service = QuestionsService.instance;
  final _search = TextEditingController();
  String _difficulty = 'Todas', _alternatives = 'Todas', _subject = 'Todas';
  List<ActivityQuestion> _questions = [];
  List<String> _subjects = [];
  int _page = 1, _totalPages = 1, _total = 0;
  bool _loading = true; String? _error; Timer? _debounce;
  @override void initState() { super.initState(); DashboardEvents.changes.addListener(_reload); _reload(); }
  @override void dispose() { DashboardEvents.changes.removeListener(_reload); _debounce?.cancel(); _search.dispose(); super.dispose(); }
  void _reload() => _load(1);
  Future<void> _load(int page) async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _service.list(page: page, search: _search.text.trim(), difficulty: _difficulty == 'Todas' ? null : ApiMappers.difficultyFromLabel(_difficulty), subject: _subject == 'Todas' ? null : _subject, alternatives: int.tryParse(_alternatives));
      if (!mounted) return;
      setState(() { _questions = result.questions; _subjects = result.subjects; _page = result.page; _totalPages = result.totalPages; _total = result.total; _loading = false; });
    } on ApiException catch (e) { if (mounted) setState(() { _loading = false; _error = e.message; }); }
  }
  void _onSearch(String _) { _debounce?.cancel(); _debounce = Timer(const Duration(milliseconds: 400), _reload); }
  void _snack(String message, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? EducanoColors.error : EducanoColors.successGreen, behavior: SnackBarBehavior.floating));
  Future<void> _addQuestion() => createQuestionFromDashboard(context);
  Future<void> _edit(ActivityQuestion q) async { final saved = await showActivityQuestionDialog(context, question: q); if (saved != null && mounted) { _snack('Questão atualizada.'); _load(_page); } }
  Future<void> _delete(ActivityQuestion q) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Excluir questão'), content: Text('Excluir "${q.title}"? Ela também sai das atividades em que foi usada.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: EducanoColors.error), onPressed: () => Navigator.pop(context, true), child: const Text('Excluir'))]));
    if (ok != true) return;
    try { await _service.delete(q.id); if (!mounted) return; _snack('Questão excluída.'); _load(_page); } on ApiException catch (e) { _snack(e.message, error: true); }
  }
  void _details(ActivityQuestion q) => showDialog(context: context, builder: (_) => AlertDialog(title: Row(children: [Expanded(child: Text(q.title)), IconButton(onPressed: () { Navigator.pop(context); _edit(q); }, icon: const Icon(Icons.edit_rounded)), IconButton(onPressed: () { Navigator.pop(context); _delete(q); }, icon: const Icon(Icons.delete_outline_rounded, color: Colors.red))]), content: SizedBox(width: 560, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(q.statement), const SizedBox(height: 12), ...q.options.asMap().entries.map((e) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: e.key == q.correctOptionIndex ? EducanoColors.successGreen : Colors.grey.shade300), borderRadius: BorderRadius.circular(10)), child: Text('${String.fromCharCode(65 + e.key)}. ${e.value}'))), Text('Dificuldade: ${q.difficulty.label}  •  Matéria: ${q.subject}${q.topic.isEmpty ? '' : '  •  Tema: ${q.topic}'}'), if (q.authorName != null) Text('Professor responsável: ${q.authorName}', style: const TextStyle(color: EducanoColors.textSecondary)), if (q.explanation.isNotEmpty) ...[const SizedBox(height: 12), const Text('Gabarito comentado', style: TextStyle(fontWeight: FontWeight.w600)), Text(q.explanation)]])))));
  Future<void> _report() async {
    showDialog<void>(context: context, builder: (_) => FutureBuilder<Map<String, dynamic>>(future: _service.report(), builder: (context, snap) {
      Widget body;
      if (snap.hasError) { body = Text(snap.error.toString(), style: const TextStyle(color: EducanoColors.error)); }
      else if (!snap.hasData) { body = const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())); }
      else {
        final r = snap.data!; final respostas = r['respostas'] as Map<String, dynamic>;
        Widget group(String title, List items, String Function(Map<String, dynamic>) label) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), ...items.cast<Map<String, dynamic>>().map((g) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Expanded(child: Text(label(g))), Text('${g['total'] ?? g['usos']}')])))]);
        body = SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Total de questões: ${r['total']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text('Respostas em simulados: ${respostas['total']}  •  Taxa de acerto: ${((respostas['taxaAcerto'] as num) * 100).round()}%'),
          group('Por dificuldade', r['porDificuldade'] as List, (g) => ApiMappers.difficulty(g['dificuldade'] as String?).label),
          group('Por matéria', r['porMateria'] as List, (g) => ApiMappers.subjectLabel(g['materia'] as String?)),
          group('Por professor', r['porProfessor'] as List, (g) => (g['professor'] as Map?)?['nome'] as String? ?? 'Sem responsável'),
          group('Mais usadas em simulados', r['maisUsadas'] as List, (g) => '${g['titulo']} (${ApiMappers.subjectLabel(g['materia'] as String?)})'),
        ]));
      }
      return AlertDialog(title: const Text('Relatório de questões'), content: SizedBox(width: 480, child: body), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]);
    }));
  }
  Widget _filters() => LayoutBuilder(builder: (context, constraints) {
    final search = TextField(controller: _search, onChanged: _onSearch, decoration: const InputDecoration(hintText: 'Buscar por titulo, pergunta ou tema...', prefixIcon: Icon(Icons.search_rounded)));
    final difficulty = DropdownButtonFormField<String>(initialValue: _difficulty, decoration: const InputDecoration(labelText: 'Dificuldade'), items: ['Todas', ...ActivityQuestionDifficulty.values.map((e) => e.label)].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { setState(() => _difficulty = v!); _reload(); });
    final subject = DropdownButtonFormField<String>(initialValue: _subject, decoration: const InputDecoration(labelText: 'Matéria'), items: ['Todas', ...{...questionSubjects, ..._subjects}].map((v) => DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) { setState(() => _subject = v!); _reload(); });
    final alternatives = DropdownButtonFormField<String>(initialValue: _alternatives, decoration: const InputDecoration(labelText: 'Alternativas'), items: ['Todas', '2', '3', '4', '5'].map((v) => DropdownMenuItem(value: v, child: Text(v == 'Todas' ? v : '$v opcoes'))).toList(), onChanged: (v) { setState(() => _alternatives = v!); _reload(); });
    if (constraints.maxWidth < 900) return Column(children: [search, const SizedBox(height: 16), Row(children: [Expanded(child: difficulty), const SizedBox(width: 16), Expanded(child: subject)]), const SizedBox(height: 16), alternatives]);
    return Row(children: [Expanded(child: search), const SizedBox(width: 16), SizedBox(width: 150, child: difficulty), const SizedBox(width: 16), SizedBox(width: 200, child: subject), const SizedBox(width: 16), SizedBox(width: 150, child: alternatives)]);
  });
  Widget _pagination() => Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(onPressed: _page > 1 && !_loading ? () => _load(_page - 1) : null, icon: const Icon(Icons.chevron_left_rounded)), Text('Página $_page de ${_totalPages == 0 ? 1 : _totalPages}'), IconButton(onPressed: _page < _totalPages && !_loading ? () => _load(_page + 1) : null, icon: const Icon(Icons.chevron_right_rounded))]));
  @override Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Questoes', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text('Gerencie as questoes cadastradas.', style: Theme.of(context).textTheme.bodyLarge), const SizedBox(height: 24), Wrap(spacing: 8, runSpacing: 8, children: [ElevatedButton.icon(onPressed: _addQuestion, icon: const Icon(Icons.add_rounded), label: const Text('Nova Questao')), OutlinedButton.icon(onPressed: _report, icon: const Icon(Icons.bar_chart_rounded), label: const Text('Relatório'))]), const SizedBox(height: 16), _filters(), const SizedBox(height: 24),
    DashboardListCard(title: 'Lista de Questoes', count: _total, children: [
      if (_error != null) Padding(padding: const EdgeInsets.all(24), child: Row(children: [Expanded(child: Text(_error!, style: const TextStyle(color: EducanoColors.error))), TextButton(onPressed: _reload, child: const Text('Tentar novamente'))])),
      if (_loading) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
      else if (_error == null && _questions.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Nenhuma questão encontrada.'))
      else ..._questions.map((q) => DashboardListRow(onTap: () => _details(q), leading: const Icon(Icons.quiz_outlined), title: q.title, subtitle: '${q.subject}  •  ${q.difficulty.label}  •  ${q.options.length} alternativas  •  correta: ${q.correctOptionIndex >= 0 ? q.options[q.correctOptionIndex] : '—'}', trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => _edit(q), icon: const Icon(Icons.edit_rounded)), IconButton(onPressed: () => _delete(q), icon: const Icon(Icons.delete_outline_rounded, color: Colors.red))]))),
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
