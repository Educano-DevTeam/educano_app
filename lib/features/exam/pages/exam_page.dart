import 'package:flutter/material.dart';
import '../models/exam_session.dart';
import '../widgets/exam_page_content.dart';

class ExamPage extends StatelessWidget {
  const ExamPage({super.key, required this.session});
  final ExamSession session;
  @override
  Widget build(BuildContext context) => ExamPageContent(session: session);
}
