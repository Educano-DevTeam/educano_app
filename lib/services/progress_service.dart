import 'api_client.dart';

/// Progresso do aluno, ranking, planos e resumo do dashboard.
class ProgressService {
  ProgressService._();

  static final ProgressService instance = ProgressService._();

  final _api = ApiClient.instance;

  /// Estatísticas do usuário logado (nível, XP, cursos, desempenho).
  Future<Map<String, dynamic>> me() async =>
      await _api.get('/progress/me') as Map<String, dynamic>;

  Future<Map<String, dynamic>> ranking({int page = 1}) async =>
      await _api.get('/ranking', query: {'page': page}) as Map<String, dynamic>;

  Future<Map<String, dynamic>> plans() async =>
      await _api.get('/plans') as Map<String, dynamic>;

  Future<String> subscribe(String planId) async {
    final data = await _api.post('/plans/$planId/subscribe') as Map<String, dynamic>;
    return data['message'] as String? ?? 'Plano alterado.';
  }

  Future<Map<String, dynamic>> dashboardSummary() async =>
      await _api.get('/dashboard/summary') as Map<String, dynamic>;
}
