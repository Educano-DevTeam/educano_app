import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class _NavItem {
  final String route;
  final IconData icon;
  final String label;
  const _NavItem(this.route, this.icon, this.label);
}

/// Reproduz a bottom nav do protótipo mobile: Home, Flashcards, Ranking, Loja.
class AppBottomNavBar extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onSelect;

  const AppBottomNavBar({super.key, required this.currentRoute, required this.onSelect});

  static const List<_NavItem> _items = [
    _NavItem('/home', Icons.home_outlined, 'Home'),
    _NavItem('/flashcards', Icons.style_outlined, 'Flashcards'),
    _NavItem('/ranking', Icons.emoji_events_outlined, 'Ranking'),
    _NavItem('/loja', Icons.storefront_outlined, 'Loja'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2)),
          ],
        ),
        child: Row(
          children: _items.map((item) {
            final bool selected = item.route == currentRoute;
            final Color color = selected ? AppColors.primary : AppColors.textSecondary;
            return Expanded(
              child: InkWell(
                onTap: () => onSelect(item.route),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 22, color: color),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: color,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
