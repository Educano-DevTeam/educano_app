import 'package:flutter/material.dart';

import 'app_menu.dart';
import 'app_routes.dart';
import 'navigation_service.dart';

class AppNavigation {
  AppNavigation._();

  /// Menus que pertencem internamente ao Dashboard.
  static bool isDashboardMenu(AppMenu menu) {
    switch (menu) {
      case AppMenu.dashboard:
      case AppMenu.users:
      case AppMenu.courses:
      case AppMenu.questions:
      case AppMenu.store_inventory:
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
        _goTo(AppRoutes.home);
        break;

      case AppMenu.store_inventory:
        _goTo(AppRoutes.home);
        break;

      // ==============================================================
      // DASHBOARD
      // ==============================================================

      case AppMenu.dashboard:
      case AppMenu.users:
      case AppMenu.courses:
      case AppMenu.questions:
      case AppMenu.itens:
        _goToDashboard(menu);
        break;

      // ==============================================================
      // FUTURAS PÁGINAS
      // ==============================================================

      case AppMenu.profile:
        // Futuramente:
        // _goTo(AppRoutes.profile);
        break;

      case AppMenu.settings:
        // Futuramente:
        // _goTo(AppRoutes.settings);
        break;

      // ==============================================================
      // LOGOUT
      // ==============================================================

      case AppMenu.logout:
        _logout(context);
        break;
    }
  }

  /// Abre o Dashboard já selecionando uma seção específica.
  static void _goToDashboard(AppMenu menu) {
    NavigationService.pushReplacementNamed(
      AppRoutes.dashboard,
      arguments: menu,
    );
  }

  static void _goTo(String route) {
    NavigationService.pushReplacementNamed(route);
  }

  static void _logout(BuildContext context) {
    // Futuramente:
    // limpar sessão/token
    // redirecionar para login
  }
}
