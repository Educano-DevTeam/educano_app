import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../widgets/dashboard_items_content.dart';

class DashboardItemsPage extends StatelessWidget {
  const DashboardItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedMenu: AppMenu.itens,
      child: const DashboardItemsContent(),
    );
  }
}