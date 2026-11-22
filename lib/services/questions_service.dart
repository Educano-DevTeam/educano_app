import '../core/utils/api_mappers.dart';
import '../features/course/models/course_models.dart';
import 'api_client.dart';

class QuestionPage {
  final List<ActivityQuestion> questions;
  final int page;
  final int totalPages;
  final int total;

  const QuestionPage({
    required this.questions,
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
    String? theme,
    int limit = 30,
  }) async {
    final response = await _api.get(
      '/questions',
      query: {
        'pagina': page,
        'limite': limit,
        'busca': search,
        'dificuldade': difficulty,
        'tema': theme?.trim().toLowerCase(),
      },
    );
    final data = ApiClient.responseMap(
      response,
      endpoint: '/questions',
      optional: true,
    );

    final pagination = ApiClient.responseMap(
      data['paginacao'],
      endpoint: '/questions.paginacao',
      optional: true,
    );

    return QuestionPage(
      questions: ApiClient.parseResponse(
        '/questions',
        () => ApiClient.responseList(
          data['dados'],
          endpoint: '/questions.dados',
        ).map(ApiMappers.question).toList(),
      ),
      page: ApiClient.responseInt(
        pagination['pagina'],
        endpoint: '/questions.paginacao.pagina',
        fallback: page,
      ),
      totalPages: ApiClient.responseInt(
        pagination['totalPaginas'],
        endpoint: '/questions.paginacao.totalPaginas',
      ),
      total: ApiClient.responseInt(
        pagination['total'],
        endpoint: '/questions.paginacao.total',
      ),
    );
  }

  /// Temas disponíveis para os filtros de telas que podem consultar o banco.
  Future<List<String>> themes() async {
    final firstPage = await list(page: 1, limit: 100);
    final questions = [...firstPage.questions];
    for (var page = 2; page <= firstPage.totalPages; page++) {
      questions.addAll((await list(page: page, limit: 100)).questions);
    }
    final themes = <String>{};
    for (final question in questions) {
      final theme = question.topic.trim().toLowerCase();
      if (theme.isNotEmpty) themes.add(theme);
    }
    return themes.toList()..sort();
  }

  Future<ActivityQuestion> create(ActivityQuestion question) async {
    final response = await _api.post(
      '/questions',
      ApiMappers.questionPayload(question),
    );
    final data = ApiClient.responseMap(response, endpoint: '/questions');
    return ApiClient.parseResponse(
      '/questions',
      () => ApiMappers.question(
        ApiClient.responseMap(data['questao'], endpoint: '/questions.questao'),
      ),
    );
  }

  Future<ActivityQuestion> update(ActivityQuestion question) async {
    final response = await _api.patch(
      '/questions/${question.id}',
      ApiMappers.questionPayload(question),
    );
    final data = ApiClient.responseMap(
      response,
      endpoint: '/questions/${question.id}',
    );
    return ApiClient.parseResponse(
      '/questions/${question.id}',
      () => ApiMappers.question(
        ApiClient.responseMap(
          data['questao'],
          endpoint: '/questions/${question.id}.questao',
        ),
      ),
    );
  }

  Future<void> delete(String id) => _api.delete('/questions/$id');

  Future<Map<String, dynamic>> report() async => ApiClient.responseMap(
    await _api.get('/questions/report'),
    endpoint: '/questions/report',
  );
}
