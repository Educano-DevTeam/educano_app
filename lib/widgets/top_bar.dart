import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';

/// Barra superior roxa/azul reproduzida do protótipo.
/// No mobile o botão de menu abre o Drawer; no web serve apenas de atalho visual.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;

  const TopBar({super.key, required this.onMenuTap});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);

    return Material(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              const SizedBox(width: 4),
              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
              ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Educano',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: Colors.white),
              ),
              const SizedBox(width: 2),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primary, size: 18),
              ),
              if (!mobile) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Daniel Lima',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Administrador', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ] else
                const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}
