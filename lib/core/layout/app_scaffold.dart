import 'package:flutter/material.dart';

import '../navigation/app_menu.dart';
import '../theme/theme.dart';
import 'responsive_layout.dart';

import '../widgets/app_header.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_bottom_navigation.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final AppMenu selectedMenu;
  final bool sidebarExpanded;
  final TextEditingController searchController;
  final ValueChanged<AppMenu> onMenuSelected;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onMenuPressed;

  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppScaffold({
    super.key,
    required this.child,
    required this.selectedMenu,
    required this.sidebarExpanded,
    required this.searchController,
    required this.onMenuSelected,
    required this.onMenuPressed,
    required this.scaffoldKey,
    this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: Scaffold(
        key: scaffoldKey,
        drawer: AppSidebar(
          isMobile: true,
          selectedMenu: selectedMenu,
          sidebarExpanded: true,
          onMenuSelected: (menu) {
            onMenuSelected(menu);
            Navigator.pop(context);
          },
        ),

        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                isMobile: true,
                onMenuPressed: onMenuPressed,
                searchController: searchController,
              ),

              Expanded(child: child),

              AppBottomNavigation(selectedMenu: selectedMenu, onItemSelected: onMenuSelected)
            ],
          ),
        ),
      ),

      contentMaxWidht: Scaffold(
        backgroundColor: EducanoColors.background,
        key: scaffoldKey,

        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                isMobile: false,
                onMenuPressed: onMenuPressed,
                searchController: searchController,
              ),

              Expanded(
                child: Row(
                  children: [
                    AppSidebar(
                      isMobile: false,
                      selectedMenu: selectedMenu,
                      sidebarExpanded: sidebarExpanded,
                      onToggleSidebar: onToggleSidebar,
                      onMenuSelected: onMenuSelected,
                    ),

                    Expanded(
                      child: child,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}