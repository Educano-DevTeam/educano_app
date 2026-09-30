import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/widgets/ui/app_fab_menu.dart';

import '../widgets/dashboard_content.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AppScaffold(
          selectedMenu: AppMenu.dashboard,
          child: DashboardContent(
            selectedMenu: AppMenu.dashboard,
          ),
        ),

        Positioned(
          right: 24,
          bottom: 24,
          child: AppFabMenu(
            actions: [
              AppFabAction(
                label: 'Cadastrar Usuário',
                icon: Icons.person_add_alt_rounded,
                color: EducanoColors.primaryBlue,
                onPressed: () {
                  // Futuramente:
                  // NavigationService.pushNamed(
                  //   AppRoutes.dashboardUsers,
                  // );
                },
              ),

              AppFabAction(
                label: 'Cadastrar Curso',
                icon: Icons.school_rounded,
                color: EducanoColors.successGreen,
                onPressed: () {
                  // Futuramente abrir editor de curso.
                },
              ),

              AppFabAction(
                label: 'Cadastrar Questão',
                icon: Icons.quiz_rounded,
                color: EducanoColors.accentYellow,
                onPressed: () {
                  // Futuramente abrir editor de questão.
                },
              ),

              AppFabAction(
                label: 'Cadastrar Item',
                icon: Icons.store_rounded,
                color: const Color(0xFFE94B0C),
                onPressed: () {
                  // Futuramente abrir editor de item.
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}