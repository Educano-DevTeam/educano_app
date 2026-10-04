import 'package:flutter/material.dart';

import '../navigation/app_menu.dart';
import '../navigation/app_navigation.dart';
import '../theme/theme.dart';
import 'responsive_layout.dart';

import '../widgets/components/app_header.dart';
import '../widgets/components/app_sidebar.dart';
import '../widgets/components/app_bottom_navigation.dart';
import '../../features/materials/widgets/course_mini_audio_player.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;
  final AppMenu selectedMenu;

  const AppScaffold({
    super.key,
    required this.child,
    required this.selectedMenu,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _sidebarExpanded = true;

  final TextEditingController _searchController =
      TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarExpanded = !_sidebarExpanded;
    });
  }

  void _handleMenuSelected(AppMenu menu) {
    AppNavigation.onMenuSelected(context, menu);
  }

  void _handleMenuPressed(bool isMobile) {
    if (isMobile) {
      _scaffoldKey.currentState?.openDrawer();
      return;
    }

    _toggleSidebar();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      desktopBody: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: EducanoColors.background,
      drawer: AppSidebar(
        isMobile: true,
        selectedMenu: widget.selectedMenu,
        sidebarExpanded: true,
        onMenuSelected: (menu) {
          Navigator.pop(context);
          _handleMenuSelected(menu);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              isMobile: true,
              onMenuPressed: () => _handleMenuPressed(true),
              searchController: _searchController,
            ),

            Expanded(
              child: Stack(children: [
                Positioned.fill(child: widget.child),
                const Positioned(left: 0, right: 0, bottom: 0, child: CourseMiniAudioPlayer()),
              ]),
            ),

            AppBottomNavigation(
              selectedMenu: widget.selectedMenu,
              onItemSelected: _handleMenuSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: EducanoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              isMobile: false,
              onMenuPressed: () => _handleMenuPressed(false),
              searchController: _searchController,
            ),

            Expanded(
              child: Row(
                children: [
                  AppSidebar(
                    isMobile: false,
                    selectedMenu: widget.selectedMenu,
                    sidebarExpanded: _sidebarExpanded,
                    onToggleSidebar: _toggleSidebar,
                    onMenuSelected: _handleMenuSelected,
                  ),

                  Expanded(
                    child: Stack(children: [
                      Positioned.fill(child: widget.child),
                      const Positioned(left: 0, right: 0, bottom: 0, child: CourseMiniAudioPlayer()),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
