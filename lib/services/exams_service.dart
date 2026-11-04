import '../core/utils/api_mappers.dart';
import '../features/course/models/course_models.dart';
import '../features/exam/models/exam_session.dart';
import 'api_client.dart';

/// Simulados e atividades: geração, respostas, dicas e finalização.
class ExamsService {
  ExamsService._();

  static final ExamsService instance = ExamsService._();

  final _api = ApiClient.instance;

  Future<ExamSession> create({
    required List<String> subjects,
    required String difficulty,
    required int count,
  }) async {
    final data = await _api.post('/exams', {
      'materias': [
        for (final subject in subjects) ApiMappers.subjectValue(subject) ?? subject,
      ],
      'dificuldade': ApiMappers.difficultyFromLabel(difficulty),
      'quantidade': count,
    }) as Map<String, dynamic>;
    return sessionFromApi(data['simulado'] as Map<String, dynamic>);
  }

  Future<ExamSession> startActivity(String materialId) async {
    final data = await _api.post('/exams/activities/$materialId') as Map<String, dynamic>;
    return sessionFromApi(data['simulado'] as Map<String, dynamic>);
  }

  Future<ExamSession> get(String id, {bool review = false}) async {
    final data = await _api.get('/exams/$id') as Map<String, dynamic>;
    return sessionFromApi(data['simulado'] as Map<String, dynamic>, review: review);
  }

  /// Salva a resposta da questão (salvamento automático).
  Future<void> answer(ExamSession session, int index, int? option) async {
    final question = session.questions[index];
    await _api.put('/exams/${session.id}/answers/${question.id}', {
      'idAlternativa': option == null ? null : question.optionIds[option],
    });
  }

  /// Usa uma Dica Extra e devolve o índice da alternativa eliminada.
  Future<int?> useHint(ExamSession session, int index) async {
    final question = session.questions[index];
    final data = await _api.post(
      '/exams/${session.id}/questions/${question.id}/hint',
    ) as Map<String, dynamic>;
    final eliminated = data['idAlternativaEliminada'] as String?;
    final position = eliminated == null ? -1 : question.optionIds.indexOf(eliminated);
    return position < 0 ? null : position;
  }

  Future<ExamSession> finish(String id) async {
    final data = await _api.post('/exams/$id/finish') as Map<String, dynamic>;
    return sessionFromApi(data['simulado'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> history({String type = 'SIMULADO', int page = 1}) async {
    final data = await _api.get('/exams', query: {'tipo': type, 'page': page})
        as Map<String, dynamic>;
    return (data['dados'] as List).cast<Map<String, dynamic>>();
  }

  static ExamSession sessionFromApi(Map<String, dynamic> api, {bool review = false}) {
    final items = (api['questoes'] as List).cast<Map<String, dynamic>>();
    final answers = <int, int>{};
    final eliminated = <int, int>{};
    final questions = <ActivityQuestion>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final alternatives = (item['alternativas'] as List).cast<Map<String, dynamic>>();
      final ids = alternatives.map((a) => a['id'] as String).toList();

      final chosen = ids.indexOf(item['idAlternativaEscolhida'] as String? ?? '');
      if (chosen >= 0) answers[i] = chosen;

      final removed = ids.indexOf(item['idAlternativaEliminada'] as String? ?? '');
      if (removed >= 0) eliminated[i] = removed;

      questions.add(ActivityQuestion(
        id: item['id'] as String,
        title: item['titulo'] as String? ?? 'Questão ${i + 1}',
        statement: item['enunciado'] as String? ?? '',
        difficulty: ApiMappers.difficulty(item['dificuldade'] as String?),
        options: alternatives.map((a) => a['texto'] as String).toList(),
        optionIds: ids,
        correctOptionIndex: alternatives.indexWhere((a) => a['correta'] == true),
        subject: ApiMappers.subjectLabel(item['materia'] as String?),
        topic: item['tema'] as String? ?? '',
        explanation: item['explicacao'] as String? ?? '',
      ));
    }

    final result = api['resultado'] as Map<String, dynamic>?;

    return ExamSession(
      id: api['id'] as String,
      title: api['titulo'] as String,
      questions: questions,
      durationMinutes: api['duracaoMinutos'] as int,
      remainingSeconds: api['tempoRestanteSegundos'] as int?,
      isActivity: api['tipo'] == 'ATIVIDADE',
      isFinished: api['status'] == 'FINALIZADO',
      isReview: review,
      answers: answers,
      eliminated: eliminated,
      result: result == null ? null : ExamResult.fromApi(result),
    );
  }
}
