import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';
import '../../../core/layout/app_scaffold.dart';
import '../widgets/dashboard_content.dart';

/// StatefulWidget
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  AppMenu selectedMenu = AppMenu.dashboard;
  bool sidebarExpanded = true;
  
  final TextEditingController searchController =
    TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey =
    GlobalKey<ScaffoldState>();

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
    return AppScaffold(
      selectedMenu: selectedMenu,
      sidebarExpanded: sidebarExpanded,
      searchController: searchController,
      onToggleSidebar: toggleSidebar,
      scaffoldKey: scaffoldKey,

      onMenuPressed: () {
        if (MediaQuery.of(context).size.width < 768) {
          scaffoldKey.currentState?.openDrawer();
        } else {
          toggleSidebar();
        }
      },

      onMenuSelected: (menu) {
        setState(() {
          selectedMenu = menu;
        });
      },

      child: DashboardContent(
        selectedMenu: selectedMenu,
      ),
    );
  }
}