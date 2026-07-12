import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';
import '../views/dashboard_home_view.dart';

class DashboardContent extends StatelessWidget {
   final AppMenu selectedMenu;

   const DashboardContent({
      super.key,
      required this.selectedMenu,
   });

   @override
   Widget build(BuildContext context) {

      switch(selectedMenu){
         case AppMenu.dashboard:
          return const DashboardHomeView();
        // case AppMenu.users:
        //   return const DashboardUsersView();
        // case AppMenu.courses:
        //   return const DashboardCoursesView();
        // case AppMenu.questions:
        //   return const DashboardQuestionsView();
        // case AppMenu.store:
        //   return const DashboardItemsView();
        default:
          return const SizedBox();
      }
   }
}