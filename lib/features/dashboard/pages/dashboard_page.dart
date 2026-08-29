import 'package:flutter/material.dart';

import '../../../core/theme/educano_colors.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/widgets/ui/app_fab_menu.dart';
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
    final isMobile = MediaQuery.of(context).size.width <= 500;

    return Stack(
      children: [
        AppScaffold(
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

          child: DashboardContent(selectedMenu: selectedMenu),
        ),

        // ============================================================
        // FAB GLOBAL DA DASHBOARD
        // ============================================================
        Positioned(
          right: isMobile ? 16 : 24,

          // Mobile: sobe o FAB para não ficar sobre
          // o BottomNavigation.
          bottom: isMobile ? 95 : 24,

          child: AppFabMenu(
            actions: [
              AppFabAction(
                label: 'Cadastrar Usuário',
                icon: Icons.person_add_alt_rounded,
                color: EducanoColors.primaryBlue,
                onPressed: () {
                  // TODO
                },
              ),

              AppFabAction(
                label: 'Cadastrar Curso',
                icon: Icons.school_rounded,
                color: EducanoColors.successGreen,
                onPressed: () {
                  // TODO
                },
              ),

              AppFabAction(
                label: 'Cadastrar Questão',
                icon: Icons.quiz_rounded,
                color: EducanoColors.accentYellow,
                onPressed: () {
                  // TODO
                },
              ),

              AppFabAction(
                label: 'Cadastrar Item',
                icon: Icons.store_rounded,
                color: const Color(0xFFE94B0C),
                onPressed: () {
                  // TODO
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
