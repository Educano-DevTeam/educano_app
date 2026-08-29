import 'package:flutter/material.dart';

import '../../theme/educano_colors.dart';
import '../../../core/navigation/app_menu.dart';

class AppBottomNavigation extends StatelessWidget {
  final AppMenu selectedMenu;
  final ValueChanged<AppMenu> onItemSelected;

  const AppBottomNavigation({
    super.key,
    required this.selectedMenu,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [
            Expanded(
              child: _buildItem(
                icon: Icons.home_rounded,
                label: "Home",
                menu: AppMenu.home,
              ),
            ),

            Expanded(
              child: _buildItem(
                icon: Icons.style_rounded,
                label: "Flashcards",
                menu: AppMenu.flashcards,
              ),
            ),

            Expanded(
              child: _buildItem(
                icon: Icons.emoji_events_rounded,
                label: "Ranking",
                menu: AppMenu.ranking,
              ),
            ),

            Expanded(
              child: _buildItem(
                icon: Icons.person_rounded,
                label: "Perfil",
                menu: AppMenu.profile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required AppMenu menu,
  }) {
    final bool selected = selectedMenu == menu;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onItemSelected(menu),

      child: SizedBox(
        height: 60,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: selected
              ? EducanoColors.lightBlue.withOpacity(.18)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),

          width: double.infinity,
          
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                  ? EducanoColors.primaryBlue
                  : Colors.grey,
              ),

              const SizedBox(height: 4),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
                  color: selected
                    ? EducanoColors.primaryBlue
                    : Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}