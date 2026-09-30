import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../widgets/dashboard_courses_content.dart';

class DashboardCoursesPage extends StatelessWidget {
  const DashboardCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      selectedMenu: AppMenu.courses,
      child: DashboardCoursesContent(),
    );
  }
}