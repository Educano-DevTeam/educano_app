import '../../course/models/course_models.dart';

class ExamSession {
  ExamSession({
    required this.title,
    required this.questions,
    required this.durationMinutes,
    this.isActivity = false,
    this.isReview = false,
    Map<int, int> answers = const {},
  }) : answers = Map<int, int>.from(answers);

  final String title;
  final List<ActivityQuestion> questions;
  final int durationMinutes;
  final bool isActivity;
  final bool isReview;
  final Map<int, int> answers;

  int get answeredCount => answers.length;
  int get correctCount => answers.entries
      .where((entry) => questions[entry.key].correctOptionIndex == entry.value)
      .length;
}
