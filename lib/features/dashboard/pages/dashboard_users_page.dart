import 'package:flutter/material.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../widgets/dashboard_users_content.dart';

class DashboardUsersPage extends StatelessWidget {
  const DashboardUsersPage({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    selectedMenu: AppMenu.usersListage,
    child: const DashboardUsersContent(selectedMenu: AppMenu.usersListage),
  );
}
