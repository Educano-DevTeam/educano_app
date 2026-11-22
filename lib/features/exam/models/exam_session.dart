import '../../course/models/course_models.dart';

/// Acertos de uma matéria ou tema no resultado do simulado.
class ExamAreaScore {
  const ExamAreaScore({required this.name, required this.correct, required this.total});

  final String name;
  final int correct;
  final int total;

  double get ratio => total == 0 ? 0 : correct / total;

  factory ExamAreaScore.fromApi(Map<String, dynamic> json) => ExamAreaScore(
    name: json['nome'] as String,
    correct: json['acertos'] as int,
    total: json['total'] as int,
  );
}

/// Resultado calculado pela API ao finalizar o simulado.
class ExamResult {
  const ExamResult({
    required this.correct,
    required this.total,
    required this.score,
    required this.xp,
    required this.coins,
    required this.bySubject,
    required this.byTopic,
  });

  final int correct;
  final int total;
  final int score;
  final int xp;
  final int coins;
  final List<ExamAreaScore> bySubject;
  final List<ExamAreaScore> byTopic;

  factory ExamResult.fromApi(Map<String, dynamic> json) => ExamResult(
    correct: json['acertos'] as int,
    total: json['total'] as int,
    score: json['nota'] as int,
    xp: json['xpGanho'] as int? ?? 0,
    coins: json['moedasGanhas'] as int? ?? 0,
    bySubject: (json['porMateria'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ExamAreaScore.fromApi)
        .toList(),
    byTopic: (json['porTema'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ExamAreaScore.fromApi)
        .toList(),
  );
}

class ExamSession {
  ExamSession({
    required this.title,
    required this.questions,
    required this.durationMinutes,
    this.id,
    this.remainingSeconds,
    this.isActivity = false,
    this.isReview = false,
    this.isFinished = false,
    this.result,
    Map<int, int> answers = const {},
    Map<int, int> eliminated = const {},
  }) : answers = Map<int, int>.from(answers),
       eliminated = Map<int, int>.from(eliminated);

  /// ID do simulado na API.
  final String? id;
  final String title;
  final List<ActivityQuestion> questions;
  final int durationMinutes;

  /// Tempo restante informado pela API ao abrir o simulado.
  final int? remainingSeconds;
  final bool isActivity;
  final bool isReview;
  final bool isFinished;
  final ExamResult? result;

  /// Índice da questão -> índice da alternativa escolhida.
  final Map<int, int> answers;

  /// Índice da questão -> alternativa eliminada pela Dica Extra.
  final Map<int, int> eliminated;

  int get answeredCount => answers.length;
  int get correctCount => result?.correct ??
      answers.entries
          .where(
            (entry) =>
                entry.key >= 0 &&
                entry.key < questions.length &&
                questions[entry.key].correctOptionIndex == entry.value,
          )
          .length;

  ExamSession asReview() => ExamSession(
    id: id,
    title: title,
    questions: questions,
    durationMinutes: durationMinutes,
    isActivity: isActivity,
    isReview: true,
    isFinished: isFinished,
    result: result,
    answers: answers,
    eliminated: eliminated,
  );
}
