import '../core/utils/api_mappers.dart';
import '../features/course/models/course_models.dart';
import 'api_client.dart';

class QuestionPage {
  final List<ActivityQuestion> questions;
  final List<String> subjects;
  final int page;
  final int totalPages;
  final int total;

  const QuestionPage({
    required this.questions,
    required this.subjects,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

/// Banco de questões (somente equipe: admin, professor e parceiro).
class QuestionsService {
  QuestionsService._();

  static final QuestionsService instance = QuestionsService._();

  final _api = ApiClient.instance;

  Future<QuestionPage> list({
    int page = 1,
    String? search,
    String? difficulty,
    String? subject,
    int? alternatives,
    bool onlyMine = false,
  }) async {
    final data = await _api.get('/questions', query: {
      'page': page,
      'busca': search,
      'dificuldade': difficulty,
      'materia': subject == null ? null : ApiMappers.subjectValue(subject),
      'alternativas': alternatives,
      if (onlyMine) 'minhas': 'true',
    }) as Map<String, dynamic>;

    final pagination = data['paginacao'] as Map<String, dynamic>;

    return QuestionPage(
      questions: (data['dados'] as List)
          .cast<Map<String, dynamic>>()
          .map(ApiMappers.question)
          .toList(),
      subjects: ApiMappers.subjects.values.toList(),
      page: pagination['pagina'] as int,
      totalPages: pagination['totalPaginas'] as int,
      total: pagination['total'] as int,
    );
  }

  Future<ActivityQuestion> create(ActivityQuestion question) async {
    final data = await _api.post('/questions', ApiMappers.questionPayload(question))
        as Map<String, dynamic>;
    return ApiMappers.question(data['questao'] as Map<String, dynamic>);
  }

  Future<ActivityQuestion> update(ActivityQuestion question) async {
    final data = await _api.put(
      '/questions/${question.id}',
      ApiMappers.questionPayload(question),
    ) as Map<String, dynamic>;
    return ApiMappers.question(data['questao'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _api.delete('/questions/$id');

  Future<Map<String, dynamic>> report() async =>
      await _api.get('/questions/report') as Map<String, dynamic>;
}
