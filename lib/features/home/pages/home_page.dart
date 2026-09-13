import 'package:educano_app/core/constants/app_breakpoints.dart';
import 'package:educano_app/features/home/widgets/home_content.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/layout/app_scaffold.dart';

/// StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppMenu selectedMenu = AppMenu.home;
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
    final isMobile = MediaQuery.of(context).size.width <= AppBreakpoints.mobile;

    return AppScaffold(
      selectedMenu: selectedMenu,
      sidebarExpanded: sidebarExpanded,
      searchController: searchController,
      onToggleSidebar: toggleSidebar,
      scaffoldKey: scaffoldKey,

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

      child: HomeContent(selectedMenu: selectedMenu),
    );
  }
}
