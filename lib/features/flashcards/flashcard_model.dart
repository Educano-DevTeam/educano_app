class Flashcard {
  final String id;
  final String userId;
  final String title;
  final String question;
  final String answer;
  final int monthlyRepetitions;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;

  const Flashcard({
    required this.id,
    required this.userId,
    required this.title,
    required this.question,
    required this.answer,
    required this.monthlyRepetitions,
    this.lastReviewedAt,
    this.nextReviewAt,
  });

  Flashcard copyWith({
    String? id,
    String? userId,
    String? title,
    String? question,
    String? answer,
    int? monthlyRepetitions,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      monthlyRepetitions: monthlyRepetitions ?? this.monthlyRepetitions,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'question': question,
        'answer': answer,
        'monthlyRepetitions': monthlyRepetitions,
        'lastReviewedAt': lastReviewedAt?.toIso8601String(),
        'nextReviewAt': nextReviewAt?.toIso8601String(),
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: (json['title'] as String?) ?? 'Flashcard',
      question: json['question'] as String,
      answer: json['answer'] as String,
      monthlyRepetitions: (json['monthlyRepetitions'] as num?)?.toInt() ?? 4,
      lastReviewedAt: _date(json['lastReviewedAt']),
      nextReviewAt: _date(json['nextReviewAt']),
    );
  }

  static DateTime? _date(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// Regra provisória para o mock local:
  /// N revisões/mês => intervalo aproximado de 30/N dias.
  Flashcard reviewedNow() {
    final now = DateTime.now();
    final days = 30 / monthlyRepetitions.clamp(1, 30);
    final next = now.add(Duration(minutes: (days * 24 * 60).round()));

    return copyWith(
      lastReviewedAt: now,
      nextReviewAt: next,
    );
  }
}
