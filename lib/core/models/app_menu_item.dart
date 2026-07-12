import 'package:flutter/material.dart';

import '../auth/app_user_role.dart';
import '../navigation/app_menu.dart';

/// Modelo que representa um item de navegação.
class AppMenuItem {
  final AppMenu menu;
  final String title;
  final IconData icon;

  /// Perfis autorizados.
  /// Ainda não será utilizado para filtrar.
  final List<AppUserRole> roles;

  const AppMenuItem({
    required this.menu,
    required this.title,
    required this.icon,
    required this.roles,
  });
}