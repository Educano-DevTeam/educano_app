import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../navigation/app_menu.dart';

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final AppMenu menu;
  final AppMenu selectedMenu;
  final bool expanded;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.menu,
    required this.selectedMenu,
    required this.expanded,
    required this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  /// Controla o efeito de hover (Web/Desktop).
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Verifica se este item está selecionado.
    final bool selected = widget.menu == widget.selectedMenu;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          isHovering = true;
        });
      },

      onExit: (_) {
        setState(() {
          isHovering = false;
        });
      },

      child: GestureDetector(
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,

          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),

          decoration: BoxDecoration(
            color: selected
              ? EducanoColors.primaryBlue.withValues(alpha: 0.12)
              : isHovering
                ? EducanoColors.secondaryBlue.withValues(alpha: 0.10)
                : Colors.transparent,

            borderRadius: BorderRadius.circular(12),
          ),

          child: Row(
            mainAxisAlignment: widget.expanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,

            children: [
              Icon(
                widget.icon,
                size: 22,
                color: selected
                  ? EducanoColors.primaryBlue
                  : isHovering
                    ? EducanoColors.primaryBlue
                    : EducanoColors.textSecondary,
              ),

              if (widget.expanded) ...[
                const SizedBox(width: 16),

                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: widget.expanded ? 1 : 0,

                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w500,

                        color: selected
                          ? EducanoColors.primaryBlue
                          : EducanoColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}