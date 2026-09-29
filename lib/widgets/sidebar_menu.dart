import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class _SidebarMenuItem {
  final IconData icon;
  final String label;
  final String route;
  const _SidebarMenuItem(this.icon, this.label, this.route);
}

/// Reproduz o menu lateral do protótipo (seções PRINCIPAL, DASHBOARD e
/// OUTRAS OPÇÕES). É usado tanto como painel fixo (web) quanto como
/// conteúdo do Drawer (mobile).
class SidebarMenu extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onSelect;

  const SidebarMenu({super.key, required this.currentRoute, required this.onSelect});

  static const List<_SidebarMenuItem> _principal = [
    _SidebarMenuItem(Icons.home_outlined, 'Home', '/home'),
    _SidebarMenuItem(Icons.style_outlined, 'Flashcards', '/flashcards'),
    _SidebarMenuItem(Icons.emoji_events_outlined, 'Ranking', '/ranking'),
    _SidebarMenuItem(Icons.person_outline, 'Perfil', '/perfil'),
  ];

  static const List<_SidebarMenuItem> _dashboard = [
    _SidebarMenuItem(Icons.dashboard_outlined, 'Painel', '/painel'),
    _SidebarMenuItem(Icons.group_outlined, 'Usuários', '/usuarios'),
    _SidebarMenuItem(Icons.menu_book_outlined, 'Cursos', '/cursos'),
    _SidebarMenuItem(Icons.quiz_outlined, 'Questões', '/questoes'),
    _SidebarMenuItem(Icons.storefront_outlined, 'Loja', '/loja'),
  ];

  static const List<_SidebarMenuItem> _outras = [
    _SidebarMenuItem(Icons.settings_outlined, 'Configurações', '/configuracoes'),
    _SidebarMenuItem(Icons.logout, 'Logout', '/logout'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _sectionTitle('PRINCIPAL'),
          ..._principal.map(_buildItem),
          const SizedBox(height: 12),
          _sectionTitle('DASHBOARD'),
          ..._dashboard.map(_buildItem),
          const SizedBox(height: 12),
          _sectionTitle('OUTRAS OPÇÕES'),
          ..._outras.map(_buildItem),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildItem(_SidebarMenuItem item) {
    final bool selected = item.route == currentRoute;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onSelect(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(item.icon, size: 19, color: selected ? Colors.white : AppColors.textPrimary),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
