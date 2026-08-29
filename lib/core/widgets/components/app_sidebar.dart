import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../navigation/app_menu.dart';
import 'sidebar_item.dart';
import 'sidebar_section.dart';

class AppSidebar extends StatelessWidget {
  final AppMenu selectedMenu;
  final bool sidebarExpanded;

  final ValueChanged<AppMenu> onMenuSelected;
  final VoidCallback? onToggleSidebar;
  
  final bool isMobile;

  const AppSidebar({
    super.key,
    required this.isMobile,
    required this.selectedMenu,
    required this.sidebarExpanded,
    required this.onMenuSelected,
    this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {

    final double sidebarWidth =
        sidebarExpanded ? 260 : 80;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: sidebarWidth,

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(
          right: BorderSide(
            color: EducanoColors.border,
          ),
        ),
      ),

      child: Column(
        children: [
          Divider(
            color: EducanoColors.border,
            height: 1,
          ),

          // Espaço reservado para os menus
          Expanded(
            child: ListView(
              children: [
                if (!isMobile)
                  SidebarSection(
                    title: "Principal",
                    expanded: sidebarExpanded,
                    children: [

                      SidebarItem(
                        icon: Icons.home,
                        title: "Home",
                        menu: AppMenu.home,
                        selectedMenu: selectedMenu,
                        expanded: sidebarExpanded,
                        onTap: () => onMenuSelected(AppMenu.home),
                      ),
                      SidebarItem(
                        icon: Icons.style_rounded,
                        title: "Flashcards",
                        menu: AppMenu.flashcards,
                        selectedMenu: selectedMenu,
                        expanded: sidebarExpanded,
                        onTap: () => onMenuSelected(AppMenu.flashcards),
                      ),
                      SidebarItem(
                        icon: Icons.emoji_events_rounded,
                        title: "Ranking",
                        menu: AppMenu.ranking,
                        selectedMenu: selectedMenu,
                        expanded: sidebarExpanded,
                        onTap: () => onMenuSelected(AppMenu.ranking),
                      ),
                      SidebarItem(
                        icon: Icons.person_rounded,
                        title: "Perfil",
                        menu: AppMenu.profile,
                        selectedMenu: selectedMenu,
                        expanded: sidebarExpanded,
                        onTap: () => onMenuSelected(AppMenu.profile),
                      ),
                    ],
                  ),

                SidebarSection(
                  title: "Dashboard",
                  expanded: sidebarExpanded,
                  children: [

                    SidebarItem(
                      icon: Icons.dashboard_rounded,
                      title: "Painel",
                      menu: AppMenu.dashboard,
                      selectedMenu: selectedMenu,
                      expanded: sidebarExpanded,
                      onTap: () => onMenuSelected(AppMenu.dashboard),
                    ),
                    SidebarItem(
                      icon: Icons.group_rounded,
                      title: "Usuários",
                      menu: AppMenu.users,
                      selectedMenu: selectedMenu,
                      expanded: sidebarExpanded,
                      onTap: () => onMenuSelected(AppMenu.users),
                    ),
                    SidebarItem(
                      icon: Icons.school_rounded,
                      title: "Cursos",
                      menu: AppMenu.courses,
                      selectedMenu: selectedMenu,
                      expanded: sidebarExpanded,
                      onTap: () => onMenuSelected(AppMenu.courses),
                    ),
                    SidebarItem(
                      icon: Icons.quiz_rounded,
                      title: "Questões",
                      menu: AppMenu.questions,
                      selectedMenu: selectedMenu,
                      expanded: sidebarExpanded,
                      onTap: () => onMenuSelected(AppMenu.questions),
                    ),
                    SidebarItem(
                      icon: Icons.store_rounded,
                      title: "Loja",
                      menu: AppMenu.store,
                      selectedMenu: selectedMenu,
                      expanded: sidebarExpanded,
                      onTap: () => onMenuSelected(AppMenu.store),
                    ),

                  ],
                ),

                SidebarSection(
                  title: "Outras opções",
                  expanded: sidebarExpanded,
                  children: [

                    SidebarItem(
                      icon: Icons.settings_rounded,
                      title: "Configurações",
                      menu: AppMenu.settings,
                      selectedMenu: selectedMenu,
                      expanded: sidebarExpanded,
                      onTap: () => onMenuSelected(AppMenu.settings),
                    ),
                    SidebarItem(
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      menu: AppMenu.logout,
                      selectedMenu: selectedMenu,
                      expanded: sidebarExpanded,
                      onTap: () => onMenuSelected(AppMenu.logout),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}