import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';
import '../views/dashboard_questions_view.dart';

class DashboardQuestionsContent extends StatelessWidget {
  final AppMenu selectedMenu;

  const DashboardQuestionsContent({
    super.key,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedMenu) {
      case AppMenu.questionsListage:
        return const DashboardQuestionsView();

      default:
        return const SizedBox.shrink();
    }
  }
}
