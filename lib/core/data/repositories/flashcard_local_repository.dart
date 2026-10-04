import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/flashcards/flashcard_model.dart';

class LocalFlashcardRepository {
  LocalFlashcardRepository({String? userId}) : userId = userId ?? demoUserId;

  static const String demoUserId = 'demo-admin-001';
  static const String _storagePrefix = 'educano.flashcards.';

  final String userId;
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  String get _storageKey => '$_storagePrefix$userId';

  Future<List<Flashcard>> getAll() async {
    final raw = await _prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      final seed = _seedCards();
      await _save(seed);
      return seed;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Flashcard.fromJson(item as Map<String, dynamic>))
        .where((card) => card.userId == userId)
        .toList();
  }

  Future<void> create(Flashcard flashcard) async {
    final cards = await getAll();
    cards.add(flashcard);
    await _save(cards);
  }

  Future<void> update(Flashcard flashcard) async {
    final cards = await getAll();
    final index = cards.indexWhere((card) => card.id == flashcard.id);
    if (index == -1) return;
    cards[index] = flashcard;
    await _save(cards);
  }

  Future<void> delete(String id) async {
    final cards = await getAll();
    cards.removeWhere((card) => card.id == id);
    await _save(cards);
  }

  Future<Flashcard?> review(String id) async {
    final cards = await getAll();
    final index = cards.indexWhere((card) => card.id == id);
    if (index == -1) return null;

    final reviewed = cards[index].reviewedNow();
    cards[index] = reviewed;
    await _save(cards);
    return reviewed;
  }

  Future<void> _save(List<Flashcard> cards) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(cards.map((card) => card.toJson()).toList()),
    );
  }

  List<Flashcard> _seedCards() {
    return [
      _seed('Brasil - Geografia', 'Qual é a capital do Brasil?', 'Brasília.'),
      _seed('Multiplicação - Matemática', 'Quanto é 8 vezes 7?', '56.'),
      _seed('Lua - História', 'Em que ano o homem pisou na Lua pela primeira vez?', '1969.'),
      _seed('T. Periódica - Química', 'Qual é o símbolo químico da água?', 'H2O.'),
      _seed('Sistema Solar - Ciências', 'Qual é o maior planeta do sistema solar?', 'Júpiter.'),
      _seed('Brasil - Geografia', 'Quantos estados tem o Brasil?', '26 estados e um Distrito Federal.'),
      _seed('Literatura - Linguagens', 'Quem escreveu o livro "Dom Casmurro"?', 'Machado de Assis.'),
    ];
  }

  Flashcard _seed(String title, String question, String answer) {
    final now = DateTime(2026, 8, 10);
    return Flashcard(
      id: '${userId}_${title}_$question'.hashCode.toString(),
      userId: userId,
      title: title,
      question: question,
      answer: answer,
      monthlyRepetitions: 4,
      lastReviewedAt: now,
      nextReviewAt: now.add(const Duration(days: 7)),
    );
  }
}
