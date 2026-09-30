import 'package:educano_app/features/dashboard/widgets/dashcoard_items_content.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/navigation/app_navigation.dart';

class DashboardItemsPage extends StatefulWidget {
  const DashboardItemsPage({super.key});
  @override
  State<DashboardItemsPage> createState() => _DashboardItemsPageState();
}

class _DashboardItemsPageState extends State<DashboardItemsPage> {
  AppMenu selectedMenu = AppMenu.itens;
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
      selectedMenu: AppMenu.itens,
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

      child: DashboardItemsContent(selectedMenu: selectedMenu),
    );
  }
}
