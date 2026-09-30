import 'package:educano_app/features/dashboard/widgets/dashboard_courses_content.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/navigation/app_navigation.dart';

class DashboardCoursesPage extends StatefulWidget {
  const DashboardCoursesPage({super.key});
  @override
  State<DashboardCoursesPage> createState() => _DashboardCoursesPageState();
}

class _DashboardCoursesPageState extends State<DashboardCoursesPage> {
  AppMenu selectedMenu = AppMenu.courses;
  bool sidebarExpanded = true;

  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedMenu: AppMenu.courses,
      child: DashboardCoursesContent(selectedMenu: selectedMenu),
    );
  }
}
