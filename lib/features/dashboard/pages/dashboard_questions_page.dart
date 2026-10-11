import 'package:flutter/material.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../widgets/dashboard_questions_content.dart';

class DashboardQuestionsPage extends StatelessWidget {
  const DashboardQuestionsPage({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    selectedMenu: AppMenu.questionsListage,
    child: const DashboardQuestionsContent(
      selectedMenu: AppMenu.questionsListage,
    ),
  );
}
