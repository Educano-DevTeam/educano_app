import 'exam_session.dart';

class ExamHistoryRecord {
  const ExamHistoryRecord({required this.session, required this.finishedAt});
  final ExamSession session;
  final DateTime finishedAt;
}

class ExamHistoryStore {
  ExamHistoryStore._();
  static final List<ExamHistoryRecord> records = [];

  static void add(ExamSession session) {
    if (session.isActivity) return;
    records.insert(0, ExamHistoryRecord(session: session, finishedAt: DateTime.now()));
  }
}
