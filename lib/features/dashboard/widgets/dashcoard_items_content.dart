import 'package:educano_app/core/navigation/app_menu.dart';
import 'package:flutter/material.dart';

import '../views/dashboard_Items_view.dart';

class DashboardItemsContent extends StatelessWidget {
  final AppMenu selectedMenu;
  
  const DashboardItemsContent({
    super.key,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    switch(selectedMenu){
         case AppMenu.itens:
          return const DashboardItemsView();
        default:
          return const SizedBox();
      }
  }
}