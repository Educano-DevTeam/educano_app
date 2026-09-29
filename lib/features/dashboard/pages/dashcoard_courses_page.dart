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

  void toggleSidebar() {
    setState(() {
      sidebarExpanded = !sidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width <= AppBreakpoints.mobile;

    return AppScaffold(
      selectedMenu: AppMenu.courses,
      sidebarExpanded: sidebarExpanded,
      searchController: searchController,
      scaffoldKey: scaffoldKey,

      onToggleSidebar: toggleSidebar,

      onMenuPressed: () {
        if (isMobile) {
          scaffoldKey.currentState?.openDrawer();
        } else {
          toggleSidebar();
        }
      },

      onMenuSelected: (menu) {
        AppNavigation.onMenuSelected(context, menu);
      },

      child: DashboardCoursesContent(selectedMenu: selectedMenu),
    );
  }
}
