import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';
import '../views/dashboard_courses_view.dart';
import '../views/dashboard_home_view.dart';
import '../views/dashboard_items_view.dart';
import '../../student/views/account_plan_view.dart';
import '../../student/views/student_progress_view.dart';
import '../../student/views/student_store_view.dart';

class DashboardContent extends StatelessWidget {
  final AppMenu selectedMenu;

  const DashboardContent({
    super.key,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedMenu) {
      // Dashboard (admin)
      case AppMenu.dashboard:
        return const DashboardHomeView();
      case AppMenu.courses:
        return const DashboardCoursesView();

      // Student screens
      case AppMenu.home:
        return const StudentProgressView();
      case AppMenu.store:
        return const StudentStoreView();
      case AppMenu.storeItems:
        return const DashboardItemsView();
      case AppMenu.profile:
        return const AccountPlanView();

      // Não implementados ainda (outras tarefas da equipe)
      // case AppMenu.users:  return const DashboardUsersView();
      // case AppMenu.questions: return const DashboardQuestionsView();

      default:
        return const SizedBox();
    }
  }
}
