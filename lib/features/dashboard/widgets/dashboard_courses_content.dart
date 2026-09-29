import 'package:educano_app/core/navigation/app_menu.dart';
import 'package:flutter/material.dart';

import '../views/dashboard_courses_view.dart';

class DashboardCoursesContent extends StatelessWidget {
  final AppMenu selectedMenu;
  
  const DashboardCoursesContent({
    super.key,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    switch(selectedMenu){
         case AppMenu.courses:
          return const DashboardCoursesView();
        default:
          return const SizedBox();
      }
  }
}