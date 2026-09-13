import 'package:educano_app/core/navigation/app_navigation.dart';
import 'package:educano_app/features/dashboard/views/course_editor_view.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/widgets/ui/app_fab_menu.dart';
import '../widgets/dashboard_content.dart';

/// StatefulWidget
class DashboardPage extends StatefulWidget {
  final AppMenu initialMenu;

  const DashboardPage({super.key, this.initialMenu = AppMenu.dashboard});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late AppMenu selectedMenu;
  bool sidebarExpanded = true;

  final TextEditingController searchController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    selectedMenu = widget.initialMenu;
  }

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

    return Stack(
      children: [
        AppScaffold(
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
            if (AppNavigation.isDashboardMenu(menu)) {
              setState(() {
                selectedMenu = menu;
              });
            } else {
              AppNavigation.onMenuSelected(context, menu);
            }
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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CourseEditorView()),
                  );

                  if (result != null) {
                    // Futuramente atualizar os dados do dashboard.
                  }
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
