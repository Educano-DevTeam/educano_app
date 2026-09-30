import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';
import '../views/dashboard_users_view.dart';

class DashboardUsersContent extends StatelessWidget {
  final AppMenu selectedMenu;

  const DashboardUsersContent({
    super.key,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedMenu) {
      case AppMenu.users:
        //return const DashboardUsersView();

      default:
        return const SizedBox.shrink();
    }
  }
}