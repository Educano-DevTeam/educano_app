import 'api_client.dart';

/// Progresso do aluno, ranking, planos e resumo do dashboard.
class ProgressService {
  ProgressService._();

  static final ProgressService instance = ProgressService._();

  final _api = ApiClient.instance;

  /// Estatísticas do usuário logado (nível, XP, cursos, desempenho).
  Future<Map<String, dynamic>> me() async => ApiClient.responseMap(
    await _api.get('/progress/me'),
    endpoint: '/progress/me',
  );

  Future<Map<String, dynamic>> ranking({int page = 1}) async =>
      ApiClient.responseMap(
        await _api.get('/ranking', query: {'page': page}),
        endpoint: '/ranking',
      );

  Future<Map<String, dynamic>> plans() async =>
      ApiClient.responseMap(await _api.get('/plans'), endpoint: '/plans');

  Future<String> subscribe(String planId) async {
    final response = await _api.post('/plans/$planId/subscribe');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/plans/$planId/subscribe',
    );
    return ApiClient.responseString(
          data['message'],
          endpoint: '/plans/$planId/subscribe.message',
        ) ??
        'Plano alterado.';
  }

  Future<Map<String, dynamic>> dashboardSummary() async =>
      ApiClient.responseMap(
        await _api.get('/dashboard/summary'),
        endpoint: '/dashboard/summary',
      );
}
