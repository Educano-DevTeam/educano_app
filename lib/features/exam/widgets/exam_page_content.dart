import 'package:flutter/material.dart';
import '../models/exam_session.dart';
import '../views/exam_view.dart';

class ExamPageContent extends StatelessWidget {
  const ExamPageContent({super.key, required this.session});
  final ExamSession session;
  @override
  Widget build(BuildContext context) => ExamView(session: session);
}
