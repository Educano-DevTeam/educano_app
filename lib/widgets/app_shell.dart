import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import 'top_bar.dart';
import 'sidebar_menu.dart';
import 'bottom_nav_bar.dart';

/// Casca comum das 3 telas do app.
///
/// >= 900px de largura -> layout Web: sidebar fixa + topbar no topo.
/// < 900px de largura  -> layout Mobile: topbar com Drawer + bottom nav.
///
/// Assim as 6 telas do protótipo (3 telas x Web/Mobile) são cobertas por
/// um único conjunto de widgets responsivos, como pedido.
class AppShell extends StatelessWidget {
  final String currentRoute;
  final Widget child;

  const AppShell({super.key, required this.currentRoute, required this.child});

  void _navigate(BuildContext context, String route) {
    if (route == currentRoute) return;
    const implemented = ['/ranking', '/perfil', '/configuracoes'];
    if (implemented.contains(route)) {
      Navigator.of(context).pushReplacementNamed(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tela "$route" não faz parte deste protótipo.'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = Responsive.isMobile(context);

    if (!mobile) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Column(
          children: [
            TopBar(onMenuTap: () {}),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 232,
                    child: SidebarMenu(
                      currentRoute: currentRoute,
                      onSelect: (route) => _navigate(context, route),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.cardBorder),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
      appBar: TopBar(onMenuTap: () => scaffoldKey.currentState?.openDrawer()),
      drawer: Drawer(
        child: SafeArea(
          child: SidebarMenu(
            currentRoute: currentRoute,
            onSelect: (route) {
              Navigator.of(context).pop();
              _navigate(context, route);
            },
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentRoute: currentRoute,
        onSelect: (route) => _navigate(context, route),
      ),
    );
  }
}
