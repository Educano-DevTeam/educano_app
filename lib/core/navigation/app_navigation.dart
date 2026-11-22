import 'package:flutter/material.dart';

import 'app_menu.dart';
import 'app_routes.dart';
import 'navigation_service.dart';
import '../../services/auth_service.dart';

class AppNavigation {
  AppNavigation._();

  /// Menus que pertencem internamente ao Dashboard.
  static bool isDashboardMenu(AppMenu menu) {
    switch (menu) {
      case AppMenu.dashboard:
      case AppMenu.usersListage:
      case AppMenu.coursesListage:
      case AppMenu.questionsListage:
      case AppMenu.itensListage:
        return true;

      default:
        return false;
    }
  }

  /// Navegação global da aplicação.
  static void onMenuSelected(BuildContext context, AppMenu menu) {
    switch (menu) {
      // ==============================================================
      // HOME
      // ==============================================================

      case AppMenu.home:
        _goTo(AppRoutes.home);
        break;

      case AppMenu.flashcards:
        _goTo(AppRoutes.flashcards);
        break;

      case AppMenu.ranking:
        _goTo(AppRoutes.ranking);
        break;

      case AppMenu.storeInventory:
        _goTo(AppRoutes.storeInventory);
        break;

      case AppMenu.profile:
        _goTo(AppRoutes.profile);
        break;

      case AppMenu.settings:
        _goTo(AppRoutes.settings);
        break;

      case AppMenu.course:
        _goTo(AppRoutes.course);
        break;

      case AppMenu.courses:
        _goTo(AppRoutes.courses);
        break;

      case AppMenu.accountPlan:
        _goTo(AppRoutes.accountPlan);
        break;
      case AppMenu.material:
        _goTo(AppRoutes.material);
        break;
      case AppMenu.lastExams:
        _goTo(AppRoutes.lastExams);
        break;
      case AppMenu.examConfig:
        _goTo(AppRoutes.examConfig);
        break;
      case AppMenu.exam:
        _goTo(AppRoutes.exam);
        break;
      case AppMenu.activity:
        _goTo(AppRoutes.activity);
        break;
      case AppMenu.examFinish:
        _goTo(AppRoutes.examFinish);
        break;
      case AppMenu.examResult:
        _goTo(AppRoutes.examResult);
        break;

      // ==============================================================
      // DASHBOARD
      // ==============================================================

      case AppMenu.dashboard:
        _goTo(AppRoutes.dashboard);
        break;

      case AppMenu.usersListage:
        _goTo(AppRoutes.dashboardUsers);
        break;
      case AppMenu.coursesListage:
        _goTo(AppRoutes.dashboardCourses);
        break;
      case AppMenu.questionsListage:
        _goTo(AppRoutes.dashboardQuestions);
        break;
      case AppMenu.itensListage:
        _goTo(AppRoutes.dashboardItems);
        break;

      // ==============================================================
      // LOGOUT
      // ==============================================================

      case AppMenu.logout:
        _confirmLogout(context);
        break;
    }
  }

  static void _goTo(String route) {
    NavigationService.pushReplacementNamed(route);
  }

  static Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Deseja realmente encerrar sua sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await _logout(context);
  }

  static Future<void> _logout(BuildContext context) async {
    try {
      final remoteError = await AuthService.instance.logout();
      if (context.mounted) {
        if (remoteError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sessão encerrada localmente; falha ao revogar no servidor: '
                '${remoteError.message}',
              ),
            ),
          );
        }
        NavigationService.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível encerrar a sessão: $error')),
      );
    }
  }
}
