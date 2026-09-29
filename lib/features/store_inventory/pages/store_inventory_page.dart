import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/navigation/app_navigation.dart';
import '../widgets/store_inventory_content.dart';

class StoreInventoryPage extends StatefulWidget {
  const StoreInventoryPage({super.key});

  @override
  State<StoreInventoryPage> createState() => _StoreInventoryPageState();
}

class _StoreInventoryPageState extends State<StoreInventoryPage> {
  bool _sidebarExpanded = true;

  final TextEditingController searchController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void toggleSidebar() {
    setState(() {
      _sidebarExpanded = !_sidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final isMobile = width <= AppBreakpoints.mobile;

    return AppScaffold(
      selectedMenu: AppMenu.storeInventory,
      sidebarExpanded: _sidebarExpanded,
      scaffoldKey: _scaffoldKey,

      onToggleSidebar: () {
        setState(() {
          _sidebarExpanded = !_sidebarExpanded;
        });
      },

      onMenuPressed: () {
        if (isMobile) {
          _scaffoldKey.currentState?.openDrawer();
        } else {
          setState(() {
            _sidebarExpanded = !_sidebarExpanded;
          });
        }
      },

      onMenuSelected: (menu) {
        AppNavigation.onMenuSelected(context, menu);
      },

      searchController: searchController,
      child: const StoreInventoryContent(selectedMenu: AppMenu.storeInventory),
    );
  }
}
