import '../../../features/flashcards/flashcard_model.dart';
import '../../../services/api_client.dart';

/// Flashcards do usuário logado, guardados na API (privados por conta).
class FlashcardRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<Flashcard>> getAll() async {
    final data = await _api.get('/flashcards') as Map<String, dynamic>;
    return (data['dados'] as List)
        .cast<Map<String, dynamic>>()
        .map(Flashcard.fromApi)
        .toList();
  }

  Future<Flashcard> create(Flashcard flashcard) async {
    final data = await _api.post('/flashcards', flashcard.toApi()) as Map<String, dynamic>;
    return Flashcard.fromApi(data['flashcard'] as Map<String, dynamic>);
  }

  Future<Flashcard> update(Flashcard flashcard) async {
    final data = await _api.patch('/flashcards/${flashcard.id}', flashcard.toApi())
        as Map<String, dynamic>;
    return Flashcard.fromApi(data['flashcard'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _api.delete('/flashcards/$id');

  Future<Flashcard?> review(String id) async {
    final data = await _api.post('/flashcards/$id/visualizar') as Map<String, dynamic>;
    return Flashcard.fromApi(data['flashcard'] as Map<String, dynamic>);
  }
}
