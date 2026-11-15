import 'dart:convert';

import '../core/utils/api_mappers.dart';
import '../features/course/models/course_models.dart';
import '../features/exam/models/exam_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final response = await _api.post('/exams', {
      'materias': [
        for (final subject in subjects)
          ApiMappers.subjectValue(subject) ?? subject,
      ],
      'dificuldade': ApiMappers.difficultyFromLabel(difficulty),
      'quantidade': count,
    });
    final data = ApiClient.responseMap(response, endpoint: '/exams');
    return sessionFromApi(
      ApiClient.responseMap(data['simulado'], endpoint: '/exams.simulado'),
    );
  }

  Future<ExamSession> startActivity(String materialId) async {
    final detailsResponse = await _api.get('/tests/$materialId');
    final detailsData = ApiClient.responseMap(detailsResponse, endpoint: '/tests/$materialId');
    final test = ApiClient.responseMap(detailsData['teste'], endpoint: '/tests/$materialId.teste');
    final response = await _api.post('/tests/$materialId/attempts');
    final data = ApiClient.responseMap(response, endpoint: '/tests/$materialId/attempts');
    final attempt = ApiClient.responseMap(data['tentativa'], endpoint: '/tests/$materialId/attempts.tentativa');
    final questions = ApiClient.responseList(data['questoes'], endpoint: '/tests/$materialId/attempts.questoes');
    final session = _sessionFromAttempt(attempt, test, questions);
    final saved = await SharedPreferencesAsync().getString('educano.exam.${session.id}.answers');
    if (saved != null) {
      final draft = (jsonDecode(saved) as Map).cast<String, dynamic>();
      for (var i = 0; i < session.questions.length; i++) {
        final selected = draft[session.questions[i].id];
        final option = session.questions[i].optionIds.indexOf(selected as String? ?? '');
        if (option >= 0) session.answers[i] = option;
      }
    }
    return session;
  }

  Future<ExamSession> get(String id, {bool review = false}) async {
    final response = await _api.get('/exams/$id');
    final data = ApiClient.responseMap(response, endpoint: '/exams/$id');
    return sessionFromApi(
      ApiClient.responseMap(data['simulado'], endpoint: '/exams/$id.simulado'),
      review: review,
    );
  }

  /// Salva a resposta da questão (salvamento automático).


  /// Usa uma Dica Extra e devolve o índice da alternativa eliminada.
  Future<int?> useHint(ExamSession session, int index) async {
    final question = session.questions[index];
    final response = await _api.post(
      '/exams/${session.id}/questions/${question.id}/hint',
    );
    final data = ApiClient.responseMap(
      response,
      endpoint: '/exams/${session.id}/questions/${question.id}/hint',
    );
    final eliminated = ApiClient.responseString(
      data['idAlternativaEliminada'],
      endpoint: '/exams/hint.idAlternativaEliminada',
    );
    final position = eliminated == null
        ? -1
        : question.optionIds.indexOf(eliminated);
    return position < 0 ? null : position;
  }

  Future<ExamSession> finish(ExamSession session) async {
    final id = session.id!;
    final responses = [
      for (var i = 0; i < session.questions.length; i++)
        {
          'idQuestao': session.questions[i].id,
          'resposta': session.answers[i] == null ? null : session.questions[i].optionIds[session.answers[i]!],
        },
    ];
    final response = await _api.post('/tests/attempts/$id/submit', {'respostas': responses});
    final data = ApiClient.responseMap(response, endpoint: '/tests/attempts/$id/submit');
    final resultData = ApiClient.responseMap(data['resultado'], endpoint: '/tests/attempts/$id/submit.resultado');
    final reward = ApiClient.responseMap(data['recompensa'], endpoint: '/tests/attempts/$id/submit.recompensa', optional: true);
    final result = ExamResult(
      correct: ApiClient.responseInt(resultData['acertos'], endpoint: '/tests/result.acertos'),
      total: ApiClient.responseInt(resultData['totalQuestoes'], endpoint: '/tests/result.totalQuestoes'),
      score: (ApiMappers.number(resultData['notaFinal']) ?? 0).round(),
      xp: ApiClient.responseInt(reward['xp'], endpoint: '/tests/reward.xp'),
      coins: ApiClient.responseInt(reward['moedas'], endpoint: '/tests/reward.moedas'),
      bySubject: const [],
      byTopic: const [],
    );
    await SharedPreferencesAsync().remove('educano.exam.$id.answers');
    return ExamSession(
      id: session.id, title: session.title, questions: session.questions,
      durationMinutes: session.durationMinutes, isActivity: session.isActivity,
      isFinished: true, result: result, answers: session.answers,
    );
  }

  Future<void> answer(ExamSession session, int index, int? option) async {
    final key = 'educano.exam.${session.id}.answers';
    final preferences = SharedPreferencesAsync();
    final encoded = await preferences.getString(key);
    final answers = encoded == null ? <String, dynamic>{} : (jsonDecode(encoded) as Map).cast<String, dynamic>();
    final question = session.questions[index];
    answers[question.id] = option == null ? null : question.optionIds[option];
    await preferences.setString(key, jsonEncode(answers));
  }

  static ExamSession _sessionFromAttempt(Map<String, dynamic> attempt, Map<String, dynamic> test, List<Map<String, dynamic>> questions) {
    final mapped = <ActivityQuestion>[];
    for (final question in questions) {
      const letters = ['A', 'B', 'C', 'D', 'E'];
      final options = [question['alternativaA'], question['alternativaB'], question['alternativaC'], question['alternativaD'], question['alternativaE']]
          .whereType<String>().toList();
      mapped.add(ActivityQuestion(
        id: question['idQuestao'] as String,
        title: question['titulo'] as String? ?? '',
        statement: question['enunciado'] as String? ?? '',
        difficulty: ActivityQuestionDifficulty.medium,
        options: options,
        optionIds: letters.take(options.length).toList(),
        correctOptionIndex: -1,
      ));
    }
    return ExamSession(
      id: attempt['id'] as String,
      title: test['tema'] as String? ?? 'Atividade',
      questions: mapped,
      durationMinutes: ApiClient.responseInt(test['tempoMinutos'], endpoint: '/tests/attempt.tempoMinutos'),
      isActivity: test['tipo'] == 'ATIVIDADE',
    );
  }

  Future<List<Map<String, dynamic>>> history({
    String type = 'SIMULADO',
    int page = 1,
  }) async {
    final response = await _api.get(
      '/exams',
      query: {'tipo': type, 'page': page},
    );
    final data = ApiClient.responseMap(
      response,
      endpoint: '/exams',
      optional: true,
    );
    return ApiClient.responseList(data['dados'], endpoint: '/exams.dados');
  }

  static ExamSession sessionFromApi(
    Map<String, dynamic> api, {
    bool review = false,
  }) {
    return ApiClient.parseResponse('/exams.simulado', () {
      final items = ApiClient.responseList(
        api['questoes'],
        endpoint: '/exams.simulado.questoes',
      );
      final answers = <int, int>{};
      final eliminated = <int, int>{};
      final questions = <ActivityQuestion>[];

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final alternatives = ApiClient.responseList(
          item['alternativas'],
          endpoint: '/exams.questoes.alternativas',
        );
        final ids = alternatives.map((a) => a['id'] as String).toList();

        final chosen = ids.indexOf(
          item['idAlternativaEscolhida'] as String? ?? '',
        );
        if (chosen >= 0) answers[i] = chosen;

        final removed = ids.indexOf(
          item['idAlternativaEliminada'] as String? ?? '',
        );
        if (removed >= 0) eliminated[i] = removed;

        questions.add(
          ActivityQuestion(
            id: item['id'] as String,
            title: item['titulo'] as String? ?? 'Questão ${i + 1}',
            statement: item['enunciado'] as String? ?? '',
            difficulty: ApiMappers.difficulty(item['dificuldade'] as String?),
            options: alternatives
                .map(
                  (a) => ApiClient.responseString(
                    a['texto'],
                    endpoint: '/exams.questoes.alternativas.texto',
                  )!,
                )
                .toList(),
            optionIds: ids,
            correctOptionIndex: alternatives.indexWhere(
              (a) => a['correta'] == true,
            ),
            subject: ApiMappers.subjectLabel(item['materia'] as String?),
            topic: item['tema'] as String? ?? '',
            explanation: item['explicacao'] as String? ?? '',
          ),
        );
      }

      final result = api['resultado'] == null
          ? null
          : ApiClient.responseMap(
              api['resultado'],
              endpoint: '/exams.simulado.resultado',
            );

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
    });
  }
}
