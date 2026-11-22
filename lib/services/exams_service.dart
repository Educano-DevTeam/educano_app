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
    required String theme,
    required String difficulty,
    required int count,
    required int durationMinutes,
  }) async {
    final response = await _api.post('/tests/simulados', {
      'tema': theme.trim().toLowerCase(),
      'tempoMinutos': durationMinutes,
      'dificuldade': ApiMappers.difficultyFromLabel(difficulty),
      'quantidadeQuestoes': count,
    });
    final data = ApiClient.responseMap(response, endpoint: '/tests/simulados');
    final simulado = ApiClient.responseMap(
      data['simulado'],
      endpoint: '/tests/simulados.simulado',
    );
    final testId = ApiClient.responseString(
      simulado['id'],
      endpoint: '/tests/simulados.simulado.id',
      required: true,
    )!;
    final attemptResponse = await _api.post('/tests/$testId/attempts');
    final attemptData = ApiClient.responseMap(
      attemptResponse,
      endpoint: '/tests/$testId/attempts',
    );
    return _sessionFromAttempt(
      ApiClient.responseMap(
        attemptData['tentativa'],
        endpoint: '/tests/$testId/attempts.tentativa',
      ),
      ApiClient.responseMap(
        attemptData['teste'],
        endpoint: '/tests/$testId/attempts.teste',
      ),
      ApiClient.responseList(
        attemptData['questoes'],
        endpoint: '/tests/$testId/attempts.questoes',
      ),
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
    final response = await _api.get('/tests/attempts/$id');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/tests/attempts/$id',
    );
    final attempt = ApiClient.responseMap(
      data['tentativa'],
      endpoint: '/tests/attempts/$id.tentativa',
    );
    return _sessionFromSavedAttempt(attempt, review: review);
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
    // O envio não inclui o gabarito na resposta. Busque a tentativa já
    // finalizada para exibir as alternativas corretas imediatamente.
    final reviewed = await get(id, review: true);
    return ExamSession(
      id: session.id, title: session.title, questions: reviewed.questions,
      durationMinutes: session.durationMinutes, isActivity: session.isActivity,
      isFinished: true, result: result, answers: reviewed.answers,
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
      final alternatives = [
        for (final letter in letters)
          if (question['alternativa$letter'] is String)
            MapEntry(letter, question['alternativa$letter'] as String),
      ];
      final options = alternatives.map((entry) => entry.value).toList();
      mapped.add(ActivityQuestion(
        id: question['idQuestao'] as String,
        title: question['titulo'] as String? ?? '',
        statement: question['enunciado'] as String? ?? '',
        difficulty: ActivityQuestionDifficulty.medium,
        options: options,
        optionIds: alternatives.map((entry) => entry.key).toList(),
        correctOptionIndex: -1,
      ));
    }
    return ExamSession(
      id: attempt['id'] as String,
      title: test['tema'] as String? ??
          (test['tipo'] == 'SIMULADO' ? 'Simulado' : 'Atividade'),
      questions: mapped,
      durationMinutes: ApiClient.responseInt(test['tempoMinutos'], endpoint: '/tests/attempt.tempoMinutos'),
      isActivity: test['tipo'] == 'ATIVIDADE',
    );
  }

  Future<ExamSession> _sessionFromSavedAttempt(
    Map<String, dynamic> attempt, {
    bool review = false,
  }) async {
    final test = ApiClient.responseMap(
      attempt['teste'],
      endpoint: '/tests/attempt.teste',
    );
    final rows = ApiClient.responseList(
      attempt['questoes'],
      endpoint: '/tests/attempt.questoes',
    );
    const letters = ['A', 'B', 'C', 'D', 'E'];
    final answers = <int, int>{};
    final questions = <ActivityQuestion>[];

    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      final options = <String>[];
      final optionIds = <String>[];
      for (final letter in letters) {
        final text = row['alternativa$letter'];
        if (text is String) {
          options.add(text);
          optionIds.add(letter);
        }
      }
      final selected = optionIds.indexOf(
        row['respostaUsuario'] as String? ?? '',
      );
      if (selected >= 0) answers[index] = selected;
      questions.add(
        ActivityQuestion(
          id: row['idQuestao'] as String,
          title: 'Questão ${index + 1}',
          statement: row['enunciado'] as String? ?? '',
          difficulty: ActivityQuestionDifficulty.medium,
          options: options,
          optionIds: optionIds,
          correctOptionIndex: optionIds.indexOf(
            row['respostaCorreta'] as String? ?? '',
          ),
        ),
      );
    }

    final attemptId = attempt['id'] as String;
    final saved = await SharedPreferencesAsync().getString(
      'educano.exam.$attemptId.answers',
    );
    if (saved != null) {
      final draft = (jsonDecode(saved) as Map).cast<String, dynamic>();
      for (var index = 0; index < questions.length; index++) {
        final selected = questions[index].optionIds.indexOf(
          draft[questions[index].id] as String? ?? '',
        );
        if (selected >= 0) answers[index] = selected;
      }
    }

    final duration = ApiClient.responseInt(
      test['tempoMinutos'],
      endpoint: '/tests/attempt.teste.tempoMinutos',
    );
    final elapsed = ApiClient.responseInt(
      attempt['tempoConsumido'],
      endpoint: '/tests/attempt.tempoConsumido',
    );
    final finished = attempt['enviadoEm'] != null;
    final score = ApiMappers.number(attempt['notaFinal']);
    final totalCorrect = rows.where((row) => row['acertou'] == true).length;
    final result = !finished
        ? null
        : ExamResult(
            correct: totalCorrect,
            total: rows.length,
            score: score?.round() ?? 0,
            xp: 0,
            coins: 0,
            bySubject: const [],
            byTopic: const [],
          );

    return ExamSession(
      id: attemptId,
      title: test['tema'] as String? ?? 'Simulado',
      questions: questions,
      durationMinutes: duration,
      remainingSeconds: finished
          ? null
          : (duration * 60 - elapsed).clamp(0, duration * 60).toInt(),
      isActivity: test['tipo'] == 'ATIVIDADE',
      isFinished: finished,
      isReview: review,
      result: result,
      answers: answers,
    );
  }

  Future<List<Map<String, dynamic>>> history({
    String type = 'SIMULADO',
    int page = 1,
  }) async {
    final response = await _api.get(
      '/tests/attempts',
      query: {'pagina': page, 'limite': 30},
    );
    final data = ApiClient.responseMap(
      response,
      endpoint: '/tests/attempts',
      optional: true,
    );
    final attempts = ApiClient.responseList(
      data['dados'],
      endpoint: '/tests/attempts.dados',
    );
    return [
      for (final attempt in attempts)
        if ((attempt['teste'] as Map?)?['tipo'] == type)
          _historyItem(attempt),
    ];
  }

  Future<Map<String, dynamic>> monthlyGrades({
    int page = 1,
    int limit = 7,
  }) async {
    final endpoint = '/tests/attempts/grades/monthly';
    final response = await _api.get(
      endpoint,
      query: {'pagina': page, 'limite': limit},
    );
    return ApiClient.responseMap(response, endpoint: endpoint);
  }

  static Map<String, dynamic> _historyItem(Map<String, dynamic> attempt) {
    final test = attempt['teste'] as Map? ?? const {};
    final theme = test['tema'] as String?;
    final duration = (test['tempoMinutos'] as num?)?.toInt() ?? 0;
    final elapsed = (attempt['tempoConsumido'] as num?)?.toInt() ?? 0;
    final total = (test['quantidadeQuestoes'] as num?)?.toInt() ?? 0;
    final score = ApiMappers.number(attempt['notaFinal']);
    final finished = attempt['enviadoEm'] != null;
    return {
      ...attempt,
      'titulo': theme?.isNotEmpty == true ? theme : 'Simulado',
      'materias': theme == null || theme.isEmpty ? <String>[] : [theme],
      'status': finished ? 'FINALIZADO' : 'EM_ANDAMENTO',
      'finalizadoEm': attempt['enviadoEm'],
      'acertos': score == null || total == 0
          ? null
          : ((score / 100) * total).round(),
      'total': total,
      'expirado': !finished && duration > 0 && elapsed >= duration * 60,
    };
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
